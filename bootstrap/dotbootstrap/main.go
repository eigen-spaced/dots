// Command dotbootstrap is the interactive setup TUI for this dotfiles repo.
// It presents a selectable list of components (Homebrew, toolchains, dev tools,
// Emacs, stow packages, launchd agents) and runs the chosen ones with live
// progress. It shells out to brew/mise/pnpm/etc.; it does not replace them.
package main

import (
	"flag"
	"fmt"
	"os"
	"path/filepath"

	tea "github.com/charmbracelet/bubbletea"
)

func main() {
	dry := flag.Bool("dry-run", false, "show commands instead of running them")
	repoFlag := flag.String("repo", "", "path to the dotfiles repo (default: auto-detect)")
	flag.Parse()

	repo := *repoFlag
	if repo == "" {
		r, err := detectRepo()
		if err != nil {
			fmt.Fprintln(os.Stderr, "dotbootstrap:", err)
			os.Exit(1)
		}
		repo = r
	}

	items := registry(repo)

	// Headless fallback (no TTY, e.g. piped/CI): probe installed state and print
	// what's already present vs. what the default selection would install. The
	// interactive picker needs a terminal.
	if !isTTY() {
		installed := detectInstalled(items)
		fmt.Println("Already installed (skipped):")
		for i, it := range items {
			if installed[i] {
				fmt.Printf("  ✓ %s\n", it.title)
			}
		}
		fmt.Println("\nWould install (default selection):")
		for i, it := range items {
			if it.def && !installed[i] {
				fmt.Printf("  + %-32s %s\n", it.title, firstLine(it.cmd))
			}
		}
		return
	}

	if _, err := tea.NewProgram(newModel(items, *dry, repo), tea.WithAltScreen()).Run(); err != nil {
		fmt.Fprintln(os.Stderr, "dotbootstrap:", err)
		os.Exit(1)
	}
}

// detectRepo walks up from the executable and cwd to find the dotfiles repo
// (a dir holding both .git and bootstrap/).
func detectRepo() (string, error) {
	var starts []string
	if exe, err := os.Executable(); err == nil {
		starts = append(starts, filepath.Dir(exe))
	}
	if wd, err := os.Getwd(); err == nil {
		starts = append(starts, wd)
	}
	for _, start := range starts {
		for d := start; ; {
			if exists(filepath.Join(d, ".git")) && exists(filepath.Join(d, "bootstrap")) {
				return d, nil
			}
			parent := filepath.Dir(d)
			if parent == d {
				break
			}
			d = parent
		}
	}
	return "", fmt.Errorf("could not locate the dotfiles repo (pass --repo)")
}

func exists(p string) bool {
	_, err := os.Stat(p)
	return err == nil
}

func isTTY() bool {
	fi, err := os.Stdout.Stat()
	return err == nil && (fi.Mode()&os.ModeCharDevice) != 0
}

func firstLine(s string) string {
	for i := 0; i < len(s); i++ {
		if s[i] == '\n' {
			return s[:i] + " …"
		}
	}
	return s
}
