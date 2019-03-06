PROJECT = clap-counter
BIN = bin/
GMP = lib/libgmp.a
GMP_REMOTE = server.lerax.me/archive/libgmp.a
REMOTE =  lerax@server.lerax.me:clap-counter/

build:
	stack build

serve:
	stack build --exec $(PROJECT)

deps:
	@mkdir -p lib
	[ ! -f $(GMP) ] && wget $(GMP_REMOTE) -O $(GMP) || true

dist: deps
	mkdir -p $(BIN)
	stack --local-bin-path $(BIN) install

deploy: dist
	rsync -ra -e ssh bin/clap-counter $(REMOTE)
