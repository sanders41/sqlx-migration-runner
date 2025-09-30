FROM rust:1-alpine3.22 AS builder

RUN apk add --no-cache \
    build-base \
    openssl-dev \
    openssl-libs-static \
    pkgconfig

RUN cargo install sqlx-cli --no-default-features -F native-tls -F postgres


FROM alpine:3.22 AS runner

COPY --from=builder /usr/local/cargo/bin/sqlx /usr/local/bin/sqlx

CMD ["/bin/sh", "-c", "/usr/local/bin/sqlx database create && /usr/local/bin/sqlx migrate run"]
