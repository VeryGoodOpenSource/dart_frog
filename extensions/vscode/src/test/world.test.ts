var assert = require("assert");

import { Workbench, ModalDialog } from "vscode-extension-tester";

describe("Sample Command palette tests", () => {
  it("using executeCommand", async () => {
    await new Workbench().executeCommand("Dart Frog: New Route");

    const dialog = new ModalDialog();
    const message = dialog.getMessage();
    assert.equal(message, "Please enter a valid route name");
  });
});
