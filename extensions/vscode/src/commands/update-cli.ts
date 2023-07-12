const cp = require("child_process");

import { window, ProgressOptions } from "vscode";
import { isDartFrogCLIInstalled } from "../utils/utils";

/**
 * Update Dart Frog CLI in the user's system.
 *
 * If Dart Frog CLI is not installed, this function does nothing.
 */
export const updateCLI = async (): Promise<void> => {
  if (!isDartFrogCLIInstalled()) {
    return;
  }

  const options: ProgressOptions = {
    location: 15,
    title: "Updating Dart Frog CLI...",
  };
  window.withProgress(options, updateDartFrogCLIVersion);
};

/**
 * Updates Dart Frog CLI to the latest version.
 *
 * @returns {Promise<void>} A promise that resolves when the update is
 * complete.
 */
async function updateDartFrogCLIVersion(): Promise<void> {
  await cp.exec(
    `dart_frog update`,
    function (error: Error, stdout: String, stderr: String) {
      if (error) {
        window.showErrorMessage(error.message);
      }
    }
  );
}
