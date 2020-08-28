;
;;; init.el --- Initialization file for Emacs:
;;; Commentary: Emacs Startup File --- initialization for Emacs

;;;; custom-set-variables
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(column-number-mode t)
 '(js-indent-level 2)
 '(package-selected-packages
   (quote
    (tide dired-toggle lsp-vue lsp-mode vue-mode git-gutter edit-server json-mode typescript-mode prettier-js company-tern company markdown-preview-mode handlebars-mode pug-mode yaml-mode slim-mode markdown-mode eshell-git-prompt add-node-modules-path flycheck helm-ls-hg package-utils helm-ls-git web-mode js2-mode helm-git-grep)))
 '(show-paren-mode t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "Ricty Diminished" :foundry "outline" :slant normal :weight normal :height 120 :width normal)))))

(setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")

;;; packages:
(package-initialize)

;;; git-gutter
(global-git-gutter-mode t)

;;; edit-server start
(when (and (daemonp) (locate-library "edit-server"))
   ;(setq edit-server-host "0.0.0.0")
   (edit-server-start))

;;; MELPHA:
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)

;;; バックアップとオートセーブファイルを~/.emacs.d/backups/へ集める:
(add-to-list 'backup-directory-alist
             (cons "." "~/.emacs.d/backups/"))
(setq auto-save-file-name-transforms
      `((".*" ,(expand-file-name "~/.emacs.d/backups/") t)))


;;; タイトルバーにファイルのフルパスを表示する:
(setq frame-title-format "%f")

;;; 行番号を表示する:
;; (global-linum-mode t)
(global-linum-mode 1)
(add-hook 'eshell-mode-hook (lambda () (linum-mode -1)))
(add-hook 'dired-mode-hook (lambda () (linum-mode -1)))
(add-hook 'shell-mode-hook (lambda () (linum-mode -1)))
(add-hook 'ibuffer-mode-hook (lambda () (linum-mode -1)))

;;; カラム番号も表示する:
(column-number-mode t)

;;; 空白文字を強制表示:
(setq-default show-trailing-whitespace t)
(set-face-background 'trailing-whitespace "#b14770")

;;; 対応する括弧を表示:
(show-paren-mode t)
(setq show-paren-delay 0)

;;; 行間:
(setq-default line-spacing 0)

;;; 全角スペースを強制表示する:
(require 'whitespace)
(global-whitespace-mode 1)
(setq whitespace-style '(face
                         trailing
                         tabs
                         spaces
                         empty
                         space-mark
                         tab-mark
                         ))
(setq whitespace-display-mappings
      '((space-mark ?\u3000 [?\u25a1])
        (tab-mark ?\t [?\u00BB ?\t] [?\\ ?\t])))
(setq whitespace-space-regexp "\\(\u3000+\\)")

;;; タブ文字ではなくスペースを使う:
(setq-default indent-tabs-mode nil)

;;; タブ幅をスペース2つ分にする:
(setq-default tab-width 2)

;;; 1行ずつスクロールさせる:
(setq scroll-conservatively 35
      scroll-margin 0
      scroll-step 1)

;;; フレーム(ウィンドウ)の透明度を設定する:
(set-frame-parameter (selected-frame) 'alpha '(0.80))

;;; カーソルのある行をハイライトする:
;; (global-hl-line-mode t)

;; eshell-git-prompt
(eshell-git-prompt-use-theme 'robbyrussell)

;;; aspell:
(setq-default ispell-program-name "aspell")

;;; flycheck:
(require 'flycheck)
(add-hook 'after-init-hook #'global-flycheck-mode) ; you must write 'flycheck-add-mode' after this line

;;; companyの設定:
(global-company-mode) ; 全バッファで有効にする

;;; depth絡みの不具合への対策:
;; override
(defun company-tern-depth (candidate)
  "Return depth attribute for CANDIDATE.  'nil' entries are treated as 0."
  (let ((depth (get-text-property 0 'depth candidate)))
    (if (eq depth nil) 0 depth)))

;;; js系でcompany-ternを有効にする:
(defun js-company-tern-hook ()
  (when (locate-library "tern")
    ;; .tern-port を作らない
    (setq tern-command '("tern" "--no-port-file"))
    (tern-mode t)))

;;; backend追加:
;; Symbol's value as variable is void: company-backendsと出るので
;; (add-to-list 'company-backends 'company-tern)
(with-eval-after-load 'company
  (add-to-list 'company-backends 'company-tern))

;; company-dabbrev-codeは現在開いているバッファからワードを拾ってくる
;; IdとIDとかの表記ゆれにやられるのであえて切っている
;; (add-to-list 'company-backends '(company-tern :with company-dabbrev-code))

;;; js系のインデント数
(setq my-js-mode-indent-num 2)

;;; jsonの設定
(add-to-list 'auto-mode-alist '("\\.eslintrc\\'" . json-mode))

;;; js-modeの設定
(add-hook 'js-mode-hook
          (lambda ()
            (add-node-modules-path)
            (js-company-tern-hook)))

;;; js2-modeの設定:
(require 'js2-mode)
(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))
(add-to-list 'auto-mode-alist '("\\.es6\\'" . js2-mode))
(add-hook 'js2-mode-hook
          (lambda ()
            (add-node-modules-path)
            (setq js2-basic-offset my-js-mode-indent-num)
            (setq js-switch-indent-offset my-js-mode-indent-num)
            (prettier-js-mode)
            (js-company-tern-hook)
            ))

;;; typescriptの設定:
;;;; tide-modeのセットアップ用関数
(defun setup-tide-mode ()
            (interactive)
            (setq typescript-indent-level my-js-mode-indent-num)
            (add-node-modules-path)
            (tide-setup)
            (flycheck-mode +1)
            ;; (flycheck-add-next-checker 'javascript-eslint '(warning . typescript-tide))
                                        ; script below works good so comment out this line
            (flycheck-add-next-checker 'typescript-tide 'javascript-eslint 'append)
                                        ; typescript-tide is recognized as right checker if defined after tide-setup.
                                        ; if dropped out from typescript-mode-hoook scope,
                                        ; typescript-tide cannnot be recognized as right checker.
            (tide-hl-identifier-mode +1)
            (prettier-js-mode)
            ;; (setq flycheck-check-syntax-automatically '(save mode-enabled))
            (eldoc-mode t)
            (js-company-tern-hook))

(add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-mode))
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . typescript-mode))
(add-hook 'typescript-mode-hook #'setup-tide-mode)
(flycheck-add-mode 'javascript-eslint 'typescript-mode)

;;; handlebarsの設定:
(require 'handlebars-mode)
(add-to-list 'auto-mode-alist '("\\.hbs\\'" . handlebars-mode))

;;; pugの設定:
(require 'pug-mode)
(add-to-list 'auto-mode-alist '("\\.pug\\'" . pug-mode))

;;; cssの設定:
(add-hook 'css-mode-hook
          (lambda ()
            (setq css-indent-offset 2)
            ))

;;; scssの設定:
(add-hook 'scss-mode-hook
          (lambda ()
            (setq css-indent-offset 2)
            ))

;;; rubyの設定:
(autoload 'ruby-mode "ruby-mode"
  "Mode for editing ruby source files" t)
(setq ruby-insert-encoding-magic-comment nil)
(add-to-list 'auto-mode-alist '("\\.rb$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Capfile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Gemfile$" . ruby-mode))

;;; web-mode:
(require 'web-mode)
(add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))

;;; slim-mode:
(require 'slim-mode)
(add-to-list 'auto-mode-alist '("\\.slim\\'" . slim-mode))

;;; markdown:
(require 'markdown-mode)
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))

;;; dired-mode:
(ffap-bindings)
(add-hook 'dired-load-hook (lambda ()
                (define-key dired-mode-map "r" 'wdired-change-to-wdired-mode)))

;;; vue:
(add-to-list 'auto-mode-alist '("\\.vue\\'" . vue-mode))
;; (eval-after-load 'vue-mode
;;     '(add-hook 'vue-mode-hook #'add-node-modules-path))

;; (flycheck-add-mode 'javascript-eslint 'js-mode)
;; (flycheck-add-mode 'javascript-eslint 'typescript-mode)
;; (flycheck-add-mode 'javascript-eslint 'vue-html-mode)
;; (flycheck-add-mode 'javascript-eslint 'css-mode)

;;end
;
