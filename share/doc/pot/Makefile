# Minimal makefile for Sphinx documentation
#

# pot.7 will be generated together with pot.8

all: _build/man/pot.8

# You can set these variables from the command line.
SPHINXOPTS    =
SPHINXBUILD   = sphinx-build
SPHINXPROJ    = pot
SOURCEDIR     = .
BUILDDIR      = _build
SRC7 = Description.md Images.md index.md Installation.md QuickStart.md Synopsis.md
SRC8 = pot.md pot-Synopsis.md

help:
	$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

_build/man/pot.8: Makefile conf.py $(SRC7) $(SRC8)
	$(SPHINXBUILD) -M man "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)
	sed -i "" 's/\ep$$/\p/g' _build/man/pot.8

view7: _build/man/pot.8
	man _build/man/pot.7

view: _build/man/pot.8
	man _build/man/pot.8
