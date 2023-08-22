const sinon = require("sinon");
var proxyquire = require("proxyquire");

import { afterEach, beforeEach } from "mocha";
import { DartFrogApplication } from "../../../daemon";

suite("start-dev-server command", () => {
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
      commands: {
        executeCommand: sinon.stub(),
      },
    };

    utilsStub = {
      isDartFrogCLIInstalled: sinon.stub(),
      suggestInstallingDartFrogCLI: sinon.stub(),
      resolveDartFrogProjectPathFromWorkspace: sinon.stub(),
      nearestDartFrogProject: sinon.stub(),
    };
    utilsStub.isDartFrogCLIInstalled.returns(true);

    dartFrogDaemon = {
      // eslint-disable-next-line @typescript-eslint/naming-convention
      DartFrogDaemon: sinon.stub(),
    };
    dartFrogDaemon.DartFrogDaemon.instance = sinon.stub();

    command = proxyquire("../../../commands/start-dev-server", {
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
    dartFrogDaemon.DartFrogDaemon.instance.applicationRegistry = sinon.stub();
    dartFrogDaemon.DartFrogDaemon.instance.applicationRegistry.all = sinon
      .stub()
      .returns([]);
    utilsStub.resolveDartFrogProjectPathFromWorkspace.returns(undefined);
    utilsStub.nearestDartFrogProject.returns(undefined);

    await command.startDevServer();

    sinon.assert.calledOnceWithExactly(
      utilsStub.suggestInstallingDartFrogCLI,
      "Running this command requires Dart Frog CLI to be installed."
    );
  });

  test("does not suggest installing Dart Frog CLI when installed", async () => {
    utilsStub.isDartFrogCLIInstalled.returns(true);
    dartFrogDaemon.DartFrogDaemon.instance.isReady = true;
    dartFrogDaemon.DartFrogDaemon.instance.applicationRegistry = sinon.stub();
    dartFrogDaemon.DartFrogDaemon.instance.applicationRegistry.all = sinon
      .stub()
      .returns([]);
    utilsStub.resolveDartFrogProjectPathFromWorkspace.returns(undefined);
    utilsStub.nearestDartFrogProject.returns(undefined);

    await command.startDevServer();

    sinon.assert.notCalled(utilsStub.suggestInstallingDartFrogCLI);
  });

  test("starts daemon if not ready", async () => {
    utilsStub.isDartFrogCLIInstalled.returns(true);
    dartFrogDaemon.DartFrogDaemon.instance.isReady = false;
    dartFrogDaemon.DartFrogDaemon.instance.applicationRegistry = sinon.stub();
    dartFrogDaemon.DartFrogDaemon.instance.applicationRegistry.all = sinon
      .stub()
      .returns([]);
    utilsStub.resolveDartFrogProjectPathFromWorkspace.returns(undefined);
    utilsStub.nearestDartFrogProject.returns(undefined);

    await command.startDevServer();

    sinon.assert.calledOnceWithExactly(
      vscodeStub.commands.executeCommand,
      "dart-frog.start-daemon"
    );
  });

  test("does not start daemon if already ready", async () => {
    utilsStub.isDartFrogCLIInstalled.returns(true);
    dartFrogDaemon.DartFrogDaemon.instance.isReady = true;
    dartFrogDaemon.DartFrogDaemon.instance.applicationRegistry = sinon.stub();
    dartFrogDaemon.DartFrogDaemon.instance.applicationRegistry.all = sinon
      .stub()
      .returns([]);
    utilsStub.resolveDartFrogProjectPathFromWorkspace.returns(undefined);
    utilsStub.nearestDartFrogProject.returns(undefined);

    await command.startDevServer();

    sinon.assert.neverCalledWith(
      vscodeStub.commands.executeCommand,
      "dart-frog.start-daemon"
    );
  });

  suite("shows confirmation before running", () => {
    beforeEach(() => {
      utilsStub.isDartFrogCLIInstalled.returns(true);
      dartFrogDaemon.DartFrogDaemon.instance.isReady = true;
      dartFrogDaemon.DartFrogDaemon.instance.applicationRegistry = sinon.stub();
      utilsStub.resolveDartFrogProjectPathFromWorkspace.returns(undefined);
      utilsStub.nearestDartFrogProject.returns(undefined);
    });

    test("when there is already a running server", async () => {
      dartFrogDaemon.DartFrogDaemon.instance.applicationRegistry.all = sinon
        .stub()
        .returns([new DartFrogApplication("test", 8080, 8181)]);

      await command.startDevServer();

      sinon.assert.calledOnceWithExactly(
        vscodeStub.window.showInformationMessage,
        "A server is already running, would you like to start another server?",
        "Start another server",
        "Cancel"
      );
    });

    test("when there is already more than one running server", async () => {
      dartFrogDaemon.DartFrogDaemon.instance.applicationRegistry.all = sinon
        .stub()
        .returns([
          new DartFrogApplication("test", 8080, 8181),
          new DartFrogApplication("test2", 8081, 8182),
        ]);

      await command.startDevServer();

      sinon.assert.calledOnceWithExactly(
        vscodeStub.window.showInformationMessage,
        "There are 2 servers already running, would you like to start another server?",
        "Start another server",
        "Cancel"
      );
    });
  });

  suite("does not start server", () => {
    test("when user cancelled confirmation when there is already a running server", async () => {});

    test("when user cancelled confirmation when there is already more than one running server", async () => {});
  });
});
