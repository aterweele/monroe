;;; monroe-clojure-ts.el --- Using monroe with clojure-ts-mode  -*- lexical-binding: t; -*-

;; Copyright (C) 2024  Alex ter Weele

;; Author: Alex ter Weele
;; Keywords: 

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; 

;;; Code:

(defun monroe-clojure-ts-completion-at-point ()
  (let* ((bnds (bounds-of-thing-at-point 'symbol))
         (start (car bnds))
         (end (cdr bnds)))
    (list start end
          (completion-table-merge
           (completion-table-dynamic
            (lambda (_)
              (clojure-ts-bindings-above-point)))
           (completion-table-dynamic
            (lambda (string)
              (when-let ((response
                          (ignore-errors
                            (monroe-send-sync-request
                             (list "op" "completions"
                                   "ns" (monroe-get-clojure-ns)
                                   "prefix" string)))))
                (monroe-dbind-response
                 response (completions)
                 (when completions
                   (mapcar 'cdadr completions))))))))))

(defun monroe-clojure-ts-enable ()
  (setq-local comint-indirect-setup-function #'clojure-ts-mode)
  (comint-fontify-input-mode)
  ;; copied from `shell-mode'
  (setq-local indent-line-function #'comint-indent-input-line-default)
  ;; contrast the above with what IELM does, which is set
  ;; `indent-line-function' to #'ielm-indent-line. I don't we can set
  ;; to `treesit-indent'; that doesn't work.
  (setq-local indent-region-function #'comint-indent-input-region-default)
  ;; This is a bit opinionated. But if we don't do this,
  ;; `comint-highlight-input' (default value: bold) overrides the
  ;; fontification we achieved with
  ;; `comint-fontify-input-mode'. `inferior-python-mode' also does
  ;; this, but IELM and `shell' don't.
  (setq-local comint-highlight-input nil)
  (set-syntax-table clojure-ts-mode-syntax-table)

  ;; i.e., override the existing `completion-at-point-functions' and
  ;; install a hopefully-better one
  (setq-local completion-at-point-functions (list #'monroe-clojure-ts-completion-at-point))

  ;; TODO steal more from `inferior-lisp-mode', `run-python', etc.
  )

(provide 'monroe-clojure-ts)
;;; monroe-clojure-ts.el ends here
