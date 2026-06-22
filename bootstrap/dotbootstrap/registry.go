package main

import "fmt"

// item is one selectable unit of work. cmd is a shell snippet run via `bash -c`
// (with a PATH/toolchain preamble; see runner.go). check is an optional shell
// test (exit 0 == already installed) used to dim + pre-deselect items that are
// already present; an empty check means "always offer" (cheap/idempotent steps).
type item struct {
	group string
	title string
	desc  string
	cmd   string
	check string
	def   bool // selected by default (when not already installed)
}

// have reports a `command -v` check for a binary.
func have(bin string) string { return "command -v " + bin + " >/dev/null 2>&1" }

// registry is the full, editable catalog. To add a tool, add a line. Items run
// in this order, so toolchains land before the tools that need them.
func registry(repo string) []item {
	stow := func(pkg, desc string) item {
		// No reliable per-package "installed" check; re-stow (--restow) is cheap
		// and idempotent, so always offer it, selected by default.
		return item{"Dotfiles (stow)", pkg, desc,
			fmt.Sprintf("cd %q && stow --no-folding --restow %s", repo, pkg), "", true}
	}
	// pnpm global package; bin is the executable it provides (for the install check).
	pnpm := func(title, pkg, desc, bin string) item {
		return item{"Dev tools", title, desc, "pnpm add -g " + pkg, have(bin), true}
	}

	return []item{
		// --- Homebrew base --------------------------------------------------
		{"Homebrew", "Core CLI tools", "git stow mise direnv fzf fd ripgrep jq tmux ffmpeg gum",
			"brew install git stow mise direnv fzf fd ripgrep jq tmux ffmpeg gum",
			have("gum") + " && " + have("fd") + " && " + have("rg"), true},
		{"Homebrew", "libvips", "vipsthumbnail — Doom dirvish thumbnails", "brew install vips", have("vipsthumbnail"), true},
		{"Homebrew", "bat", "syntax-highlighting pager — colored dirvish previews", "brew install bat", have("bat"), true},

		// --- Apps (casks) ---------------------------------------------------
		{"Apps (casks)", "Ghostty", "terminal emulator", "brew install --cask ghostty", "[ -d /Applications/Ghostty.app ]", true},
		{"Apps (casks)", "Hammerspoon", "scriptable macOS hotkeys", "brew install --cask hammerspoon", "[ -d /Applications/Hammerspoon.app ]", true},

		// --- Emacs ----------------------------------------------------------
		{"Emacs", "emacs-plus@30", "native-comp Emacs built from source",
			"brew install d12frosted/emacs-plus/emacs-plus@30", have("emacs"), false},
		{"Emacs", "Emacs daemon agent", "launchd agent: emacs --fg-daemon at login", emacsDaemonCmd,
			`[ -f "$HOME/Library/LaunchAgents/com.sunny.emacs-daemon.plist" ]`, false},
		{"Emacs", "Emacs Dock launcher", "/Applications/Emacs.app applet (emacsclient -c)",
			repo + "/bootstrap/emacs/build-emacs-launcher.sh", "[ -d /Applications/Emacs.app ]", false},
		{"Emacs", "notmuch", "notmuch mail indexer + Emacs client", "brew install notmuch", have("notmuch"), false},
		{"Emacs", "afew", "notmuch auto-tagging (py3.11 + setuptools<81 for pkg_resources)",
			`uv tool install --python 3.11 --with "setuptools<81" afew`, have("afew"), false},
		{"Emacs", "isync (mbsync)", "IMAP sync: Gmail -> ~/.mail maildir", "brew install isync", have("mbsync"), false},
		{"Emacs", "pinentry-mac", "GPG/Keychain pinentry", "brew install pinentry-mac", have("pinentry-mac"), false},
		{"Emacs", "mupdf", "emacs-reader backend (epub/mobi/cbz)", "brew install mupdf", have("mutool"), false},
		{"Emacs", "pdf-tools build deps", "automake/autoconf/pkg-config/poppler — compiles epdfinfo (PDF rendering)",
			"brew install automake autoconf pkg-config poppler", have("automake"), false},

		// --- Toolchains -----------------------------------------------------
		{"Toolchains", "mise runtimes", "node, python, go, uv, pnpm (latest)",
			"mise install node@latest python@latest go@latest uv@latest pnpm@latest",
			have("node") + " && " + have("pnpm") + " && " + have("go"), true},
		{"Toolchains", "pnpm global config", "PNPM_HOME + minimumReleaseAge supply-chain guard",
			"pnpm config set --global minimumReleaseAge 7200", "", true}, // 5 days
		{"Toolchains", "rustup", "stable toolchain + rust-src", rustupCmd, have("rustup"), true},

		// --- Dev tools: Lua -------------------------------------------------
		{"Dev tools", "lua-language-server", "Lua LSP", "brew install lua-language-server", have("lua-language-server"), true},
		{"Dev tools", "stylua", "Lua formatter", "cargo install stylua", have("stylua"), true},
		// --- Dev tools: C/C++ ----------------------------------------------
		{"Dev tools", "llvm (clangd + clang-format)", "C/C++ LSP + formatter", "brew install llvm",
			"[ -x /opt/homebrew/opt/llvm/bin/clang-format ]", true},
		// llvm is keg-only, so its bin/ stays off PATH. Symlink just clang-format
		// (not clangd — Apple's /usr/bin/clangd is fine) so apheleia can find it.
		{"Dev tools", "clang-format on PATH", "symlink keg-only clang-format into /opt/homebrew/bin",
			"ln -sf /opt/homebrew/opt/llvm/bin/clang-format /opt/homebrew/bin/clang-format", have("clang-format"), true},
		// --- Dev tools: Rust ------------------------------------------------
		{"Dev tools", "rust-analyzer", "Rust LSP (rustup component)", "rustup component add rust-analyzer", have("rust-analyzer"), true},
		// --- Dev tools: Go --------------------------------------------------
		{"Dev tools", "gopls", "Go LSP (mise, version-matched)", "mise use -g go:golang.org/x/tools/gopls@latest", have("gopls"), true},
		{"Dev tools", "goimports", "Go imports formatter (mise)", "mise use -g go:golang.org/x/tools/cmd/goimports@latest", have("goimports"), true},
		// --- Dev tools: Python ----------------------------------------------
		{"Dev tools", "ruff", "Python linter/formatter", "uv tool install ruff", have("ruff"), true},
		{"Dev tools", "ty", "Python type checker (Astral)", "uv tool install ty", have("ty"), true},
		{"Dev tools", "pyrefly", "Python type checker (Meta)", "uv tool install pyrefly", have("pyrefly"), true},
		// --- Dev tools: Web / JS / TS ---------------------------------------
		pnpm("vscode-langservers-extracted", "vscode-langservers-extracted", "css/html/json/eslint LSPs", "vscode-css-language-server"),
		pnpm("svelte-language-server", "svelte-language-server", "Svelte LSP", "svelteserver"),
		pnpm("tailwindcss-language-server", "@tailwindcss/language-server", "Tailwind LSP", "tailwindcss-language-server"),
		pnpm("vue-language-server", "@vue/language-server", "Vue LSP (vue_ls)", "vue-language-server"),
		{"Dev tools", "vue-typescript-plugin", "Vue hybrid-mode TS plugin", "pnpm add -g @vue/typescript-plugin", "", true},
		pnpm("astro-language-server", "@astrojs/language-server", "Astro LSP", "astro-ls"),
		pnpm("bash-language-server", "bash-language-server", "Bash LSP", "bash-language-server"),
		pnpm("vim-language-server", "vim-language-server", "Vimscript LSP", "vim-language-server"),
		pnpm("typescript", "typescript", "tsserver for typescript-tools.nvim", "tsserver"),
		pnpm("prettier", "prettier", "JS/TS/web formatter", "prettier"),
		pnpm("prettierd", "@fsouza/prettierd", "prettier daemon (fast)", "prettierd"),
		// --- Dev tools: Writing ---------------------------------------------
		{"Dev tools", "harper-ls", "grammar/spell LSP", "brew install harper", have("harper-ls"), true},
		// --- Dev tools: Clojure (off by default) ----------------------------
		{"Dev tools", "clojure-lsp", "Clojure LSP",
			"brew install clojure-lsp/brew/clojure-lsp-native", have("clojure-lsp"), false},
		// --- Dev tools: editor/misc CLIs ------------------------------------
		pnpm("neovim (node provider)", "neovim", "Neovim node remote-plugin host", "neovim-node-host"),
		{"Dev tools", "tree-sitter-cli", "tree-sitter CLI", "cargo install tree-sitter-cli", have("tree-sitter"), true},
		pnpm("codex", "@openai/codex", "OpenAI Codex CLI", "codex"),

		// --- Dotfiles (stow) ------------------------------------------------
		stow("nvim", "Neovim config"),
		stow("emacs", "Emacs config (~/.config/emacs)"),
		stow("doom", "Doom Emacs config"),
		stow("bat", "bat config + pixel-miri16 theme"),
		stow("zsh", "zsh config"),
		stow("tmux", "tmux config"),
		stow("ghostty", "Ghostty config"),
		stow("hammerspoon", "Hammerspoon config"),
		stow("scripts", "~/.config/scripts helpers"),

		// --- post-stow build steps ------------------------------------------
		// Compile the stowed pixel-miri16 bat theme into bat's machine-local
		// cache (~/.cache/bat); must run after `brew install bat` + `stow bat`.
		{"Dotfiles (stow)", "bat theme cache", "compile pixel-miri16 into ~/.cache/bat",
			"bat cache --build", "bat --list-themes 2>/dev/null | grep -q pixel-miri16", true},
		// Pre-compile tree-sitter grammars for the config's languages so the
		// first visit to each never warns.  Driven through the running daemon
		// (treesit-auto already loaded), so there's no second Emacs racing elpa.
		{"Dotfiles (stow)", "emacs tree-sitter grammars", "compile grammars for the config's languages",
			grammarInstallCmd, `ls "$HOME/.config/emacs/tree-sitter/"libtree-sitter-go.* >/dev/null 2>&1`, true},

		// --- launchd agents -------------------------------------------------
		{"launchd", "update reminder", "daily 11:00 check; notifies if update-all stale 14d+", updateReminderCmd,
			`[ -f "$HOME/Library/LaunchAgents/com.sunny.update-reminder.plist" ]`, false},
	}
}

// rustupCmd installs rustup if missing, then pins stable + rust-src.
const rustupCmd = `if ! command -v rustup >/dev/null 2>&1; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable --no-modify-path
fi
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
rustup default stable
rustup component add rust-src`

// emacsDaemonCmd installs the launchd agent that runs the Emacs daemon at login.
const emacsDaemonCmd = `label="com.sunny.emacs-daemon"
plist="$HOME/Library/LaunchAgents/$label.plist"
mkdir -p "$HOME/Library/LaunchAgents"
cat > "$plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$label</string>
    <key>ProgramArguments</key>
    <array>
        <string>/opt/homebrew/bin/emacs</string>
        <string>--fg-daemon</string>
        <string>--init-directory=$HOME/.config/emacs</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/emacs-daemon.stdout.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/emacs-daemon.stderr.log</string>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/opt/homebrew/bin:/opt/homebrew/sbin:/usr/bin:/bin:/usr/sbin:/sbin</string>
        <key>LSP_USE_PLISTS</key>
        <string>1</string>
    </dict>
</dict>
</plist>
PLIST
launchctl bootout "gui/$(id -u)/$label" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$plist"`

// updateReminderCmd installs the daily update-all reminder launchd agent.
const updateReminderCmd = `label="com.sunny.update-reminder"
plist="$HOME/Library/LaunchAgents/$label.plist"
mkdir -p "$HOME/Library/LaunchAgents"
cat > "$plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$label</string>
    <key>ProgramArguments</key>
    <array>
        <string>$HOME/.config/scripts/update-all</string>
        <string>--remind</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>11</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
</dict>
</plist>
PLIST
launchctl bootout "gui/$(id -u)/$label" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$plist"`

// grammarInstallCmd compiles tree-sitter grammars for the config's languages.
// It waits for the Emacs daemon, then drives treesit-auto from inside it (so
// only one Emacs touches elpa/), installing any grammar not already present.
const grammarInstallCmd = `for i in $(seq 1 60); do emacsclient -e t >/dev/null 2>&1 && break; sleep 2; done
emacsclient --eval '(let ((treesit-language-source-alist (treesit-auto--build-treesit-source-alist)))
  (dolist (lang (quote (go gomod c cpp python rust javascript typescript tsx json yaml toml css html bash markdown dockerfile)))
    (unless (treesit-ready-p lang t) (ignore-errors (treesit-install-language-grammar lang)))))'`
