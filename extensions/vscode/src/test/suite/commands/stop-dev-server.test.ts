const sinon = require("sinon");
var proxyquire = require("proxyquire");

import * as assert from "assert";
import {
  DaemonResponse,
  DartFrogApplication,
  StopDaemonRequest,
} from "../../../daemon";
import { afterEach, beforeEach } from "mocha";

suite("stop-dev-server command", () => {
  let vscodeStub: any;
  let utilsStub: any;
  let daemon: any;
  let command: any;
  let progress: any;

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
      resolveDartFrogProjectPathFromWorkspaceFolders: sinon.stub(),
      nearestParentDartFrogProject: sinon.stub(),
      quickPickApplication: sinon.stub(),
      quickPickProject: sinon.stub(),
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
    });

    test("is not shown when there is a single running application", async () => {
      daemon.applicationRegistry.all.returns([application1]);

      await command.stopDevServer();

      sinon.assert.notCalled(utilsStub.quickPickApplication);
    });

    test("is shown when there is more than a single running application", async () => {
      daemon.applicationRegistry.all.returns([application1, application2]);
      utilsStub.quickPickApplication.resolves(application1);

      await command.stopDevServer();

      sinon.assert.calledOnceWithExactly(
        utilsStub.quickPickApplication,
        {
          placeHolder: "Select a server to stop",
        },
        [application1, application2]
      );
    });

    test("never stops the server when dismissed", async () => {
      daemon.applicationRegistry.all.returns([application1, application2]);
      utilsStub.quickPickApplication.resolves(undefined);

      await command.stopDevServer();

      sinon.assert.notCalled(daemon.send);
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

    suite("stop error message", () => {
      test("is shown when error occurs", async () => {
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

      test('is not shown when error is "Application not found"', async () => {
        const stopResponse: DaemonResponse = {
          id: stopRequest.id,
          result: undefined,
          error: {
            message: "Application not found",
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

        sinon.assert.neverCalledWith(
          vscodeStub.window.showErrorMessage,
          stopResponse.error.message
        );
        sinon.assert.calledOnce(progress.report);
      });
    });

    test("takes at least 250ms before resolving", async () => {
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

      const start = Date.now();
      await progressFunction(progress);
      const end = Date.now();
      const elapsed = end - start;

      assert.ok(elapsed >= 250);
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
