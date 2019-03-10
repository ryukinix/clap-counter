FROM haskell:8.4
WORKDIR /app
ADD package.yaml .
ADD stack.yaml .
RUN stack setup
COPY . .
RUN make build
RUN make dist
EXPOSE 3000
ENTRYPOINT ["/app/bin/clap-counter"]
