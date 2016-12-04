;; __        __    _  __      _       _       _ _         _
;; \ \      / /__ | |/ _| ___( )___  (_)_ __ (_) |_   ___| |
;;  \ \ /\ / / _ \| | |_ / _ \// __| | | '_ \| | __| / _ \ |
;;   \ V  V / (_) | |  _|  __/ \__ \ | | | | | | |_ |  __/ |
;;    \_/\_/ \___/|_|_|  \___| |___/ |_|_| |_|_|\__(_)___|_|

;; Temporarily set garbage collect threshold high to improve start time
(setq gc-cons-threshold most-positive-fixnum)
(add-hook 'after-init-hook (lambda () (setq gc-cons-threshold 800000)))

;; Setup package control
(require 'package)
(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                         ("marmalade" . "http://marmalade-repo.org/packages/")
                         ("melpa" . "http://melpa.org/packages/")))
(setq package-enable-at-startup nil)
(package-initialize)

;; Have use-package auto download
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)

;;
;; G E N E R A L   S E T T I N G S
;;
(setq inhibit-splash-screen t
      inhibit-startup-message t
      inhibit-startup-echo-area-message "wolfe")
(tool-bar-mode -1) ; No toolbar
(scroll-bar-mode -1) ; Hide scrollbars
(menu-bar-mode -1) ; No menubar
(show-paren-mode t) ; Highlights matching parens
(setq initial-scratch-message "") ; No scratch text
(fset 'yes-or-no-p 'y-or-n-p) ; y/n instead of yes/no
(setq-default indent-tabs-mode nil)
(column-number-mode t)
(delete-selection-mode 1) ; Replace selection on insert
(setq vc-follow-symlinks t) ; Always follow symlinks
(when (member "Inconsolata" (font-family-list)) ; Set default font
  (add-to-list 'default-frame-alist '(font . "Inconsolata-15" ))
  (set-face-attribute 'default t :font "Inconsolata-15"))
(setq custom-file "~/.emacs.d/custom.el") ; Set custom file
(load custom-file 'noerror) ; Load custom file
(setq tags-revert-without-query t) ; Don't ask to reload TAGS file
(setq scroll-margin 10
      scroll-step 1
      scroll-conservatively 10000
      scroll-preserve-screen-position 1)
(custom-set-faces
 '(column-marker-1 ((t (:background "color-88"))))
 '(hl-line ((t (:weight bold)))))
(global-hl-line-mode 1)
(load-file "~/.emacs.d/lisp/column-marker.el")
(add-hook 'prog-mode-hook (lambda () (interactive) (column-marker-1 81)))
(setq custom-theme-directory "~/.emacs.d/themes")
(load-theme 'ujelly t)

;; When in terminal
(unless (display-graphic-p) 
  (setq nlinum-format "%d ")
  (add-to-list 'default-frame-alist '(background-color . "color-16"))
  (custom-set-faces
   '(linum ((t (:background "color-16" :foreground "#ffffff"))))))

;;
;; F U N C T I O N S
;;
(defun what-face (pos)
  (interactive "d")
  (let ((face (or (get-char-property (point) 'read-face-name)
                  (get-char-property (point) 'face))))
    (if face (message "Face: %s" face) (message "No face at %d" pos))))

(defun wolfe/compile-no-prompt ()
  (interactive)
  (let ((compilation-read-command nil))
    (compile (eval compile-command))))

(defun wolfe/ivy--regex-fuzzy (str)
  "Build a regex sequence from STR.
 Insert .* between each char."
  (if (string-match "\\`\\(\\^?\\)\\(.*?\\)\\(\\$?\\)\\'" str)
      (prog1
          (concat (match-string 1 str)
                  (mapconcat
                   (lambda (x)
                     (format "\\(%c\\)" x))
                   (delq 32 (string-to-list (match-string 2 str)))
                   ".*?")
                  (match-string 3 str))
        (setq ivy--subexps (length (match-string 2 str))))
    str))

(defun wolfe/compile-dot-emacs ()
  "Byte-compile dotfiles."
  (interactive)
  (byte-recompile-directory user-emacs-directory 0)) 

(defun wolfe/clear-all-elc ()
  (interactive)
  (shell-command "find ~/.emacs.d/ -name \"*.elc\" -type f -delete"))

(defun wolfe/remove-elc-on-save ()
  "If you're saving an elisp file, likely the .elc is no longer valid."
  (add-hook 'after-save-hook
            (lambda ()
              (if (file-exists-p (concat buffer-file-name "c"))
                  (delete-file (concat buffer-file-name "c"))))
            nil t))
(add-hook 'emacs-lisp-mode-hook 'wolfe/remove-elc-on-save)

(defun wolfe/find-tag ()
  "Jump to the tag at point without prompting"
  (interactive)
  (find-tag (find-tag-default)))

(defadvice find-tag (around refresh-etags activate)
  "Rerun etags and reload tags if tag not found and redo find-tag.              
   If buffer is modified, ask about save before running etags."
  (condition-case err
      ad-do-it
    (error (and (buffer-modified-p) (not (ding))
                (save-buffer))
           (save-window-excursion (shell-command "etags -R *"))
           ad-do-it)))

(defun wolfe/controlz ()
  (interactive)
  (when (eq (display-graphic-p) nil)
    (suspend-frame)))

(defun wolfe/org-open (name)
  "Opens the file in the dropbox path"
  (interactive)
  (when (eq system-type 'gnu/linux)
    (evil-buffer-new nil (concat "~/Dropbox/org/" name ".org")))
  (when (eq system-type 'windows-nt)
    (evil-buffer-new nil (concat "C:\\Users\\Josh\\Dropbox\\org\\"
                                 name ".org"))))

(defun wolfe/org-dropbox-path ()
  "Returns the dropbox path"
  (interactive)
  (cond
   ((eq system-type 'gnu/linux)
    "~/Dropbox/org/")
   ((eq system-type 'windows-nt)
    "C:\\Users\\Josh\\Dropbox\\org\\")
   (else "")))

(defun wolfe/dropbox-start ()
  (interactive)
  (if (eq nil (file-exists-p "/virtual/wolfejos/dropbox/.dropbox-dist"))
      (call-process-shell-command "(python ~/.emacs.d/dropbox.py start -i&)")
    (call-process-shell-command "(python ~/.emacs.d/dropbox.py start&)")))

(defun wolfe/dropbox-stop ()
  (interactive)
  (call-process-shell-command "python ~/.emacs.d/dropbox.py stop&"))

(defun wolfe/load-init ()
  "Reloads init file"
  (interactive)
  (load-file "~/.emacs.d/init.el"))

(defun narrow-or-widen-dwim (p)
  "Widen if buffer is narrowed, narrow-dwim otherwise.
Dwim means: region, org-src-block, org-subtree, or
defun, whichever applies first. Narrowing to
org-src-block actually calls `org-edit-src-code'.

With prefix P, don't widen, just narrow even if buffer
is already narrowed."
  (interactive "P")
  (declare (interactive-only))
  (cond ((and (buffer-narrowed-p) (not p)) (widen))
        ((region-active-p)
         (narrow-to-region (region-beginning)
                           (region-end)))
        ((derived-mode-p 'org-mode)
         ;; `org-edit-src-code' is not a real narrowing
         ;; command. Remove this first conditional if
         ;; you don't want it.
         (cond ((ignore-errors (org-edit-src-code) t)
                (delete-other-windows))
               ((ignore-errors (org-narrow-to-block) t))
               (t (org-narrow-to-subtree))))
        ((derived-mode-p 'latex-mode)
         (LaTeX-narrow-to-environment))
        (t (narrow-to-defun))))

(defun wolfe/man ()
  (if (executable-find "man")
      (man (word-at-point))
    (woman)))

;;
;; E V I L
;;
(use-package general)
(use-package evil
  :demand
  :init
  (setq evil-want-C-u-scroll t) ; Unbind <C-u> for evil mode's use
  (setq evil-want-C-i-jump nil)
  :config
  (evil-mode t)
  (setq evil-split-window-below t)
  (setq evil-vsplit-window-right t)
  (setq-default evil-symbol-word-search t) 
  (setq evil-lookup-func #'wolfe/man)
  (evil-ex-define-cmd "re[load]" 'wolfe/load-init) ; Custom reload command
  (define-key evil-ex-map "e " 'counsel-find-file) ; Trigger file completion :e
  (global-unset-key (kbd "M-SPC")) ; Unbind secondary leader

  (general-create-definer wolfe/bind-leader
                          :keymaps 'global
                          :states '(normal insert visual emacs)
                          :prefix "SPC"
                          :non-normal-prefix "M-SPC")

  :general
  (:states 'motion
           "k" 'evil-previous-visual-line
           "j" 'evil-next-visual-line)
  (:states 'operator
           "k" 'evil-previous-line
           "j" 'evil-next-line)
  

  (:states 'normal
           "C-M-h" help-map
           "C-h"  'evil-window-left
           "C-j"  'evil-window-down
           "C-k"  'evil-window-up
           "C-l"  'evil-window-right
           "C-z"  'wolfe/controlz)

  (wolfe/bind-leader
   "w" 'save-buffer
   "S" 'eval-buffer
   "s" 'eval-defun
   "b" 'mode-line-other-buffer
   "k" 'kill-buffer
   "m" 'ivy-switch-buffer
   "t" 'wolfe/find-tag
   "e" 'iedit-mode
   "c" 'wolfe/compile-no-prompt
   "n" 'narrow-or-widen-dwim
   "p" 'counsel-git
   ";" (lambda() (interactive) (save-excursion (end-of-line) (insert-char ?\;)))
   "id" (lambda() (interactive) (indent-region (point-min) (point-max)))
   "os" (lambda() (interactive) (wolfe/org-open "school"))
   "ol" (lambda() (interactive) (wolfe/org-open "life"))
   "init" (lambda() (interactive) (evil-buffer-new nil "~/.emacs.d/init.el"))))

;; Tpope's surround
(use-package evil-surround
  :config
  (global-evil-surround-mode 1))

(use-package evil-magit)

;;
;; O R G - M O D E
;;
(use-package ox-reveal
  :ensure nil
  :config
  (setq org-reveal-root "file:///home/wolfe/emacs-workshop/reveal.js")
  (use-package htmlize
    :ensure nil))

(setq org-pretty-entities t
      org-src-fontify-natively t
      org-src-tab-acts-natively t
      org-src-window-setup 'current-window
      org-fontify-whole-heading-line t
      org-fontify-done-headline t
      org-fontify-quote-and-verse-blocks t
      org-ellipsis "⤵")

;; Better looking org headers
(use-package org-bullets
  :config
  (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1))))

;;
;; G E N E R A L   P A C K A G E S
;;
(use-package delight
  :config
  (delight '((emacs-lisp-mode "ξ" :major)
             (lisp-interaction-mode "λ" :major)
             (python-mode "π" :major)
             (c-mode "𝐂 " :major)
             (org-mode "Ø" :major)
             (rust-mode "ℜ " :major)
             (company-mode " α" company)
             (racer-mode " ρ" racer)
             (ivy-mode " ι" ivy)
             (eldoc-mode " ε" eldoc)
             (undo-tree-mode "" undo-tree)
             (auto-revert-mode "" autorevert))))

(use-package ivy
  :demand
  :bind (("M-x" . counsel-M-x)
         ("C-x C-f" . counsel-find-file)
         :map ivy-minibuffer-map
         ("TAB" . ivy-next-line)
         ("RET" . ivy-alt-done))
  :init
  (use-package smex)
  (use-package counsel)
  :config
  (setq ivy-re-builders-alist
        '((t . wolfe/ivy--regex-fuzzy)))
  (setq ivy-wrap t)
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers t))

(use-package swiper
  :bind (("C-s" . swiper)))

(use-package nlinum-relative
  :config
  (nlinum-relative-setup-evil)
  (setq nlinum-relative-redisplay-delay 0.25) 
  (setq nlinum-relative-current-symbol "")
  (add-hook 'prog-mode-hook 'nlinum-relative-mode))

(use-package magit
  :config
  (global-set-key "\C-x\g" 'magit-status))

(use-package iedit
  :config
  (setq iedit-toggle-key-default nil)
  (custom-set-faces
   '(iedit-occurrence ((t (:background "color-93"))))))

(use-package flycheck
  :config
  (global-flycheck-mode)
  
  (with-eval-after-load 'flycheck
    (setq-default flycheck-disabled-checkers '(emacs-lisp-checkdoc))))

;;
;; L A N G U A G E  S P E C I F I C
;;

(use-package web-mode
  :config
  (add-to-list 'auto-mode-alist '("\\.html\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.php\\'" . web-mode)))

(use-package latex-preview-pane
  :defer t)

(use-package rust-mode)
(use-package racer
  :config
  (setq racer-rust-src-path "~/Projects/rustsrc")
  (add-hook 'rust-mode-hook #'racer-mode)
  (add-hook 'racer-mode-hook #'eldoc-mode))

;;
;; C O M P A N Y
;;
(use-package company
  :init
  (global-company-mode)
  :config
  (setq company-idle-delay 0) ; Delay to complete
  (setq company-minimum-prefix-length 1)
  (setq company-selection-wrap-around t) ; Loops around suggestions

  (if (display-graphic-p)
      (define-key company-active-map [tab] 'company-select-next)
    (define-key company-active-map (kbd "C-i") 'company-select-next))

  ;; C / C++
  (setq company-clang-insert-arguments nil))

;;Inherits colors from theme to style autocomplete menu correctly
;;(require 'color)
;;(let ((bg (face-attribute 'default :background)))
;;  (custom-set-faces
;;   `(company-tooltip ((t (:inherit default :background ,(color-lighten-name bg 2)))))
;;   `(company-scrollbar-bg ((t (:background ,(color-lighten-name bg 10)))))
;;   `(company-scrollbar-fg ((t (:background ,(color-lighten-name bg 5)))))
;;   `(company-tooltip-selection ((t (:inherit font-lock-function-name-face))))
;;   `(company-tooltip-common ((t (:inherit font-lock-constant-face)))))))



(use-package company-math
  :config
  (defun wolfe/latex-setup ()
    (setq-local company-backends
                (append '((company-math-symbols-latex company-latex-commands))
                        company-backends)))

  (add-hook 'tex-mode-hook 'wolfe/latex-setup))

;;
;; M I S C
;;
(setq gdb-many-windows t ;; use gdb-many-windows by default
      gdb-show-main t
      ;; Non-nil means display source file containing the main routine at startup
      ) 

;;
;; B A C K U P S
;;
(setq backup-by-copying t) ; Stop shinanigans with links
(setq backup-directory-alist '((".*" . "~/.bak.emacs/backup/")))
;; Creates directory if it doesn't already exist
(if (eq nil (file-exists-p "~/.bak.emacs/")) 
    (make-directory "~/.bak.emacs/"))
;; Creates auto directory if it doesn't already exist
(if (eq nil (file-exists-p "~/.bak.emacs/auto"))
    (make-directory "~/.bak.emacs/auto"))
;; backup in one place. flat, no tree structure
(setq auto-save-file-name-transforms '((".*" "~/.bak.emacs/auto/" t)))

;; Local Variables:
;; byte-compile-warnings: (not free-vars)
;; End:
