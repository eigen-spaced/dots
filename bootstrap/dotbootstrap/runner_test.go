package main

import (
	"strings"
	"testing"
)

// drain collects all output lines and the terminal done event.
func drain(ch <-chan taskEvent) (lines []string, done bool, err error) {
	for ev := range ch {
		if ev.done {
			done, err = true, ev.err
		} else {
			lines = append(lines, ev.line)
		}
	}
	return
}

func TestStartTaskStreamsAndSucceeds(t *testing.T) {
	lines, done, err := drain(startTask("echo hello && echo world", false))
	if !done {
		t.Fatal("missing done event")
	}
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	got := strings.Join(lines, "\n")
	if !strings.Contains(got, "hello") || !strings.Contains(got, "world") {
		t.Fatalf("expected streamed output, got: %q", got)
	}
}

func TestStartTaskReportsFailure(t *testing.T) {
	_, done, err := drain(startTask("exit 3", false))
	if !done {
		t.Fatal("missing done event")
	}
	if err == nil {
		t.Fatal("expected non-nil error for failing command")
	}
}

func TestStartTaskDryRunDoesNotExecute(t *testing.T) {
	// A real run of this would create the file; dry-run must only echo it.
	lines, done, err := drain(startTask("touch /tmp/dotbootstrap_should_not_exist", true))
	if !done || err != nil {
		t.Fatalf("dry-run should succeed without executing: done=%v err=%v", done, err)
	}
	if len(lines) != 1 || !strings.HasPrefix(lines[0], "$ ") {
		t.Fatalf("dry-run should echo the command once, got: %v", lines)
	}
}
