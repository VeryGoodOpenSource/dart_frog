# 🦄 Contributing to Dart Frog's Visual Studio Code extension

First of all, thank you for taking the time to contribute! 🎉👍 Before you do, please carefully read this guide.

## Opening an issue

We highly recommend [creating an issue][bug_report_link] if you have found a bug, want to suggest a feature, or recommend a change. Please do not immediately open a pull request. Opening an issue first allows us to reach an agreement on a fix before you put significant effort into a pull request.

When reporting a bug, please use the built-in [Bug Report][bug_report_link] template and provide as much information as possible including detailed reproduction steps. Once one of the package maintainers has reviewed the issue and we reach an agreement on the fix, open a pull request.

## Developing for Dart Frog's Visual Studio Code extension

To develop for Very Good CLI you will need to become familiar with Visual Studio Code extensions development and Very Good Ventures' processes and conventions:

### Setting up your local development environment

1. Install a valid [Dart SDK](https://dart.dev/get-dart) in your local environment. Compatible Dart SDK versions with test optimizer can be found [here](https://github.com/VeryGoodOpenSource/very_good_cli/blob/main/pubspec.yaml). If you have Flutter installed, you likely have a valid Dart SDK version already installed.

2. Install a valid [Node.js](https://nodejs.org) in your local environment.

3. Get all project dependencies:

```sh
# Get project dependencies:
npm i
```

3. Open the project in Visual Studio Code:

```sh
# Open Visual Studio Code (from /extensions/vscode)
code .
```

4. Inside the editor, press F5. This will compile and run the extension in a new **Extension Development Host** window.

5. After a change, make sure to **Run Developer: Reload Window** in the new window.

💡 **Note**: For further information about debugging Visual Studio Code's extensions refer to the [official documentation](https://code.visualstudio.com/api/get-started/your-first-extension).

### Creating a Pull Request

Before creating a Pull Request please:

1. [Fork](https://docs.github.com/en/get-started/quickstart/contributing-to-projects) the [GitHub repository](https://github.com/VeryGoodOpenSource/dart_frog) and create your branch from `main`:

```sh
# 🪵 Branch from `main`
git branch <branch-name>
git checkout <branch-name>
```

[conventional_commits_link]: https://www.conventionalcommits.org/en/v1.0.0
[bug_report_link]: https://github.com/VeryGoodOpenSource/dart_frog/issues/new?assignees=&labels=bug&template=bug_report.md&title=fix%3A+
