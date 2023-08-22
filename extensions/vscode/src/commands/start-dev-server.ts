import { window } from "vscode";

/**
 * Starts the development server.
 *
 * This command can be launched from the Command Palette.
 */
export const startDevServer = async (): Promise<void> => {
  window.showInformationMessage("Hello World!");
};
