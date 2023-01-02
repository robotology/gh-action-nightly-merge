# Testing the Script

Here are some guidelines/steps which will allow you to test changes.

First it assumed you've created for yourself a repository on GitHub. 
Note that in order to be able to finally test the github action in isolation, you'll need to grant "Read and Write permissions"
for actions on your repository. 
ref: https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/enabling-features-for-your-repository/managing-github-actions-settings-for-a-repository#configuring-the-default-github_token-permissions

## Test Cases

### Initial setup

Clone your test repository
```
git clone https://your_repo
```

Make some changes in the master branch

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

#### Local Tests

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

GITHUB_TOKEN='...' GITHUB_REPOSITORY='lefrog/test-merging' GITHUB_WORKSPACE=$PWD INPUT_USER_NAME='your_github_user' INPUT_PUSH_TOKEN='GITHUB_TOKEN' INPUT_USER_EMAIL='foo@bar.com' INPUT_STABLE_BRANCH='master' ${PATH_TO_YOUR_CODE}/gh-action-nightly-merge/entrypoint.sh
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

GITHUB_TOKEN='...' GITHUB_REPOSITORY='lefrog/test-merging' GITHUB_WORKSPACE=$PWD INPUT_USER_NAME='your_github_user' INPUT_PUSH_TOKEN='GITHUB_TOKEN' INPUT_USER_EMAIL='foo@bar.com' INPUT_STABLE_BRANCH='main' ${PATH_TO_YOUR_CODE}/gh-action-nightly-merge/entrypoint.sh
```

#### End-to-end tests

In your test repository, add commit/push the following github action in your master branch

```
#file: .github/workflows/main.yml

name: 'Merge Stable branch'
on:
  workflow_dispatch:
jobs:
  nightly-merge:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout
      uses: actions/checkout@v3
    - name: Nightly Merge
      uses: lefrog/gh-action-nightly-merge@fix-issue-6
      with:
        stable_branch: 'test-master'
        development_branch: 'feat-merge-no-conflict'
        allow_ff: false
        user_name: 'github-actions[bot]'
        user_email: 'foo@bar.com'
        push_token: 'GITHUB_TOKEN'
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        REPO_TOKEN: ${{ secrets.REPO_TOKEN }}
```

and repeat the same changes above but manually trigger the action. 
