const sinon = require("sinon");
var proxyquire = require("proxyquire");

import { afterEach, beforeEach } from "mocha";

suite("create command", () => {
  const targetUri = { fsPath: "/home/dart_frog" };

  let vscodeStub: any;
  let childProcessStub: any;
  let utilsStub: any;
  let command: any;

  beforeEach(() => {
    vscodeStub = {
      window: {
        showErrorMessage: sinon.stub(),
        showInputBox: sinon.stub(),
        showOpenDialog: sinon.stub(),
        withProgress: sinon.stub(),
      },
    };
    childProcessStub = {
      exec: sinon.stub(),
    };
    utilsStub = {
      isDartFrogCLIInstalled: sinon.stub(),
      suggestInstallingDartFrogCLI: sinon.stub(),
    };
    utilsStub.isDartFrogCLIInstalled.returns(true);

    command = proxyquire("../../../commands/create", {
      vscode: vscodeStub,
      // eslint-disable-next-line @typescript-eslint/naming-convention
      child_process: childProcessStub,
      // eslint-disable-next-line @typescript-eslint/naming-convention
      "../utils": utilsStub,
    });
  });

  afterEach(() => {
    sinon.restore();
  });

  test("suggests installing Dart Frog CLI when not installed", async () => {
    utilsStub.isDartFrogCLIInstalled.returns(false);

    await command.create(targetUri);

    sinon.assert.calledWith(
      utilsStub.suggestInstallingDartFrogCLI,
      "Running this command requires Dart Frog CLI to be installed."
    );
  });

  test("does not suggest installing Dart Frog CLI when installed", async () => {
    utilsStub.isDartFrogCLIInstalled.returns(true);

    await command.create(targetUri);

    sinon.assert.notCalled(utilsStub.suggestInstallingDartFrogCLI);
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
      vscodeStub.window.showOpenDialog.resolves();

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
      vscodeStub.window.showInputBox.returns("my_project");

      await command.create(targetUri);

      sinon.assert.neverCalledWith(
        vscodeStub.window.showErrorMessage,
        "Please enter a project name"
      );
    });
  });

  suite("progress", () => {
    test("is shown when prompt is valid", async () => {
      const projectName = "my_project";
      vscodeStub.window.showInputBox.returns(projectName);

      await command.create(targetUri);

      sinon.assert.calledOnceWithMatch(vscodeStub.window.withProgress, {
        location: 15,
        title: `Creating ${projectName} Dart Frog Project...`,
      });
    });

    test("is not shown when prompt is undefined", async () => {
      vscodeStub.window.showInputBox.returns(undefined);

      await command.create(targetUri);

      sinon.assert.notCalled(vscodeStub.window.withProgress);
    });

    test("is not shown when prompt is empty", async () => {
      vscodeStub.window.showInputBox.returns("");

      await command.create(targetUri);

      sinon.assert.notCalled(vscodeStub.window.withProgress);
    });

    test("is not shown when prompt is white spaced", async () => {
      vscodeStub.window.showInputBox.returns("  ");

      await command.create(targetUri);

      sinon.assert.notCalled(vscodeStub.window.withProgress);
    });
  });

  test("runs `dart_frog create` command when project name is valid and uri is defined", async () => {
    vscodeStub.window.showInputBox.returns("my_project");

    await command.create(targetUri);

    const progressFunction = vscodeStub.window.withProgress.getCall(0).args[1];
    await progressFunction();

    sinon.assert.calledOnceWithMatch(
      childProcessStub.exec,
      "dart_frog create 'my_project'",
      { cwd: targetUri.fsPath }
    );
  });

  test("runs `dart_frog create` command when project name is valid and uri not defined", async () => {
    vscodeStub.window.showOpenDialog.resolves([targetUri]);
    vscodeStub.window.showInputBox.returns("my_project");

    await command.create();

    const progressFunction = vscodeStub.window.withProgress.getCall(0).args[1];
    await progressFunction();

    sinon.assert.calledOnceWithMatch(
      childProcessStub.exec,
      "dart_frog create 'my_project'",
      { cwd: targetUri.fsPath }
    );
  });

  test("shows error when `dart_frog create` command fails", async () => {
    const error = new Error("Command failed");
    const createCommand = "dart_frog create 'my_project'";

    vscodeStub.window.showInputBox.returns("my_project");
    childProcessStub.exec.withArgs(createCommand).yields(error);

    await command.create(targetUri);

    const progressFunction = vscodeStub.window.withProgress.getCall(0).args[1];
    await progressFunction();

    sinon.assert.calledWith(vscodeStub.window.showErrorMessage, error.message);
  });
});
