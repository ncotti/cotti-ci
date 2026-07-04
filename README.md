# cottiCI

Reusable CI scripts for your own projects, to be used as [Github's composite actions][composite_action].

## Features

* Markdown linter with [markdownlint-cli2][markdown-cli2] and broken links checker with [lychee][lychee].
* Bash linter with [shellcheck][shellcheck].
* Check for the presence of the license and copyright notice in source files.
* Run [BATS][bats] (Bash Automated Testing System) tests.

## Usage

All CI scripts are defined as [Github's composite actions][composite_action], and an example of their execution is provided in the [examples.yml][example_ci_execution] file.

To use one of them in your CI workflow, you would normally do the following:

1. Checkout your own Git repository.
2. Call the CI action with `uses: ncotti/cotti-ci/actions/<action_name>@main`

An minimal example Github workflow looks like this:

```yml
name: "Examples"
on: push

jobs:
  example_CI:
    runs-on: ubuntu-latest
    env:
      REPO_PATH: .
    steps:
      - name: "Checkout project repo"
        uses: actions/checkout@v5
        with:
          path: ${{ env.REPO_PATH }}

      - name: "Call <CI_ACTION>"
        uses: ncotti/cotti-ci/actions/<CI_ACTION>@main
        with:
          # Define the CI inputs
          target_dir: ${{ env.REPO_PATH }}
```

## Contributing

**Found a bug?** Glad to fix it. Open an [issue][issue] containing the steps to replicate it, or open a [Pull Request][pr] with the fix.

You developed an exciting **new feature**, which extends the current functionality, and you would like to be include it in the repo? No problem, open a [Pull Request][pr] and I will review it.

<!-- Internal links -->
[example_ci_execution]: /.github/workflows/examples.yml

<!-- External links -->
[composite_action]: https://docs.github.com/en/actions/tutorials/create-actions/create-a-composite-action

[markdown-cli2]: https://github.com/DavidAnson/markdownlint-cli2
[shellcheck]: https://github.com/koalaman/shellcheck
[bats]: https://bats-core.readthedocs.io/en/stable/
[lychee]: https://github.com/lycheeverse/lychee

[issue]: https://github.com/ncotti/cotti-ci/issues
[pr]: https://github.com/ncotti/cotti-ci/pulls
