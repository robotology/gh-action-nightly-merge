FROM alpine:latest

LABEL repository="http://github.com/robotology/gh-action-nightly-merge"
LABEL homepage="http://github.com/robotology/gh-action-nightly-merge"
LABEL "com.github.actions.name"="Nightly Merge"
LABEL "com.github.actions.description"="Automatically merge the stable branch into the development one."
LABEL "com.github.actions.icon"="git-merge"
LABEL "com.github.actions.color"="orange"

RUN apk --no-cache add bash curl git jq

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
