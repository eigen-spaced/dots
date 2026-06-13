;;; doom-carbonfox-theme.el --- carbonfox, ported from nightfox.nvim -*- lexical-binding: t; no-byte-compile: t; -*-
;;
;; A Doom Emacs port of carbonfox from EdenEast/nightfox.nvim,
;; a dark theme inspired by IBM Carbon.
;;
;;; Code:

(require 'doom-themes)


;;
;;; Variables

(defgroup doom-carbonfox-theme nil
  "Options for the `doom-carbonfox' theme."
  :group 'doom-themes)

(defcustom doom-carbonfox-brighter-comments nil
  "If non-nil, comments will be highlighted more vividly."
  :group 'doom-carbonfox-theme
  :type 'boolean)

(defcustom doom-carbonfox-padded-modeline doom-themes-padded-modeline
  "If non-nil, adds a 4px padding to the mode-line.
Can be an integer to determine the exact padding."
  :group 'doom-carbonfox-theme
  :type '(choice integer boolean))


;;
;;; Theme definition

(def-doom-theme doom-carbonfox
  "A dark theme ported from nightfox.nvim's carbonfox."

  ;; name        default   256       16
  ((bg         '("#161616" "#161616" "black"))
   (fg         '("#f2f4f8" "#f2f4f8" "brightwhite"))

   ;; Darker bg, used by solaire for sidebars/popups (carbonfox bg0)
   (bg-alt     '("#0c0c0c" "#0c0c0c" "black"))
   (fg-alt     '("#b6b8bb" "#b6b8bb" "white"))

   ;; carbonfox: bg0..bg4, sel0, comment, fg3, white
   (base0      '("#0c0c0c" "#080808" "black"))
   (base1      '("#161616" "#121212" "brightblack"))
   (base2      '("#252525" "#262626" "brightblack"))
   (base3      '("#2a2a2a" "#2a2a2a" "brightblack"))
   (base4      '("#353535" "#3a3a3a" "brightblack"))
   (base5      '("#535353" "#585858" "brightblack"))
   (base6      '("#6e6f70" "#6c6c6c" "brightblack"))
   (base7      '("#7b7c7e" "#808080" "brightblack"))
   (base8      '("#dfdfe0" "#dadada" "white"))

   (grey       base5)
   (red        '("#ee5396" "#ff5f87" "red"))
   (orange     '("#3ddbd9" "#5fd7d7" "brightcyan"))
   (green      '("#25be6a" "#00af5f" "green"))
   (teal       '("#2dc7c4" "#00d7d7" "brightcyan"))
   (yellow     '("#08bdba" "#00afaf" "yellow"))
   (blue       '("#78a9ff" "#87afff" "brightblue"))
   (dark-blue  '("#6690d9" "#5f87d7" "blue"))
   (magenta    '("#be95ff" "#af87ff" "brightmagenta"))
   (violet     '("#c8a5ff" "#d7afff" "magenta"))
   (cyan       '("#33b1ff" "#5fafff" "brightcyan"))
   (dark-cyan  '("#2b96d9" "#0087d7" "cyan"))

   ;; extra carbonfox colors
   (pink         '("#ff7eb6" "#ff87af" "brightred"))
   (pink-bright  '("#ff91c1" "#ffafd7" "brightred"))
   (blue-bright  '("#8cb6ff" "#87afff" "brightblue"))
   (orange-bright '("#5ae0df" "#5fd7d7" "brightcyan"))
   (sel0         '("#2a2a2a" "#2a2a2a" "brightblack"))
   (sel1         '("#525253" "#585858" "brightblack"))

   ;; face categories -- required for all themes
   (highlight      blue)
   (vertical-bar   base0)
   (selection      sel0)
   (builtin        red)
   (comments       (if doom-carbonfox-brighter-comments base7 base6))
   (doc-comments   (doom-lighten comments 0.2))
   (constants      orange-bright)
   (functions      blue-bright)
   (keywords       magenta)
   (methods        blue-bright)
   (operators      fg-alt)
   (type           yellow)
   (strings        green)
   (variables      base8)
   (numbers        orange)
   (region         sel0)
   (error          red)
   (warning        magenta)
   (success        green)
   (vc-modified    yellow)
   (vc-added       green)
   (vc-deleted     red)

   ;; custom categories
   (modeline-fg          fg-alt)
   (modeline-fg-alt      base7)
   (modeline-bg          base0)
   (modeline-bg-inactive base0)
   (-modeline-pad
    (when doom-carbonfox-padded-modeline
      (if (integerp doom-carbonfox-padded-modeline)
          doom-carbonfox-padded-modeline
        4))))

  ;;;; Base theme face overrides
  (((line-number &override) :foreground base7)
   ((line-number-current-line &override) :foreground fg)
   ((font-lock-comment-face &override) :slant 'italic)
   (font-lock-doc-face :inherit 'font-lock-comment-face :foreground doc-comments)
   (font-lock-preprocessor-face :foreground pink-bright)
   (font-lock-regexp-grouping-backslash :foreground teal)
   (font-lock-regexp-grouping-construct :foreground teal)

   (hl-line :background base2)
   (isearch :foreground fg :background sel1)
   (lazy-highlight :foreground fg :background base4)
   (tooltip :background base0 :foreground fg)
   (cursor :background blue)

   (mode-line
    :background modeline-bg :foreground modeline-fg
    :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg)))
   (mode-line-inactive
    :background modeline-bg-inactive :foreground modeline-fg-alt
    :box (if -modeline-pad `(:line-width ,-modeline-pad :color ,modeline-bg-inactive)))
   (mode-line-emphasis :foreground highlight)

   ;;;; doom-modeline
   (doom-modeline-bar :background highlight)
   (doom-modeline-buffer-path :foreground blue :weight 'bold)
   (doom-modeline-buffer-major-mode :inherit 'doom-modeline-buffer-path)

   ;;;; ivy / vertico
   (vertico-current :background base3)
   (ivy-current-match :background base3 :distant-foreground nil)

   ;;;; org <built-in>
   ((org-block &override) :background base0)
   ((org-block-begin-line &override) :background base0 :foreground comments)
   ((org-quote &override) :background base0)
   (org-hide :foreground bg)

   ;;;; markdown-mode
   (markdown-markup-face :foreground base5)
   (markdown-header-face :inherit 'bold :foreground blue-bright)
   ((markdown-code-face &override) :background base0)

   ;;;; rainbow-delimiters
   (rainbow-delimiters-depth-1-face :foreground blue)
   (rainbow-delimiters-depth-2-face :foreground magenta)
   (rainbow-delimiters-depth-3-face :foreground cyan)
   (rainbow-delimiters-depth-4-face :foreground orange)
   (rainbow-delimiters-depth-5-face :foreground pink)
   (rainbow-delimiters-depth-6-face :foreground green)
   (rainbow-delimiters-depth-7-face :foreground yellow)

   ;;;; whitespace / fringe
   (whitespace-tab :foreground base4)
   (whitespace-space :foreground base4))

  ;;;; Base theme variable overrides
  ())

;;; doom-carbonfox-theme.el ends here
