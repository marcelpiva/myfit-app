fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## Android

### android build

```sh
[bundle exec] fastlane android build
```

Build App Bundle for release

### android internal

```sh
[bundle exec] fastlane android internal
```

Deploy to internal testing track

### android alpha

```sh
[bundle exec] fastlane android alpha
```

Deploy to alpha (closed testing) track

### android beta

```sh
[bundle exec] fastlane android beta
```

Deploy to beta (open testing) track

### android production

```sh
[bundle exec] fastlane android production
```

Deploy to production

### android promote_to_production

```sh
[bundle exec] fastlane android promote_to_production
```

Promote internal to production

### android upload_only

```sh
[bundle exec] fastlane android upload_only
```

Upload only (AAB must already be built)

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
