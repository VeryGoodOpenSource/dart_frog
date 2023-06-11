const cp = require("child_process");
const path = require("node:path");

import { InputBoxOptions, Uri, window } from "vscode";

// TODO(alestiago): Support running from command palette.
export const newRoute = async (uri: Uri) => {
  const routeName = await getRouteName();
  if (routeName === undefined || routeName.trim() === "") {
    return;
  }

  const workingDirectory = uri.fsPath;

  executeDartFrogNewCommand(routeName, workingDirectory);
};

/**
 * Shows an input box to the user and returns a Thenable that resolves to a string
 * the user provided.
 * @returns { Thenable<string | undefined>} routeName
 */
function getRouteName(): Thenable<string | undefined> {
  const inputBoxOptions: InputBoxOptions = {
    prompt: "Route name",
    placeHolder: "index",
  };
  return window.showInputBox(inputBoxOptions);
}

/**
 * Runs the `dart_frog new` command with the given route name.
 * @param {string} routeName
 * @param {String} workingDirectory
 */
function executeDartFrogNewCommand(
  routeName: String,
  workingDirectory: String
) {
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
