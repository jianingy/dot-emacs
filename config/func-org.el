;; table convert
;;;###autoload 
(defun ywb-org-table-convert-region (beg end wspace)
  (interactive "r\nP")
  (require 'org)
  (when (= beg (point-min))
    (save-excursion
      (goto-char beg)
      (insert "\n")
      (setq beg (1+ beg))))
  (or (eq major-mode 'org-mode) (org-mode))
  (org-table-convert-region beg end wspace))
;;;###autoload 
(defun ywb-org-table-export-here (beg end)
  (interactive "r")
  (require 'org)
  (let ((buf (generate-new-buffer "*temp*"))
        (table (delete-and-extract-region beg end)))
    (with-current-buffer buf
      (insert table)
      (goto-char (point-min))
      (while (re-search-forward "^[ \t]*|[ \t]*" nil t)
        (replace-match "" t t)
        (end-of-line 1))
      (goto-char (point-min))
      (while (re-search-forward "[ \t]*|[ \t]*$" nil t)
        (replace-match "" t t)
        (goto-char (min (1+ (point)) (point-max))))
      (goto-char (point-min))
      (while (re-search-forward "^-[-+]*$" nil t)
        (replace-match "")
        (if (looking-at "\n")
            (delete-char 1)))
      (goto-char (point-min))
      (while (re-search-forward "[ \t]*|[ \t]*" nil t)
        (replace-match "\t" t t))
      (setq table (buffer-string))
      (kill-buffer buf))
    (insert table)))
;;;###autoload
(defun ywb-org-table-sort-lines (reverse beg end numericp)
  (interactive "P\nr\nsSorting method: [n]=numeric [a]=alpha: ")
  (setq numericp (string-match "[nN]" numericp))
  (org-table-align)
  (save-excursion
    (setq beg (progn (goto-char beg) (line-beginning-position))
          end (progn (goto-char end) (line-end-position))))
  (let ((col (org-table-current-column))
        (cmp (if numericp
                 (lambda (a b) (< (string-to-number a)
                                  (string-to-number b)))
               'string<)))
    (ywb-sort-lines-1 reverse beg end
                      (lambda (pos1 pos2)
                        (let ((dat1 (split-string (buffer-substring-no-properties
                                                   (car pos1) (cdr pos1))
                                                  "\\s-*|\\s-*"))
                              (dat2 (split-string (buffer-substring-no-properties
                                                   (car pos2) (cdr pos2))
                                                  "\\s-*|\\s-*")))
                          (funcall cmp (nth col dat1) (nth col dat2)))))
    (dotimes (i col) (org-table-next-field))))

(defvar ywb-edit-rst-table-context nil)
;;;###autoload
(defun ywb-edit-rst-table (beg end)
  "编辑 rst 表格"
  (interactive "r")
  (setq ywb-edit-rst-table-context
        (list (cons 'beg (set-marker (make-marker) beg))
              (cons 'end (set-marker (make-marker) end))
              (cons 'buffer (current-buffer))))
  (let ((content (buffer-substring beg end))
        (tmp-buffer (get-buffer-create "*rst-table*")))
    (with-current-buffer tmp-buffer
      (erase-buffer)
      (insert content)
      (goto-char (point-min))
      (ywb-rst-table-to-org)
      (org-mode)
      (local-set-key "\C-c'" 'ywb-edit-rst-table-submit))
    (switch-to-buffer tmp-buffer)))

(defun ywb-rst-table-to-org ()
  "将 rst 表格转换为 org 表格"
  (let ((beg (point))
        (end (line-end-position))
        stop)
    (while (re-search-forward "\\s-+" end t)
      (setq stop (cons stop (- (point) beg 2))))
    (goto-char beg)
    (while (not (eobp))
      (if (char-equal (char-after) ?=)
          (ywb-org-convert-table-header)
        (ywb-org-convert-table-row stop))
      (forward-line 1))))

(defun ywb-org-convert-table-header ()
  "转换 rst 表格头为 org 表格"
  (let ((beg (point))
        (end (make-marker)))
    (set-marker end (line-end-position))
    (insert "|-")
    (while (re-search-forward "\\s-+" end t)
      (replace-match "+"))
    (goto-char beg)
    (while (re-search-forward "[=]+" end t)
      (replace-match (make-string (length (match-string 0)) ?-)))
    (goto-char end)
    (insert-char ?| 1)))

(defun ywb-org-convert-table-row (stop)
  "转换 rst 行为 org 行"
  (let ((beg (point))
        (end (set-marker (make-marker) (line-end-position))))
    (insert "| ")
    (while stop
      (move-to-column (cdr stop))
      (when (re-search-forward " " end t)
        (backward-char 1)
        (insert "|"))
      (setq stop (car stop)))))

(defun ywb-edit-rst-table-submit ()
  "修改 rst 表结束，原位替换"
  (interactive)
  (ywb-org-convert-table-rst)
  (let ((content (buffer-string)))
    (switch-to-buffer (cdr (assoc 'buffer ywb-edit-rst-table-context)))
    (goto-char (cdr (assoc 'beg ywb-edit-rst-table-context)))
    (delete-region (point) (cdr (assoc 'end ywb-edit-rst-table-context)))
    (insert content)))

(defun ywb-org-convert-table-rst ()
  (goto-char (point-min))
  (while (and (not (eobp)) (char-equal (char-after) ?|))
    (if (string-equal (buffer-substring (point) (+ (point) 2)) "|-")
        (ywb-rst-convert-table-header)
      (ywb-rst-convert-table-row))
    (forward-line 1))
  (delete-trailing-whitespace (point-min) (point-max)))

(defun ywb-org-export-table-as-rst (beg end)
  "将 org 表格转换为 rst 表格"
  (interactive "r")
  (let ((content (buffer-substring beg end)))
    (with-temp-buffer
      (insert content)
      (ywb-org-convert-table-rst)
      (setq content (buffer-string)))
    (insert content)))
(defun ywb-rst-convert-table-header ()
  (let ((beg (point))
        (end (make-marker)))
    (set-marker end (line-end-position))
    (delete-char 2)
    (while (re-search-forward "[|-]+" end t)
      (replace-match (make-string (length (match-string 0)) ?=)))
    (goto-char beg)
    (while (re-search-forward "\\+" end t)
      (replace-match "  "))))
(defun ywb-rst-convert-table-row ()
  (let ((beg (point))
        (end (make-marker)))
    (set-marker end (line-end-position))
    (delete-char 2)
    (while (re-search-forward "|" end t)
      (replace-match "  "))))

;;;###autoload
(defun ywb-box-table (beg end)
  (interactive "r")
  (require 'org)
  (let ((tbl (delete-and-extract-region beg end)))
    (insert
     (substring 
      (with-temp-buffer
        (org-mode)
        (insert "\n")
        (setq beg (point))
        (insert tbl)
        (setq end (point))
        (ywb-org-table-convert-region beg end nil)
        (beginning-of-line 1) (open-line 1) (insert "|-")
        (org-cycle 1) (end-of-line 1) (insert "\n|-")
        (org-cycle 1) (goto-char (point-max)) (insert "|-")
        (org-cycle 1) (beginning-of-line 1) (kill-line)
        (buffer-string)) 1))))
