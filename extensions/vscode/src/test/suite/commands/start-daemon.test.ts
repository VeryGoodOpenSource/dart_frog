const sinon = require("sinon");
var proxyquire = require("proxyquire");

import { afterEach, beforeEach } from "mocha";

suite("start-daemon command", () => {
  let vscodeStub: any;
  let utilsStub: any;
  let dartFrogDaemon: any;
  let command: any;

  beforeEach(() => {
    vscodeStub = {
      window: {
        showInformationMessage: sinon.stub(),
        showErrorMessage: sinon.stub(),
        withProgress: sinon.stub(),
      },
    };

    utilsStub = {
      isDartFrogCLIInstalled: sinon.stub(),
      suggestInstallingDartFrogCLI: sinon.stub(),
      resolveDartFrogProjectPathFromActiveTextEditor: sinon.stub(),
      resolveDartFrogProjectPathFromWorkspaceFolders: sinon.stub(),
      nearestParentDartFrogProject: sinon.stub(),
    };
    utilsStub.isDartFrogCLIInstalled.returns(true);

    dartFrogDaemon = {
      // eslint-disable-next-line @typescript-eslint/naming-convention
      DartFrogDaemon: sinon.stub(),
    };
    dartFrogDaemon.DartFrogDaemon.instance = sinon.stub();

    command = proxyquire("../../../commands/start-daemon", {
      vscode: vscodeStub,
      // eslint-disable-next-line @typescript-eslint/naming-convention
      "../utils": utilsStub,
      // eslint-disable-next-line @typescript-eslint/naming-convention
      "../daemon": dartFrogDaemon,
    });
  });

  afterEach(() => {
    sinon.restore();
  });

  test("suggests installing Dart Frog CLI when not installed", async () => {
    utilsStub.isDartFrogCLIInstalled.returns(false);

    dartFrogDaemon.DartFrogDaemon.instance.isReady = true;

    await command.startDaemon();

    sinon.assert.calledOnceWithExactly(
      utilsStub.suggestInstallingDartFrogCLI,
      "Running this command requires Dart Frog CLI to be installed."
    );
  });

  test("does not suggest installing Dart Frog CLI when installed", async () => {
    utilsStub.isDartFrogCLIInstalled.returns(true);

    dartFrogDaemon.DartFrogDaemon.instance.isReady = true;

    await command.startDaemon();

    sinon.assert.notCalled(utilsStub.suggestInstallingDartFrogCLI);
  });

  test("shows information message when already running", async () => {
    utilsStub.isDartFrogCLIInstalled.returns(true);

    dartFrogDaemon.DartFrogDaemon.instance.isReady = true;

    await command.startDaemon();

    sinon.assert.calledOnceWithExactly(
      vscodeStub.window.showInformationMessage,
      "Daemon is already running."
    );
  });

  suite("shows error", () => {
    test("when failed to find Dart Frog project path from workspace folders and active text editor", async () => {
      utilsStub.isDartFrogCLIInstalled.returns(true);
      dartFrogDaemon.DartFrogDaemon.instance.isReady = false;
      utilsStub.resolveDartFrogProjectPathFromWorkspaceFolders.returns();
      utilsStub.resolveDartFrogProjectPathFromActiveTextEditor.returns();

      await command.startDaemon();

      sinon.assert.calledOnceWithExactly(
        vscodeStub.window.showErrorMessage,
        "Failed to find a Dart Frog project within the current workspace."
      );
    });

    test("when failed to find Dart Frog root project path", async () => {
      utilsStub.isDartFrogCLIInstalled.returns(true);
      dartFrogDaemon.DartFrogDaemon.instance.isReady = false;
      utilsStub.resolveDartFrogProjectPathFromWorkspaceFolders.returns("path");
      utilsStub.nearestParentDartFrogProject.returns();

      await command.startDaemon();

      sinon.assert.calledOnceWithExactly(
        vscodeStub.window.showErrorMessage,
        "Failed to find a Dart Frog project within the current workspace."
      );
    });
  });

  suite("starts daemon", () => {
    test("starts daemon when found a Dart Frog project path from workspace folder", async () => {
      utilsStub.isDartFrogCLIInstalled.returns(true);
      dartFrogDaemon.DartFrogDaemon.instance.isReady = false;
      dartFrogDaemon.DartFrogDaemon.instance.invoke = sinon.stub();
      utilsStub.resolveDartFrogProjectPathFromWorkspaceFolders.returns([
        "path",
        "another-path",
      ]);
      utilsStub.nearestParentDartFrogProject.returns("path");

      await command.startDaemon();

      const progressFunction =
        vscodeStub.window.withProgress.getCall(0).args[1];
      const progress = sinon.stub();
      progress.report = sinon.stub();
      await progressFunction(progress);

      sinon.assert.calledOnceWithExactly(
        dartFrogDaemon.DartFrogDaemon.instance.invoke,
        "path"
      );
    });

    test("starts daemon when found a Dart Frog project path from active text editor", async () => {
      utilsStub.isDartFrogCLIInstalled.returns(true);
      dartFrogDaemon.DartFrogDaemon.instance.isReady = false;
      dartFrogDaemon.DartFrogDaemon.instance.invoke = sinon.stub();
      utilsStub.resolveDartFrogProjectPathFromWorkspaceFolders.returns();
      utilsStub.resolveDartFrogProjectPathFromActiveTextEditor.returns("path");
      utilsStub.nearestParentDartFrogProject.returns("path");

      await command.startDaemon();

      const progressFunction =
        vscodeStub.window.withProgress.getCall(0).args[1];
      const progress = sinon.stub();
      progress.report = sinon.stub();
      await progressFunction(progress);

      sinon.assert.called(
        utilsStub.resolveDartFrogProjectPathFromWorkspaceFolders
      );
      sinon.assert.calledOnceWithExactly(
        dartFrogDaemon.DartFrogDaemon.instance.invoke,
        "path"
      );
    });
  });

  test("updates progress when starting daemon", async () => {
    utilsStub.isDartFrogCLIInstalled.returns(true);
    dartFrogDaemon.DartFrogDaemon.instance.isReady = false;
    dartFrogDaemon.DartFrogDaemon.instance.invoke = sinon.stub();
    utilsStub.resolveDartFrogProjectPathFromWorkspaceFolders.returns("path");
    utilsStub.nearestParentDartFrogProject.returns("path");

    await command.startDaemon();

    const progressFunction = vscodeStub.window.withProgress.getCall(0).args[1];
    const progress = sinon.stub();
    progress.report = sinon.stub();
    await progressFunction(progress);

    sinon.assert.calledWith(progress.report.getCall(0), {
      message: "Starting daemon...",
    });
    sinon.assert.calledWith(progress.report.getCall(1), {
      message: "Daemon successfully started.",
      increment: 100,
    });
  });

  suite("does not start daemon", () => {
    test("when it is already running", async () => {
      utilsStub.isDartFrogCLIInstalled.returns(true);
      dartFrogDaemon.DartFrogDaemon.instance.isReady = true;
      dartFrogDaemon.DartFrogDaemon.instance.invoke = sinon.stub();

      await command.startDaemon();

      sinon.assert.notCalled(dartFrogDaemon.DartFrogDaemon.instance.invoke);
    });

    test("when failed to find Dart Frog project path from workspace folders and active text editor", async () => {
      utilsStub.isDartFrogCLIInstalled.returns(true);
      dartFrogDaemon.DartFrogDaemon.instance.isReady = false;
      dartFrogDaemon.DartFrogDaemon.instance.invoke = sinon.stub();
      utilsStub.resolveDartFrogProjectPathFromWorkspaceFolders.returns();
      utilsStub.resolveDartFrogProjectPathFromActiveTextEditor.returns();

      await command.startDaemon();

      sinon.assert.notCalled(dartFrogDaemon.DartFrogDaemon.instance.invoke);
    });

    test("when failed to find Dart Frog root project path", async () => {
      utilsStub.isDartFrogCLIInstalled.returns(true);
      dartFrogDaemon.DartFrogDaemon.instance.isReady = false;
      dartFrogDaemon.DartFrogDaemon.instance.invoke = sinon.stub();
      utilsStub.resolveDartFrogProjectPathFromWorkspaceFolders.returns("path");
      utilsStub.nearestParentDartFrogProject.returns(undefined);

      await command.startDaemon();

      sinon.assert.notCalled(dartFrogDaemon.DartFrogDaemon.instance.invoke);
    });
  });
});
