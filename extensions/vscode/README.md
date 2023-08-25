[![Dart Frog Logo][logo_black]][dart_frog_link_light]

This is the [Dart Frog](https://dartfrog.vgv.dev/) [VS Code](https://code.visualstudio.com/) extension, which provides tools for effectively managing Dart Frog projects.

Developed with 💙 by [Very Good Ventures][very_good_ventures_link] 🦄

## Installation

Dart Frog can be installed from the [VS Code Marketplace](https://marketplace.visualstudio.com/items?itemName=VeryGoodVentures.dart-frog) or by [searching within VS Code](https://code.visualstudio.com/docs/editor/extension-gallery#_search-for-an-extension).

## Demonstration

![demonstration](https://raw.githubusercontent.com/VeryGoodOpenSource/dart_frog/main/extensions/vscode/assets/new-route-middleware-usage.gif)

## Commands

| Command                               | Description                 | Launch from                     |
| ------------------------------------- | --------------------------- | ------------------------------- |
| `Dart Frog: Create`                   | Creates a new Dart Frog app | Context menu or command palette |
| `Dart Frog: Install CLI`              | Installs Dart Frog CLI      | Command palette                 |
| `Dart Frog: Update CLI`               | Updates Dart Frog CLI       | Command palette                 |
| `Dart Frog: New Route`                | Generates a new route       | Context menu or command palette |
| `Dart Frog: New Middleware`           | Generates a new middleware  | Context menu or command palette |
| `Dart Frog: Start Daemon`             | Starts the Dart Frog daemon | Command palette                 |
| `Dart Frog: Start Development Server` | Starts a Dart Frog server   | Command palette or CodeLens     |
| `Dart Frog: Stop Development Server`  | Stops a Dart Frog server    | Command palette                 |

## Configuration

| Name                       | Description                                         | Type    | Default |
| -------------------------- | --------------------------------------------------- | ------- | ------- |
| `dart-frog.enableCodeLens` | Whether or not to enable [CodeLens][code_lens_link] | Boolean | True    |

[ci_link]: https://github.com/VeryGoodOpenSource/dart_frog/actions/workflows/main.yaml
[dart_frog_link_light]: https://github.com/verygoodopensource/dart_frog
[license_link]: https://opensource.org/licenses/MIT
[logo_black]: https://raw.githubusercontent.com/VeryGoodOpenSource/dart_frog/main/assets/dart_frog_logo_black.png
[very_good_ventures_link]: https://verygood.ventures
[code_lens_link]: https://code.visualstudio.com/blogs/2017/02/12/code-lens-roundup
