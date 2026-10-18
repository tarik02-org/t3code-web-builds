# t3code-web-builds

Hosted builds of the [T3 Code](https://github.com/pingdotgg/t3code) web app, for
[t3code-gateway](https://github.com/tarik02-org/t3code-gateway).

Upstream publishes its hosted web app only to its own deployment. Its CLI tarballs carry a
different build that expects to be served by the T3 Code server itself. This repository builds
`apps/web` from each upstream stable and nightly tag with `VITE_HOSTED_APP_CHANNEL` set, and
publishes the result as `T3-Code-Web-<version>.zip` (the app under `dist/`). No code is changed.

## How it updates

- `update` runs hourly. For each channel it compares `releases/<channel>` with upstream's newest
  published release, and opens or updates an `update/<channel>` PR with auto-merge enabled.
- `ci` builds both pinned tags on every PR; the `main` ruleset requires its `ci` job.
- `release` runs when `releases/` changes on `main` and publishes a release for each pinned tag
  that has none yet. Stable releases become `latest`; nightlies are prereleases.

Build a tag locally with `./scripts/build.sh <tag> <output-dir>`.
