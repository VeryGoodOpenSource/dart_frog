const sinon = require("sinon");
var proxyquire = require("proxyquire");

import { afterEach, beforeEach } from "mocha";

suite("create command", () => {
  const targetUri = { fsPath: "/home/dart_frog" };

  let vscodeStub: any;
  let childProcessStub: any;
  let command: any;

  beforeEach(() => {
    vscodeStub = {
      window: {
        showErrorMessage: sinon.stub(),
        showInputBox: sinon.stub(),
        showOpenDialog: sinon.stub(),
      },
    };
    childProcessStub = {
      exec: sinon.stub(),
    };

    command = proxyquire("../../../commands/create", {
      vscode: vscodeStub,
      // eslint-disable-next-line @typescript-eslint/naming-convention
      child_process: childProcessStub,
    });
  });

  afterEach(() => {
    sinon.restore();
  });

  test("project input box is shown with directory name as value", async () => {
    await command.create(targetUri);

    sinon.assert.calledOnceWithExactly(vscodeStub.window.showInputBox, {
      prompt: "Project name",
      value: "dart_frog",
    });
  });

  suite("file open dialog", () => {
    test("is shown when Uri is undefined", async () => {
      vscodeStub.window.showOpenDialog.returns(Promise.resolve(undefined));

      await command.create();

      sinon.assert.calledOnceWithExactly(vscodeStub.window.showOpenDialog, {
        canSelectMany: false,
        openLabel: "Select a folder or file to create the project in",
        canSelectFolders: true,
        canSelectFiles: true,
      });
    });

    test("is not shown when Uri is defined", async () => {
      await command.create(targetUri);

      sinon.assert.notCalled(vscodeStub.window.showOpenDialog);
    });
  });

  suite("error message", () => {
    test("is shown when prompt is undefined", async () => {
      vscodeStub.window.showInputBox.returns(undefined);

      await command.create(targetUri);

      sinon.assert.calledOnceWithExactly(
        vscodeStub.window.showErrorMessage,
        "Please enter a project name"
      );
    });

    test("is shown when prompt is empty", async () => {
      vscodeStub.window.showInputBox.returns("");

      await command.create(targetUri);

      sinon.assert.calledOnceWithExactly(
        vscodeStub.window.showErrorMessage,
        "Please enter a project name"
      );
    });

    test("is shown when prompt is white spaced", async () => {
      vscodeStub.window.showInputBox.returns("  ");

      await command.create(targetUri);

      sinon.assert.calledOnceWithExactly(
        vscodeStub.window.showErrorMessage,
        "Please enter a project name"
      );
    });

    test("is not shown when prompt is valid", async () => {
      vscodeStub.window.showInputBox.returns("dart_frog");

      await command.create(targetUri);

      sinon.assert.neverCalledWith(
        vscodeStub.window.showErrorMessage,
        "Please enter a project name"
      );
    });
  });
});
