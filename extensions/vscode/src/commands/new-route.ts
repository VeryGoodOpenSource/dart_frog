import {
  InputBoxOptions,
  OpenDialogOptions,
  Uri,
  window,
  workspace,
} from "vscode";

export const newRoute = async (uri: Uri) => {
  const routeName = await getRouteName();
};

/**
 * Shows an input box to the user and returns a Thenable that resolves to a string
 * the user provided.
 * @returns { Thenable<string | undefined>} routeName
 */
function getRouteName(): Thenable<string | undefined> {
  const blocNamePromptOptions: InputBoxOptions = {
    prompt: "Route name",
    placeHolder: "index",
  };
  return window.showInputBox(blocNamePromptOptions);
}
