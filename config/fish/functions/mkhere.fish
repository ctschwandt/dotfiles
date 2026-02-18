function mkhere
    set -l name (basename "$PWD")
    command git rev-parse --is-inside-work-tree >/dev/null 2>&1
    or command git init; or return 1
    command gh auth status >/dev/null 2>&1
    or begin
        echo "GitHub CLI not authenticated"
        return 1
    end
    command gh repo create "$name" --private --source=. --remote=origin; or return 1
    echo "✓ GitHub repo created:"
    echo "  https://github.com/ctschwandt/$name"
    command git add -A
    command git commit -m "init"
    command git push -u origin main
end
