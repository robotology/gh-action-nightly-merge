#!/bin/bash

set -e

if [[ -z "$GITHUB_TOKEN" ]]; then
  echo "Set the GITHUB_TOKEN env variable."
  exit 1
fi

# FIXME these should be configurable
STABLE_BRANCH=master
DEVELOPMENT_BRANCH=devel

# FIXME: check that this is the main repository and not a fork

echo "https://x-access-token:GITHUB_TOKEN@github.com/$GITHUB_REPOSITORY.git"

git remote set-url origin https://x-access-token:$GITHUB_TOKEN@github.com/$GITHUB_REPOSITORY.git
git config --global user.email "actions@github.com"
git config --global user.name "GitHub Merge Action"

set -o xtrace

git fetch origin $STABLE_BRANCH
git checkout -b $STABLE_BRANCH origin/$STABLE_BRANCH
git log -1 --pretty=oneline $STABLE_BRANCH

git fetch origin $DEVELOPMENT_BRANCH
git checkout -b $DEVELOPMENT_BRANCH origin/$DEVELOPMENT_BRANCH
git log -1 --pretty=oneline $DEVELOPMENT_BRANCH

if git merge-base --is-ancestor $STABLE_BRANCH $DEVELOPMENT_BRANCH; then
  echo "No merge is necessary"
  exit 0
fi;

# do the merge
# FIXME "--no-ff should be configurable"
git merge --no-ff --no-edit $STABLE_BRANCH
git push --force-with-lease origin $DEVELOPMENT_BRANCH
