# clap-counter

This software is a service which count likes in a website. It is  as a
_like counter_ so to speak.

It serves everything in a REST API which has two rules:

``` html
GET v1/claps/<url>
POST v1/claps/<url>
```

The GET request returns the number of claps of `<url>` sent and the POST
request adds 1 on the number of claps of `<url>`.

# Installing and executing

To build the software the (stack)[] is used. The tool will automatically
download every dependency of the project using cabal and the haskell
repository.

After installing the _stack_ you may use the Makefile to build and execute the
project. Use the **build** rule to build and the **serve** rule to serve the
server which will count likes depending on the request made to the website.

# Docker

The dockerfile will be implemented soon and will be available on the docker hub.
