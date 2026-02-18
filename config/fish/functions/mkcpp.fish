function mkcpp
    set -l dir $argv[1]
    if test -z "$dir"
        echo "Usage: mkcpp <dir>"
        return 1
    end
    set -l tpl "$HOME/.config/fish/templates/cpp"
    mkdir -p "$dir"; or return 1
    cp -a "$tpl/." "$dir/"; or return 1
    cd "$dir"
end
