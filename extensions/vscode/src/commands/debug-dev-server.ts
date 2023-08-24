import { window } from "vscode";

export const debugDevServer = async (): Promise<void> => {
  window.showInformationMessage("Debugging dev server...");
};
