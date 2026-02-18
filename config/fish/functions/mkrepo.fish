function mkrepo
    function usage
        echo "usage:"
        echo "  mkrepo <repo-name>"
        echo "  mkrepo <repo-name> <cpp|py|ocaml>"
        echo "  mkrepo <repo-name> <cpp|py|ocaml> [public|private|pub|priv|pu|pr|p]"
        return 1
    end

    set -l argc (count $argv)
    if test $argc -lt 1 -o $argc -gt 3
        usage; return 1
    end

    set -l name $argv[1]
    set -l visibility private
    set -l gitignore ""

    if test $argc -ge 2
        switch $argv[2]
            case cpp
                set gitignore "C++"
            case py
                set gitignore "Python"
            case ocaml
                set gitignore "OCaml"
            case public pub pu private priv pri pr p
            case "*"
                usage; return 1
        end
    end

    if test $argc -ge 2
        set -l last $argv[-1]
        switch $last
            case private priv pri pr p
                set visibility private
            case public pub pu
                set visibility public
        end
    end

    set -l cmd gh repo create "$name" --$visibility --clone --add-readme --license MIT
    if test -n "$gitignore"
        set cmd $cmd --gitignore "$gitignore"
    end

    command $cmd
    cd "$name"; or return
end
