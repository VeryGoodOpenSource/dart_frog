const cp = require("child_process");

import { window, ProgressOptions } from "vscode";

/**
 * Installs Dart Frog CLI in the user's system if not already installed.
 */
export const installCLI = async (): Promise<void> => {
  if (!hasDartFrogCliInstalled()) {
    const options: ProgressOptions = {
      location: 15,
      title: "Installing Dart Frog CLI...",
    };
    window.withProgress(options, installDartFrogCliVersion);
  }
};

/**
 * Whether the user has Dart Frog CLI installed in their system.
 *
 * @returns {boolean} True if the user has Dart Frog CLI installed in their
 * system, false otherwise.
 */
function hasDartFrogCliInstalled(): boolean {
  try {
    cp.execSync(`dart_frog --version`);
    return true;
  } catch (error) {
    return false;
  }
}

/**
 * Installs the latest version of Dart Frog CLI available in the pub.dev
 * repository.
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
