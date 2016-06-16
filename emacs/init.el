(setq inhibit-startup-message t)
(setq ring-bell-function (lambda ())) ;; disable bell

(tool-bar-mode -1)
(menu-bar-mode -1)

;; CUA mode
(cua-mode t)
(setq cua-auto-tabify-rectangles nil) ;; Don't tabify after rectangle commands
(transient-mark-mode 1)               ;; No region when it is not highlighted
(setq cua-keep-region-after-copy t)   ;; Standard Windows behaviour

(setq-default indent-tabs-mode nil)

;(set-default-font "Terminus-14")

(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                         ("marmalade" . "http://marmalade-repo.org/packages/")
                         ("melpa" . "http://melpa.milkbox.net/packages/")))

(setq package-enable-at-startup nil)
(package-initialize)

(require 'package)

(defun ensure-packages (&rest packages)
  (dolist (pkg packages)
    (unless (package-installed-p pkg)
      (package-install pkg))))

(ensure-packages
 'undo-tree
 'auto-complete
 'paredit
 'highlight-symbol
 'rainbow-delimiters
 'color-theme
 'color-theme-sanityinc-tomorrow
 'slime)


(defun goto-match-paren (arg)
  "Go to the matching parenthesis if on parenthesis, otherwise insert %.
vi style of % jumping to matching brace."
  (interactive "p")
  (cond ((looking-at "\\s\(") (forward-list 1) (backward-char 1))
        ((looking-at "\\s\)") (forward-char 1) (backward-list ))))

;;(global-set-key (kbd "C-/") 'auto-complete)
(global-set-key (kbd "C-s") 'isearch-forward-regexp)
(global-set-key (kbd "C-r") 'isearch-backward-regexp)
(global-set-key (kbd "M-r") 'query-replace-regexp)

(global-set-key (kbd "C-%") 'goto-match-paren)
(global-set-key (kbd "RET") 'newline-and-indent)
(global-set-key (kbd "C-j") 'newline)

(global-set-key (kbd "C-`") 'other-window)

(global-set-key (kbd "<f10>") 'menu-bar-mode)
(global-set-key (kbd "<f9>") 'shell)

(global-set-key (kbd "M-)") 'delete-pair)

(require 'highlight-symbol)

(setq highlight-symbol-idle-delay 0)
(global-set-key [(control f3)] 'highlight-symbol-at-point)
(global-set-key [f3] 'highlight-symbol-next)
(global-set-key [(shift f3)] 'highlight-symbol-prev)
(global-set-key [(meta f3)] 'highlight-symbol-query-replace)
(global-set-key [(control shift f3)] 'highlight-symbol-remove-all)

(add-hook 'prog-mode-hook 'highlight-symbol-mode)

(eval-after-load 'paredit
  '(progn
     (define-key paredit-mode-map (kbd "C-<left>")
       'left-word)
     (define-key paredit-mode-map (kbd "C-<right>")
       'right-word)
     (define-key paredit-mode-map (kbd "C-M-<right>")
       'paredit-forward-slurp-sexp)
     (define-key paredit-mode-map (kbd "C-M-<left>")
       'paredit-forward-barf-sexp)
     (define-key paredit-mode-map (kbd "C-M-<up>")
       'paredit-raise-sexp)
     (define-key paredit-mode-map (kbd "M-s")
       'replace-string)
     (define-key paredit-mode-map (kbd "M-)")
       'delete-pair)))
(show-paren-mode 1)
(setq show-paren-delay 0)
(setq show-paren-style 'expression)

(require 'auto-complete)
(setq ac-use-quick-help t)
(global-auto-complete-mode)

(require 'undo-tree)
(setq undo-tree-auto-save-history t)
(setq undo-tree-visualizer-timestamps t)
(global-undo-tree-mode)

(require 'edit-server)
(edit-server-start)

(global-set-key (kbd "C-y") 'undo-tree-redo)
(global-set-key (kbd "C-z") 'undo-tree-undo)

(defun hook-name (mode)
  (intern (concat (symbol-name mode) "-mode-hook")))

(require 'paredit)
(dolist (mode '(emacs-lisp lisp clojure scheme))
  (add-hook (hook-name mode) 'paredit-mode))

;;(global-set-key (kbd "<backspace>") 'delete-region-or-default-action)
;;;; delete selected region by backspace
;;(delete-selection-mode t)
;; TODO need hook for paredit, because it uses it's own binding on backspace

;; (define-minor-mode ez-kill-region-with-backspace-mode
;;   "Smart completion"
;;   :keymap (let ((map (make-sparse-keymap)))
;;             (define-key map (kbd "<backspace>") 'ez-kill-region-with-backspace)
;;             map))

;; (defun ez-kill-region-with-backspace ()
;;   (interactive)
;;   (if (use-region-p)
;;       (delete-region (region-beginning) (region-end))
;;     (let ((ez-kill-region-with-backspace-mode nil))
;;       (call-interactively (key-binding (kbd "<backspace>"))))))

;; (ez-kill-region-with-backspace-mode t)

(require 'rainbow-delimiters)
(global-rainbow-delimiters-mode)

(require 'color-theme)
(setq color-theme-is-global t)
(color-theme-initialize)
(setq custom-safe-themes t)
(load-theme 'sanityinc-tomorrow-eighties)

(require 'saveplace)
(setq-default save-place t)
(setq save-place-file "~/.emacs.d/saved-places")

;; Took this from:
;; https://github.com/technomancy/emacs-starter-kit/blob/v2/starter-kit-defuns.el
(defun esk-pretty-lambdas ()
  (font-lock-add-keywords
   nil `(("(?\\(lambda\\>\\)"
          (0 (progn (compose-region (match-beginning 1) (match-end 1)
                                    ,(make-char 'greek-iso8859-7 107))
                    nil))))))

(defun esk-add-watchwords ()
  (font-lock-add-keywords
   nil '(("\\<\\(FIX\\(ME\\)?\\|TODO\\|HACK\\|NOCOMMIT\\)"
          1 font-lock-warning-face t))))

(add-hook 'prog-mode-hook 'esk-pretty-lambdas)
(add-hook 'prog-mode-hook 'esk-add-watchwords)

(require 'slime)
(require 'slime-autoloads)
(slime-setup '(slime-fancy))
(defun load-mt-lisp ()
  "sets inferior to ac64 and starts slime"
  (interactive)
  (let ((mt-home (getenv "MOUSETRAP_HOME")))
    (setq inferior-lisp-program (expand-file-name (concat mt-home "/bin/mousetrap64"))))
  (slime))

(defun load-re-lisp ()
  "sets inferior to re64 and starts slime"
  (interactive)
  (let ((mt-home (getenv "REWEB_HOME")))
    (setq inferior-lisp-program (expand-file-name (concat mt-home "/bin/re"))))
  (slime))

(defun lisp-add-keywords (face-name keyword-rules)
  (let* ((keyword-list (mapcar #'(lambda (x)
				   (symbol-name (cdr x)))
			       keyword-rules))
	 (keyword-regexp (concat "(\\("
				 (regexp-opt keyword-list)
				 "\\)[ \n]")))
    (font-lock-add-keywords 'lisp-mode
			    `((,keyword-regexp 1 ',face-name))))
  (mapc #'(lambda (x)
	    (put (cdr x)
		 ;;'scheme-indent-function
		 'common-lisp-indent-function
		 (car x)))
	keyword-rules))

(lisp-add-keywords
 'font-lock-keyword-face
 '((1 . mv-let*)
   (1 . letvar)
   (1 . letvar*)
   (nil . deftrf)
   (2 . !~)
   (2 . !.)
   (2 . foreach)
   (2 . forsome)
   (2 . forthis)
   (2 . /.)
   (2 . foreach-child)
   
   (0 . aif)
   (1 . awhen)
   ))

(push "~/.emacs.d/twiki-mode" load-path)
(require 'twiki)

(add-hook 'haskell-mode-hook 'haskell-indent-mode)
(add-hook 'haskell-mode-hook 'interactive-haskell-mode)

(setenv "PATH" (concat "~/.cabal/bin:" (getenv "PATH")))
(add-to-list 'exec-path "~/.cabal/bin")
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(haskell-tags-on-save t))

(load-file "~/.emacs.d/grammarer.el")

(defun json-format ()
  (interactive)
  (save-excursion
    (shell-command-on-region (mark) (point) "python -m json.tool" (buffer-name) t)))

;;(set-default-font "Monospace-10:antialias=False")
(set-default-font "Terminus-12:antialias=False")

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(cursor ((t (:background "indian red"))))
 '(trailing-whitespace ((t (:background "magenta" :foreground "#ffcc66")))))
