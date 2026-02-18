# Environment
set -gx EDITOR "emacsclient -n"
set -gx VISUAL "emacsclient -c -n"

umask 077

set -gx LS_COLORS 'di=1;34:fi=0:ln=31:pi=5:so=5:bd=1;34:cd=5:or=31:mi=0:ex=35:ow=1;34'

# opam (fish-compatible)
if type -q opam
    eval (opam env --shell=fish)
end