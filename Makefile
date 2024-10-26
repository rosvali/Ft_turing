NAME = ft_turing

# Order matters, no way to escape the interperter :()
SRCS = srcs/Types.ml srcs/Parsing.ml srcs/Display.ml srcs/Turing.ml srcs/main.ml
SRCS_OBJS_NATIVE = $(SRCS:.ml=.cmx)
SRCS_OBJS_INTERP = $(SRCS:.ml=.cmo)

INTERFACES = 
INTERFACES_OBJS = $(INTERFACES:.mli=.cmi)

PKGFLAGS = -package yojson,spectrum,core
LINKFLAGS = -linkpkg

all : native

native: setup_linux $(INTERFACES_OBJS) $(SRCS_OBJS_NATIVE) 
	@echo "..........native linking........"
	eval `opam env` && ocamlfind ocamlopt $(PKGFLAGS) $(LINKFLAGS) -o $(NAME) $(SRCS_OBJS_NATIVE) -I srcs
	$(MAKE) clean

# Note: run eval `opam config env` when loading interp for linux
interp: setup_linux $(INTERFACES_OBJS) $(SRCS_OBJS_INTERP)
	@echo "..........interp linking........"
	eval `opam env` && ocamlfind ocamlc $(PKGFLAGS) $(LINKFLAGS) -o $(NAME) $(SRCS_OBJS_INTERP) -I srcs
	$(MAKE) clean

setup_linux:  #linux with apt
	hash -r
	type ocaml || sudo apt install -y ocaml-interp

	hash -r
	type opam || \
		(sudo apt install -y opam &&\
		opam init -y)

	hash -r 
	eval `opam env` && opam -y install yojson spectrum core

.SUFFIXES:
.SUFFIXES: .ml .mli .cmo .cmi .cmx

.ml.cmx : 
	@echo "..........native compiling........"
	eval `opam env` && ocamlfind ocamlopt  $(PKGFLAGS) -c $< -I srcs

.ml.cmo : 
	@echo "..........interp compiling........"
	eval `opam env` && ocamlfind ocamlc  $(PKGFLAGS) -c  $< -I srcs

.mli.cmi :
	@echo "..........compiling headers........"
	ocamlc -c $< -I srcs

clean : 
	rm -f srcs/*.o srcs/*.cmx srcs/*.cmi srcs/*.cmo

fclean : clean
	rm -f $(NAME)

re : re_na

re_int : fclean interp

re_na : fclean native