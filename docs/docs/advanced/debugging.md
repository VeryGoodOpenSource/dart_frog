---
sidebar_position: 10
title: 🐛 Debugging
---

In some cases, you'll want to debug your Dart Frog app, and you might have noticed that by adding just the breakpoint, the debugger doesn't stop there like it does by default in a Flutter app.
Below, there are two quick and easy options for debugging code in Dart Frog.

## Debugging with Dart Frog IDE Extension 🐸

:::caution
This extension is only available for Visual Studio Code, if you are using another IDE, please refer to the **Debugging by Attaching to Dart Process** section.
:::

:::info
If you are interested in an extension for Android Studio or OpenVSX there are some open issues you can follow to learn more about it.

- **Android Studio** [#1326](https://github.com/VeryGoodOpenSource/dart_frog/issues/1326)

- **OpenVSX** [#907](https://github.com/VeryGoodOpenSource/dart_frog/issues/907)

:::

- Go to the Visual Studio Code Marketplace in [here](https://marketplace.visualstudio.com/items?itemName=VeryGoodVentures.dart-frog) and install the extension.

:::info
You can also install the extension by searching for `Dart Frog` in the extensions tab in Visual Studio Code.
:::

- Open your Dart Frog app.
- Open **Visual Studio Command Palette** by clicking `Shift` + `Command` + `P` (Mac) / `Ctrl` + `Shift` + `P` (Windows/Linux).
  You will see different options as shown in the image below.

![Dart Frog Extension Options](../../static/img/dart_frog_extension_options.png)

- Click on the `Dart Frog: Start and Debug Development Server` option. This will start the Dart Frog server in debug mode.

:::info
You can also select the `Dart Frog: Debug Development Server` option if you already have the server running.
:::

- Add the breakpoints in your code and try to access the endpoint where it gets hit. You will now see that the debugger stops at your breakpoints 🎉.

![Demo - Dart Frog Extension](../../static/img/debugging_with_extension.gif)

## Debugging by Attaching to Dart Process 🎯

- Open your Dart Frog application and run the server using the `dart_frog dev` command.
- In the terminal, you'll see something like `The Dart VM service is listening on http://127.0.0.1:8181/XXXXXXXXX/`. Copy the URL, as you'll need it in the next steps.
- Open the **Visual Studio Command Palette** by clicking `Shift` + `Command` + `P` (Mac) / `Ctrl` + `Shift` + `P` (Windows/Linux) and search for `Debug: Attach to Dart process`.
- Paste the URL you copied in the previous steps and press `Enter`. Now the debugger will stop at the breakpoints you added in your code 🎉.

![Demo - Dart Process](../../static/img/debugging_with_dart_process.gif)
