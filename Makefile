PROJECT = clap-counter
BIN = bin/
BIN_ABS = $(shell pwd)/$(BIN)
GMP = lib/libgmp.a
GMP_REMOTE = server.lerax.me/archive/libgmp.a
SSH = lerax@server.lerax.me
REMOTE =  $(SSH):clap-counter/

build:
	stack build

serve:
	stack build --exec $(PROJECT)

deps:
	@mkdir -p lib
	[ ! -f $(GMP) ] && curl -sL $(GMP_REMOTE) -O $(GMP) || true

dist: deps
	mkdir -p $(BIN)
	stack --local-bin-path $(BIN) install

deploy: dist
	rsync -P -ra -e ssh bin/clap-counter $(REMOTE)
	ssh $(SSH) -t sudo systemctl restart clap-counter

docker-build:
	docker build -t $(PROJECT) .

docker-serve:
	docker run -it --network=host $(PROJECT)


docker-dist:
	mkdir -p $(BIN)
	docker run -it -v $(BIN_ABS):/app/$(BIN) --entrypoint=make $(PROJECT) dist
