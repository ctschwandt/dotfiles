function sync
    command git rev-parse --is-inside-work-tree >/dev/null 2>&1
    or begin
        echo "Not in a Git repository."
        return 1
    end
    set -l msg (string join " " $argv)
    if test -z "$msg"
        set msg "sync"
    end
    command git add .
    command git diff --cached --quiet
    if test $status -eq 0
        echo "Nothing to commit."
        return 0
    end
    command git commit -m "$msg"
    command git push
end
