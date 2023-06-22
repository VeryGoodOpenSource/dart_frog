import * as vscode from "vscode";

/**
 * This method is called when the extension is activated.
 *
 * The extension is activated the very first time the command is executed.
 *
 * @param {vscode.ExtensionContext} context
 */
export function activate(
  context: vscode.ExtensionContext
): vscode.ExtensionContext {
  return context;
}

export function deactivate() {}
