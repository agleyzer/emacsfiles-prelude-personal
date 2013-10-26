;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Disabling some stupid prelude settings. ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq mac-command-modifier 'super)
(setq mac-option-modifier 'meta)

;; paredit mode is driving me nuts
(defun disable-prelude-lisp-mode-crap ()
  (paredit-mode -1)
  (diminish 'rainbow-mode)
  (diminish 'volatile-highlights-mode)
)

(add-hook 'emacs-lisp-mode-hook 'disable-prelude-lisp-mode-crap t)

;; Disable line highlight
(global-hl-line-mode -1)

;; disable annoying parens
(electric-pair-mode -1)
(smartparens-global-mode -1)

;; disable stupid prelude defaults
(defun prelude-c-mode-common-defaults ()
  (setq indent-tabs-mode nil)
  (setq c-basic-offset 4))

(global-hl-line-mode -1)
(setq prelude-whitespace nil)
(setq prelude-flyspell nil)
(setq prelude-guru nil)
(yas-global-mode -1)
(show-paren-mode 1)

;; disabling prelude-whitespace removes whitespace cleanup... fuck
(defun my-prog-mode-defaults ()
  (add-hook 'before-save-hook 'whitespace-cleanup nil t))

(add-hook 'prelude-prog-mode-hook 'my-prog-mode-defaults t)

;; hide stupid minor modes from my modeline
(diminish 'eldoc-mode)
;; (diminish 'ruby-block-mode)
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
(add-to-list 'auto-mode-alist '("\\.ctxinc$" . javascript-mode))
(add-to-list 'auto-mode-alist '("\\.in$" . javascript-mode))

;; prelude sets it to 'meta...
(setq mac-command-modifier 'super)

;; command -/= to scale text
(global-set-key (kbd "s--") 'text-scale-decrease)
(global-set-key (kbd "s-=") 'text-scale-increase)
(global-set-key (kbd "s-F") 'ag-toggle-fullscreen)

(defun ag-toggle-fullscreen ()
  "Toggle full screen"
  (interactive)

  (if (version< emacs-version "24.3")
      (ns-toggle-fullscreen)
    (if (not (frame-parameter nil 'fullscreen))
        (set-frame-parameter nil 'fullscreen 'fullboth)
      (progn
        (set-frame-parameter nil 'fullscreen nil)
        ;; weird, but it seems that I have to turn tool bar on and off
        ;; for full screen to work in snow leopard
        (tool-bar-mode 1)
        (tool-bar-mode -1)))))


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
  (mapc (lambda (x) (kill-buffer x))
          (buffer-list))
  (delete-other-windows))

(defun my-shell ()
  (interactive)
  (delete-other-windows)
  (split-window)
  (other-window 1)
  (ansi-term "/bin/zsh" "localhost"))

(require 'term)
(defun visit-ansi-term ()
  "If the current buffer is:
     1) a running ansi-term named *ansi-term*, rename it.
     2) a stopped ansi-term, kill it and create a new one.
     3) a non ansi-term, go to an already running ansi-term
        or start a new one while killing a defunt one"
  (interactive)
  (let ((is-term (string= "term-mode" major-mode))
        (is-running (term-check-proc (buffer-name)))
        (term-cmd "/bin/zsh")
        (anon-term (get-buffer "*ansi-term*")))
    (if is-term
        (if is-running
            (if (string= "*ansi-term*" (buffer-name))
                (call-interactively 'rename-buffer)
              (if anon-term
                  (switch-to-buffer-other-window "*ansi-term*")
                (ansi-term term-cmd)))
          (kill-buffer (buffer-name))
          (ansi-term term-cmd))
      (if anon-term
          (if (term-check-proc "*ansi-term*")
              (switch-to-buffer-other-window "*ansi-term*")
            (kill-buffer "*ansi-term*")
            (delete-other-windows)
            (split-window)
            (other-window 1)
            (ansi-term term-cmd))
        (delete-other-windows)
        (split-window)
        (other-window 1)
        (ansi-term term-cmd)))))

;; Scala and Ensime

(add-to-list 'auto-mode-alist '("\\.scala$" . scala-mode))

;; (defun my-sbt-switch ()
;;   "Switch to the sbt shell (create if necessary) if or if already there, back.
;;    If already there but the process is dead, restart the process. "
;;   (interactive)
;;   (let ((sbt-buf "*sbt*"))
;;     (if (equal sbt-buf (buffer-name))
;;         (switch-to-buffer-other-window (other-buffer))
;;       (if (get-buffer sbt-buf)
;;           (progn
;;             (switch-to-buffer-other-window sbt-buf)
;;             (goto-char (point-max)))
;;         (message "SBT is not running?")))))
;;
;; (global-set-key [f7] 'my-sbt-switch)

(defun my-eval-scala ()
  (interactive)
  (let (
        (selection (buffer-substring-no-properties (region-beginning) (region-end))))
    (if (= (length selection) 0)
        (ensime-inf-eval-definition)
      (ensime-inf-eval-region (region-beginning) (region-end)))))

(defun my-scala-find-tag ()
  "Meant to be set as M-."
  (interactive)
  (if (ensime-connected-p) (call-interactively 'ensime-edit-definition)
    (call-interactively 'find-tag)))

(defun my-scala-mode-hook ()
  (flymake-mode)
  (add-hook 'before-save-hook 'whitespace-cleanup)
  (local-set-key [f7] 'ensime-sbt-switch)
  (local-set-key [S-f7] 'ensime-sbt-clear)
  (local-set-key [f8] 'ensime-inf-switch)
  (local-set-key [f4] 'ensime-inf-eval-region)
  (local-set-key [S-f4] 'ensime-inf-eval-definition)

  ;;(local-set-key (kbd "M-.") 'my-scala-find-tag)
  (define-key ensime-mode-map (kbd "M-.") 'my-scala-find-tag)

  (subword-mode +1)

  (require 'key-chord)
  (key-chord-mode +1)
  (key-chord-define ensime-mode-map "ii" 'ensime-import-type-at-point)
  (key-chord-define ensime-mode-map "II" 'ensime-refactor-organize-imports)
  (key-chord-define ensime-mode-map "qq" 'ensime-inf-switch))

(eval-after-load 'scala-mode2
  '(progn
     (message "scala-mode2 ftw")

     ;; (add-to-list 'load-path (expand-file-name "~/apps/ensime/elisp/"))
     (add-to-list 'load-path (expand-file-name "~/apps/ensime/elisp"))

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
     (add-hook 'scala-mode-hook 'my-scala-mode-hook)
     (add-hook 'scala-mode-hook 'ensime-scala-mode-hook)
))


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
   deft-directory "~/OldDropbox/orgfiles/"
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
(global-set-key "\M-s" 'visit-ansi-term)
(global-set-key "\M-g" 'goto-line)

(global-set-key [C-tab] 'other-window)
(global-set-key [home] 'beginning-of-line)
(global-set-key [end] 'end-of-line)

(global-set-key [f1] 'helm-man-woman)
(global-set-key [f2] 'deft)
(global-set-key [f3] 'visit-ansi-term)
(global-set-key [f4] 'compile)

(global-set-key [f5] 'nuke-all-buffers)
(global-set-key [f6] (quote (lambda () (interactive) (compile "curl -v http://localhost:8080/adx/foo"))))

(global-set-key [C-M-s-left] 'backward-mark)
(global-set-key [C-M-s-right] 'forward-mark)

(global-set-key [C-S-right] 'shift-right)
(global-set-key [C-S-left] 'shift-left)

; ;; switch buffers with M-NUM
; (require 'window-number)
; (window-number-mode)
; (window-number-meta-mode)

;; enables arrows in comint mode
(require 'comint)
;; (define-key comint-mode-map (kbd "M-") 'comint-next-input)
;; (define-key comint-mode-map (kbd "M-") 'comint-previous-input)
(define-key comint-mode-map [down] 'comint-next-matching-input-from-input)
(define-key comint-mode-map [up] 'comint-previous-matching-input-from-input)

;; (when (load "flymake" t)
;;   (defun flymake-pylint-init ()
;;     (let* ((temp-file (flymake-init-create-temp-buffer-copy
;;                        'flymake-create-temp-inplace))
;;            (local-file (file-relative-name
;;                         temp-file
;;                         (file-name-directory buffer-file-name))))
;;       (list "epylint" (list local-file))))
;;   (add-to-list 'flymake-allowed-file-name-masks
;;                '("\\.py\\'" flymake-pylint-init)))


(add-hook 'python-mode-hook
          '(lambda ()
             (local-set-key [f7] 'python-shell-switch-to-shell)))


;; (setq ipython-command "/usr/local/share/python/ipython")
;; (require 'ipython)

(require 'highlight-symbol)
(global-set-key [mouse-3] 'highlight-symbol-at-point)

(require 'sr-speedbar)

(setq sr-speedbar-width 15)

;; show all files
(setq speedbar-show-unknown-files t)

;; turn off the ugly icons
(setq speedbar-use-images nil)

;; left-side pane
(setq sr-speedbar-right-side nil)

;; don't refresh on buffer changes
(setq sr-speedbar-auto-refresh nil)

;; make speedbar text smaller
(setq speedbar-mode-hook
      '(lambda ()
         (progn
           (message "whoa")
           (text-scale-decrease 2))))

(global-set-key [s-f12] 'sr-speedbar-toggle)

(require 'powerline)
(powerline-default-theme)

;; Temp fix for https://github.com/nex3/magithub/pull/12
(setq magit-log-edit-confirm-cancellation t)


;; Toggle window dedication

(defun toggle-window-dedicated ()
  "Toggle whether the current active window is dedicated or not"
  (interactive)
  (message
   (if (let (window (get-buffer-window (current-buffer)))
         (set-window-dedicated-p window
                                 (not (window-dedicated-p window))))
       "Window '%s' is dedicated"
     "Window '%s' is normal")
   (current-buffer)))
