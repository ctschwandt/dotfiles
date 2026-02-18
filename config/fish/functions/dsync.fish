function dsync --description "Sync selected dotfiles into ~/projects/dotfiles and push. Usage: dsync [--force|-f] [--msg|-m MESSAGE]"
    set -l repo "$HOME/projects/dotfiles"
    set -l src  "$HOME/.config"
    set -l dst  "$repo/config"

    # ---- args ----
    set -l do_force 0
    set -l msg ""
    set -l i 1
    while test $i -le (count $argv)
        switch $argv[$i]
            case --force -f
                set do_force 1
            case --msg -m
                set i (math $i + 1)
                if test $i -le (count $argv)
                    set msg $argv[$i]
                end
            case '*'
                # ignore unknown args
        end
        set i (math $i + 1)
    end

    if test -z "$msg"
        set msg "dsync: update dotfiles"
    end

    # ---- sanity checks ----
    if not test -d "$repo/.git"
        echo "ERROR: $repo is not a git repo."
        echo "Fix: mkdir -p ~/projects; and cd ~/projects; and git clone git@github.com:ctschwandt/dotfiles.git dotfiles"
        return 1
    end

    if not test -d "$src"
        echo "ERROR: missing source config dir: $src"
        return 1
    end

    mkdir -p "$dst"

    # ---- allowlist of things to sync ----
    set -l dirs \
        hypr \
        illogical-impulse \
        quickshell \
        rofi \
        wlogout \
        kitty \
        foot \
        fish \
        zshrc.d \
        emacs \
        btop \
        mpv \
        fontconfig \
        gtk-3.0 \
        gtk-4.0 \
        xdg-desktop-portal \
        systemd \
        Kvantum \
        matugen \
        kde-material-you-colors

    set -l files starship.toml

    echo "Syncing into: $repo"
    echo "From: $src"
    echo

    # ---- copy dirs ----
    for name in $dirs
        set -l s "$src/$name"
        set -l d "$dst/$name"
        if test -d "$s"
            rm -rf "$d"
            cp -a "$s" "$d"
            echo "OK   dir  $name"
        else
            echo "SKIP dir  $name (missing in $src)"
        end
    end

    # ---- copy files ----
    for name in $files
        set -l s "$src/$name"
        set -l d "$dst/$name"
        if test -f "$s"
            cp -a "$s" "$d"
            echo "OK   file $name"
        else
            echo "SKIP file $name (missing in $src)"
        end
    end

    echo
    cd "$repo"; or return 1

    git add -A

    # Commit only if there are changes
    set -l changes (git status --porcelain)
    if test -z "$changes"
        echo "No changes to commit."
    else
        git commit -m "$msg"
    end

    # Push (force only if requested)
    if test $do_force -eq 1
        echo "Pushing with --force-with-lease..."
        git push --force-with-lease origin main
    else
        echo "Pushing normally..."
        git push origin main
    end
end