;;; early-init.el --- Early Emacs initialization -*- lexical-binding: t; -*-

;; Log native-compilation warnings without popping up the warnings buffer.
(setq native-comp-async-report-warnings-errors 'silent)
(setq package-enable-at-startup nil)

;; Don't pop up ordinary warnings/errors.
;; Only :emergency warnings should interrupt me.
(setq warning-minimum-level :emergency)

;; Still record normal warnings in *Warnings*.
(setq warning-minimum-log-level :warning)

;; Native compilation warnings should also stay quiet.
(setq native-comp-async-report-warnings-errors 'silent)

;; Also persist warnings to a file.
(defvar my-warning-log-file
  (expand-file-name "emacs-warnings.log" user-emacs-directory))

(defun my-log-warning-to-file (type message &optional level _buffer-name)
  (let ((inhibit-message t))
    (write-region
     (format "[%s] %-10s %-20s %s\n"
             (format-time-string "%Y-%m-%d %H:%M:%S")
             (or level :warning)
             type
             message)
     nil
     my-warning-log-file
     'append
     'silent)))

(advice-add 'display-warning :before #'my-log-warning-to-file)
