[![Dart Frog Logo][logo_white]][dart_frog_link_dark]
[![Dart Frog Logo][logo_black]][dart_frog_link_light]

[![ci][ci_badge]][ci_link]
[![coverage][coverage_badge]][ci_link]
[![pub package][pub_badge]][pub_link]
[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]

A fast, minimalistic backend framework for Dart 🎯

Developed with 💙 by [Very Good Ventures][very_good_ventures_link] 🦄

## Experimental 🚧

`dart_frog` is an experimental project under development and should not be used in production at this time.

## Quick Start 🚀

### Prerequisites 📝

In order to use Dart Frog you must have the [Dart SDK][dart_installation_link] installed on your machine.

### Installing 🧑‍💻

```sh
# 📦 Install the dart_frog cli from source
dart pub global activate dart_frog_cli
```

### Creating a Project ✨

Use the `dart_frog create` command to create a new project.

```sh
# 🚀 Create a new project called "my_project"
dart_frog create my_project
```

### Start the Dev Server 🏁

Next, open the newly created project and start the dev server via:

```sh
# 🏁 Start the dev server
dart_frog dev
```

### Create a Production Build 📦

Create a production build which includes a `DockerFile` so that you can deploy anywhere:

```sh
# 📦 Create a production build
dart_frog build
```

## Documentation 📝

View the full documentation [here][documentation_link].

[ci_badge]: https://github.com/VeryGoodOpenSource/dart_frog/actions/workflows/dart_frog.yaml/badge.svg
[ci_link]: https://github.com/VeryGoodOpenSource/dart_frog/actions/workflows/dart_frog.yaml
[coverage_badge]: https://raw.githubusercontent.com/VeryGoodOpenSource/dart_frog/main/packages/dart_frog/coverage_badge.svg
[dart_frog_link_dark]: https://github.com/verygoodopensource/dart_frog#gh-dark-mode-only
[dart_frog_link_light]: https://github.com/verygoodopensource/dart_frog#gh-light-mode-only
[dart_installation_link]: https://dart.dev/get-dart
[documentation_link]: https://github.com/VeryGoodOpenSource/dart_frog/blob/main/README.md#documentation-
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[logo_black]: https://raw.githubusercontent.com/VeryGoodOpenSource/dart_frog/main/assets/dart_frog_logo_black.png#gh-light-mode-only
[logo_white]: https://raw.githubusercontent.com/VeryGoodOpenSource/dart_frog/main/assets/dart_frog_logo_white.png#gh-dark-mode-only
[pub_badge]: https://img.shields.io/pub/v/dart_frog.svg
[pub_link]: https://pub.dartlang.org/packages/dart_frog
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[very_good_ventures_link]: https://verygood.ventures
