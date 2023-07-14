import * as vscode from "vscode";
import { installCLI, newRoute, newMiddleware } from "./commands";

/**
 * This method is called when the extension is activated.
 *
 * The extension is activated the very first time a command is executed or
 * if the workspace contains a pubspec.yaml file.
 *
 * @param {vscode.ExtensionContext} context
 * @returns The same instance of the extension context passed in.
 * @see {@link https://code.visualstudio.com/api/references/activation-events} for further details about
 * extension activation events.
 */
export function activate(
  context: vscode.ExtensionContext
): vscode.ExtensionContext {
  installCLI();

  context.subscriptions.push(
    vscode.commands.registerCommand("extension.install-cli", installCLI),
    vscode.commands.registerCommand("extension.new-route", newRoute),
    vscode.commands.registerCommand("extension.new-middleware", newMiddleware)
  );
  return context;
}
