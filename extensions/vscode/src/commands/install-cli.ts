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
 * @returns {boolean} Whether the user has dart_frog_cli installed in their system.
 */
function hasDartFrogCliInstalled(): boolean {
  const command = `dart_frog --version`;
  try {
    cp.execSync(command);
    return true;
  } catch (error) {
    return false;
  }
}

/**
 * Installs the latest version of dart_frog_cli available in the pub.dev repository.
 */
async function installDartFrogCliVersion() {
  const command = `dart pub global activate dart_frog_cli`;
  await cp.exec(
    command,
    function (error: Error, stdout: String, stderr: String) {
      if (error) {
        window.showErrorMessage(error.message);
      }
    }
  );
}

/**
 * Updates the latest version of dart_frog_cli available in the pub.dev repository.
 */
async function updateDartFrogCliVersion() {
  // TODO(alestiago): Allow the user to opt-out of updating dart_frog_cli.
  // https://github.com/VeryGoodOpenSource/dart_frog/issues/707
  const command = `dart_frog update`;
  await cp.exec(
    command,
    function (error: Error, stdout: String, stderr: String) {
      if (error) {
        window.showErrorMessage(error.message);
      }
    }
  );
}
