# gh-action-auto-merge

Automatically merge the stable branch into the development one.

If the merge is not necessary, the action will do nothing.
If the merge fails due to conflicts, the action will fail, and the repository
maintainer should perform the merge manually.

## Installation

To enable the action simply create the `.github/workflows/nightly-merge.yml`
file with the following content:

```yml
name: 'Nightly Merge'

on:
  schedule:
    - cron:  '*/0 0 * * *'

jobs:
  automerge:

    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@master

    - name: Nightly Merge
      uses: robotology/gh-action-nightly-merge@master
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Warnings

This is a work in progress.
At the moment:

* The stable branch name must be `master`
* The development branch name must be `devel`
* The actions will probably start also on forks if the actions are enabled for the forks.
