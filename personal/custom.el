;;-*- mode: emacs-lisp -*- -*-

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;                 General Settings

;; Some more packages
(prelude-require-packages
 '(uuid yasnippet gist ido-ubiquitous icomplete ledger-mode
        php-mode browse-at-remote editorconfig nodejs-repl js2-mode))

;; With more recent editions of prelude this is needed to _really_ get helm
(require 'prelude-helm-everywhere)

;; Tell projectile to use git grep
(setq projectile-use-git-grep t)
(setq projectile-tags-command "/usr/local/bin/ctags -Re -f \"%s\" %s")

;; Don't cleanup whitespace on every save.
(setq prelude-clean-whitespace-on-save nil)

;;Jump to file+line on Github. Yeah!
(global-set-key (kbd "C-c g g") 'browse-at-remote)

;*scratch*
(setq initial-scratch-message ";; *scratch*")
(setq initial-major-mode 'lisp-interaction-mode)

;; bury *scratch* buffer instead of kill it
(defadvice kill-buffer (around kill-buffer-around-advice activate)
  (let ((buffer-to-kill (ad-get-arg 0)))
    (if (equal buffer-to-kill "*scratch*")
        (bury-buffer)
      ad-do-it)))

;;; Always do syntax highlighting
(global-font-lock-mode 1)

;;;; Customize colors and fonts
(set-face-attribute 'default nil :height 120
                    :family "DejaVu Sans Mono")
(set-face-attribute 'show-paren-match
                    nil :height 1.0)

(setq mac-command-modifier 'meta)
(setq mac-option-modifier 'super)

;;; Also highlight parens
(setq show-paren-delay 0
      show-paren-style 'parenthesis)
(show-paren-mode 1)

;; Fish doesn't always play nice with emacs expectations, use sh
;; instead
(setq shell-file-name "/bin/sh")

;; Make it easy to open url
(global-set-key (kbd "C-c b") 'browse-url)

;; Change where backup files are stored
(defvar user-temporary-file-directory
  (concat temporary-file-directory user-login-name "/"))
(make-directory user-temporary-file-directory t)
(setq backup-by-copying t)
(setq backup-directory-alist
      `(("." . ,user-temporary-file-directory)
        (,tramp-file-name-regexp nil)))
(setq auto-save-list-file-prefix
      (concat user-temporary-file-directory ".auto-saves-"))
(setq auto-save-file-name-transforms
      `((".*" ,user-temporary-file-directory t)))

;; Various adjustments to defaults
(setq-default truncate-lines t)
(setq x-select-enable-primary t)
(setq x-select-enable-clipboard t)
(setq tab-width 4) ;;4 is closer to most people's settings then the default of 8
(setq-default tab-width 4)
(setq-default indent-tabs-mode nil) ;;Tabs Vrs Spaces
(tool-bar-mode 0)
(menu-bar-mode -1)
(fset 'yes-or-no-p 'y-or-n-p)
(scroll-bar-mode -1)
(column-number-mode t)
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)
(setq default-input-method "TeX")

(global-set-key (kbd "<f7>") 'flymake-mode) ;;f7 now toggles flymake mode, especially good for django

;;Use trash in dired mode
(setq delete-by-moving-to-trash t)

;; Cleanup older, unneeded buffers
(require 'midnight)
(midnight-delay-set 'midnight-delay "4:30am")

;; Text mode help
(add-hook 'text-mode-hook
          (lambda()
            (set-fill-column 80)
            (auto-fill-mode t)
            (flyspell-mode t)))

(defun archive-todo ()
  "Archive ToDo item"
  (interactive)
  (move-beginning-of-line nil)
  (kill-line 1)
  (end-of-buffer)
  (yank)
  (pop-global-mark))

(defun markdown-helpers ()
  (define-key markdown-mode-map (kbd "C-c C-c") 'org-toggle-checkbox)
  (define-key markdown-mode-map (kbd "C-c C-d") 'archive-todo)
  (setq markdown-command "pandoc")
  (turn-on-orgtbl))

;; Enable org table editing in a few places
(add-hook 'markdown-mode-hook 'markdown-helpers)
(add-hook 'text-mode-hook 'turn-on-orgtbl)
(add-hook 'mail-mode-hook 'turn-on-orgtbl)

;; Remember cursor position between file open / close
(setq save-place-file "~/.emacs.d/saveplace") ;; keep my ~/ clean
(setq-default save-place t)                   ;; activate it for all buffers
(require 'saveplace)

;;Sets replace-regexp to not try and do fancy things with case see:
;;http://sunsite.univie.ac.at/textbooks/emacs/emacs_16.html
(setq case-replace nil)

;;; Change the default browser from firefox to chrome
;; (setq browse-url-generic-program (executable-find "google-chrome")
;;       browse-url-browser-function 'browse-url-generic)

;;<f4> inserts date
(defun insert-date (prefix)
  "Insert the current date."
  (interactive "P")
  (let ((format "%A, %d. %B %Y"))
    (insert (format-time-string format))))
(global-set-key (kbd "<f4>") 'insert-date)

;; Improve pane navigation
;; use Shift+arrow_keys to move cursor around split panes
(windmove-default-keybindings)

;; when cursor is on edge, move to the other side, as in a toroidal
;; space
(setq windmove-wrap-around t)

;; Auto complete / company mode.
(setq company-idle-delay 0.7) ;;Delay so that typing is smoother

;; Setup Dot Editor Config
(require 'editorconfig)
(editorconfig-mode 1)

;; Because some people use tabs
(defun toggle-whitespace-mode ()
  "Toggle Whitespace Mode"
  (interactive)
  (if prelude-whitespace
      (setq prelude-whitespace nil)
    (setq prelude-whitespace t)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                   Legder

(add-to-list 'auto-mode-alist '("\\.lgr$" . ledger-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                   MS SQL

;; Use Sybase mode, and have sqsh installed first, then can connect to
;; MS SQL
(set 'sql-sybase-program "sqsh")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                   JS

;; https://theholyjava.wordpress.com/2015/03/11/a-usable-node-repl-for-emacs/
(load-file "~/.emacs.d/personal/nodejs-repl-eval.el")
(require 'nodejs-repl-eval)

(add-hook 'js2-mode-hook '(lambda ()
                            (local-set-key "\C-x\C-e" 'nodejs-repl-eval-dwim)
                            (local-set-key "\C-c\C-b" 'nodejs-repl-send-buffer)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                   Python

;;Use ipython for `run-python'
;; (setq
;;  python-shell-interpreter "ipython"
;;  python-shell-interpreter-args ""
;;  python-shell-prompt-regexp "In \\[[0-9]+\\]: "
;;  python-shell-prompt-output-regexp "Out\\[[0-9]+\\]: "
;;  python-shell-completion-setup-code
;;  "from IPython.core.completerlib import module_completion"
;;  python-shell-completion-module-string-code
;;  "';'.join(module_completion('''%s'''))\n"
;;  python-shell-completion-string-code
;;  "';'.join(get_ipython().Completer.all_completions('''%s'''))\n")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                   ERC settings

(setq erc-port 6697)
(setq erc-server "irc.freenode.net")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                   YasSnippets

;; Develop and keep personal snippets under ~/me/data/snippets
(require 'yasnippet)

(setq yas/root-directory "~/me/data/snippets/")
;; Load the snippets
(yas/load-directory yas/root-directory)

(yas/global-mode 1)
(setf yas/indent-line nil) ;;stop weird indenting

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               custom-set-variables
