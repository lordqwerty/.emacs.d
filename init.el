;;; package --- summary
;;; Commentary:

(require 'package)

;;; Code:
(setq package-enable-at-startup nil)
(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
                    (not (gnutls-available-p))))
       (proto (if no-ssl "http" "https")))
  ;; Comment/uncomment these two lines to enable/disable MELPA and MELPA Stable as desired
  (add-to-list 'package-archives (cons "melpa" (concat proto "://melpa.org/packages/")) t)
  ;;(add-to-list 'package-archives (cons "melpa-stable" (concat proto "://stable.melpa.org/packages/")) t)
  (when (< emacs-major-version 24)
    ;; For important compatibility libraries like cl-lib
    (add-to-list 'package-archives '("gnu" . (concat proto "://elpa.gnu.org/packages/")))))
(package-initialize)

;; Bootstrap `use-package'
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; Utilities

(defun init-kill-buffer-current ()
  "Kill the current buffer."
  (interactive)
  (kill-buffer (current-buffer)))

;;; Global Configuration

;; Store customizations in a separate file.
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file)

;; Store auto-saves and backups in emacs.d/var.
(let* ((vdir (expand-file-name "var" user-emacs-directory))
       (adir (expand-file-name "autosaves/" vdir))
       (ldir (expand-file-name "auto-save-list/" vdir))
       (bdir (expand-file-name "backups/" vdir)))
  (make-directory adir t)
  (make-directory bdir t)
  (setq auto-save-file-name-transforms `((".*" ,(concat adir "\\1") t))
        auto-save-list-file-prefix (concat ldir "/saves-")
        backup-directory-alist `((".*" . ,bdir))))

(when (member "Inconsolata" (font-family-list))
  (set-frame-font "Inconsolata 15"))

;; Simplify prompts.
(fset 'yes-or-no-p 'y-or-n-p)

;; Reduce noise.
(setq confirm-nonexistent-file-or-buffer nil
      inhibit-splash-screen t
      inhibit-startup-echo-area-message t
      inhibit-startup-message t
      initial-scratch-message nil
      kill-buffer-query-functions (remq 'process-kill-buffer-query-function kill-buffer-query-functions)
      ring-bell-function 'ignore)

;; Prevent accidental closure.
(setq confirm-kill-emacs 'y-or-n-p)

;; Display column number in modeline.
(setq column-number-mode t)

;; Collect garbage less frequently.
(setq gc-cons-threshold 104857600)

;; Delete the trailing newline.
(setq kill-whole-line t)

;; Adjust indentation and line wrapping.
(let ((spaces 2)
      (max-line-length 100))
  (setq-default fill-column max-line-length
                indent-tabs-mode nil
                tab-width spaces
                tab-stop-list (number-sequence spaces max-line-length spaces)))


(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("c620ce43a0b430dcc1b06850e0a84df4ae5141d698d71e17de85e7494377fd81" "59171e7f5270c0f8c28721bb96ae56d35f38a0d86da35eab4001aebbd99271a8" "e9460a84d876da407d9e6accf9ceba453e2f86f8b86076f37c08ad155de8223c" default)))
 '(package-selected-packages
   (quote
    (yaml-mode intero smex use-package latex-pretty-symbols markdown-mode haskell-mode atom-one-dark-theme atom-dark-theme))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(load-theme 'atom-one-dark)

(bind-key "C-c C-SPC" #'delete-trailing-whitespace)
(bind-key "C-x C-b" #'ibuffer)
(bind-key "C-x C-k" #'init-kill-buffer-current)
(bind-key "M-/" #'hippie-expand)
(bind-key "M-o" #'other-window)

(global-subword-mode 1)

;;; General Packages

(use-package company
  :demand
  :diminish ""
  :init
  (progn
    (setq company-idle-delay 0.3)
    (global-company-mode)))

(use-package exec-path-from-shell
  :defer t
  :if (memq window-system '(mac ns))
  :init
  (progn
    (setq exec-path-from-shell-check-startup-files nil)
    (exec-path-from-shell-initialize)))

(use-package helm
  :demand
  :diminish ""
  :bind (("C-M-y" . helm-show-kill-ring)
         ("C-h a" . helm-apropos)
         ("C-x C-f" . helm-find-files)
         ("C-x b" . helm-mini)
         ("M-s o" . helm-occur)
         ("M-x" . helm-M-x)
         :map helm-map
         ([tab] . helm-execute-persistent-action))
  :init
  (progn
    (setq helm-M-x-fuzzy-match t
          helm-apropos-fuzzy-match t
          helm-buffers-fuzzy-matching t
          helm-ff-newfile-prompt-p nil
          helm-locate-fuzzy-match t
          helm-recentf-fuzzy-match t)
    (require 'helm-config)
    (helm-mode)))

(use-package which-key
  :demand
  ;;; :pin melpa
  :init (which-key-mode))

(use-package yaml-mode
  :defer t)

(use-package yasnippet
  :demand
  :diminish (yas-minor-mode . "")
  :init
  (progn
    (add-to-list 'hippie-expand-try-functions-list #'yas-hippie-try-expand)
    (yas-global-mode))
  :config
  (progn
    (defun init-yas-uncapitalize (cap)
      (concat (downcase (substring cap 0 1))
              (substring cap 1)))

    (unbind-key "TAB" yas-minor-mode-map)
    (unbind-key "<tab>" yas-minor-mode-map)))

;;; Demo Packages

(use-package demo-it
  :defer t)

(use-package expand-region
  :defer t
  :bind ("C-=" . er/expand-region))

(use-package fancy-narrow
  :defer t)

(use-package org
  :defer t
  :init
  (progn
    (setq org-hide-emphasis-markers t
          org-log-done 'time
          org-src-fontify-natively t
          org-startup-truncated nil))
  :config
  (progn
    (progn
      (org-babel-do-load-languages
       'org-babel-load-languages
       '((emacs-lisp . t)
         (sh . t))))))

(use-package org-bullets
  :defer t
  :init
  (progn
    (add-hook 'org-mode-hook #'org-bullets-mode)))

(use-package org-tree-slide
:defer t)

;; smex
(use-package smex
  :ensure t
  :bind (("M-x" . smex))
  :config (smex-initialize))

;; intero itself
(use-package intero
  :ensure t)
(add-hook 'haskell-mode-hook 'intero-mode)

;;; Development Packages

(use-package compile
  :defer t
  :init
  (progn
    (setq compilation-scroll-output 'first-error)

    (defun init-compilation-colorize ()
      "Colorize compilation."
      (let ((inhibit-read-only t))
        (goto-char compilation-filter-start)
        (move-beginning-of-line nil)
        (ansi-color-apply-on-region (point) (point-max))))

    (add-hook 'compilation-filter-hook #'init-compilation-colorize)))

(use-package etags
  :bind (("M-." . init-goto-tag))
  :init
  (progn
    (setq tags-revert-without-query t))
  :config
  (progn
    (defun init-goto-tag ()
      "Jump to the definition."
      (interactive)
      (find-tag (find-tag-default)))))

(use-package helm-projectile
  :demand
  :init
  (progn
    (setq projectile-completion-system 'helm)
    (helm-projectile-on)))

(use-package flycheck
  :demand
  :diminish ""
  :bind (:map flycheck-mode-map
              ("M-n" . flycheck-next-error)
              ("M-p" . flycheck-previous-error))
  :init
  (progn
    (add-hook 'after-init-hook #'global-flycheck-mode))
  :config
  (progn
    (defun init-flycheck-may-enable-mode (f)
      "Disallow flycheck in special buffers."
      (interactive)
      (and (not (string-prefix-p "*" (buffer-name)))
           (apply (list f))))

    (advice-add 'flycheck-may-enable-mode :around
                #'init-flycheck-may-enable-mode)))

(use-package magit
  :defer t
  :init
  (progn
    (setq magit-push-always-verify nil
          magit-revert-buffers t)
    (add-hook 'git-commit-mode-hook #'flyspell-mode)))

(use-package paren
  :defer t
  :init
  (show-paren-mode))

(use-package projectile
  :demand
  :diminish ""
  :init
  (progn
    (setq projectile-create-missing-test-files t
          projectile-mode-line nil
          projectile-use-git-grep t)
    (projectile-mode)))

;;; Haskell Packages

(use-package haskell-mode
  :defer t
  :bind (:map haskell-mode-map
              ("M-g i" . haskell-navigate-imports)
              ("M-g M-i" . haskell-navigate-imports))
  :init
  (progn
    (setq haskell-compile-cabal-build-alt-command
          "cd %s && stack clean && stack build --ghc-options -ferror-spans"
          haskell-compile-cabal-build-command
          "cd %s && stack build --ghc-options -ferror-spans"
          haskell-compile-command
          "stack ghc -- -Wall -ferror-spans -fforce-recomp -c %s")))

(use-package haskell-snippets
  :defer t)

(use-package hlint-refactor
  :defer t
  :diminish ""
  :init (add-hook 'haskell-mode-hook #'hlint-refactor-mode))

(use-package intero
  :defer t
  :diminish " λ"
  :bind (:map intero-mode-map
              ("M-." . init-intero-goto-definition))
  :init
  (progn
    (defun init-intero ()
      "Enable Intero unless visiting a cached dependency."
      (if (and buffer-file-name
               (string-match ".+/\\.\\(stack\\|stack-work\\)/.+" buffer-file-name))
          (progn
            (eldoc-mode -1)
            (flycheck-mode -1))
        (intero-mode)
        (set (make-local-variable 'projectile-tags-command) "codex update")))

    (add-hook 'haskell-mode-hook #'init-intero))
  :config
  (progn
    (defun init-intero-goto-definition ()
      "Jump to the definition of the thing at point using Intero or etags."
      (interactive)
      (or (intero-goto-definition)
          (find-tag (find-tag-default))))

(flycheck-add-next-checker 'intero '(warning . haskell-hlint))))

;; Markdown
(use-package markdown-mode
  :defer t
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init (setq markdown-command "multimarkdown"))
