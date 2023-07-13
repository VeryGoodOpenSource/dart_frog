import * as vscode from "vscode";
import { installCLI, newRoute, newMiddleware, updateCLI } from "./commands";
import {
  readDartFrogCLIVersion,
  isCompatibleDartFrogCLIVersion,
  isDartFrogCLIInstalled,
} from "./utils";

/**
 * This method is called when the extension is activated.
 *
 * The extension is activated the very first time the command is executed.
 *
 * @param {vscode.ExtensionContext} context
 * @returns The same instance of the extension context passed in.
 */
export function activate(
  context: vscode.ExtensionContext
): vscode.ExtensionContext {
  if (isDartFrogCLIInstalled()) {
    suggestInstallingDartFrogCLI();
  } else {
    ensureCompatibleDartFrogCLI();
  }

  context.subscriptions.push(
    vscode.commands.registerCommand("extension.install-cli", installCLI),
    vscode.commands.registerCommand("extension.update-cli", updateCLI),
    vscode.commands.registerCommand("extension.new-route", newRoute),
    vscode.commands.registerCommand("extension.new-middleware", newMiddleware)
  );
  return context;
}

/**
 * Suggests the user to install Dart Frog CLI.
 *
 * This method should be called upon activation of the extension whenever
 * Dart Frog CLI is not installed in the user's system.
 *
 * If Dart Frog CLI is not installed in the user's system, the user is prompted
 * to install Dart Frog CLI. This is optional, and the user can choose to
 * install Dart Frog CLI at a later time but the extension may not work as
 * intended until Dart Frog CLI is installed.
 *
 * @see {@link isDartFrogCLIInstalled}, to check if Dart Frog CLI is installed
 */
export async function suggestInstallingDartFrogCLI(): Promise<void> {
  const selection = await vscode.window.showWarningMessage(
    "Dart Frog CLI is not installed. Install Dart Frog CLI to use this extension.",
    "Install Dart Frog CLI",
    "Ignore"
  );
  switch (selection) {
    case "Install Dart Frog CLI":
      await installCLI();
      break;
    case "Ignore":
      break;
    default:
      break;
  }
}

/**
 * This method should be called upon activation of the extension to ensure that
 * the version of Dart Frog CLI installed in the user's system is compatible
 * with this extension.
 *
 * If the version of Dart Frog CLI installed in the user's system is not
 * compatible with this extension, the user is prompted to update Dart Frog CLI
 * or ignore the warning. If the user chooses to update Dart Frog CLI, the
 * extension will attempt to update Dart Frog CLI. Otherwise, the user will
 * proceed to use the extension at their own risk.
 *
 * If Dart Frog CLI is not installed in the user's system, this method will
 * do nothing and returns immediately.
 *
 * @see {@link isCompatibleDartFrogCLIVersion}, to check if the version of
 * Dart Frog CLI installed in the user's system is compatible with this
 * extension.
 */
export async function ensureCompatibleDartFrogCLI(): Promise<void> {
  const version = readDartFrogCLIVersion();
  if (!version) {
    return;
  }

  const versionIsCompatible = isCompatibleDartFrogCLIVersion(version);
  if (versionIsCompatible) {
    return;
  }

  const selection = await vscode.window.showWarningMessage(
    `Dart Frog CLI version ${version} is not compatible with this extension.`,
    "Update Dart Frog CLI",
    "Ignore"
  );
  switch (selection) {
    case "Update Dart Frog CLI":
      updateCLI();
      break;
    case "Ignore":
      break;
    default:
      break;
  }
}
