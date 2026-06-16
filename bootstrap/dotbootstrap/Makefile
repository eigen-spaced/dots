# dotbootstrap — interactive dotfiles setup TUI.
#
#   make build   # local dev build (./dotbootstrap)
#   make dist    # committed prebuilt binary -> ../bin/dotbootstrap-darwin-arm64
#   make test    # unit tests
BINARY := dotbootstrap
DIST   := ../bin/$(BINARY)-darwin-arm64

.PHONY: build dist test clean
build:
	go build -o $(BINARY) .

dist:
	mkdir -p ../bin
	CGO_ENABLED=0 GOOS=darwin GOARCH=arm64 go build -trimpath -ldflags "-s -w" -o $(DIST) .

test:
	go test ./...

clean:
	rm -f $(BINARY)
