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

(defun monroe-clojure-ts-enable ()
  ;; copied from `clojure-ts-mode'.
  (set-syntax-table clojure-ts-mode-syntax-table)
  (clojure-ts--ensure-grammars)
  (let ((markdown-available (treesit-ready-p 'markdown_inline t)))
    (when markdown-available
      (treesit-parser-create 'markdown_inline)
      (setq-local treesit-range-settings clojure-ts--treesit-range-settings))
    (when (treesit-ready-p 'clojure)
      (treesit-parser-create 'clojure)
      (clojure-ts-mode-variables markdown-available)
      (when clojure-ts--debug
        (setq-local treesit--indent-verbose t)
        (when (eq clojure-ts--debug 'font-lock)
          (setq-local treesit--font-lock-verbose t))
        (treesit-inspect-mode))
      ;; NOTE: do this although we are NOT setting up a major mode.
      (treesit-major-mode-setup)
      (add-hook 'completion-at-point-functions #'clojure-ts-completion-at-point
                nil 'local)
      ;; Workaround for treesit-transpose-sexps not correctly working with
      ;; treesit-thing-settings on Emacs 30.
      ;; Once treesit-transpose-sexps it working again this can be removed
      (when (fboundp 'transpose-sexps-default-function)
        (setq-local transpose-sexps-function #'transpose-sexps-default-function)))))

(provide 'monroe-clojure-ts)
;;; monroe-clojure-ts.el ends here
