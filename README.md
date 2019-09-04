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
  nightly-merge:

    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@master

    - name: Nightly Merge
      uses: robotology/gh-action-nightly-merge@master
      with:
        stable_branch: 'master'
        development_branch: 'devel'
        allow_ff: false
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Parameters

### `stable_branch`

The name of the stable branch (default `master`).

### `development_branch`

The name of the development branch (default `devel`).

### `allow_ff`

Allow fast forward merge (default `false`). If not enabled, merges will use `--no-ff`.

### `allow_forks`

Allow action to run on forks (default `false`).
