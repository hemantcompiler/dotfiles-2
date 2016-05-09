;; __        __    _  __      _       _       _ _         _
;; \ \      / /__ | |/ _| ___( )___  (_)_ __ (_) |_   ___| |
;;  \ \ /\ / / _ \| | |_ / _ \// __| | | '_ \| | __| / _ \ |
;;   \ V  V / (_) | |  _|  __/ \__ \ | | | | | | |_ |  __/ |
;;    \_/\_/ \___/|_|_|  \___| |___/ |_|_| |_|_|\__(_)___|_|

;; Setup package control
(require 'package)
(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/"))
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(add-to-list 'package-archives '("melpa-stable" . "http://stable.melpa.org/packages/"))
(setq package-enable-at-startup nil)
(package-initialize)

;; Specifies local directory to load packages from
(add-to-list 'load-path "~/.emacs.d/lisp/")
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")
(let ((default-directory  "~/.emacs.d/packages/"))
  (normal-top-level-add-subdirs-to-load-path))

(require 'use-package)

;; Essential settings.
(setq inhibit-splash-screen t
      inhibit-startup-message t
      inhibit-startup-echo-area-message t)
(tool-bar-mode -1) ; No toolbar
(scroll-bar-mode -1) ; Hide scrollbars
(menu-bar-mode -1) ; Hide menu bar
(show-paren-mode t) ; Highlights matching parenthesis
(electric-pair-mode t)
(setq initial-scratch-message "") ; No scratch text
(setq-default show-trailing-whitespace t) ; Shows all trailing whitespace
(use-package sublime-themes
  :ensure t
  :config
  (load-theme 'spolsky t)) ; Color theme

;; Base evil package
(use-package evil
  :ensure t
  :init
  ;; Unbind <C-u> for evil mode's use
  (setq evil-want-C-u-scroll t)
  :config
  (evil-mode t)
  ;; Move up and down through wrapped lines
  (define-key evil-normal-state-map (kbd "j") 'evil-next-visual-line)
  (define-key evil-normal-state-map (kbd "k") 'evil-previous-visual-line)
  (setq evil-split-window-below t)
  (setq evil-vsplit-window-right t))

;; evil leader key
(use-package evil-leader
  :ensure t
  :config
  (evil-leader/set-leader "<SPC>")
  (setq evil-leader/in-all-states 1)
  (global-evil-leader-mode)
  (evil-leader/set-key
    "w"  'save-buffer ; w(rite)
    "so" 'eval-buffer ; so(urce)
    "S" 'eval-defun ; S(ource)
    "bb" 'mode-line-other-buffer ; b(ack) b(buffer)
    "bn" 'next-buffer ; b(uffer) n(ext)
    "bp" 'previous-buffer ; b(uffer) p(revious)
    "bd" 'kill-buffer ; b(uffer) d(elete)
    "bl" 'helm-buffers-list ; b(uffer) l(ist)
    "init" (lambda() (interactive) (evil-buffer-new nil "~/.emacs.d/init.el"))))

;; Tpope's surround
(use-package evil-surround
  :ensure t
  :config
  (global-evil-surround-mode 1))

;; Narrowing completion engine
(use-package helm
  :ensure t
  :config
  (helm-autoresize-mode 1)
  (global-set-key (kbd "M-x")     'undefined)
  (global-set-key (kbd "M-x")     'helm-M-x)
  (global-set-key (kbd "C-x r b") 'helm-filtered-bookmarks)
  (global-set-key (kbd "C-x C-f") 'helm-find-files)
  (global-set-key (kbd "C-x C-b") 'undefined)
  (global-set-key (kbd "C-x C-b") 'helm-buffers-list)
  (helm-mode t))

(use-package linum-relative
  :ensure t
  :config
  (setq linum-relative-current-symbol "")
  (global-linum-mode t)
  (linum-relative-mode))

;; External configuration for powerline and evil powerline (~/.emacs.d/lisp/init-powerline.el)

(require 'init-powerline)

(use-package web-mode
  :ensure t)

;; Autocompletion backend
(use-package company
  :ensure t
  :init
  (global-company-mode)
  :config
  (setq company-idle-delay 0) ; Delay to complete
  (setq company-selection-wrap-around t) ; Loops around suggestions
  (define-key company-active-map [tab] 'company-select-next) ; Tab to cycle forward
  (define-key company-active-map (kbd "C-n") 'company-select-next) ; Ctrl-N to cycle forward (vim-ish)
  (define-key company-active-map (kbd "C-p") 'company-select-previous) ; Ctrl-P to cycle back (vim-ish)

  ;; Inherits colors from theme to style autocomplete menu correctly
  (require 'color)
  (let ((bg (face-attribute 'default :background)))
  (custom-set-faces
      `(company-tooltip ((t (:inherit default :background ,(color-lighten-name bg 2)))))
      `(company-scrollbar-bg ((t (:background ,(color-lighten-name bg 10)))))
      `(company-scrollbar-fg ((t (:background ,(color-lighten-name bg 5)))))
      `(company-tooltip-selection ((t (:inherit font-lock-function-name-face))))
      `(company-tooltip-common ((t (:inherit font-lock-constant-face)))))))

;; Uses jedi server and company mode frameword for Python completion
(use-package company-jedi
  :ensure t
  :config
  (defun my/python-mode-hook ()
  (add-to-list 'company-backends 'company-jedi))
  (add-hook 'python-mode-hook 'my/python-mode-hook))

(use-package markdown-mode
  :ensure t
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init (setq markdown-command "multimarkdown")
  :config
  (setq markdown-live-preview-delete-export 'delete-on-export))

(use-package expand-region
  :ensure t
  :config
  (global-set-key (kbd "C-=") 'er/expand-region))

(use-package neotree
  :ensure t
  :config
  (global-set-key [f8] 'neotree-toggle)
  (add-hook 'neotree-mode-hook
    (lambda ()
      (define-key evil-normal-state-local-map (kbd "TAB") 'neotree-enter)
      (define-key evil-normal-state-local-map (kbd "SPC") 'neotree-enter)
      (define-key evil-normal-state-local-map (kbd "q") 'neotree-hide)
      (define-key evil-normal-state-local-map (kbd "RET") 'neotree-enter))))

(use-package org-bullets
  :ensure t
  :config
  (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1))))

(use-package evil-org
  :ensure t)

(use-package company-web
  :ensure t
  :config
  (add-to-list 'company-backends 'company-web-html))

;; Backup options
;; backup in one place. flat, no tree structure
(setq backup-directory-alist '((".*" . "~/.bak.emacs/backup/")))
(setq auto-save-file-name-transforms '((".*" "~/.bak.emacs/auto/" t)))
(setq backup-by-copying t) ; Stop shinanigans with links

;; esc quits
(defun minibuffer-keyboard-quit ()
"Abort recursive edit.
In Delete Selection mode, if the mark is active, just deactivate it;
then it takes a second \\[keyboard-quit] to abort the minibuffer."
  (interactive)
  (if (and delete-selection-mode transient-mark-mode mark-active)
      (setq deactivate-mark  t)
    (when (get-buffer "*Completions*") (delete-windows-on "*Completions*"))
    (abort-recursive-edit)))
(define-key evil-normal-state-map [escape] 'keyboard-quit)
(define-key evil-visual-state-map [escape] 'keyboard-quit)
(define-key minibuffer-local-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-ns-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-completion-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-must-match-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-isearch-map [escape] 'minibuffer-keyboard-quit)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("913b84f0b08939412114f7c5b5a1c581e3ac841615a67d81dda28d2b7c4b7892" "3c83b3676d796422704082049fc38b6966bcad960f896669dfc21a7a37a748fa" "0c29db826418061b40564e3351194a3d4a125d182c6ee5178c237a7364f0ff12" default)))
 '(vc-follow-symlinks t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(company-scrollbar-bg ((t (:background "#2b333c"))))
 '(company-scrollbar-fg ((t (:background "#20262d"))))
 '(company-tooltip ((t (:inherit default :background "#1a1f24"))))
 '(company-tooltip-common ((t (:inherit font-lock-constant-face))))
 '(company-tooltip-selection ((t (:inherit font-lock-function-name-face)))))