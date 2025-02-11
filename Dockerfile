FROM debian:11.6-slim as builder

WORKDIR /app

RUN apt update
RUN apt install curl unzip -y

RUN curl https://bun.sh/install | bash

COPY package.json .
COPY bun.lockb .
COPY prisma prisma

RUN /root/.bun/bin/bun install
RUN /root/.bun/bin/bun prisma generate

# ? -------------------------
FROM gcr.io/distroless/base

WORKDIR /app

COPY --from=builder /root/.bun/bin/bun bun
COPY --from=builder /app/node_modules node_modules

COPY src src
COPY tsconfig.json .
# COPY public public

ENV NODE_ENV production
CMD ["./bun", "src/index.ts"]

EXPOSE 9000
