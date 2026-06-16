package main

import (
	"strings"
	"testing"
)

func TestRunViewShowsProgress(t *testing.T) {
	m := newModel(registry("/tmp"), true)
	m.st = stateRun
	m.runList = []int{0, 1, 2, 3}
	m.runPos = 2
	m.results = []result{{title: "a"}, {title: "b"}}
	if !strings.Contains(m.runView(), "/4") {
		t.Fatalf("expected task count (x/4) in run view, got: %q", m.runView())
	}
}

// The select list must never render more lines than the terminal height, and
// the cursor item must be visible from the start (the overflow bug).
func TestSelectViewWindowsToHeight(t *testing.T) {
	m := newModel(registry("/tmp"), false)
	m.height = 12
	m = m.clampScroll()
	out := m.selectView()
	if lines := strings.Count(out, "\n") + 1; lines > m.height {
		t.Fatalf("select view %d lines exceeds height %d", lines, m.height)
	}
	if !strings.Contains(out, "Core CLI tools") {
		t.Fatal("first item (cursor) should be visible at launch")
	}
}

func TestSelectViewScrollsToCursor(t *testing.T) {
	m := newModel(registry("/tmp"), false)
	m.height = 12
	m.cursor = len(m.items) - 1
	m = m.clampScroll()
	out := m.selectView()
	if last := m.items[len(m.items)-1].title; !strings.Contains(out, last) {
		t.Fatalf("last item %q should be visible after scrolling down", last)
	}
	if strings.Contains(out, "Core CLI tools") {
		t.Fatal("top item should have scrolled off-screen")
	}
}
