# Edit this for your own project dependencies
OPAM_DEPENDS="ocamlfind incremental ppx_driver=v0.9.2 ppx_jane=v0.9.0 ounit re ezirmin jbuilder core ocaml-migrate-parsetree"
	 
# echo "yes" | sudo add-apt-repository ppa:avsm/ppa

wget https://raw.github.com/ocaml/opam/master/shell/opam_installer.sh -O - | sh -s /usr/local/bin

# sudo apt-get update
# sudo apt-get install ocaml ocaml-native-compilers camlp4-extra opam

export OPAMYES=1
opam init

# opam install ocaml
# opam switch 4.05.0

opam install ${OPAM_DEPENDS}
eval `opam config env`

#ocamlfind list

make
