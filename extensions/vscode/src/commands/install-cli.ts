const cp = require("child_process");

import { window, ProgressOptions } from "vscode";
import { isDartFrogCLIInstalled } from "../utils/utils";

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
  await cp.exec(
    `dart pub global activate dart_frog_cli`,
    function (error: Error, stdout: String, stderr: String) {
      if (error) {
        window.showErrorMessage(error.message);
      }
    }
  );
}
