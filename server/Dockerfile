# Cloud Run 用のイメージ。server/ をビルドコンテキストにする:
#   gcloud run deploy iterinerary-api --source server ...
FROM golang:1.26 AS build
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /out/api ./cmd/server

# CA 証明書を含む最小のイメージ。root ではないユーザーで動かす。
FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=build /out/api /api
ENV PORT=8080
EXPOSE 8080
ENTRYPOINT ["/api"]
