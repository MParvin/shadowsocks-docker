FROM golang:alpine3.19 as builder

RUN apk update && apk add --no-cache git

WORKDIR /src

RUN git clone https://github.com/MParvin/go-shadowsocks2.git .

RUN go mod tidy

RUN go build -o /app/go-shadowsocks2 .

FROM alpine:3.19

COPY --from=builder /app/go-shadowsocks2 /app/go-shadowsocks2

CMD ["/app/go-shadowsocks2"]