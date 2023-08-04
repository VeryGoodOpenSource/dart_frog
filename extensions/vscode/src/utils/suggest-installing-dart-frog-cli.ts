import * as vscode from "vscode";
import { installCLI } from "../commands";
import { isDartFrogCLIInstalled } from ".";

/**
 * Suggests the user to install Dart Frog CLI.
 *
 * This method should be called whenever Dart Frog CLI is not installed and it
 * is recommended to install it. Like for example, upon the extension activation
 * or when the user tries to run a command that requires Dart Frog CLI.
 *
 * It prompts the user to install Dart Frog CLI. This is optional, the user
 * can choose to install Dart Frog CLI at a later time but the extension may
 * not work as intended until Dart Frog CLI is installed.
 *
 * @see {@link isDartFrogCLIInstalled}, to check if Dart Frog CLI is installed.
 */
export async function suggestInstallingDartFrogCLI(
  message: string = "Dart Frog CLI is not installed. Install Dart Frog CLI to use this extension."
): Promise<void> {
  const selection = await vscode.window.showWarningMessage(
    message,
    "Install Dart Frog CLI",
    "Ignore"
  );
  switch (selection) {
    case "Install Dart Frog CLI":
      await installCLI();
      return;
    case "Ignore":
    default:
      return;
  }
}
