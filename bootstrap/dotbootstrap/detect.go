package main

import (
	"os/exec"
	"sync"

	tea "github.com/charmbracelet/bubbletea"
)

// detectInstalled runs every item's `check` concurrently and returns, per item,
// whether it's already installed. Items with no check are reported false
// ("always offer"). Each check runs through the same shell preamble so
// toolchain binaries resolve.
func detectInstalled(items []item) []bool {
	res := make([]bool, len(items))
	var wg sync.WaitGroup
	sem := make(chan struct{}, 8) // bound concurrent process spawns
	for i, it := range items {
		if it.check == "" {
			continue
		}
		wg.Add(1)
		go func(i int, chk string) {
			defer wg.Done()
			sem <- struct{}{}
			defer func() { <-sem }()
			res[i] = exec.Command("bash", "-c", shellPreamble+"\n"+chk).Run() == nil
		}(i, it.check)
	}
	wg.Wait()
	return res
}

type checkResultMsg struct{ installed []bool }

// detectCmd probes installed state off the UI thread.
func detectCmd(items []item) tea.Cmd {
	return func() tea.Msg { return checkResultMsg{installed: detectInstalled(items)} }
}
