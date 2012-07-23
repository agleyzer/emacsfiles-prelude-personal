; Here are some examples of how to override the defaults for the
;; various prelude-emacs settings.  To *append* to any of the
;; configurations attached to prelude-*-hooks, you can attach a
;; function to the appropriate hook:

(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/"))

;; disable whitespace-mode and whitespace-cleanup
(add-hook 'prelude-prog-mode-hook
          (lambda ()
            (prelude-turn-off-whitespace)
            (turn-off-flyspell)
            (add-hook 'before-save-hook 'whitespace-cleanup)
            ) t)

;; For other global settings, just run the appropriate function; all
;; personal/*.el files will be evaluate after prelude-emacs is loaded.

;; disable line highlight
(global-hl-line-mode -1)
(xterm-mouse-mode)

;; make the cursor blinking
;; (blink-cursor-mode t)

(add-to-list 'auto-mode-alist '("\\.ctxsrc$" . javascript-mode))


;; (prelude-restore-arrow-keys)

;; (insert "\n(set-default-font \"" (cdr (assoc 'font (frame-parameters))) "\")\n")
(set-default-font "-apple-Anonymous_Pro-medium-normal-normal-*-20-*-*-*-m-0-iso10646-1")

;; (set-default-font "-apple-Inconsolata-medium-normal-normal-*-20-*-*-*-m-0-iso10646-1")

;; disable annoying parens
(electric-pair-mode -1)

;; turn off the bell
(setq ring-bell-function 'ignore)

;; command -/= to scale text
(global-set-key (kbd "s--") 'text-scale-decrease)
(global-set-key (kbd "s-=") 'text-scale-increase)
(global-set-key (kbd "s-F") 'ns-toggle-fullscreen)

(defun set-frame-position-to-zero ()
  (interactive)
  (set-frame-position (selected-frame) 0 0)
  (set-frame-width (selected-frame) 80)
  (set-frame-height (selected-frame) 20))

(global-set-key (quote [f3]) 'set-frame-position-to-zero)

(global-hl-line-mode -1)

;; (whitespace-mode -1)

;; Kills all them buffers except scratch
;; optained from http://www.chrislott.org/geek/emacs/dotemacs.html
(defun nuke-all-buffers ()
  "kill all buffers, leaving *scratch* only"
  (interactive)
  (mapcar (lambda (x) (kill-buffer x))
          (buffer-list))
  (delete-other-windows))

(global-set-key (quote [f5]) (quote nuke-all-buffers))

(defun my-shell ()
  (interactive)
  (delete-other-windows)
  (split-window)
  (other-window 1)
  (shell))

;; Set some keys - that's the way I like it :)
(global-set-key "\M-s" (quote my-shell))
(global-set-key "\M-g" (quote goto-line))
(global-set-key (quote [f1]) (quote manual-entry))
(global-set-key (quote [C-tab]) (quote other-window))
(global-set-key (quote [home]) (quote beginning-of-line))
(global-set-key (quote [end]) (quote end-of-line))
(global-set-key (quote [f6]) (quote (lambda () (interactive) (compile "curl -v http://localhost:8080/adx/foo"))))


;;; Remove hooks from prelude
;;; (remove-hook 'message-mode-hook 'prelude-turn-on-flyspell)
;;; (remove-hook 'text-mode-hook 'prelude-turn-on-flyspell)

;;; ;; Overwrite prelude function removing flyspell-prog-mode
;;; (defun my-prelude-coding-hook ()
;;;   (prelude-local-comment-auto-fill)
;;;   ;; (prelude-turn-off-whitespace)
;;;   ;; (prelude-turn-on-abbrev)
;;;   ;; (prelude-add-watchwords)
;;;   ;; keep the whitespace decent all the time (in this buffer)
;;;   (add-hook 'before-save-hook 'whitespace-cleanup nil t))
;;;
;;; ;; remove default prelude hook
;;; (remove-hook 'prelude-prog-mode-hook 'prelude-prog-mode-defaults)
;;;
;;; ;; add mine
;;; (add-hook 'prelude-prog-mode-hook 'my-prelude-coding-hook t)

;; Scala and Ensime
(add-to-list 'auto-mode-alist '("\\.scala$" . scala-mode))

(eval-after-load 'scala-mode
  '(progn
     (require 'scala-mode-auto)
     (require 'scala-mode-feature-speedbar)
     (add-hook 'scala-mode-hook
               '(lambda ()
                  (add-hook 'before-save-hook 'whitespace-cleanup)
                  (local-set-key [f7] 'ensime-sbt-switch)
                  (local-set-key [S-f7] 'ensime-sbt-clear)
                  (local-set-key [f8] 'ensime-inf-switch)
                  (subword-mode +1)))

     ;; (add-to-list 'load-path (expand-file-name "~/apps/ensime/elisp/"))
     (add-to-list 'load-path "/Users/204114/apps/ensime-github/dist_2.9.2/elisp")

     (require 'ensime)
     (add-hook 'scala-mode-hook 'ensime-scala-mode-hook)))

(global-set-key [C-M-s-left] 'backward-mark)
(global-set-key [C-M-s-right] 'forward-mark)
(defun my-pop-global-mark ()
  "Pop off global mark ring and jump to the top location."
  (interactive)
  ;; Pop entries which refer to non-existent
  ;; buffers or buffers that are not visiting files.
  (while (and global-mark-ring
              (let ((buffer (marker-buffer (car global-mark-ring))))
                (or (not buffer)
                    (not (buffer-file-name buffer)))))
    (setq global-mark-ring (cdr global-mark-ring)))
  (or global-mark-ring
      (error "No global mark set"))
  (let* ((marker (car global-mark-ring))
         (buffer (marker-buffer marker))
         (position (marker-position marker)))
    (setq global-mark-ring (nconc (cdr global-mark-ring)
                                  (list (car global-mark-ring))))
    (set-buffer buffer)
    (or (and (>= position (point-min))
             (<= position (point-max)))
        (if widen-automatically
            (widen)
          (error "Global mark position is outside accessible part of buffer")))
    (goto-char position)
    (switch-to-buffer buffer)))

(global-set-key [M-s-left] 'my-pop-global-mark)
(global-set-key [C-M-s-left] 'pop-to-mark-command)


(when (require 'deft nil) 'noerror
  (setq
   deft-extension "org"
   deft-directory "~/Dropbox/orgfiles/"
   deft-text-mode 'org-mode)
  (global-set-key (quote [f2]) 'deft))

;; change magit diff colors
(eval-after-load 'magit
  '(progn
     ;; disable shitty section highlighting, it sucks
     (defun magit-highlight-section ())
     (set-face-foreground 'magit-diff-add "green3")
     (set-face-foreground 'magit-diff-del "red3")))

;; trying to make zsh work in ansi-term
(add-hook 'term-exec-hook
          (function
           (lambda ()
             (set-buffer-process-coding-system 'utf-8-unix 'utf-8-unix))))
(setq system-uses-terminfo nil)

;; this is so prelude uses my current shell
(defun prelude-visit-term-buffer ()
  (interactive)
  (if (not (get-buffer "*ansi-term*"))
      (ansi-term "/bin/zsh")
    (switch-to-buffer "*ansi-term*")))

;; zsh stuff - this should prevent stupid named dirs showing up in the output
;; (setq shell-dirstack-query "hash -dr; dirs")

;; Shift the selected region right if distance is positive, left if
;; negative

(defun shift-region (distance)
  (let ((mark (mark)))
    (save-excursion
      (indent-rigidly (region-beginning) (region-end) distance)
      (push-mark mark t t)
      ;; Tell the command loop not to deactivate the mark
      ;; for transient mark mode
      (setq deactivate-mark nil))))

(defun shift-right ()
  (interactive)
  (shift-region 1))

(defun shift-left ()
  (interactive)
  (shift-region -1))

;; Bind (shift-right) and (shift-left) function to your favorite keys. I use
;; the following so that Ctrl-Shift-Right Arrow moves selected text one
;; column to the right, Ctrl-Shift-Left Arrow moves selected text one
;; column to the left:

(global-set-key [C-S-right] 'shift-right)
(global-set-key [C-S-left] 'shift-left)
