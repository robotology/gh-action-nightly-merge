#!/bin/bash

set -e

if [[ -z "$GITHUB_TOKEN" ]]; then
  echo "Set the GITHUB_TOKEN env variable."
  exit 1
fi

echo
echo "  'Nightly Merge Action' is using the following input:"
echo "    - stable_branch = '$INPUT_STABLE_BRANCH'"
echo "    - development_branch = '$INPUT_DEVELOPMENT_BRANCH'"
echo "    - allow_ff = $INPUT_ALLOW_FF"
echo "    - allow_forks = $INPUT_ALLOW_FORKS"
echo

NO_FF="--no-ff"
if $INPUT_ALLOW_FF; then
  NO_FF=""
fi

if ! $INPUT_ALLOW_FORKS; then
  URI=https://api.github.com
  API_HEADER="Accept: application/vnd.github.v3+json"
  AUTH_HEADER="Authorization: token $GITHUB_TOKEN"
  pr_resp=$(curl -X GET -s -H "${AUTH_HEADER}" -H "${API_HEADER}" "${URI}/repos/$GITHUB_REPOSITORY")
  if [[ "$(echo "$pr_resp" | jq -r .fork)" != "false" ]]; then
    echo "Nightly merge action is disabled for forks (use the 'allow_forks' option to enable it)."
    exit 0
  fi
fi

git remote set-url origin https://x-access-token:$GITHUB_TOKEN@github.com/$GITHUB_REPOSITORY.git
git config --global user.email "actions@github.com"
git config --global user.name "GitHub Nightly Merge Action"

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
echo
echo "  'Nightly Merge Action' is trying to merge the '$INPUT_STABLE_BRANCH' branch ($(git log -1 --pretty=%H $INPUT_STABLE_BRANCH))"
echo "  into the '$INPUT_DEVELOPMENT_BRANCH' branch ($(git log -1 --pretty=%H $INPUT_DEVELOPMENT_BRANCH))"
echo
set -o xtrace

# Do the merge
git merge $NO_FF --no-edit $INPUT_STABLE_BRANCH

# Push the branch
git push origin $INPUT_DEVELOPMENT_BRANCH
