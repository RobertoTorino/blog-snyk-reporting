FROM docker.io/library/alpine:14
LABEL version="1.0"
LABEL description="demo"

RUN apk update && apk upgrade
RUN apk add --no-cache maven
