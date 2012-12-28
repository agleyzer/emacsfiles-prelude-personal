;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Disabling some stupid prelude settings. ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; paredit mode is driving me nuts
(defun disable-prelude-lisp-mode-crap ()
  (paredit-mode -1)
  (diminish 'rainbow-mode)
  (diminish 'elisp-slime-nav-mode)
  (diminish 'volatile-highlights-mode))

(add-hook 'emacs-lisp-mode-hook 'disable-prelude-lisp-mode-crap t)

;; Disable line highlight
(global-hl-line-mode -1)

;; disable annoying parens
(electric-pair-mode -1)

;; disable stupid prelude defaults
(defun prelude-c-mode-common-defaults ()
  (setq indent-tabs-mode nil)
  (setq c-basic-offset 4))

(global-hl-line-mode -1)
(setq prelude-whitespace nil)
(setq prelude-flyspell nil)
(setq prelude-guru nil)
(yas-global-mode -1)

;; hide stupid minor modes from my modeline
(diminish 'eldoc-mode)
(diminish 'ruby-block-mode)
(diminish 'projectile-mode "Proj")
(diminish 'prelude-mode "Prel")
(diminish 'abbrev-mode)

;; this is so prelude uses my current shell
(defun prelude-visit-term-buffer ()
  (interactive)
  (if (not (get-buffer "*ansi-term*"))
      (ansi-term "/bin/zsh")
    (switch-to-buffer "*ansi-term*")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Other custom settings ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; turn off the bell
(setq ring-bell-function 'ignore)


(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/"))

(defun my-c++-hook ()
  (local-set-key (quote [f4]) (lambda () (interactive )(compile "rmake"))))

(add-hook 'c++-mode-hook 'my-c++-hook)



;; TODO make it work in text mode only
(when (not (display-graphic-p))
  (xterm-mouse-mode))

;; make the cursor blinking
;; (blink-cursor-mode t)

(add-to-list 'auto-mode-alist '("\\.ctxsrc$" . javascript-mode))

;; (insert "\n(set-default-font \"" (cdr (assoc 'font (frame-parameters))) "\")\n")
;; (set-default-font "-apple-Anonymous_Pro-medium-normal-normal-*-20-*-*-*-m-0-iso10646-1")

(set-default-font "-apple-Source_Code_Pro-medium-normal-normal-*-20-*-*-*-m-0-iso10646-1")

;; command -/= to scale text
(global-set-key (kbd "s--") 'text-scale-decrease)
(global-set-key (kbd "s-=") 'text-scale-increase)
(global-set-key (kbd "s-F") 'ns-toggle-fullscreen)

(defun set-frame-position-to-zero ()
  (interactive)
  (set-frame-position (selected-frame) 0 0)
  (set-frame-width (selected-frame) 80)
  (set-frame-height (selected-frame) 20))


;; Kills all them buffers except scratch
;; optained from http://www.chrislott.org/geek/emacs/dotemacs.html
(defun nuke-all-buffers ()
  "kill all buffers, leaving *scratch* only"
  (interactive)
  (mapcar (lambda (x) (kill-buffer x))
          (buffer-list))
  (delete-other-windows))

(defun my-shell ()
  (interactive)
  (delete-other-windows)
  (split-window)
  (other-window 1)
  (shell))

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
     (add-to-list 'load-path (expand-file-name "~/apps/ensime-github/dist_2.9.2/elisp"))

     (require 'ensime)

     ;; (defvar my-ensime-active-subproject "adx-main")

     ;; (defadvice ensime-config-maybe-set-active-subproject
     ;;   (around my-ensime-config-maybe-set-active-subproject)
     ;;   "this will stop ensime from asking what the main project is"
     ;;   (if my-ensime-active-subproject
     ;;       (let (config (ad-get-arg 0))
     ;;         (message "subproject: %s" my-ensime-active-subproject)
     ;;         (ensime-set-key config :active-subproject my-ensime-active-subproject))
     ;;     ad-do-it))

     ;; (ad-activate 'ensime-config-maybe-set-active-subproject)

     (add-hook 'scala-mode-hook 'ensime-scala-mode-hook)))

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
   deft-text-mode 'org-mode))

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

;; zsh stuff - this should prevent stupid named dirs showing up in the output
;; (svbetq shell-dirstack-query "hash -dr; dirs")

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

;; this supposed to copy environment values from shell
(when (memq window-system '(mac ns))
  (exec-path-from-shell-initialize))

(exec-path-from-shell-copy-env "DYLD_LIBRARY_PATH")

(require 'expand-region)
(global-set-key (kbd "C-=") 'er/expand-region)

;; disable bold faces, yeah
(mapc
 (lambda (face)
   (set-face-attribute face nil :weight 'normal :underline nil))
 (face-list))

;; Set some keys - that's the way I like it :)
(global-set-key "\M-s" 'my-shell)
(global-set-key "\M-g" 'goto-line)

(global-set-key [C-tab] 'other-window)
(global-set-key [home] 'beginning-of-line)
(global-set-key [end] 'end-of-line)

(global-set-key [f2] 'deft)
(global-set-key [f3] 'set-frame-position-to-zero)
(global-set-key [f4] 'compile)

(global-set-key [f5] 'nuke-all-buffers)
(global-set-key [f6] (quote (lambda () (interactive) (compile "curl -v http://localhost:8080/adx/foo"))))

(global-set-key [C-M-s-left] 'backward-mark)
(global-set-key [C-M-s-right] 'forward-mark)

(global-set-key [C-S-right] 'shift-right)
(global-set-key [C-S-left] 'shift-left)
