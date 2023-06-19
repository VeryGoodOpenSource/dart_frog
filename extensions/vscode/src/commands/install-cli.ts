const cp = require("child_process");

import { window, ProgressOptions } from "vscode";

/**
 * Installs Dart Frog's CLI in the user's system.
 *
 * If already installed, it updates it to the latest version when possible.
 */
export const installCLI = async () => {
  if (!hasDartFrogCliInstalled()) {
    const options: ProgressOptions = {
      location: 15,
      title: "Installing Dart Frog's CLI...",
    };
    window.withProgress(options, installDartFrogCliVersion);
  } else {
    const options: ProgressOptions = {
      location: 15,
      title: "Updating Dart Frog's CLI...",
    };
    window.withProgress(options, updateDartFrogCliVersion);
  }
};

/**
 * Whether the user has dart_frog_cli installed in their system.
 *
 * @returns {boolean} True if the user has dart_frog_cli installed in their system,
 * false otherwise.
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
 * Installs the latest version of dart_frog_cli available in the pub.dev repository.
 *
 * @returns {Promise<void>} A promise that resolves when the installation is complete.
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

/**
 * Updates the latest version of dart_frog_cli available in the pub.dev repository.
 *
 * @returns {Promise<void>} A promise that resolves when the update is complete.
 */
async function updateDartFrogCliVersion(): Promise<void> {
  // TODO(alestiago): Allow the user to opt-out of updating dart_frog_cli.
  // https://github.com/VeryGoodOpenSource/dart_frog/issues/707
  await cp.exec(
    `dart_frog update`,
    function (error: Error, stdout: String, stderr: String) {
      if (error) {
        window.showErrorMessage(error.message);
      }
    }
  );
}
