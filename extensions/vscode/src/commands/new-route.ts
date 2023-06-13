const cp = require("child_process");
const path = require("node:path");

import { InputBoxOptions, Uri, window, OpenDialogOptions } from "vscode";

// TODO(alestiago): Support running from command palette.
export const newRoute = async (uri: Uri) => {
  const routeName = await promptRouteName();
  if (routeName === undefined || routeName.trim() === "") {
    return;
  }

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

  executeDartFrogNewCommand(routeName, workingDirectory);
};

/**
 * Shows an input box to the user and returns a Thenable that resolves to a string
 * the user provided.
 *
 * @returns { Thenable<string | undefined>} routeName
 */
function promptRouteName(): Thenable<string | undefined> {
  const inputBoxOptions: InputBoxOptions = {
    prompt: "Route name",
    placeHolder: "index",
  };
  return window.showInputBox(inputBoxOptions);
}

/**
 * Shows an open dialog to the user and returns a Promise that resolves to a string
 * when the user selects a folder or file.
 *
 * This is used when the user activates the command from the command palette instead
 * of the context menu.
 *
 * @returns { Promise<string | undefined>} targetDirectory
 */
async function promptForTargetDirectory(): Promise<string | undefined> {
  const options: OpenDialogOptions = {
    canSelectMany: false,
    openLabel: "Select a folder or file to create the Route in",
    canSelectFolders: true,
    canSelectFiles: true,
  };
  return window.showOpenDialog(options).then((uri) => {
    if (uri === undefined) {
      return undefined;
    }
    return uri[0].fsPath;
  });
}

/**
 * Checks if the given path is a valid working directory.
 *
 * A valid working directory is a directory that contains a `routes` directory.
 *
 * @param {String} workingDirectory
 * @returns {Boolean} isValid
 **/
function isValidWorkingPath(workingDirectory: String) {
  const workingDirectorySplits = workingDirectory.split(path.sep);
  const routesIndex = workingDirectorySplits.findIndex((e) => e === "routes");
  return routesIndex !== -1;
}

/**
 * Runs the `dart_frog new` command with the given route name.
 *
 * @param {string} routeName
 * @param {String} workingDirectory
 */
function executeDartFrogNewCommand(
  routeName: String,
  workingDirectory: String
) {
  let workingDirectorySplits = workingDirectory.split(path.sep);

  // TODO(alestiago): Simplify logic, to avoid duplication, once the following
  // issue is resolved: https://github.com/VeryGoodOpenSource/dart_frog/issues/701
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
  const normalizedRouteName = path.join(
    workingDirectorySplits.slice(routesIndex + 1).join(path.sep),
    routeName
  );

  const command = `dart_frog new route ${normalizedRouteName}`;

  cp.exec(
    command,
    {
      cwd: dartProjectDirectory,
    },
    function (error: Error, stdout: String, stderr: String) {
      if (error) {
        // TODO(alestiago): Parse error message and show it in a more user-friendly way.
        window.showErrorMessage(stderr.toString());
      }
    }
  );
}
