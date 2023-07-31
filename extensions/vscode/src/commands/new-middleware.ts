const cp = require("child_process");

import { Uri, window, OpenDialogOptions, ProgressOptions } from "vscode";
import { nearestDartFrogProject, normalizeRoutePath } from "../utils";

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
 * @param {Uri | undefined} uri
 */
export const newMiddleware = async (uri: Uri | undefined): Promise<void> => {
  let selectedUri;
  if (uri === undefined) {
    selectedUri = await promptForTargetDirectory();
    if (selectedUri === undefined) {
      window.showErrorMessage("Please select a valid directory");
      return;
    }
  } else {
    selectedUri = uri.fsPath;
  }

  const dartFrogProjectPath = nearestDartFrogProject(selectedUri);
  if (dartFrogProjectPath === undefined) {
    window.showErrorMessage(
      "No Dart Frog project found in the selected directory"
    );
    return;
  }

  const routePath = normalizeRoutePath(selectedUri, dartFrogProjectPath);

  const options: ProgressOptions = {
    location: 15,
    title: `Creating '${routePath}' middleware...`,
  };
  window.withProgress(options, async function () {
    executeDartFrogNewMiddlewareCommand(routePath, dartFrogProjectPath);
  });
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
 * Runs the `dart_frog new middleware` command with the given route path.
 *
 * @param {string} routePath, the path of the new middleware.
 * @param {String} dartFrogProjectPath, the root of the Dart Frog project.
 */
function executeDartFrogNewMiddlewareCommand(
  routePath: String,
  dartFrogProjectPath: String
): void {
  cp.exec(
    `dart_frog new middleware '${routePath}'`,
    {
      cwd: dartFrogProjectPath,
    },
    function (error: Error, stdout: String, stderr: String) {
      if (error) {
        window.showErrorMessage(error.message);
      }
    }
  );
}
