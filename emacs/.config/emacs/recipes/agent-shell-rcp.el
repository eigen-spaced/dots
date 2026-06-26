;;; agent-shell-rcp.el --- LLM coding agents over ACP -*- lexical-binding: t; -*-
;; Native Emacs shells that drive ACP agents (Claude Code, Gemini, ...), by
;; xenodium.  Pulls in acp + shell-maker from MELPA.
;;
;; Auth defaults to the Claude subscription/login flow -- the `claude-agent-acp'
;; CLI handles OAuth, so no key is stored in this (public) config.  Install that
;; CLI first; its binary must be on PATH (it is the default
;; `agent-shell-anthropic-claude-acp-command'):
;;   pnpm add -g @agentclientprotocol/claude-agent-acp
;;
;; Start with `M-x agent-shell' (dispatches to the configured agent) or
;; `M-x agent-shell-anthropic-start-claude-code'.  `C-u M-x agent-shell' forces
;; a new session.  In the shell: RET submits, S-RET/M-J newline, C-c C-c aborts.
;;; Code:
(eval-when-compile (require 'use-package))

;; Deferred: `agent-shell' is autoloaded by the package; both commands live in
;; (or pull in) agent-shell.el, which `(require 'agent-shell-anthropic)' itself,
;; so the anthropic entry point resolves once either command runs.
(use-package agent-shell
  :commands (agent-shell agent-shell-anthropic-start-claude-code)
  ;; `C-c n' only inside an agent shell -> spawn a fresh session (the
  ;; `C-u M-x agent-shell' equivalent, since C-u is half-page-scroll in meow).
  :bind (:map agent-shell-mode-map
              ("C-c n" . agent-shell-new-shell)))

;; To authenticate with an API key from the macOS Keychain instead of login,
;; drop this into the `:config' above (key lives in Keychain, not the repo):
;;   (setq agent-shell-anthropic-authentication
;;         (agent-shell-anthropic-make-authentication
;;          :api-key (auth-source-pick-first-password :host "api.anthropic.com")))

(provide 'agent-shell-rcp)
;;; agent-shell-rcp.el ends here
