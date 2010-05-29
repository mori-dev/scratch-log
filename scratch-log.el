;; -*- Mode: Emacs-Lisp ; Coding: utf-8 -*-

;; (get-buffer-create "*scratch*")

(eval-when-compile
  (require 'cl))

(defvar scratch-log-file "~/.emacs.d/.scratch-log")
(defvar prev-scratch-string-file "~/.emacs.d/.scratch-log-prev")
(defvar restore-scratch-p t)

(defun dump-scratch-when-kill-buf ()
  (interactive)
  (when (string= "*scratch*" (buffer-name))
    (make-prev-scratch-string-file)
    (append-scratch-log-file)))

(defun dump-scratch-when-kill-emacs ()
  (interactive)
  (awhen (get-buffer "*scratch*")  
    (with-current-buffer it
      (make-prev-scratch-string-file)
      (append-scratch-log-file))))

(defun make-prev-scratch-string-file ()
  (write-region (point-min) (point-max) prev-scratch-string-file))

(defun append-scratch-log-file ()
  (let* ((time (format-time-string "** %Y/%m/%d-%H:%m" (current-time)))
         (buf-str (buffer-substring-no-properties (point-min) (point-max)))
         (contents (concat "\n" time "\n" buf-str)))
    (with-current-buffer (get-buffer-create "tmp")
      (erase-buffer)
      (insert contents)
      (append-to-file (point-min) (point-max) scratch-log-file))))

(defun restore-scratch ()
  (interactive)
  (when restore-scratch-p
    (with-current-buffer "*scratch*"
      (erase-buffer)
      (when (file-exists-p prev-scratch-string-file)
        (insert-file-contents prev-scratch-string-file)))))

;; Utility
(defmacro aif (test-form then-form &rest else-forms)
  (declare (indent 2))
  `(let ((it ,test-form))
     (if it ,then-form ,@else-forms)))

(defmacro* awhen (test-form &body body)
  (declare (indent 1))
  `(aif ,test-form
       (progn ,@body)))

(add-hook 'kill-buffer-hook 'dump-scratch-when-kill-buf)
(add-hook 'kill-emacs-hook 'dump-scratch-when-kill-emacs)
(add-hook 'emacs-startup-hook 'restore-scratch)

(provide 'scratch-log.el)
