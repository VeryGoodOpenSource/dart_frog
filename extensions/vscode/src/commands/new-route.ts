const cp = require("child_process");
const path = require("node:path");

import {
  InputBoxOptions,
  OpenDialogOptions,
  Uri,
  window,
  workspace,
} from "vscode";

export const newRoute = async (uri: Uri) => {
  const routeName = await getRouteName();
  if (routeName === undefined || routeName.trim() === "") {
    return;
  }

  const workingDirectory = uri.fsPath;

  // TODO(alestiago): Create issue in dart_frog new to allow creating a new route
  // outside Dart Frog directory, and remove this workaround.
  let dartProjectDirectory = path.parse(workingDirectory);

  runDartFrogNewCommand(routeName, workingDirectory);
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
 * @returns {void}
 */
function runDartFrogNewCommand(routeName: String, workingDirectory: String) {
  const command = `dart_frog new route ${routeName}`;

  cp.exec(
    command,
    {
      cwd: workingDirectory,
    },
    function (error: Error, stdout: String, stderr: String) {
      if (error) {
        // TODO(alestiago): Parse error message and show it in a more user-friendly way.
        window.showErrorMessage(stderr.toString());
      }
    }
  );
}
