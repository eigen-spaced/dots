;;; format-rcp.el --- apheleia, aggressive-indent, formatter config templates -*- lexical-binding: t; -*-
;; Format-on-save (apheleia), live indentation (aggressive-indent), and
;; `my/formatter-init' to drop a language's formatter config into a project.
;;; Code:
(eval-when-compile (require 'use-package))

(use-package apheleia
  :init (apheleia-global-mode +1)
  :config
  (setf (alist-get 'python-mode apheleia-mode-alist)    '(ruff-isort ruff)
        (alist-get 'python-ts-mode apheleia-mode-alist) '(ruff-isort ruff)))

;; Live re-indent, Lisp-only: elsewhere electric-indent + apheleia own it, and
;; aggressive-indent (blind to .clang-format/prettier) would fight them.
(use-package aggressive-indent
  :hook ((emacs-lisp-mode lisp-interaction-mode lisp-mode scheme-mode)
         . aggressive-indent-mode))

;; Match clang-format's IndentWidth for live c/c++ typing; save reformats anyway.
(setq c-ts-mode-indent-offset 4)

;; Use C99/C++ `//' line comments instead of the `/* */' block default, so M-/
;; (my/meow-comment) toggles per-line cleanly.  With a block comment-end, uncomment
;; strips the leading `/*' but leaves the trailing ` */' behind.  Empty comment-end
;; fixes that; comment-start-skip still matches `//', so existing `//' lines
;; uncomment fine.
(defun my/c-line-comments ()
  "Prefer `//' line comments in C-family buffers."
  (setq-local comment-start "// "
              comment-end ""))
(dolist (h '(c-ts-mode-hook c++-ts-mode-hook c-mode-hook c++-mode-hook))
  (add-hook h #'my/c-line-comments))

;; Formatter templates, inline so `my/formatter-init' can drop the right one per
;; filetype.  clang-format mirrors ~/Documents/projects/psydaw/.clang-format.
(defvar my/clang-format-template "\
AccessModifierOffset: -4
AlignAfterOpenBracket: Align
AlignConsecutiveAssignments: true
AlignConsecutiveBitFields: None
AlignConsecutiveDeclarations: None
AlignConsecutiveMacros: AcrossEmptyLinesAndComments
AlignEscapedNewlines: Right
AlignTrailingComments: true
AllowAllArgumentsOnNextLine: true
AllowAllParametersOfDeclarationOnNextLine: true
AllowShortBlocksOnASingleLine: Always
AllowShortCaseLabelsOnASingleLine: false
AllowShortEnumsOnASingleLine: true
AllowShortFunctionsOnASingleLine: Inline
AllowShortIfStatementsOnASingleLine: true
AllowShortLambdasOnASingleLine: All
AllowShortLoopsOnASingleLine: false
AlwaysBreakAfterReturnType: None
AlwaysBreakBeforeMultilineStrings: false
AlwaysBreakTemplateDeclarations: No
BinPackArguments: true
BinPackParameters: true
BitFieldColonSpacing: Both
BreakBeforeBraces: Custom
BraceWrapping:
  AfterCaseLabel: false
  AfterClass: false
  AfterFunction: true
  AfterControlStatement: false
  SplitEmptyFunction: false
  AfterEnum: false
  AfterNamespace: false
  AfterStruct: false
  AfterUnion: false
  AfterExternBlock: false
  BeforeCatch: true
  BeforeElse: true
  BeforeLambdaBody: false
  BeforeWhile: true
  SplitEmptyRecord: false
  SplitEmptyNamespace: false
BreakBeforeBinaryOperators: All
BreakBeforeConceptDeclarations: false
BreakBeforeTernaryOperators: true
BreakConstructorInitializers: BeforeColon
BreakInheritanceList: BeforeColon
BreakStringLiterals: true
ColumnLimit: 80
CompactNamespaces: false
Cpp11BracedListStyle: true
DerivePointerAlignment: false
EmptyLineBeforeAccessModifier: Never
FixNamespaceComments: true
IncludeBlocks: Merge
IndentCaseLabels: false
IndentExternBlock: Indent
IndentRequires: false
IndentWidth: 4
IndentWrappedFunctionNames: false
KeepEmptyLinesAtTheStartOfBlocks: false
NamespaceIndentation: All
PointerAlignment: Left
SortUsingDeclarations: true
SpaceAfterCStyleCast: false
SpaceAfterLogicalNot: false
SpaceAfterTemplateKeyword: false
SpaceAroundPointerQualifiers: Default
SpaceBeforeAssignmentOperators: true
SpaceBeforeCaseColon: false
SpaceBeforeCpp11BracedList: false
SpaceBeforeCtorInitializerColon: false
SpaceBeforeInheritanceColon: true
SpaceBeforeParens: Never
SpaceBeforeRangeBasedForLoopColon: false
SpaceBeforeSquareBrackets: false
SpaceInEmptyBlock: false
SpaceInEmptyParentheses: false
SpacesInCStyleCastParentheses: false
SpacesInConditionalStatement: false
SpacesInContainerLiterals: false
SpacesInParentheses: false
SpacesInSquareBrackets: false
UseTab: Never
"
  "Clang-format config written by `my/formatter-init' (see `my/formatter-configs').")

(defvar my/ruff-template "\
# Exclude a variety of commonly ignored directories.
exclude = [
    \".bzr\",
    \".direnv\",
    \".eggs\",
    \".git\",
    \".git-rewrite\",
    \".hg\",
    \".ipynb_checkpoints\",
    \".mypy_cache\",
    \".nox\",
    \".pants.d\",
    \".pyenv\",
    \".pytest_cache\",
    \".pytype\",
    \".ruff_cache\",
    \".svn\",
    \".tox\",
    \".venv\",
    \".vscode\",
    \"__pypackages__\",
    \"_build\",
    \"buck-out\",
    \"build\",
    \"dist\",
    \"node_modules\",
    \"site-packages\",
    \"venv\",
]

# Same as Black.
line-length = 88
indent-width = 4

# Assume Python 3.9
target-version = \"py39\"

[lint]
# Enable Pyflakes (`F`) and a subset of the pycodestyle (`E`) codes by default.
# Unlike Flake8, Ruff doesn't enable pycodestyle warnings (`W`) or
# McCabe complexity (`C901`) by default.
select = [\"E4\", \"E7\", \"E9\", \"F\"]
ignore = []

# Allow fix for all enabled rules (when `--fix`) is provided.
fixable = [\"ALL\"]
unfixable = []

# Allow unused variables when underscore-prefixed.
dummy-variable-rgx = \"^(_+|(_+[a-zA-Z0-9_]*[a-zA-Z0-9]+?))$\"

[format]
# Like Black, use double quotes for strings.
quote-style = \"double\"

# Like Black, indent with spaces, rather than tabs.
indent-style = \"space\"

# Like Black, respect magic trailing commas.
skip-magic-trailing-comma = false

# Like Black, automatically detect the appropriate line ending.
line-ending = \"auto\"

# Enable auto-formatting of code examples in docstrings. Markdown,
# reStructuredText code/literal blocks and doctests are all supported.
#
# This is currently disabled by default, but it is planned for this
# to be opt-out in the future.
docstring-code-format = false

# Set the line length limit used when formatting code snippets in
# docstrings.
#
# This only has an effect when the `docstring-code-format` setting is
# enabled.
docstring-code-line-length = \"dynamic\"
"
  "Ruff config written by `my/formatter-init' (see `my/formatter-configs').")

;; lang -> config; add lua/go later with a new `my/NAME-template' and entry.
(defvar my/formatter-configs
  '((cpp    :modes (c-mode c++-mode c-ts-mode c++-ts-mode)
            :file ".clang-format" :template my/clang-format-template)
    (python :modes (python-mode python-ts-mode)
            :file "ruff.toml"     :template my/ruff-template))
  "Formatter templates as (LANG :modes MODES :file NAME :template SYMBOL) entries.
`my/formatter-init' picks by major mode and writes NAME with SYMBOL's value.")

(defun my/formatter--lang-for-mode ()
  "Return the `my/formatter-configs' key matching the current major mode, or nil."
  (seq-some (lambda (entry)
              (and (apply #'derived-mode-p (plist-get (cdr entry) :modes))
                   (car entry)))
            my/formatter-configs))

(defun my/formatter-init (lang dir)
  "Write LANG's formatter config into DIR.
Interactively LANG defaults to the current major mode (else prompts) and DIR to
the project root.  Asks before overwriting."
  (interactive
   (let* ((lang (or (my/formatter--lang-for-mode)
                    (intern (completing-read
                             "Formatter config: "
                             (mapcar #'car my/formatter-configs) nil t))))
          (file (plist-get (alist-get lang my/formatter-configs) :file))
          (dir  (read-directory-name
                 (format "Write %s to: " file)
                 (if-let* ((proj (project-current))) (project-root proj) default-directory))))
     (list lang dir)))
  (let* ((entry (alist-get lang my/formatter-configs))
         (dest  (expand-file-name (plist-get entry :file) dir)))
    (if (and (file-exists-p dest)
             (not (yes-or-no-p (format "%s exists -- overwrite? " dest))))
        (message "formatter init cancelled")
      (with-temp-file dest (insert (symbol-value (plist-get entry :template))))
      (message "Wrote %s" dest))))

(provide 'format-rcp)
;;; format-rcp.el ends here
