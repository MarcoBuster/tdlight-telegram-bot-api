FROM alpine:3.12 as build

RUN apk add --no-cache --update alpine-sdk linux-headers git zlib-dev openssl-dev gperf cmake

WORKDIR /usr/src/telegram-bot-api

COPY CMakeLists.txt /usr/src/telegram-bot-api
COPY docker-entrypoint.sh /usr/src/telegram-bot-api
ADD td /usr/src/telegram-bot-api/td
ADD telegram-bot-api /usr/src/telegram-bot-api/telegram-bot-api

RUN mkdir -p build \
 && cd build \
 && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=.. .. \
 && cmake --build . --target install -j $(nproc) \
 && strip /usr/src/telegram-bot-api/bin/telegram-bot-api

FROM alpine:3.12

RUN apk --no-cache add libstdc++ curl

COPY --from=builder /usr/local/bin/telegram-bot-api /usr/local/bin/telegram-bot-api
COPY docker-entrypoint.sh /docker-entrypoint.sh

HEALTHCHECK CMD curl -f http://localhost:8082/ || exit 1

ENTRYPOINT ["/docker-entrypoint.sh"]
