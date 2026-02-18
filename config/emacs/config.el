(defconst dt/emacs-dir user-emacs-directory
  "Root of this Emacs config.")

(defun dt/in-emacs-dir (rel)
  "Return REL path inside `dt/emacs-dir`."
  (expand-file-name rel dt/emacs-dir))

(add-to-list 'load-path (dt/in-emacs-dir "scripts/"))

(require 'elpaca-setup)  ;; The Elpaca Package Manager
(require 'buffer-move)   ;; Buffer-move for better window management
(require 'app-launchers) ;; Use emacs as a run launcher like dmenu (experimental)

(use-package all-the-icons
  :ensure t
  :if (display-graphic-p))

(use-package all-the-icons-dired
  :hook (dired-mode . (lambda () (all-the-icons-dired-mode t))))

;; -------------------------
;; C/C++ indentation: force 4 spaces everywhere
;; Works for BOTH:
;;   - cc-mode:     c-mode / c++-mode
;;   - tree-sitter: c-ts-mode / c++-ts-mode
;; -------------------------

;; 1) If your Emacs/distro is auto-remapping c-mode -> c-ts-mode, that's fine.
;;    We'll configure BOTH systems so indentation is still 4 either way.

;; ---------- CC MODE (c-mode / c++-mode) ----------
(with-eval-after-load 'cc-mode

  ;; Smarter brace newline behavior for enum and initializer-list braces
  (defun cole/c-brace-open (syntax pos)
    (save-excursion
      (let ((start (c-point 'bol))
            langelem)
        (if (and (eq syntax 'brace-list-open)
                 (setq langelem (assq 'brace-list-open c-syntactic-context))
                 (progn
                   (goto-char (c-langelem-pos langelem))
                   (if (eq (char-after) ?{)
                       (c-safe (c-forward-sexp -1)))
                   (looking-at "\\<enum\\>[^_]")))
            '(before after)
          (if (< (point) start)
              '(after))))))

  (defun cole/c-brace-close (syntax pos)
    (save-excursion
      (goto-char pos)
      (if (> (c-point 'bol)
             (progn (up-list -1) (point)))
          '(before))))

  ;; Doxygen font-lock (ported)
  (defconst cole/doxygen-font-lock-doc-comments
    `(("\\s-\\([\\@].*?\\)\\s-"
       1 font-lock-constant-face prepend nil)
      ("\\[in\\]\\|\\[out\\]\\|\\[in,out\\]"
       0 font-lock-constant-face prepend nil)
      ("\\<\\(?:[a-zA-Z_][a-zA-Z0-9_]*::\\)*[a-zA-Z_][a-zA-Z0-9_]*()"
       0 font-lock-constant-face prepend nil)))

  (defconst cole/doxygen-font-lock-keywords
    `((,(lambda (limit)
          (c-font-lock-doc-comments "/\\*[*!]<?" limit
            cole/doxygen-font-lock-doc-comments)
          (c-font-lock-doc-comments "//[/!]<?" limit
            cole/doxygen-font-lock-doc-comments)))))

  ;; Define the style
  (c-add-style
   "aek"
   '((c-doc-comment-style . doxygen)
     (c-basic-offset . 4)
     (c-comment-only-line-offset . 0)
     (c-hanging-braces-alist . ((substatement-open before after)
                                (brace-list-open . cole/c-brace-open)
                                (brace-list-close . cole/c-brace-close)
                                (class-close before)))
     (c-hanging-semi&comma-criteria . (c-semi&comma-no-newlines-before-nonblanks
                                       c-semi&comma-inside-parenlist))
     (c-offsets-alist . ((topmost-intro     . 0)
                         (substatement      . +)
                         (substatement-open . 0)   ;; brace aligns with for/if/while
                         (case-label        . +)
                         (access-label      . -)
                         (inclass           . +)
                         (inline-open       . 0)
                         (brace-list-open   . 0)
                         (brace-list-close  . 0)))))

  ;; Make it the default for CC Mode
  (add-to-list 'c-default-style '(c-mode . "aek"))
  (add-to-list 'c-default-style '(c++-mode . "aek"))

  ;; Apply style + force 4 + doxygen highlighting
  (defun cole/c-mode-common-setup ()
    "Apply my CC Mode defaults."
    (c-set-style "aek")
    ;; FORCE 4 even if something else tries to override it
    (setq-local c-basic-offset 4)
    (setq-local tab-width 4)
    (setq-local indent-tabs-mode nil)
    (c-toggle-auto-hungry-state -1)
    (font-lock-add-keywords nil cole/doxygen-font-lock-keywords t))

  (add-hook 'c-mode-common-hook #'cole/c-mode-common-setup))

;; ---------- TREE-SITTER (c-ts-mode / c++-ts-mode) ----------
;; These variables are different from c-basic-offset; you must set them separately.
(with-eval-after-load 'c-ts-mode
  (setq c-ts-mode-indent-offset 4))

(with-eval-after-load 'c++-ts-mode
  (setq c++-ts-mode-indent-offset 4))

(add-hook 'c-ts-mode-hook
          (lambda ()
            (setq-local c-ts-mode-indent-offset 4)
            (setq-local tab-width 4)
            (setq-local indent-tabs-mode nil)))

(add-hook 'c++-ts-mode-hook
          (lambda ()
            (setq-local c++-ts-mode-indent-offset 4)
            (setq-local tab-width 4)
            (setq-local indent-tabs-mode nil)))

(add-hook 'hack-local-variables-hook
          (lambda ()
            (when (derived-mode-p 'c-mode 'c++-mode)
              (setq-local c-basic-offset 4
                          tab-width 4
                          indent-tabs-mode nil))))

(setq backup-directory-alist '((".*" . "~/.local/share/Trash/files")))

(use-package company
  :defer 2
  :diminish
  :custom
  (company-begin-commands '(self-insert-command))
  (company-idle-delay nil) ;; is disabled. change nil to .1 to enable
  (company-minimum-prefix-length 2)
  (company-show-numbers t)
  (company-tooltip-align-annotations 't)
  (global-company-mode t))

(use-package company-box
  :after company
  :diminish
  :hook (company-mode . company-box-mode))

(use-package dashboard
  :ensure t 
  :init
  (setq initial-buffer-choice 'dashboard-open)
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-file-icons t)
  (setq dashboard-banner-logo-title "Emacs Is More Than A Text Editor!")
  ;;(setq dashboard-startup-banner 'logo) ;; use standard emacs logo as banner
  (setq dashboard-startup-banner (dt/in-emacs-dir "images/dtmacs-logo.png"))  ;; use custom image as banner
  (setq dashboard-center-content nil) ;; set to 't' for centered content
  (setq dashboard-items '((recents . 15)
                          (agenda . 1)
                          (bookmarks . 6)
                          (projects . 3)
                          (registers . 3)))
  :custom 
  (dashboard-modify-heading-icons '((recents . "file-text")
				      (bookmarks . "book")))
  :config
  (dashboard-setup-startup-hook))

(use-package diminish)

(use-package dired-open
  :config
  (setq dired-open-extensions '(("gif" . "sxiv")
                                ("jpg" . "sxiv")
                                ("png" . "sxiv")
                                ("mkv" . "mpv")
                                ("mp4" . "mpv"))))

(use-package peep-dired
  :after dired
  :hook (evil-normalize-keymaps . peep-dired-hook)
  :config
    (evil-define-key 'normal dired-mode-map (kbd "h") 'dired-up-directory)
    (evil-define-key 'normal dired-mode-map (kbd "l") 'dired-open-file) ; use dired-find-file instead if not using dired-open package
    (evil-define-key 'normal peep-dired-mode-map (kbd "j") 'peep-dired-next-file)
    (evil-define-key 'normal peep-dired-mode-map (kbd "k") 'peep-dired-prev-file)
)

(use-package elfeed
  :config
  (setq elfeed-search-feed-face ":foreground #ffffff :weight bold"
        elfeed-feeds (quote
                       (("https://www.reddit.com/r/linux.rss" reddit linux)
                        ("https://www.reddit.com/r/commandline.rss" reddit commandline)
                        ("https://www.reddit.com/r/distrotube.rss" reddit distrotube)
                        ("https://www.reddit.com/r/emacs.rss" reddit emacs)
                        ("https://www.gamingonlinux.com/article_rss.php" gaming linux)
                        ("https://hackaday.com/blog/feed/" hackaday linux)
                        ("https://opensource.com/feed" opensource linux)
                        ("https://linux.softpedia.com/backend.xml" softpedia linux)
                        ("https://itsfoss.com/feed/" itsfoss linux)
                        ("https://www.zdnet.com/topic/linux/rss.xml" zdnet linux)
                        ("https://www.phoronix.com/rss.php" phoronix linux)
                        ("http://feeds.feedburner.com/d0od" omgubuntu linux)
                        ("https://www.computerworld.com/index.rss" computerworld linux)
                        ("https://www.networkworld.com/category/linux/index.rss" networkworld linux)
                        ("https://www.techrepublic.com/rssfeeds/topic/open-source/" techrepublic linux)
                        ("https://betanews.com/feed" betanews linux)
                        ("http://lxer.com/module/newswire/headlines.rss" lxer linux)
                        ("https://distrowatch.com/news/dwd.xml" distrowatch linux)))))
 

(use-package elfeed-goodies
  :init
  (elfeed-goodies/setup)
  :config
  (setq elfeed-goodies/entry-pane-size 0.5))

(use-package evil
  :init
  (setq evil-want-integration t
        evil-want-keybinding nil
        evil-vsplit-window-right t
        evil-split-window-below t
        evil-want-fine-undo t
        evil-undo-system 'undo-tree)
  (evil-mode))

(use-package undo-tree
  :diminish
  :init
  (global-undo-tree-mode 1)
  :config
  ;; Save undo history files (so undo persists across restarts)
  (setq undo-tree-history-directory-alist
        `(("." . ,(expand-file-name "undo-tree-history/" user-emacs-directory))))
  (setq undo-tree-auto-save-history t))

(use-package evil-collection
  :after evil
  :config
  ;; Do not uncomment this unless you want to specify each and every mode
  ;; that evil-collection should works with.  The following line is here 
  ;; for documentation purposes in case you need it.  
  ;; (setq evil-collection-mode-list '(calendar dashboard dired ediff info magit ibuffer))
  (add-to-list 'evil-collection-mode-list 'help) ;; evilify help mode
  (evil-collection-init))

(use-package evil-tutor)

;; Using RETURN to follow links in Org/Evil 
;; Unmap keys in 'evil-maps if not done, (setq org-return-follows-link t) will not work
(with-eval-after-load 'evil-maps
  (define-key evil-motion-state-map (kbd "SPC") nil)
  (define-key evil-motion-state-map (kbd "RET") nil)
  (define-key evil-motion-state-map (kbd "TAB") nil))
;; Setting RETURN key in org-mode to follow links
  (setq org-return-follows-link  t)
  (setq evil-want-C-u-scroll t)

(use-package flycheck
  :ensure t
  :defer t
  :diminish
  :init (global-flycheck-mode))

(defun cole/apply-fonts (&optional frame)
  (with-selected-frame (or frame (selected-frame))
    (when (display-graphic-p)
      (set-face-attribute 'default nil :font "JetBrains Mono" :height 139 :weight 'medium)
      (set-face-attribute 'fixed-pitch nil :font "JetBrains Mono" :height 139 :weight 'medium)
      (set-face-attribute 'variable-pitch nil :font "Ubuntu" :height 159 :weight 'medium)
      (set-face-attribute 'font-lock-comment-face nil :slant 'italic)
      (set-face-attribute 'font-lock-keyword-face nil :slant 'italic)
      (setq-default line-spacing 0.12))))

(if (daemonp)
    (add-hook 'after-make-frame-functions #'cole/apply-fonts)
  (cole/apply-fonts))

(global-set-key (kbd "C-=") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
(global-set-key (kbd "<C-wheel-up>") 'text-scale-increase)
(global-set-key (kbd "<C-wheel-down>") 'text-scale-decrease)

(use-package general
  :config
  (general-evil-setup)
  
  ;; set up 'SPC' as the global leader key
  (general-create-definer dt/leader-keys
    :states '(normal insert visual emacs)
    :keymaps 'override
    :prefix "SPC" ;; set leader
    :global-prefix "M-SPC") ;; access leader in insert mode

  (dt/leader-keys
    "SPC" '(counsel-M-x :wk "Counsel M-x")
    "." '(find-file :wk "Find file")
    "=" '(perspective-map :wk "Perspective") ;; Lists all the perspective keybindings
    "TAB TAB" '(comment-line :wk "Comment lines")
    "u" '(universal-argument :wk "Universal argument"))

  (dt/leader-keys
    "b" '(:ignore t :wk "Bookmarks/Buffers")
    "b b" '(switch-to-buffer :wk "Switch to buffer")
    "b c" '(clone-indirect-buffer :wk "Create indirect buffer copy in a split")
    "b C" '(clone-indirect-buffer-other-window :wk "Clone indirect buffer in new window")
    "b d" '(bookmark-delete :wk "Delete bookmark")
    "b i" '(ibuffer :wk "Ibuffer")
    "b k" '(kill-current-buffer :wk "Kill current buffer")
    "b K" '(kill-some-buffers :wk "Kill multiple buffers")
    "b l" '(list-bookmarks :wk "List bookmarks")
    "b m" '(bookmark-set :wk "Set bookmark")
    "b n" '(next-buffer :wk "Next buffer")
    "b p" '(previous-buffer :wk "Previous buffer")
    "b r" '(revert-buffer :wk "Reload buffer")
    "b R" '(rename-buffer :wk "Rename buffer")
    "b s" '(basic-save-buffer :wk "Save buffer")
    "b S" '(save-some-buffers :wk "Save multiple buffers")
    "b w" '(bookmark-save :wk "Save current bookmarks to bookmark file"))

  (dt/leader-keys
    "d" '(:ignore t :wk "Dired")
    "d d" '(dired :wk "Open dired")
    "d j" '(dired-jump :wk "Dired jump to current")
    "d n" '(neotree-dir :wk "Open directory in neotree")
    "d p" '(peep-dired :wk "Peep-dired"))

  (dt/leader-keys
    "e" '(:ignore t :wk "Eshell/Evaluate")    
    "e b" '(eval-buffer :wk "Evaluate elisp in buffer")
    "e d" '(eval-defun :wk "Evaluate defun containing or after point")
    "e e" '(eval-expression :wk "Evaluate and elisp expression")
    "e h" '(counsel-esh-history :which-key "Eshell history")
    "e l" '(eval-last-sexp :wk "Evaluate elisp expression before point")
    "e r" '(eval-region :wk "Evaluate elisp in region")
    "e R" '(eww-reload :which-key "Reload current page in EWW")
    "e s" '(eshell :which-key "Eshell")
    "e w" '(eww :which-key "EWW emacs web wowser"))

  (dt/leader-keys
    "f" '(:ignore t :wk "Files")    
    "f c" '((lambda () (interactive)
              (find-file (dt/in-emacs-dir "config.org"))) 
            :wk "Open emacs config.org")
    "f e" '((lambda () (interactive)
              (dired dt/emacs-dir)) 
            :wk "Open user-emacs-directory in dired")
    "f d" '(find-grep-dired :wk "Search for string in files in DIR")
    "f g" '(counsel-grep-or-swiper :wk "Search for string current file")
    "f i" '((lambda () (interactive)
              (find-file (dt/in-emacs-dir "init.el"))) 
            :wk "Open emacs init.el")
    "f j" '(counsel-file-jump :wk "Jump to a file below current directory")
    "f l" '(counsel-locate :wk "Locate a file")
    "f r" '(counsel-recentf :wk "Find recent files")
    "f u" '(sudo-edit-find-file :wk "Sudo find file")
    "f U" '(sudo-edit :wk "Sudo edit file")
    "f v" '((lambda () (interactive)
              (find-file (expand-file-name "~/dev/dotfiles/evil-cheats.txt")))
            :wk "Open evil cheat sheet"))

  
  (dt/leader-keys
    "g" '(:ignore t :wk "Git")    
    "g /" '(magit-displatch :wk "Magit dispatch")
    "g ." '(magit-file-displatch :wk "Magit file dispatch")
    "g b" '(magit-branch-checkout :wk "Switch branch")
    "g c" '(:ignore t :wk "Create") 
    "g c b" '(magit-branch-and-checkout :wk "Create branch and checkout")
    "g c c" '(magit-commit-create :wk "Create commit")
    "g c f" '(magit-commit-fixup :wk "Create fixup commit")
    "g C" '(magit-clone :wk "Clone repo")
    "g f" '(:ignore t :wk "Find") 
    "g f c" '(magit-show-commit :wk "Show commit")
    "g f f" '(magit-find-file :wk "Magit find file")
    "g f g" '(magit-find-git-config-file :wk "Find gitconfig file")
    "g F" '(magit-fetch :wk "Git fetch")
    "g g" '(magit-status :wk "Magit status")
    "g i" '(magit-init :wk "Initialize git repo")
    "g l" '(magit-log-buffer-file :wk "Magit buffer log")
    "g r" '(vc-revert :wk "Git revert file")
    "g s" '(magit-stage-file :wk "Git stage file")
    "g t" '(git-timemachine :wk "Git time machine")
    "g u" '(magit-stage-file :wk "Git unstage file"))

 (dt/leader-keys
    "h" '(:ignore t :wk "Help")
    "h a" '(counsel-apropos :wk "Apropos")
    "h b" '(describe-bindings :wk "Describe bindings")
    "h c" '(describe-char :wk "Describe character under cursor")
    "h d" '(:ignore t :wk "Emacs documentation")
    "h d a" '(about-emacs :wk "About Emacs")
    "h d d" '(view-emacs-debugging :wk "View Emacs debugging")
    "h d f" '(view-emacs-FAQ :wk "View Emacs FAQ")
    "h d m" '(info-emacs-manual :wk "The Emacs manual")
    "h d n" '(view-emacs-news :wk "View Emacs news")
    "h d o" '(describe-distribution :wk "How to obtain Emacs")
    "h d p" '(view-emacs-problems :wk "View Emacs problems")
    "h d t" '(view-emacs-todo :wk "View Emacs todo")
    "h d w" '(describe-no-warranty :wk "Describe no warranty")
    "h e" '(view-echo-area-messages :wk "View echo area messages")
    "h f" '(describe-function :wk "Describe function")
    "h F" '(describe-face :wk "Describe face")
    "h g" '(describe-gnu-project :wk "Describe GNU Project")
    "h i" '(info :wk "Info")
    "h I" '(describe-input-method :wk "Describe input method")
    "h k" '(describe-key :wk "Describe key")
    "h l" '(view-lossage :wk "Display recent keystrokes and the commands run")
    "h L" '(describe-language-environment :wk "Describe language environment")
    "h m" '(describe-mode :wk "Describe mode")
    "h r" '(:ignore t :wk "Reload")
    "h r r" '((lambda () (interactive)
                (load-file (dt/in-emacs-dir "init.el"))
                (ignore (elpaca-process-queues)))
              :wk "Reload emacs config")
    "h t" '(load-theme :wk "Load theme")
    "h v" '(describe-variable :wk "Describe variable")
    "h w" '(where-is :wk "Prints keybinding for command if set")
    "h x" '(describe-command :wk "Display full documentation for command"))

  (dt/leader-keys
    "m" '(:ignore t :wk "Org")
    "m a" '(org-agenda :wk "Org agenda")
    "m e" '(org-export-dispatch :wk "Org export dispatch")
    "m i" '(org-toggle-item :wk "Org toggle item")
    "m t" '(org-todo :wk "Org todo")
    "m B" '(org-babel-tangle :wk "Org babel tangle")
    "m T" '(org-todo-list :wk "Org todo list"))

  (dt/leader-keys
    "m b" '(:ignore t :wk "Tables")
    "m b -" '(org-table-insert-hline :wk "Insert hline in table"))

  (dt/leader-keys
    "m d" '(:ignore t :wk "Date/deadline")
    "m d t" '(org-time-stamp :wk "Org time stamp"))

  (dt/leader-keys
    "o" '(:ignore t :wk "Open")
    "o d" '(dashboard-open :wk "Dashboard")
    "o e" '(elfeed :wk "Elfeed RSS")
    "o f" '(make-frame :wk "Open buffer in new frame")
    "o F" '(select-frame-by-name :wk "Select frame by name"))

  ;; projectile-command-map already has a ton of bindings 
  ;; set for us, so no need to specify each individually.
  (dt/leader-keys
    "p" '(projectile-command-map :wk "Projectile"))

  (dt/leader-keys
    "s" '(:ignore t :wk "Search")
    "s d" '(dictionary-search :wk "Search dictionary")
    "s m" '(man :wk "Man pages")
    "s t" '(tldr :wk "Lookup TLDR docs for a command")
    "s w" '(woman :wk "Similar to man but doesn't require man"))

  (dt/leader-keys
    "t" '(:ignore t :wk "Toggle")
    "t e" '(eshell-toggle :wk "Toggle eshell")
    "t f" '(flycheck-mode :wk "Toggle flycheck")
    "t l" '(display-line-numbers-mode :wk "Toggle line numbers")
    "t n" '(neotree-toggle :wk "Toggle neotree file viewer")
    "t o" '(org-mode :wk "Toggle org mode")
    "t r" '(rainbow-mode :wk "Toggle rainbow mode")
    "t t" '(visual-line-mode :wk "Toggle truncated lines")
    "t v" '(vterm-toggle :wk "Toggle vterm"))

  (dt/leader-keys
    "w" '(:ignore t :wk "Windows")
    ;; Window splits
    "w c" '(evil-window-delete :wk "Close window")
    "w n" '(evil-window-new :wk "New window")
    "w s" '(evil-window-split :wk "Horizontal split window")
    "w v" '(evil-window-vsplit :wk "Vertical split window")
    ;; Window motions
    "w h" '(evil-window-left :wk "Window left")
    "w j" '(evil-window-down :wk "Window down")
    "w k" '(evil-window-up :wk "Window up")
    "w l" '(evil-window-right :wk "Window right")
    "w w" '(evil-window-next :wk "Goto next window")
    ;; Move Windows
    "w H" '(buf-move-left :wk "Buffer move left")
    "w J" '(buf-move-down :wk "Buffer move down")
    "w K" '(buf-move-up :wk "Buffer move up")
    "w L" '(buf-move-right :wk "Buffer move right"))

  (dt/leader-keys
  "U" '(:ignore t :wk "Undo")
  "U v" '(undo-tree-visualize :wk "Undo tree"))
)

(use-package git-timemachine
  :after git-timemachine
  :hook (evil-normalize-keymaps . git-timemachine-hook)
  :config
    (evil-define-key 'normal git-timemachine-mode-map (kbd "C-j") 'git-timemachine-show-previous-revision)
    (evil-define-key 'normal git-timemachine-mode-map (kbd "C-k") 'git-timemachine-show-next-revision)
)

;; Make sure Transient is present and recent enough
(use-package transient
  :ensure t)

(use-package with-editor
  :ensure t)

(use-package magit
  :ensure t
  :after transient)

(use-package hl-todo
  :hook ((org-mode . hl-todo-mode)
         (prog-mode . hl-todo-mode))
  :config
  (setq hl-todo-highlight-punctuation ":"
        hl-todo-keyword-faces
        `(("TODO"       warning bold)
          ("FIXME"      error bold)
          ("HACK"       font-lock-constant-face bold)
          ("REVIEW"     font-lock-keyword-face bold)
          ("NOTE"       success bold)
          ("DEPRECATED" font-lock-doc-face bold))))

(use-package counsel
  :after ivy
  :diminish
  :config
  (counsel-mode)
  (setq ivy-initial-inputs-alist nil) ;; removes starting ^ regex in M-x

  ;; 1) Make sure Emacs doesn't start life with default-directory = "/"
  (setq default-directory (expand-file-name "~"))

  ;; 2) Counsel uses `find` for file jumping; silence permission denied spam
  ;;    (and avoid walking into VCS metadata).
  (setq counsel-file-jump-args
        "find . -name .git -prune -o -type f -print 2>/dev/null")

;; Silence permission-denied spam from `find` used by counsel file-jump/occur.
  ;; This command IS executed by a shell, so redirections work here.
  (setq counsel-find-file-occur-cmd
        "find . -name .git -prune -o -type f -print 2>/dev/null | head -n 20000"))

(use-package ivy
  :bind
  ;; ivy-resume resumes the last Ivy-based completion.
  (("C-c C-r" . ivy-resume)
   ("C-x B" . ivy-switch-buffer-other-window))
  :diminish
  :custom
  (setq ivy-use-virtual-buffers t)
  (setq ivy-count-format "(%d/%d) ")
  (setq enable-recursive-minibuffers t)
  :config
  (ivy-mode))

(use-package all-the-icons-ivy-rich
  :ensure t
  :init (all-the-icons-ivy-rich-mode 1))

(use-package ivy-rich
  :after ivy
  :ensure t
  :init (ivy-rich-mode 1) ;; this gets us descriptions in M-x.
  :custom
  (ivy-virtual-abbreviate 'full
   ivy-rich-switch-buffer-align-virtual-buffer t
   ivy-rich-path-style 'abbrev)
  :config
  (ivy-set-display-transformer 'ivy-switch-buffer
                               'ivy-rich-switch-buffer-transformer))

(use-package haskell-mode)
(use-package lua-mode)
(use-package php-mode)

(use-package evil-commentary
  :after evil
  :diminish
  :config
  (evil-commentary-mode))

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :config
  (setq doom-modeline-height 35      ;; sets modeline height
        doom-modeline-bar-width 5    ;; sets right bar width
        doom-modeline-persp-name t   ;; adds perspective name to modeline
        doom-modeline-persp-icon t)) ;; adds folder icon next to persp name

(use-package neotree
  :config
  (setq neo-smart-open t
        neo-show-hidden-files t
        neo-window-width 55
        neo-window-fixed-size nil
        inhibit-compacting-font-caches t
        projectile-switch-project-action 'neotree-projectile-action) 
        ;; truncate long file names in neotree
        (add-hook 'neo-after-create-hook
           #'(lambda (_)
               (with-current-buffer (get-buffer neo-buffer-name)
                 (setq truncate-lines t)
                 (setq word-wrap nil)
                 (make-local-variable 'auto-hscroll-mode)
                 (setq auto-hscroll-mode nil)))))

(use-package toc-org
    :commands toc-org-enable
    :init (add-hook 'org-mode-hook 'toc-org-enable))

(add-hook 'org-mode-hook 'org-indent-mode)
(use-package org-bullets)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))

(eval-after-load 'org-indent '(diminish 'org-indent-mode))

(custom-set-faces
 '(org-level-1 ((t (:inherit outline-1 :height 1.7))))
 '(org-level-2 ((t (:inherit outline-2 :height 1.6))))
 '(org-level-3 ((t (:inherit outline-3 :height 1.5))))
 '(org-level-4 ((t (:inherit outline-4 :height 1.4))))
 '(org-level-5 ((t (:inherit outline-5 :height 1.3))))
 '(org-level-6 ((t (:inherit outline-5 :height 1.2))))
 '(org-level-7 ((t (:inherit outline-5 :height 1.1)))))

(require 'org-tempo)

(use-package perspective
  :custom
  ;; NOTE! I have also set 'SCP =' to open the perspective menu.
  ;; I'm only setting the additional binding because setting it
  ;; helps suppress an annoying warning message.
  (persp-mode-prefix-key (kbd "C-c M-p"))
  :init 
  (persp-mode)
  :config
  ;; Sets a file to write to when we save states
  (setq persp-state-default-file (dt/in-emacs-dir "sessions")))

;; This will group buffers by persp-name in ibuffer.
(add-hook 'ibuffer-hook
          (lambda ()
            (persp-ibuffer-set-filter-groups)
            (unless (eq ibuffer-sorting-mode 'alphabetic)
              (ibuffer-do-sort-by-alphabetic))))

;; Automatically save perspective states to file when Emacs exits.
(add-hook 'kill-emacs-hook #'persp-state-save)

(use-package projectile
  :config
  (projectile-mode 1))

(use-package rainbow-delimiters
  :hook ((emacs-lisp-mode . rainbow-delimiters-mode)
         (clojure-mode . rainbow-delimiters-mode)))

(use-package rainbow-mode
  :diminish
  :hook ((org-mode . rainbow-mode)
         (prog-mode . rainbow-mode)
         (css-mode . rainbow-mode)
         (html-mode . rainbow-mode)
         (conf-mode . rainbow-mode)))

(delete-selection-mode 1)    ;; You can select text and delete it by typing.
(electric-indent-mode 1)    ;; Turn off the weird indenting that Emacs does by default.
(electric-pair-mode -1)       ;; Turns on automatic parens pairing
;; The following prevents <> from auto-pairing when electric-pair-mode is on.
;; Otherwise, org-tempo is broken when you try to <s TAB...
(add-hook 'org-mode-hook (lambda ()
           (setq-local electric-pair-inhibit-predicate
                   `(lambda (c)
                  (if (char-equal c ?<) t (,electric-pair-inhibit-predicate c))))))
(global-auto-revert-mode t)  ;; Automatically show changes if the file has changed
(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode 1) ;; Display line numbers
(global-visual-line-mode t)  ;; Enable truncated lines
(menu-bar-mode -1)           ;; Disable the menu bar 
(scroll-bar-mode -1)         ;; Disable the scroll bar
(tool-bar-mode -1)           ;; Disable the tool bar
(setq org-edit-src-content-indentation 0) ;; Set src block automatic indent to 0 instead of 2.
(setq-default tab-width 4)
(setq-default indent-tabs-mode nil)

(use-package eshell-toggle
  :custom
  (eshell-toggle-size-fraction 3)
  (eshell-toggle-use-projectile-root t)
  (eshell-toggle-run-command nil)
  (eshell-toggle-init-function #'eshell-toggle-init-ansi-term))

  (use-package eshell-syntax-highlighting
    :after esh-mode
    :config
    (eshell-syntax-highlighting-global-mode +1))

  ;; eshell-syntax-highlighting -- adds fish/zsh-like syntax highlighting.
  ;; eshell-rc-script -- your profile for eshell; like a bashrc for eshell.
  ;; eshell-aliases-file -- sets an aliases file for the eshell.

  (setq eshell-rc-script (concat user-emacs-directory "eshell/profile")
        eshell-aliases-file (concat user-emacs-directory "eshell/aliases")
        eshell-history-size 5000
        eshell-buffer-maximum-lines 5000
        eshell-hist-ignoredups t
        eshell-scroll-to-bottom-on-input t
        eshell-destroy-buffer-when-process-dies t
        eshell-visual-commands'("bash" "fish" "htop" "ssh" "top" "zsh"))

(use-package vterm
  :commands vterm
  :config
  ;; Match your normal terminal
  (setq vterm-shell "/bin/zsh"
        vterm-shell-args '("-l")     ;; login shell → same zsh config as your terminal
        vterm-max-scrollback 5000)

  ;; If your vterm build supports it, tell vterm to let Emacs handle these keys.
  (when (boundp 'vterm-keymap-exceptions)
    (dolist (k '("C-y" "M-W"))
      (add-to-list 'vterm-keymap-exceptions k)))

  ;; Bind keys in vterm buffers
  (add-hook 'vterm-mode-hook
            (lambda ()
              ;; Paste
              (define-key vterm-mode-map (kbd "C-y") #'vterm-yank)

              ;; Copy (region must be active)
              (define-key vterm-mode-map (kbd "M-W") #'kill-ring-save)

              ;; Keep bindings consistent under Evil
              (when (bound-and-true-p evil-mode)
                (evil-define-key '(normal insert visual) vterm-mode-map
                  (kbd "C-y") #'vterm-yank
                  (kbd "M-W") #'kill-ring-save)))))

(use-package vterm-toggle
  :after vterm
  :config
  ;; In vterm, make ESC send ESC to the terminal even under Evil.
  (with-eval-after-load 'vterm
    (when (fboundp 'vterm-send-escape)
      (evil-define-key '(normal insert) vterm-mode-map
        (kbd "<escape>") #'vterm-send-escape)))

  (setq vterm-toggle-fullscreen-p nil
        vterm-toggle-scope 'project))

(use-package sudo-edit)

(add-to-list 'custom-theme-load-path (dt/in-emacs-dir "themes/"))

(use-package doom-themes
  :config
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled
  ;; Sets the default theme to load!!! 
  (load-theme 'doom-one t)
  ;; Enable custom neotree theme (all-the-icons must be installed!)
  (doom-themes-neotree-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

(use-package tldr)

(add-to-list 'default-frame-alist '(alpha-background . 100)) ; For all new frames henceforth

;; -------------------------
;; OCaml (Tuareg + Merlin + ocp-indent + ocamlformat)
;; Fish + Arch + opam safe setup
;; -------------------------

;; --------------------------------------------------
;; Ensure opam binaries are on Emacs PATH
;; --------------------------------------------------
(let* ((opam-bin (expand-file-name "~/.opam/default/bin")))
  (when (file-directory-p opam-bin)
    (add-to-list 'exec-path opam-bin)
    (setenv "PATH" (concat opam-bin path-separator (getenv "PATH")))))

;; --------------------------------------------------
;; Tuareg mode
;; --------------------------------------------------
(use-package tuareg
  :mode (("\\.ml\\'"  . tuareg-mode)
         ("\\.mli\\'" . tuareg-mode)
         ("\\.mll\\'" . tuareg-mode)
         ("\\.mly\\'" . tuareg-mode)))

;; --------------------------------------------------
;; ocp-indent (indentation engine)
;; Falls back to tuareg indentation if not found
;; --------------------------------------------------
(use-package ocp-indent
  :after tuareg
  :hook (tuareg-mode . (lambda ()
                         (setq-local indent-tabs-mode nil)
                         (if (executable-find "ocp-indent")
                             (setq-local indent-line-function #'ocp-indent-line)
                           (setq-local indent-line-function #'tuareg-indent-command)
                           (message "ocp-indent not found; using tuareg indentation")))))

;; --------------------------------------------------
;; Merlin (IDE features)
;; --------------------------------------------------
(use-package merlin
  :after tuareg
  :hook (tuareg-mode . merlin-mode)
  :custom
  (merlin-command "ocamlmerlin")
  (merlin-completion-with-doc t)
  :config
  (unless (executable-find "ocamlmerlin")
    (message "merlin: ocamlmerlin not found on PATH (fish: opam env --shell=fish | source)")))

;; --------------------------------------------------
;; ocamlformat (format on save, optional)
;; --------------------------------------------------
(use-package ocamlformat
  :after tuareg
  :hook (tuareg-mode . (lambda ()
                         (when (executable-find "ocamlformat")
                           (add-hook 'before-save-hook
                                     #'ocamlformat-before-save
                                     nil t))))
  :config
  (unless (executable-find "ocamlformat")
    (message "ocamlformat: binary not found on PATH (install via opam)")))

;; --------------------------------------------------
;; Fix TAB indentation (you globally unbound TAB in evil)
;; --------------------------------------------------
(with-eval-after-load 'tuareg
  (define-key tuareg-mode-map (kbd "TAB") #'indent-for-tab-command)
  (define-key tuareg-mode-map (kbd "<tab>") #'indent-for-tab-command)

  (with-eval-after-load 'evil
    (evil-define-key '(normal insert)
      tuareg-mode-map
      (kbd "TAB") #'indent-for-tab-command
      (kbd "<tab>") #'indent-for-tab-command)))

(use-package which-key
  :init
    (which-key-mode 1)
  :diminish
  :config
  (setq which-key-side-window-location 'bottom
	  which-key-sort-order #'which-key-key-order-alpha
	  which-key-allow-imprecise-window-fit nil
	  which-key-sort-uppercase-first nil
	  which-key-add-column-padding 1
	  which-key-max-display-columns nil
	  which-key-min-display-lines 6
	  which-key-side-window-slot -10
	  which-key-side-window-max-height 0.25
	  which-key-idle-delay 0.8
	  which-key-max-description-length 25
	  which-key-allow-imprecise-window-fit nil
	  which-key-separator " → " ))
