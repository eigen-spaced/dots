package main

import (
	"bufio"
	"io"
	"os/exec"
	"time"

	tea "github.com/charmbracelet/bubbletea"
)

// shellPreamble makes toolchain binaries resolvable regardless of the shell the
// binary was launched from (Homebrew, pnpm globals, cargo, mise shims, uv tools)
// and activates mise so `mise use`/runtime shims work mid-run.
const shellPreamble = `export PNPM_HOME="$HOME/Library/pnpm"
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PNPM_HOME/bin:$HOME/.cargo/bin:$HOME/.local/bin:$PATH"
command -v mise >/dev/null 2>&1 && eval "$(mise activate bash 2>/dev/null)" >/dev/null 2>&1
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"`

// taskEvent is streamed from a running task: output lines, then a final done.
type taskEvent struct {
	line string
	done bool
	err  error
}

// startTask runs cmd (or, in dry-run, just echoes it) and returns a channel of
// events. Output lines arrive in order, terminated by a single done event.
func startTask(cmd string, dry bool) <-chan taskEvent {
	ch := make(chan taskEvent, 256)
	go func() {
		defer close(ch)
		if dry {
			ch <- taskEvent{line: "$ " + cmd}
			time.Sleep(180 * time.Millisecond) // let the progress bar/spinner be observable
			ch <- taskEvent{done: true}
			return
		}
		c := exec.Command("bash", "-c", shellPreamble+"\n"+cmd)
		pr, pw := io.Pipe()
		c.Stdout, c.Stderr = pw, pw
		errc := make(chan error, 1)
		go func() {
			errc <- c.Run()
			_ = pw.Close()
		}()
		sc := bufio.NewScanner(pr)
		sc.Buffer(make([]byte, 0, 64*1024), 1<<20)
		for sc.Scan() {
			ch <- taskEvent{line: sc.Text()}
		}
		ch <- taskEvent{done: true, err: <-errc}
	}()
	return ch
}

// readTask is a tea.Cmd that pulls the next event off the channel.
func readTask(ch <-chan taskEvent) tea.Cmd {
	return func() tea.Msg {
		ev, ok := <-ch
		if !ok {
			return taskEvent{done: true}
		}
		return ev
	}
}
