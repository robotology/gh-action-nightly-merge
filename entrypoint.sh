#!/bin/bash

set -e

if [[ -z "$GITHUB_TOKEN" ]]; then
  echo "Set the GITHUB_TOKEN env variable."
  exit 1
fi

echo "Nightly merge is using the following input:"
echo "  - stable_branch = '$INPUT_STABLE_BRANCH'"
echo "  - development_branch = '$INPUT_DEVELOPMENT_BRANCH'"
echo "  - allow_ff = '$INPUT_ALLOW_FF'"

NO_FF="--no-ff"
if $INPUT_ALLOW_FF; then
  NO_FF=""
fi

# FIXME: check that this is the main repository and not a fork

git remote set-url origin https://x-access-token:$GITHUB_TOKEN@github.com/$GITHUB_REPOSITORY.git
git config --global user.email "actions@github.com"
git config --global user.name "GitHub Merge Action"

set -o xtrace

git fetch origin $INPUT_STABLE_BRANCH
git checkout -b $INPUT_STABLE_BRANCH origin/$INPUT_STABLE_BRANCH

git fetch origin $INPUT_DEVELOPMENT_BRANCH
git checkout -b $INPUT_DEVELOPMENT_BRANCH origin/$INPUT_DEVELOPMENT_BRANCH

if git merge-base --is-ancestor $INPUT_STABLE_BRANCH $INPUT_DEVELOPMENT_BRANCH; then
  echo "No merge is necessary"
  exit 0
fi;

set +o xtrace
echo "Nightly merge is trying to merge the following commit ($INPUT_STABLE_BRANCH):"
git log -1 --pretty=oneline $INPUT_STABLE_BRANCH
echo "into ($INPUT_DEVELOPMENT_BRANCH)"
git log -1 --pretty=oneline $INPUT_DEVELOPMENT_BRANCH

set -o xtrace

# Do the merge
git merge $NO_FF --no-edit $INPUT_STABLE_BRANCH

# Push the branch
git push --force-with-lease origin $INPUT_DEVELOPMENT_BRANCH
