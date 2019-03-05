PROJECT = clap-counter

build:
	stack build

server:
	stack build --exec $(PROJECT)
