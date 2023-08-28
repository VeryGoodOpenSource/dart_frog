const cp = require("child_process");

import { ProgressOptions, window } from "vscode";
import { isDartFrogCLIInstalled } from "../utils";

/**
 * Installs Dart Frog CLI in the user's system if not already installed.
 */
export const installCLI = async (): Promise<void> => {
  if (!isDartFrogCLIInstalled()) {
    const options: ProgressOptions = {
      location: 15,
      title: "Installing Dart Frog CLI...",
    };
    window.withProgress(options, installDartFrogCliVersion);
  }
};

/**
 * Installs Dart Frog CLI from pub.dev.
 *
 * @returns {Promise<void>} A promise that resolves when the installation is
 * complete.
 */
async function installDartFrogCliVersion(): Promise<void> {
  try {
    await cp.execSync(`dart pub global activate dart_frog_cli`);
  } catch (error: any) {
    if (error instanceof Error) {
      window.showErrorMessage(error.message);
    } else {
      window.showErrorMessage(
        `An error occurred while installing Dart Frog CLI: ${error}`
      );
    }
  }
}
