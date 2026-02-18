# -------------------------
# makefile
# -------------------------
e exe:
	ocamlc -c Print.ml
	ocamlc -I . -c main.ml
	ocamlc -I . -o main.exe Print.cmo main.cmo

r run: e
	./main.exe

c clean:
	rm -f *.cmi *.cmo main.exe
	rm -rf _build
