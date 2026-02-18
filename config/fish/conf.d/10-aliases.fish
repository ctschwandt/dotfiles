# Clear fix for kitty
alias clear "printf '\033[2J\033[3J\033[1;1H'"
alias celar "printf '\033[2J\033[3J\033[1;1H'"
alias claer "printf '\033[2J\033[3J\033[1;1H'"

# ls
alias ls 'eza --icons'
alias l  'ls -l'
alias la 'ls -a'
alias lla 'ls -la'
alias lt 'ls --tree'

# xdg-open
alias open "xdg-open"
alias o "xdg-open"
alias gnome-open "xdg-open"

alias emacs "command emacs"
alias m "make"

alias t "x-tile g 3 3"
alias t2 "x-tile g 2 2"
alias t3 "x-tile g 3 3"

alias q "qs -c ii"
alias pamcan "pacman"

# Emacs client shortcuts (default daemon)
alias x  'emacsclient -c -n -a ""'
alias e  'emacsclient -c -n -a ""'
alias xd 'emacsclient -c -n -a "emacs --debug-init --daemon"'
