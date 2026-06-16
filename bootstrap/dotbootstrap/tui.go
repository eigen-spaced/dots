package main

import (
	"fmt"
	"strings"

	"github.com/charmbracelet/bubbles/progress"
	"github.com/charmbracelet/bubbles/spinner"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

type state int

const (
	stateChecking state = iota
	stateSelect
	stateRun
	stateDone
)

type result struct {
	title string
	err   error
}

type model struct {
	items     []item
	selected  []bool
	installed []bool
	cursor    int
	offset    int // first visible visual-row in the select list
	dry       bool

	st state

	runList []int // indices into items, in registry order
	runPos  int
	ch      <-chan taskEvent
	log     []string
	results []result
	spin    spinner.Model
	prog    progress.Model

	width, height int
}

func newModel(items []item, dry bool) model {
	sel := make([]bool, len(items))
	for i := range items {
		sel[i] = items[i].def
	}
	sp := spinner.New()
	sp.Spinner = spinner.Dot
	sp.Style = spinAccent
	pr := progress.New(progress.WithDefaultGradient())
	pr.Width = 50
	return model{
		items: items, selected: sel, installed: make([]bool, len(items)),
		dry: dry, st: stateChecking, spin: sp, prog: pr, width: 80, height: 24,
	}
}

// Init kicks off the spinner and the concurrent installed-state probe.
func (m model) Init() tea.Cmd {
	return tea.Batch(m.spin.Tick, detectCmd(m.items))
}

var (
	titleStyle  = lipgloss.NewStyle().Bold(true).Foreground(lipgloss.Color("212"))
	groupStyle  = lipgloss.NewStyle().Bold(true).Foreground(lipgloss.Color("99"))
	descStyle   = lipgloss.NewStyle().Foreground(lipgloss.Color("244"))
	okStyle     = lipgloss.NewStyle().Foreground(lipgloss.Color("42"))
	failStyle   = lipgloss.NewStyle().Foreground(lipgloss.Color("203"))
	helpStyle   = lipgloss.NewStyle().Foreground(lipgloss.Color("241"))
	logStyle    = lipgloss.NewStyle().Foreground(lipgloss.Color("244"))
	spinAccent  = lipgloss.NewStyle().Foreground(lipgloss.Color("212"))
	selRowStyle = lipgloss.NewStyle().Background(lipgloss.Color("238")).Foreground(lipgloss.Color("231")).Bold(true)
	instStyle   = lipgloss.NewStyle().Foreground(lipgloss.Color("245")).Italic(true)
)

// vrow is one visual line in the select list: a group header or an item.
type vrow struct {
	header string // non-empty => header row
	item   int    // item index when header == ""
}

func (m model) rows() []vrow {
	var rs []vrow
	last := ""
	for i, it := range m.items {
		if it.group != last {
			rs = append(rs, vrow{header: it.group})
			last = it.group
		}
		rs = append(rs, vrow{item: i})
	}
	return rs
}

func cursorRow(rs []vrow, cursor int) int {
	for ri, r := range rs {
		if r.header == "" && r.item == cursor {
			return ri
		}
	}
	return 0
}

// bodyHeight is how many list rows fit (leaving room for title + footer).
func (m model) bodyHeight() int {
	h := m.height - 3
	if h < 1 {
		h = 1
	}
	return h
}

// clampScroll adjusts offset so the cursor row stays visible.
func (m model) clampScroll() model {
	rs := m.rows()
	h := m.bodyHeight()
	cr := cursorRow(rs, m.cursor)
	if cr < m.offset {
		m.offset = cr
	}
	if cr >= m.offset+h {
		m.offset = cr - h + 1
	}
	if maxOff := len(rs) - h; m.offset > maxOff {
		m.offset = maxOff
	}
	if m.offset < 0 {
		m.offset = 0
	}
	return m
}

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		m.width, m.height = msg.Width, msg.Height
		if w := msg.Width - 4; w > 10 {
			m.prog.Width = min(w, 60)
		}
		return m.clampScroll(), nil

	case tea.KeyMsg:
		if msg.String() == "ctrl+c" {
			return m, tea.Quit
		}
		switch m.st {
		case stateSelect:
			switch msg.String() {
			case "q", "ctrl+c", "esc":
				return m, tea.Quit
			case "up", "k":
				if m.cursor > 0 {
					m.cursor--
				}
				return m.clampScroll(), nil
			case "down", "j":
				if m.cursor < len(m.items)-1 {
					m.cursor++
				}
				return m.clampScroll(), nil
			case "g", "home":
				m.cursor = 0
				return m.clampScroll(), nil
			case "G", "end":
				m.cursor = len(m.items) - 1
				return m.clampScroll(), nil
			case " ", "x":
				m.selected[m.cursor] = !m.selected[m.cursor]
			case "a":
				all := true
				for _, s := range m.selected {
					if !s {
						all = false
						break
					}
				}
				for i := range m.selected {
					m.selected[i] = !all
				}
			case "enter":
				m.runList = m.runList[:0]
				for i, s := range m.selected {
					if s {
						m.runList = append(m.runList, i)
					}
				}
				if len(m.runList) == 0 {
					return m, tea.Quit
				}
				m.st = stateRun
				m.runPos = 0
				m.ch = startTask(m.items[m.runList[0]].cmd, m.dry)
				return m, tea.Batch(m.spin.Tick, readTask(m.ch))
			}
		case stateDone:
			switch msg.String() {
			case "q", "ctrl+c", "enter", "esc":
				return m, tea.Quit
			}
		}

	case checkResultMsg:
		m.installed = msg.installed
		for i := range m.selected {
			m.selected[i] = m.items[i].def && !m.installed[i]
		}
		m.st = stateSelect
		return m.clampScroll(), nil

	case spinner.TickMsg:
		if m.st != stateChecking && m.st != stateRun {
			return m, nil
		}
		var cmd tea.Cmd
		m.spin, cmd = m.spin.Update(msg)
		return m, cmd

	case taskEvent:
		if m.st != stateRun {
			return m, nil
		}
		if msg.done {
			m.results = append(m.results, result{title: m.items[m.runList[m.runPos]].title, err: msg.err})
			m.runPos++
			m.log = m.log[:0]
			if m.runPos >= len(m.runList) {
				m.st = stateDone
				return m, nil
			}
			m.ch = startTask(m.items[m.runList[m.runPos]].cmd, m.dry)
			return m, readTask(m.ch)
		}
		m.log = append(m.log, msg.line)
		if len(m.log) > 10 {
			m.log = m.log[len(m.log)-10:]
		}
		return m, readTask(m.ch)
	}
	return m, nil
}

func (m model) View() string {
	switch m.st {
	case stateChecking:
		return fmt.Sprintf("%s detecting installed tools…", m.spin.View())
	case stateRun:
		return m.runView()
	case stateDone:
		return m.doneView()
	default:
		return m.selectView()
	}
}

func (m model) selectView() string {
	rs := m.rows()
	h := m.bodyHeight()
	start := m.offset
	end := min(start+h, len(rs))

	var b strings.Builder
	head := "dotfiles bootstrap"
	if m.dry {
		head += "  (dry-run)"
	}
	b.WriteString(titleStyle.Render(head))
	if start > 0 {
		b.WriteString("  " + helpStyle.Render("▲ more"))
	}
	b.WriteString("\n")

	for ri := start; ri < end; ri++ {
		r := rs[ri]
		if r.header != "" {
			b.WriteString(groupStyle.Render(r.header) + "\n")
			continue
		}
		i := r.item
		it := m.items[i]
		desc := it.desc
		if m.installed[i] {
			desc = "installed · " + desc
		}
		if i == m.cursor {
			check := " "
			if m.selected[i] {
				check = "x"
			}
			row := fmt.Sprintf("❯ [%s] %s  %s", check, it.title, desc)
			b.WriteString(selRowStyle.Width(m.width).Render(fit(row, m.width)) + "\n")
			continue
		}
		box := "[ ]"
		if m.selected[i] {
			box = okStyle.Render("[x]")
		}
		prefix := "  [ ] " + it.title + "  "
		descOut := fit(desc, m.width-len(prefix))
		if m.installed[i] {
			descOut = instStyle.Render(descOut)
		} else {
			descOut = descStyle.Render(descOut)
		}
		b.WriteString(fmt.Sprintf("  %s %s  %s\n", box, it.title, descOut))
	}

	footer := "↑/↓ move · space toggle · a all · g/G top/bottom · enter install · q quit"
	if end < len(rs) {
		footer = "▼ more   " + footer
	}
	b.WriteString(helpStyle.Render(footer))
	return b.String()
}

func (m model) runView() string {
	total := len(m.runList)
	done := m.runPos
	ok, fail := tally(m.results)

	var b strings.Builder
	b.WriteString(titleStyle.Render(fmt.Sprintf("Installing  %d/%d", min(done+1, total), total)) + "\n")
	b.WriteString(m.prog.ViewAs(float64(done)/float64(total)) + "\n\n")
	b.WriteString(fmt.Sprintf("%s   %s\n\n",
		okStyle.Render(fmt.Sprintf("✓ %d", ok)), failStyle.Render(fmt.Sprintf("✗ %d", fail))))

	if done < total {
		b.WriteString(fmt.Sprintf("%s %s\n", m.spin.View(), m.items[m.runList[done]].title))
	}
	if len(m.log) > 0 {
		b.WriteString("\n")
		for _, l := range m.log {
			b.WriteString(logStyle.Render("  "+fit(l, m.width-2)) + "\n")
		}
	}
	return b.String()
}

func (m model) doneView() string {
	ok, fail := tally(m.results)
	var b strings.Builder
	b.WriteString(titleStyle.Render("Done") + "\n")
	b.WriteString(m.prog.ViewAs(1) + "\n\n")
	b.WriteString(fmt.Sprintf("%s, %s\n",
		okStyle.Render(fmt.Sprintf("%d ok", ok)), failStyle.Render(fmt.Sprintf("%d failed", fail))))
	if fail > 0 {
		b.WriteString("\n" + failStyle.Render("Failed:") + "\n")
		for _, r := range m.results {
			if r.err != nil {
				b.WriteString(" " + failStyle.Render("✗") + " " + r.title + "  " +
					descStyle.Render(fit(r.err.Error(), m.width-6)) + "\n")
			}
		}
	}
	b.WriteString("\n" + helpStyle.Render("enter/q to exit"))
	return b.String()
}

func tally(rs []result) (ok, fail int) {
	for _, r := range rs {
		if r.err != nil {
			fail++
		} else {
			ok++
		}
	}
	return
}

func fit(s string, n int) string {
	if n <= 0 {
		return ""
	}
	if len(s) <= n {
		return s
	}
	if n == 1 {
		return "…"
	}
	return s[:n-1] + "…"
}
