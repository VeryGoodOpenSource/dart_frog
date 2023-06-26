const cp = require("child_process");
const path = require("node:path");

import { Uri, window, OpenDialogOptions } from "vscode";

/**
 * Command to create a new middleware.
 *
 * This command is available from the command palette and the context menu.
 *
 * When launching the command from the command palette, the Uri is undefined
 * and the user is prompted to select a valid directory or file to create the
 * route in.
 *
 * When launching the command from the context menu, the Uri corresponds to the
 * selected file or directory. Only those directories or dart files under a
 * `routes` directory show the command in the context menu. Therefore the user
 * does not need to select a directory or file via the open dialog.
 *
 * All the logic associated with creating a new route is handled by the
 * `dart_frog new middleware` command, from the Dart Frog CLI.
 *
 * @see [Dart Frog CLI `new` command implementation](https://github.com/VeryGoodOpenSource/dart_frog/tree/main/packages/dart_frog_cli/lib/src/commands/new)
 * @param { Uri | undefined} uri
 */
export const newMiddleware = async (uri: Uri | undefined): Promise<void> => {
  let workingDirectory;
  if (uri === undefined) {
    const selectedUri = await promptForTargetDirectory();
    if (selectedUri === undefined) {
      window.showErrorMessage("Please select a valid directory");
      return;
    }
    workingDirectory = selectedUri;
  } else {
    workingDirectory = uri.fsPath;
  }

  if (!isValidWorkingPath(workingDirectory)) {
    window.showErrorMessage(
      "No 'routes' directory found in the selected directory"
    );
    return;
  }

  executeDartFrogNewMiddlewareCommand(workingDirectory);
};

/**
 * Shows an open dialog to the user and returns a Promise that resolves
 * to a string when the user selects a folder or file.
 *
 * This is used when the user activates the command from the command palette
 * instead of the context menu.
 *
 * @returns The path to the selected folder or file or undefined if the user
 * canceled.
 */
async function promptForTargetDirectory(): Promise<string | undefined> {
  const options: OpenDialogOptions = {
    canSelectMany: false,
    openLabel: "Select a folder or file to create the Route in",
    canSelectFolders: true,
    canSelectFiles: true,
  };
  return window.showOpenDialog(options).then((uri) => {
    if (Array.isArray(uri) && uri.length > 0) {
      return uri[0].fsPath;
    }

    return undefined;
  });
}

/**
 * Checks if the given path is a valid working directory.
 *
 * A valid working directory is a directory that contains a `routes` directory.
 *
 * @param {String} workingDirectory
 * @returns Whether or not the given path is a valid working directory.
 **/
function isValidWorkingPath(workingDirectory: String) {
  const workingDirectorySplits = workingDirectory.split(path.sep);
  const routesIndex = workingDirectorySplits.findIndex((e) => e === "routes");
  return routesIndex !== -1;
}

/**
 * Runs the `dart_frog new middleware` command with the route path segment being
 * the path relative to working directory from the routes directory.
 *
 * @param {String} workingDirectory
 */
function executeDartFrogNewMiddlewareCommand(workingDirectory: String): void {
  let workingDirectorySplits = workingDirectory.split(path.sep);

  const lastWorkingDirectoryElement =
    workingDirectorySplits[workingDirectorySplits.length - 1];
  const isFile = lastWorkingDirectoryElement.includes(".");
  if (isFile) {
    const lastDotIndex = lastWorkingDirectoryElement.lastIndexOf(".");
    workingDirectorySplits[workingDirectorySplits.length - 1] =
      lastWorkingDirectoryElement.substring(0, lastDotIndex);

    if (workingDirectorySplits[workingDirectorySplits.length - 1] === "index") {
      workingDirectorySplits.pop();
    }
  }

  const routesIndex = workingDirectorySplits.findIndex((e) => e === "routes");
  const dartProjectDirectory = workingDirectorySplits
    .slice(0, routesIndex)
    .join(path.sep);
  let normalizedRouteName = workingDirectorySplits
    .slice(routesIndex + 1)
    .join(path.sep);
  if (normalizedRouteName === "") {
    normalizedRouteName = "/";
  }

  cp.exec(
    `dart_frog new middleware '${normalizedRouteName}'`,
    {
      cwd: dartProjectDirectory,
    },
    function (error: Error, stdout: String, stderr: String) {
      if (error) {
        window.showErrorMessage(error.message);
      }
    }
  );
}
