import * as vscode from "vscode";
import { installCLI, newRoute } from "./commands";

/**
 * This method is called when the extension is activated.
 *
 * The extension is activated the very first time the command is executed.
 * @param context
 */
export function activate(context: vscode.ExtensionContext) {
  installCLI();

  context.subscriptions.push(
    vscode.commands.registerCommand("extension.new-route", newRoute)
  );
  context.subscriptions.push(
    vscode.commands.registerCommand("extension.install-cli", installCLI)
  );
}

export function deactivate() {}
