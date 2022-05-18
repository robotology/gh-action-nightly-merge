# Testing the Script

## Test Cases

### Initial setup

```
#git checkout master
cat << EOF >> file1.txt
function foo () {
  console.log('hello foo')
}
function bar () {
  console.log('hello bar')
}
EOF
git add file1.txt
git commit -m "first commit"
git push --set-upstream origin master
git tag init
git push origin init
```

T-01 Given a private repo, given a branch with no merge conflict,
when attempting to merge the branch it should succeed without errors.

```
export INPUT_DEVELOPMENT_BRANCH='feat-merge-no-conflict' 

git checkout -b ${INPUT_DEVELOPMENT_BRANCH} init
sed -i 's/hello foo/hello my favorite foo/' file1.txt
git commit -a -m 'feature update 01'
git push --set-upstream origin ${INPUT_DEVELOPMENT_BRANCH}

git checkout master
sed -i 's/hello from foo/hello from foo again/' file1.txt
git commit -a -m 'update 02'
git push

GITHUB_TOKEN='...' GITHUB_REPOSITORY='lefrog/test-merging' GITHUB_WORKSPACE=$PWD INPUT_USER_NAME='lefrog' INPUT_PUSH_TOKEN='GITHUB_TOKEN' INPUT_USER_EMAIL='pascal.lambert.ca@gmail.com' INPUT_STABLE_BRANCH='master' /home/pascal/projects/gh-action-nightly-merge/entrypoint.sh
```

T-02 Given a private repo, given a branch to merge which will have merge conflict,
when attempting to merge the branch it should fail and indicate merge conflicts
must be resolved.

```
export INPUT_DEVELOPMENT_BRANCH='feat-merge-with-conflict'

git checkout -b ${INPUT_DEVELOPMENT_BRANCH} init
echo "hello again" >> file1.txt
git add file1.txt
git commit -m "new content from ${INPUT_DEVELOPMENT_BRANCH}"
git push --set-upstream origin ${INPUT_DEVELOPMENT_BRANCH}

git checkout main
echo "hello gang" >> file1.txt
git add file1.txt
git commit -m "new content from main"
git push

GITHUB_TOKEN='...' GITHUB_REPOSITORY='lefrog/test-merging' GITHUB_WORKSPACE=$PWD INPUT_USER_NAME='lefrog' INPUT_PUSH_TOKEN='GITHUB_TOKEN' INPUT_USER_EMAIL='pascal.lambert.ca@gmail.com' INPUT_STABLE_BRANCH='main' /home/pascal/projects/gh-action-nightly-merge/entrypoint.sh
```