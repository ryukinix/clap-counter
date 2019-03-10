FROM haskell:8.4
WORKDIR /app
COPY . .
RUN stack setup
RUN make build
RUN make dist
EXPOSE 3000
ENTRYPOINT ["/app/bin/clap-counter"]
