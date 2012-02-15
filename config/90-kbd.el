;;; key setting
(define-prefix-command 'ctl-cc-map)
(define-prefix-command 'ctl-ce-map)
(define-prefix-command 'ctl-z-map)
(define-prefix-command 'f9-map)

;; global key binding
(deh-section "global-kbd"
  (deh-define-key global-map
    ("\C-d"        . 'delete-char-or-region)
    ((kbd "C-2")   . 'set-mark-command)
    ("\C-m"        . 'newline-and-indent)
    ("\C-j"        . 'newline)
    ("\M-\\"       . 'comment-dwim)  ; 终端下 C-; 无效
    ("\M-f"        . 'ywb-camelcase-forward-word)  
    ("\M-b"        . 'ywb-camelcase-backward-word)
    ((kbd "C-`")   . 'ywb-toggle-case-dwim)
    ((kbd "M-;")   . 'hippie-expand)
    ((kbd "C-SPC") . 'toggle-input-method)
    ((kbd "C-z")   . 'ctl-z-map)
    ((kbd "<f9>")  . 'f9-map)
    ((kbd "M-g g") . 'ywb-goto-line)
    ((kbd "<f5>")  . 'browse-el-find-funtion)
    ((kbd "<f6>")  . 'browse-el-go-back)
    ((kbd "<f11>") . 'w3m)
    ((kbd "<f8>")  . 'org-agenda)
    ((kbd "<f7>")  . 'calendar)
    ((kbd "C-'")   . 'comment-dwim) 
    ((kbd "S-SPC") . 'set-mark-command)
    ((kbd "M-#")   . 'ywb-shell-command-background)
    ((kbd "M-2")   . 'ywb-mark-sexp)
    ((kbd "M-3")   . 'ywb-sdcv-word)
    ((kbd "M-'")   . 'just-one-space)
    ((kbd "M-RET") . 'muse-insert-list-item)
    ((kbd "C-h j") . 'info-elisp)
    ((kbd "<C-down-mouse-1>") . 'undefined)
    ((kbd "C-M-r") . 'org-remember)
    )

  (deh-define-key (lookup-key global-map "\C-c")
    ("$" . 'toggle-truncate-lines)
    (";" . 'yow)
    ("=" . 'eim-table-add-word)
    ("[" . 'ywb-insert-char-prev-line)
    ("]" . 'ywb-insert-char-next-line)
    ("a" . 'org-agenda)
    ("b" . 'ywb-create/switch-scratch)
    ("c" . 'ctl-cc-map)
    ("d" . 'dirtree-show)
    ("e" . 'ctl-ce-map)
    ("f" . 'comint-dynamic-complete)
    ("g" . 'fold-dwim-hide-all)
    ("h" . 'help-dwim)
    ("i" . 'imenu)
    ("j" . 'ffap)
    ("k" . 'auto-fill-mode)
    ("l" . 'his-transpose-windows)
    ("n" . 'bm-next)
    ("m" . 'switch-major-mode)
    ("o" . 'browse-url-at-point)
    ("p" . 'bm-previous)
    ("r" . 'compile-dwim-run)
    ("s" . 'compile-dwim-compile)
    ("t" . 'tags-tree)
    ("u" . 'revert-buffer)
    ("v" . 'imenu-tree)
    ("w" . 'ywb-favorite-window-config)
    ("x" . 'incr-dwim)
    ("y" . 'sdcv-search)
    ("z" . 'decr-dwim)
    )

  (deh-define-key (lookup-key global-map "\C-x")
    ("\C-t" . 'transpose-sexps)
    ("\C-r" . 'find-file-root)
    ("\C-p" . 'pde-project-find-file)
    ("t"    . 'template-simple-expand-template)
    ("m"    . 'message-mail)
    ("c"    . 'ywb-clone-buffer)
    ("j"    . 'jump-to-register)
    ("an"   . 'tempo-forward-mark)
    ("ap"   . 'tempo-backward-mark)
    ("{"    . 'ywb-change-window-size)
    )

  (deh-define-key ctl-cc-map
    ("a" . 'org-agenda)
    ("b" . 'org-iswitchb)
    ("c" . 'eim-table-add-word)
    ("d" . 'deh-customize-inplace)
    ("f" . 'find-library)
    ("g" . 'gtk-lookup-symbol)
    ("h" . 'highlight-regexp)
    ("i" . 'ispell-word)
    ("l" . 'org-store-link)
    ("m" . 'markup-pickup-face-ap)
    ("n" . 'hi-lock-next)
    ("o" . 'ywb-org-table-convert-region)
    ("p" . 'hi-lock-previous)
    ("r" . 'compile-dwim-run)
    ("s" . 'compile-dwim-compile)
    ("t" . 'ywb-org-table-export-here)
    ("v" . 'view-mode)
    ("\t" . 'ispell-complete-word)
    )

  (deh-define-key ctl-ce-map
    ("m" . 'emms))

  (deh-define-key ctl-z-map
    ("h" . 'highlight-regexp)
    ("n" . 'hi-lock-next)
    ("p" . 'hi-lock-previous)))

(windmove-default-keybindings)

(deh-define-key minibuffer-local-map
  ("\t" . 'comint-dynamic-complete))
(deh-define-key read-expression-map
  ("\t" . 'PC-lisp-complete-symbol))

(deh-section "dired-kdb"
  (add-hook 'dired-mode-hook
            (lambda ()
              (deh-define-key dired-mode-map
                ( "z"    . 'ywb-dired-compress-dir)
                ( "b"    . 'ywb-list-directory-recursive)
                ( "E"    . 'ywb-dired-w3m-visit)
                ( "j"    . 'ywb-dired-jump-to-file)
                ( "J"    . 'woman-dired-find-file)
                ( " "    . 'ywb-dired-count-dir-size)
                ( "r"    . 'wdired-change-to-wdired-mode)
                ( "W"    . 'ywb-dired-copy-fullname-as-kill)
                ( "a"    . 'ywb-add-description)
                ( "\C-q" . 'ywb-dired-quickview)
                ( "/r"   . 'ywb-dired-filter-regexp)
                ( "/."   . 'ywb-dired-filter-extension)
                ))))
