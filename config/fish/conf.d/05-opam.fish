set -gx OPAM_LAST_ENV '/home/ctschwandt/.opam/.last-env/env-8a0c4e52d49bb311c723fcdf630ddc70-0';
set -gx OPAM_SWITCH_PREFIX '/home/ctschwandt/.opam/default';
set -gx OCAMLTOP_INCLUDE_PATH '/home/ctschwandt/.opam/default/lib/toplevel';
set -gx CAML_LD_LIBRARY_PATH '/home/ctschwandt/.opam/default/lib/stublibs:/home/ctschwandt/.opam/default/lib/ocaml/stublibs:/home/ctschwandt/.opam/default/lib/ocaml';
set -gx OCAML_TOPLEVEL_PATH '/home/ctschwandt/.opam/default/lib/toplevel';
builtin -n | /bin/sh -c 'grep -q \'^argparse$\'' 1>/dev/null 2>/dev/null; and set -gx MANPATH ':/home/ctschwandt/.opam/default/man';
set -gx PATH '/home/ctschwandt/.opam/default/bin' '/usr/local/sbin' '/usr/local/bin' '/usr/bin' '/usr/bin/site_perl' '/usr/bin/vendor_perl' '/usr/bin/core_perl';
