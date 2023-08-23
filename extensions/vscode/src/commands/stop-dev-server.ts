import { window } from "vscode";

export const stopDevServer = async (): Promise<void> => {
  window.showInformationMessage("Stop Dev Server");
};
