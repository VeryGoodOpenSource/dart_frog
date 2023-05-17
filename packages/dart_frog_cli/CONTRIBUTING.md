# 🦄 Contributing to Dart Frog CLI

First of all, thank you for taking the time to contribute! 🎉👍 Before you do, please carefully read this guide.

## Understanding Dart Frog CLI

## Opening an issue

We highly recommend [creating an issue][bug_report_link] if you have found a bug, want to suggest a feature, or recommend a change. Please do not immediately open a pull request. Opening an issue first allows us to reach an agreement on a fix before you put significant effort into a pull request.

When reporting a bug, please use the built-in [Bug Report][bug_report_link] template and provide as much information as possible including detailed reproduction steps. Once one of the package maintainers has reviewed the issue and we reach an agreement on the fix, open a pull request.

## Developing for Dart Frog CLI

To develop for Dart Frog CLI you will need to become familiar with Very Good Ventures processes and conventions:

### Setting up your local development environment

1. Install a valid [Dart SDK](https://dart.dev/get-dart) in your local environment. Compatible Dart SDK versions with test optimizer can be found [here](https://github.com/VeryGoodOpenSource/very_good_cli/blob/main/pubspec.yaml). If you have Flutter installed, you likely have a valid Dart SDK version already installed.

2. Install all Dart Frog CLI's dependencies:

```sh
# 📂 Get project dependencies recursively with Dart Frog CLI's
very_good packages get -r
```

3. Run all Dart Frog CLI's tests:

```sh
# 💻 Run Dart Frog CLI's unit tests (from packages/dart_frog_cli)
very_good test -r
```

If some tests do not pass out of the box, please submit an [issue](https://github.com/VeryGoodOpenSource/dart_frog/issues/new/choose).

4. Install your own version of Dart Frog CLI in your local environment:

```sh
# 🚀 Activate your own local version of Dart Frog CLI (from packages/dart_frog_cli)
dart pub global activate --source path .
```

5. If you are modifying any templates, then make sure to bundle them before activating:

```sh
# 📦 Bundle templates (from root)
tool/generate_bundles.sh
```

### Creating a Pull Request

Before creating a Pull Request please:

1. [Fork](https://docs.github.com/en/get-started/quickstart/contributing-to-projects) the [GitHub repository](https://github.com/VeryGoodOpenSource/dart_frog) and create your branch from `main`:

```sh
# 🪵 Branch from `main`
git branch <branch-name>
git checkout <branch-name>
```

Where `<branch-name>` is an appropriate name describing your change.

2. Install dependencies:

```sh
# 📂 Get project dependencies recursively with Dart Frog CLI
very_good packages get -r
```

3. Ensure you have a meaningful [semantic][conventional_commits_link] commit message.

4. Add tests! Pull Requests without 100% test coverage will **not** be merged. If you're unsure on how to do so watch our [Testing Fundamentals Course](https://www.youtube.com/watch?v=M_eZg-X789w&list=PLprI2satkVdFwpxo_bjFkCxXz5RluG8FY).

5. Ensure the existing test suite passes locally:

```sh
# 🧪 Run Dart Frog CLI's unit test
very_good test -r
```

6. Format your code:

```sh
# 🧼 Run Dart's formatter
dart format .
```

7. Analyze your code:

```sh
# 🔍 Run Dart's analyzer
dart analyze --fatal-infos --fatal-warnings .
```

Some analysis issues may be fixed automatically with:

```sh
# Automatically fix analysis issues that have associated automated fixes
dart fix --apply
```

💡 **Note**: Our repositories use [Very Good Analysis](https://github.com/VeryGoodOpenSource/very_good_analysis).

8. Create the Pull Request with a meaningful description, linking to the original issue where possible.

9. Verify that all [status checks](https://github.com/VeryGoodOpenSource/dart_frog/actions) are passing for your Pull Request once they have been approved to run by a maintainer.

💡 **Note**: While the prerequisites above must be satisfied prior to having your pull request reviewed, the reviewer(s) may ask you to complete additional work, tests, or other changes before your pull request can be accepted.

[conventional_commits_link]: https://www.conventionalcommits.org/en/v1.0.0
[bug_report_link]: https://github.com/VeryGoodOpenSource/dart_frog/issues/new?assignees=&labels=bug&projects=&template=bug_report.md&title=fix%3A+
[very_good_core_link]: doc/very_good_core.md
[very_good_ventures_link]: https://verygood.ventures/?utm_source=github&utm_medium=banner&utm_campaign=CLI
