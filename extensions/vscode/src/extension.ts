import * as vscode from "vscode";
import { newRoute } from "./commands";

/**
 * This method is called when the extension is activated.
 *
 * The extension is activated the very first time the command is executed.
 * @param context
 */
export function activate(context: vscode.ExtensionContext) {
  // TODO(alestiago): Try installing dart_frog_cli if it's not installed.
  // TODO(alestiago): Update dart_frog_cli if it's not up to date.

  context.subscriptions.push(
    vscode.commands.registerCommand("extension.new-route", newRoute)
  );

  return context;
}

export function deactivate() {}
