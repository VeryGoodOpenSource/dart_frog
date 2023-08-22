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
        showInputBox: sinon.stub(),
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

  suite("confirmation before running", () => {
    beforeEach(() => {
      utilsStub.isDartFrogCLIInstalled.returns(true);
      dartFrogDaemon.DartFrogDaemon.instance.isReady = true;
      dartFrogDaemon.DartFrogDaemon.instance.applicationRegistry = sinon.stub();
      utilsStub.resolveDartFrogProjectPathFromWorkspace.returns(undefined);
      utilsStub.nearestDartFrogProject.returns(undefined);
    });

    suite("is shown", () => {
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

    test("is not shown when there is no running server", async () => {
      dartFrogDaemon.DartFrogDaemon.instance.applicationRegistry.all = sinon
        .stub()
        .returns([]);

      await command.startDevServer();

      sinon.assert.neverCalledWith(
        vscodeStub.window.showInformationMessage,
        "A server is already running, would you like to start another server?",
        "Start another server",
        "Cancel"
      );
      sinon.assert.neverCalledWith(
        vscodeStub.window.showInformationMessage,
        "There are 2 servers already running, would you like to start another server?",
        "Start another server",
        "Cancel"
      );
    });
  });

  suite("asks for port number", () => {
    beforeEach(() => {
      utilsStub.isDartFrogCLIInstalled.returns(true);
      dartFrogDaemon.DartFrogDaemon.instance.isReady = true;
      dartFrogDaemon.DartFrogDaemon.instance.applicationRegistry = sinon.stub();
      utilsStub.resolveDartFrogProjectPathFromWorkspace.returns("path");
      utilsStub.nearestDartFrogProject.returns("path");
    });

    test("with prefilled default value when there are no running servers", async () => {
      dartFrogDaemon.DartFrogDaemon.instance.applicationRegistry.all = sinon
        .stub()
        .returns([]);

      await command.startDevServer();

      sinon.assert.calledOnceWithMatch(vscodeStub.window.showInputBox, {
        prompt: "Which port number the server should start on",
        placeHolder: "8080",
        value: "8080",
        ignoreFocusOut: true,
      });
    });

    test("without prefilled default value when there is already a running server", async () => {
      dartFrogDaemon.DartFrogDaemon.instance.applicationRegistry.all = sinon
        .stub()
        .returns([new DartFrogApplication("test", 8080, 8181)]);
      vscodeStub.window.showInformationMessage.resolves("Start another server");

      await command.startDevServer();

      sinon.assert.calledOnceWithMatch(vscodeStub.window.showInputBox, {
        prompt: "Which port number the server should start on",
        placeHolder: "8080",
        value: undefined,
        ignoreFocusOut: true,
      });
    });
  });

  suite("asks for Dart VM service port number", () => {
    beforeEach(() => {
      utilsStub.isDartFrogCLIInstalled.returns(true);
      dartFrogDaemon.DartFrogDaemon.instance.isReady = true;
      dartFrogDaemon.DartFrogDaemon.instance.applicationRegistry = sinon.stub();
      utilsStub.resolveDartFrogProjectPathFromWorkspace.returns("path");
      utilsStub.nearestDartFrogProject.returns("path");
      vscodeStub.window.showInputBox
        .withArgs({
          prompt: "Which port number the server should start on",
          placeHolder: "8080",
          value: sinon.match.any,
          ignoreFocusOut: true,
          validateInput: sinon.match.any,
        })
        .resolves("8080");
    });

    test("with prefilled default value when there are no running servers", async () => {
      dartFrogDaemon.DartFrogDaemon.instance.applicationRegistry.all = sinon
        .stub()
        .returns([]);

      await command.startDevServer();

      sinon.assert.calledOnce(
        vscodeStub.window.showInputBox.withArgs({
          prompt: "Which port number the Dart VM service should listen on",
          placeHolder: "8181",
          value: "8181",
          ignoreFocusOut: true,
          validateInput: sinon.match.any,
        })
      );
    });

    test("without prefilled default value when there is already a running server", async () => {
      dartFrogDaemon.DartFrogDaemon.instance.applicationRegistry.all = sinon
        .stub()
        .returns([new DartFrogApplication("test", 8080, 8181)]);
      vscodeStub.window.showInformationMessage.resolves("Start another server");

      await command.startDevServer();

      sinon.assert.calledOnce(
        vscodeStub.window.showInputBox.withArgs({
          prompt: "Which port number the Dart VM service should listen on",
          placeHolder: "8181",
          value: undefined,
          ignoreFocusOut: true,
          validateInput: sinon.match.any,
        })
      );
    });
  });

  suite("does not start server", () => {
    test("when there is already a running server and user cancelled confirmation prompt", async () => {});

    test("when there is already more than one running server and user cancelled confirmation prompt", async () => {});

    test("when Dart Frog project path failed to be retrieved", async () => {});

    test("when port number is escaped", async () => {});

    test("when Dart VM service port number is escaped", async () => {});
  });

  suite("starts server", () => {
    test("when there is already a running server and user confirmed confirmation prompt", async () => {});

    test("when there is already more than one running server and user confirmed confirmation prompt", async () => {});
  });
});
