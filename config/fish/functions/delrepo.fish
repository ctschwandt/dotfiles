function delrepo
    set -l repo (command gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null)
    if test -z "$repo"
        echo "Not inside a git repository"
        return 1
    end

    echo "About to DELETE GitHub repository:"
    echo "  $repo"
    echo
    read -P "Type the repo name to confirm deletion: " confirm

    if test "$confirm" != "$repo"
        echo "Confirmation failed. Aborting."
        return 1
    end

    command gh repo delete "$repo"
end
