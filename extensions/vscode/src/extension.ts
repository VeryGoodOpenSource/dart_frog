import * as vscode from "vscode";
import { installCLI, newRoute, newMiddleware, updateCLI } from "./commands";
import {
  readDartFrogCLIVersion,
  isCompatibleDartFrogCLIVersion,
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
  installCLI();
  ensureCompatibleDartFrogCLI();

  context.subscriptions.push(
    vscode.commands.registerCommand("extension.install-cli", installCLI),
    vscode.commands.registerCommand("extension.update-cli", updateCLI),
    vscode.commands.registerCommand("extension.new-route", newRoute),
    vscode.commands.registerCommand("extension.new-middleware", newMiddleware)
  );
  return context;
}

/**
 * This method is called upon activation of the extension to ensure that the
 * version of Dart Frog CLI installed in the user's system is compatible with
 * this extension.
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
