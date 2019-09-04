FROM alpine:latest

LABEL repository="http://github.com/robotology/gh-action-nightly-merge"
LABEL homepage="http://github.com/robotology/gh-action-nightly-merge"

RUN apk --no-cache add bash git

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
