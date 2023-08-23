const sinon = require("sinon");
var proxyquire = require("proxyquire");

import { afterEach, beforeEach } from "mocha";
import {
  DaemonResponse,
  DartFrogApplication,
  StartDaemonRequest,
  StopDaemonRequest,
} from "../../../daemon";
import { Uri } from "vscode";
import { assert } from "console";

suite("stop-dev-server command", () => {
  let vscodeStub: any;
  let utilsStub: any;
  let daemon: any;
  let command: any;
  let quickPick: any;
  let progress: any;

  beforeEach(() => {
    vscodeStub = {
      window: {
        showInformationMessage: sinon.stub(),
        showErrorMessage: sinon.stub(),
        withProgress: sinon.stub(),
        createQuickPick: sinon.stub(),
      },
      commands: {
        executeCommand: sinon.stub(),
      },
    };
    quickPick = sinon.stub();
    vscodeStub.window.createQuickPick.returns(quickPick);
    quickPick.show = sinon.stub();
    quickPick.dispose = sinon.stub();
    quickPick.onDidChangeSelection = sinon.stub();

    utilsStub = {
      isDartFrogCLIInstalled: sinon.stub(),
      suggestInstallingDartFrogCLI: sinon.stub(),
      resolveDartFrogProjectPathFromWorkspace: sinon.stub(),
      nearestDartFrogProject: sinon.stub(),
    };
    utilsStub.isDartFrogCLIInstalled.returns(true);

    const dartFrogDaemon = {
      // eslint-disable-next-line @typescript-eslint/naming-convention
      DartFrogDaemon: sinon.stub(),
    };
    dartFrogDaemon.DartFrogDaemon.instance = sinon.stub();
    daemon = dartFrogDaemon.DartFrogDaemon.instance;
    daemon.applicationRegistry = sinon.stub();
    daemon.applicationRegistry.all = sinon.stub();
    daemon.applicationRegistry.on = sinon.stub();
    daemon.applicationRegistry.off = sinon.stub();
    daemon.requestIdentifierGenerator = sinon.stub();
    daemon.requestIdentifierGenerator.generate = sinon.stub();
    daemon.send = sinon.stub();

    command = proxyquire("../../../commands/stop-dev-server", {
      vscode: vscodeStub,
      // eslint-disable-next-line @typescript-eslint/naming-convention
      "../utils": utilsStub,
      // eslint-disable-next-line @typescript-eslint/naming-convention
      "../daemon": dartFrogDaemon,
    });

    progress = sinon.stub();
    progress.report = sinon.stub();
  });

  afterEach(() => {
    sinon.restore();
  });

  suite("installing Dart Frog CLI", () => {
    beforeEach(() => {
      daemon.isReady = false;
      daemon.applicationRegistry.all.returns([]);
    });

    test("is suggested when not installed", async () => {
      utilsStub.isDartFrogCLIInstalled.returns(false);

      await command.stopDevServer();

      sinon.assert.calledOnceWithExactly(
        utilsStub.suggestInstallingDartFrogCLI,
        "Running this command requires Dart Frog CLI to be installed."
      );
    });

    test("is not suggested when already installed", async () => {
      utilsStub.isDartFrogCLIInstalled.returns(true);

      await command.stopDevServer();

      sinon.assert.notCalled(utilsStub.suggestInstallingDartFrogCLI);
    });
  });

  suite("no running servers information", () => {
    const message = "No running servers found.";
    const startOption = "Start server";
    const cancelOption = "Cancel";

    beforeEach(() => {
      utilsStub.isDartFrogCLIInstalled.returns(true);
    });

    suite("is shown", () => {
      test("when daemon is not ready", async () => {
        daemon.isReady = false;
        daemon.applicationRegistry.all.returns([]);

        await command.stopDevServer();

        sinon.assert.calledOnceWithExactly(
          vscodeStub.window.showInformationMessage,
          message,
          startOption,
          cancelOption
        );
      });

      test("when daemon is ready but no application is registered", async () => {
        daemon.isReady = true;
        daemon.applicationRegistry.all.returns([]);

        await command.stopDevServer();

        sinon.assert.calledOnceWithExactly(
          vscodeStub.window.showInformationMessage,
          message,
          startOption,
          cancelOption
        );
      });
    });

    test("is not shown when daemon is ready and applications are registered", async () => {
      daemon.isReady = true;
      daemon.applicationRegistry.all.returns([
        new DartFrogApplication("workingDirectory", 8080, 8181),
      ]);

      await command.stopDevServer();

      sinon.assert.notCalled(
        vscodeStub.window.showInformationMessage.withArgs(
          message,
          startOption,
          cancelOption
        )
      );
    });

    test("start server option runs start server command", async () => {
      daemon.isReady = false;
      daemon.applicationRegistry.all.returns([]);

      vscodeStub.window.showInformationMessage
        .withArgs(message, startOption, cancelOption)
        .resolves(startOption);

      await command.stopDevServer();

      sinon.assert.calledOnceWithExactly(
        vscodeStub.commands.executeCommand,
        "dart-frog.start-dev-server"
      );
    });

    suite("never stops the server", () => {
      beforeEach(() => {
        daemon.isReady = false;
        daemon.applicationRegistry.all.returns([]);
      });

      test("when `Start server` option is selected", async () => {
        vscodeStub.window.showInformationMessage
          .withArgs(message, startOption, cancelOption)
          .resolves(startOption);

        await command.stopDevServer();

        sinon.assert.notCalled(daemon.send);
      });

      test("when `Cancel` option is selected", async () => {
        vscodeStub.window.showInformationMessage
          .withArgs(message, startOption, cancelOption)
          .resolves(cancelOption);

        await command.stopDevServer();

        sinon.assert.notCalled(daemon.send);
      });

      test("when dismissed", async () => {
        vscodeStub.window.showInformationMessage
          .withArgs(message, startOption, cancelOption)
          .resolves(undefined);

        await command.stopDevServer();

        sinon.assert.notCalled(daemon.send);
      });
    });
  });

  suite("applications quick pick", () => {
    const application1 = new DartFrogApplication(
      "workingDirectory",
      8080,
      8181
    );
    const application2 = new DartFrogApplication(
      "workingDirectory",
      8081,
      8182
    );

    beforeEach(() => {
      daemon.isReady = true;

      application1.id = "application1";
      application1.address = `http://localhost:${application1.port}`;

      application2.id = "application2";
      application2.address = `http://localhost:${application2.port}`;
    });

    test("is not shown when there is a single running application", async () => {
      daemon.applicationRegistry.all.returns([application1]);

      await command.stopDevServer();

      sinon.assert.notCalled(vscodeStub.window.createQuickPick);
    });

    test("is shown when there is more than a single running application", async () => {
      daemon.applicationRegistry.all.returns([application1, application2]);

      const stopDevServer = command.stopDevServer();
      const onDidChangeSelection =
        quickPick.onDidChangeSelection.getCall(0).args[0];
      onDidChangeSelection([]);

      await stopDevServer;

      sinon.assert.calledOnce(vscodeStub.window.createQuickPick);
    });

    test("never stops the server when dismissed", async () => {
      daemon.applicationRegistry.all.returns([application1, application2]);

      const stopDevServer = command.stopDevServer();
      const onDidChangeSelection =
        quickPick.onDidChangeSelection.getCall(0).args[0];
      onDidChangeSelection(undefined);

      await stopDevServer;

      sinon.assert.notCalled(daemon.send);
    });

    test("shows appropiate items for each running applications", async () => {
      daemon.applicationRegistry.all.returns([application1, application2]);

      const stopDevServer = command.stopDevServer();
      const onDidChangeSelection =
        quickPick.onDidChangeSelection.getCall(0).args[0];
      onDidChangeSelection(undefined);

      await stopDevServer;

      const items = quickPick.items;

      sinon.assert.match(items[0], {
        label: `$(globe) localhost:${application1.port}`,
        description: application1.id,
        application: application1,
      });
      sinon.assert.match(items[1], {
        label: `$(globe) localhost:${application2.port}`,
        description: application2.id,
        application: application2,
      });
    });

    test("is disposed after selection", async () => {
      daemon.applicationRegistry.all.returns([application1, application2]);

      const stopDevServer = command.stopDevServer();
      const onDidChangeSelection =
        quickPick.onDidChangeSelection.getCall(0).args[0];
      onDidChangeSelection([application1]);

      await stopDevServer;

      sinon.assert.calledOnce(quickPick.dispose);
    });
  });

  suite("progress", () => {
    const application = new DartFrogApplication("workingDirectory", 8080, 8181);
    const stopRequest = new StopDaemonRequest("test", "application1");

    beforeEach(() => {
      application.id = stopRequest.params.applicationId;

      daemon.isReady = true;
      daemon.applicationRegistry.all.returns([application]);
      daemon.requestIdentifierGenerator.generate.returns(stopRequest.id);
    });

    test("is shown when stopping server", async () => {
      const stopResponse: DaemonResponse = {
        id: stopRequest.id,
        result: "success",
        error: undefined,
      };
      daemon.send.withArgs(stopRequest).resolves(stopResponse);

      await command.stopDevServer();

      sinon.assert.calledOnceWithExactly(
        vscodeStub.window.withProgress,
        {
          location: 15,
        },
        sinon.match.any
      );

      const deregistrationListener =
        daemon.applicationRegistry.on.getCall(0).args[1];
      deregistrationListener(application);

      const progressFunction =
        vscodeStub.window.withProgress.getCall(0).args[1];
      await progressFunction(progress);

      sinon.assert.calledWith(progress.report.getCall(0), {
        message: `Stopping server...`,
      });

      sinon.assert.calledWith(progress.report.getCall(1), {
        message: `Deregistering server...`,
        increment: 75,
      });

      sinon.assert.calledWith(progress.report.getCall(2), {
        message: `Server stopped successfully`,
        increment: 100,
      });
    });

    test("shows error message when error occurs", async () => {
      const stopResponse: DaemonResponse = {
        id: stopRequest.id,
        result: undefined,
        error: {
          message: "error message",
        },
      };
      daemon.send.withArgs(stopRequest).resolves(stopResponse);

      await command.stopDevServer();

      const deregistrationListener =
        daemon.applicationRegistry.on.getCall(0).args[1];
      deregistrationListener(application);

      const progressFunction =
        vscodeStub.window.withProgress.getCall(0).args[1];
      await progressFunction(progress);

      sinon.assert.calledWith(
        vscodeStub.window.showErrorMessage,
        stopResponse.error.message
      );
      sinon.assert.calledOnce(progress.report);
    });
  });

  test("stops server", async () => {
    const application = new DartFrogApplication("workingDirectory", 8080, 8181);
    const stopRequest = new StopDaemonRequest("test", "application1");
    const stopResponse: DaemonResponse = {
      id: stopRequest.id,
      result: "success",
      error: undefined,
    };

    application.id = stopRequest.params.applicationId;

    utilsStub.isDartFrogCLIInstalled.returns(true);
    daemon.isReady = true;
    daemon.applicationRegistry.all.returns([application]);
    daemon.requestIdentifierGenerator.generate.returns(stopRequest.id);
    daemon.send.withArgs(stopRequest).resolves(stopResponse);

    await command.stopDevServer();

    const deregistrationListener =
      daemon.applicationRegistry.on.getCall(0).args[1];
    deregistrationListener(application);

    const progressFunction = vscodeStub.window.withProgress.getCall(0).args[1];
    await progressFunction(progress);

    sinon.assert.calledOnceWithExactly(daemon.send, stopRequest);
  });
});
