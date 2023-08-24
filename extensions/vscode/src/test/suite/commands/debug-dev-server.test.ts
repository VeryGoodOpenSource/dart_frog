const sinon = require("sinon");
var proxyquire = require("proxyquire");

import { afterEach, beforeEach } from "mocha";
import {
  DaemonResponse,
  DartFrogApplication,
  StopDaemonRequest,
} from "../../../daemon";
import * as assert from "assert";
import { Uri } from "vscode";

suite("debug-dev-server command", () => {
  const application1 = new DartFrogApplication("workingDirectory1", 8080, 8181);
  application1.id = "application1";
  application1.address = `http://localhost:${application1.port}`;
  application1.vmServiceUri = `http://localhost:${application1.vmServicePort}`;

  const application2 = new DartFrogApplication("workingDirectory2", 8081, 8182);
  application2.id = "application2";
  application2.address = `http://localhost:${application2.port}`;
  application2.vmServiceUri = `http://localhost:${application2.vmServicePort}`;

  let vscodeStub: any;
  let utilsStub: any;
  let daemon: any;
  let command: any;
  let dartCodeExtension: any;

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
      extensions: {
        getExtension: sinon.stub(),
      },
      debug: {
        startDebugging: sinon.stub(),
        activeDebugSession: undefined,
      },
    };
    dartCodeExtension = sinon.stub();
    dartCodeExtension.activate = sinon.stub();
    dartCodeExtension.isActive = true;
    vscodeStub.extensions.getExtension
      .withArgs("Dart-Code.dart-code")
      .returns(dartCodeExtension);

    utilsStub = {
      isDartFrogCLIInstalled: sinon.stub(),
      suggestInstallingDartFrogCLI: sinon.stub(),
      quickPickApplication: sinon.stub(),
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
    daemon.applicationRegistry.all.returns([]);
    daemon.isReady = true;

    command = proxyquire("../../../commands/debug-dev-server", {
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

  suite("installing Dart Frog CLI", () => {
    test("is suggested when not installed", async () => {
      utilsStub.isDartFrogCLIInstalled.returns(false);

      await command.debugDevServer();

      sinon.assert.calledOnceWithExactly(
        utilsStub.suggestInstallingDartFrogCLI,
        "Running this command requires Dart Frog CLI to be installed."
      );
    });

    test("is not suggested when already installed", async () => {
      utilsStub.isDartFrogCLIInstalled.returns(true);

      await command.debugDevServer();

      sinon.assert.notCalled(utilsStub.suggestInstallingDartFrogCLI);
    });
  });

  suite("installing Dart extension", () => {
    const message = "Running this command requires the Dart extension.";
    const installOption = "Install Dart extension";
    const cancelOption = "Cancel";

    test("is suggested when not installed", async () => {
      vscodeStub.extensions.getExtension
        .withArgs("Dart-Code.dart-code")
        .returns(undefined);

      await command.debugDevServer();

      sinon.assert.calledOnceWithExactly(
        vscodeStub.window.showErrorMessage,
        message,
        installOption,
        cancelOption
      );
    });

    test("is not suggested when already installed", async () => {
      vscodeStub.extensions.getExtension
        .withArgs("Dart-Code.dart-code")
        .returns(dartCodeExtension);

      await command.debugDevServer();

      sinon.assert.notCalled(
        vscodeStub.window.showErrorMessage.withArgs(
          message,
          installOption,
          cancelOption
        )
      );
    });

    test("`Install Dart extension` option opens marketplace", async () => {
      vscodeStub.extensions.getExtension
        .withArgs("Dart-Code.dart-code")
        .returns(undefined);
      vscodeStub.window.showErrorMessage
        .withArgs(message, installOption, cancelOption)
        .resolves(installOption);

      await command.debugDevServer();

      sinon.assert.calledOnceWithExactly(
        vscodeStub.commands.executeCommand,
        "vscode.open",
        Uri.parse(
          "https://marketplace.visualstudio.com/items?itemName=Dart-Code.dart-code"
        )
      );
    });

    suite("never starts debug session", () => {
      test("when `Install Dart extension` option is selected", async () => {
        vscodeStub.extensions.getExtension
          .withArgs("Dart-Code.dart-code")
          .returns(undefined);
        vscodeStub.window.showErrorMessage
          .withArgs(message, installOption, cancelOption)
          .resolves(installOption);

        await command.debugDevServer();

        sinon.assert.notCalled(vscodeStub.debug.startDebugging);
      });

      test("when `Cancel` option is selected", async () => {
        vscodeStub.extensions.getExtension
          .withArgs("Dart-Code.dart-code")
          .returns(undefined);
        vscodeStub.window.showErrorMessage
          .withArgs(message, installOption, cancelOption)
          .resolves(cancelOption);

        await command.debugDevServer();

        sinon.assert.notCalled(vscodeStub.debug.startDebugging);
      });

      test("when dismissed", async () => {
        vscodeStub.extensions.getExtension
          .withArgs("Dart-Code.dart-code")
          .returns(undefined);
        vscodeStub.window.showErrorMessage
          .withArgs(message, installOption, cancelOption)
          .resolves(undefined);

        await command.debugDevServer();

        sinon.assert.notCalled(vscodeStub.debug.startDebugging);
      });
    });
  });

  suite("Dart extension", () => {
    test("is activated when not active", async () => {
      dartCodeExtension.isActive = false;

      await command.debugDevServer();

      sinon.assert.calledOnceWithExactly(
        vscodeStub.window.withProgress,
        {
          location: 15,
          title: `Activating Dart extension...`,
        },
        sinon.match.any
      );

      const progressFunction =
        vscodeStub.window.withProgress.getCall(0).args[1];
      await progressFunction();

      sinon.assert.calledOnceWithExactly(dartCodeExtension.activate);
    });

    test("is not activated when already active", async () => {
      dartCodeExtension.isActive = true;

      await command.debugDevServer();

      sinon.assert.notCalled(
        vscodeStub.window.withProgress.withArgs(
          {
            location: 15,
            title: `Activating Dart extension...`,
          },
          sinon.match.any
        )
      );

      sinon.assert.notCalled(dartCodeExtension.activate);
    });
  });

  suite("no running servers information", () => {
    const message = "No running servers found.";
    const startOption = "Start server";
    const cancelOption = "Cancel";

    suite("is shown", () => {
      test("when daemon is not ready", async () => {
        daemon.isReady = false;
        daemon.applicationRegistry.all.returns([]);

        await command.debugDevServer();

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

        await command.debugDevServer();

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

      await command.debugDevServer();

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

      await command.debugDevServer();

      sinon.assert.calledOnceWithExactly(
        vscodeStub.commands.executeCommand,
        "dart-frog.start-dev-server"
      );
    });

    suite("never starts debug session", () => {
      beforeEach(() => {
        daemon.isReady = false;
        daemon.applicationRegistry.all.returns([]);
      });

      test("when `Start server` option is selected", async () => {
        vscodeStub.window.showInformationMessage
          .withArgs(message, startOption, cancelOption)
          .resolves(startOption);

        await command.debugDevServer();

        sinon.assert.notCalled(vscodeStub.debug.startDebugging);
      });

      test("when `Cancel` option is selected", async () => {
        vscodeStub.window.showInformationMessage
          .withArgs(message, startOption, cancelOption)
          .resolves(cancelOption);

        await command.debugDevServer();

        sinon.assert.notCalled(vscodeStub.debug.startDebugging);
      });

      test("when dismissed", async () => {
        vscodeStub.window.showInformationMessage
          .withArgs(message, startOption, cancelOption)
          .resolves(undefined);

        await command.debugDevServer();

        sinon.assert.notCalled(vscodeStub.debug.startDebugging);
      });
    });
  });

  suite("applications quick pick", () => {
    test("is not shown when there is a single running application", async () => {
      daemon.applicationRegistry.all.returns([application1]);

      await command.debugDevServer();

      sinon.assert.notCalled(utilsStub.quickPickApplication);
    });

    test("is shown when there is more than a single running application", async () => {
      daemon.applicationRegistry.all.returns([application1, application2]);
      utilsStub.quickPickApplication.resolves(application1);

      await command.debugDevServer();

      sinon.assert.calledOnceWithExactly(
        utilsStub.quickPickApplication,
        {
          placeHolder: "Select a server to debug",
        },
        [application1, application2]
      );
    });

    test("never starts debug session when dismissed", async () => {
      daemon.applicationRegistry.all.returns([application1, application2]);
      utilsStub.quickPickApplication.resolves(undefined);

      await command.debugDevServer();

      sinon.assert.notCalled(vscodeStub.debug.startDebugging);
    });
  });

  suite("running debug session information", () => {
    const message = `A debug session is already running for this application.`;
    const createOption = "Create another debug session";
    const cancelOption = "Cancel";

    test("is shown when there is already an active debug session for the application", async () => {
      daemon.applicationRegistry.all.returns([application1]);
      vscodeStub.debug.activeDebugSession = {
        configuration: {
          applicationId: application1.id,
        },
      };

      await command.debugDevServer();

      sinon.assert.calledOnceWithExactly(
        vscodeStub.window.showInformationMessage,
        message,
        createOption,
        cancelOption
      );
    });

    suite("is not shown", () => {
      test("when there are no active debug sessions", async () => {
        vscodeStub.debug.activeDebugSession = undefined;

        await command.debugDevServer();

        sinon.assert.notCalled(
          vscodeStub.window.showInformationMessage.withArgs(
            message,
            createOption,
            cancelOption
          )
        );
      });

      test("when there is an active debug session for another application", async () => {
        daemon.applicationRegistry.all.returns([application1]);
        vscodeStub.debug.activeDebugSession = {
          configuration: {
            applicationId: `not-${application1.id}`,
          },
        };

        await command.debugDevServer();

        sinon.assert.notCalled(
          vscodeStub.window.showInformationMessage.withArgs(
            message,
            createOption,
            cancelOption
          )
        );
      });

      test("does not start debug session when cancelled", async () => {
        daemon.applicationRegistry.all.returns([application1]);
        vscodeStub.debug.activeDebugSession = {
          configuration: {
            applicationId: application1.id,
          },
        };
        vscodeStub.window.showInformationMessage
          .withArgs(message, createOption, cancelOption)
          .resolves(cancelOption);

        await command.debugDevServer();

        sinon.assert.notCalled(vscodeStub.debug.startDebugging);
      });

      test("does not start debug session when dismissed", async () => {
        daemon.applicationRegistry.all.returns([application1]);
        vscodeStub.debug.activeDebugSession = {
          configuration: {
            applicationId: application1.id,
          },
        };
        vscodeStub.window.showInformationMessage
          .withArgs(message, createOption, cancelOption)
          .resolves(undefined);

        await command.debugDevServer();

        sinon.assert.notCalled(vscodeStub.debug.startDebugging);
      });
    });
  });

  suite("starts debug session", () => {
    test("when there is a single running application", async () => {
      vscodeStub.debug.activeDebugSession = undefined;

      daemon.applicationRegistry.all.returns([application1]);

      await command.debugDevServer();

      const progressFunction =
        vscodeStub.window.withProgress.getCall(0).args[1];
      await progressFunction();

      sinon.assert.calledOnceWithExactly(
        vscodeStub.debug.startDebugging,
        undefined,
        {
          name: `Dart Frog: Development Server (${application1.address})`,
          request: "attach",
          type: "dart",
          vmServiceUri: application1.vmServiceUri,
          applicationId: application1.id,
        }
      );
    });

    test("when there is more than one running application and debug session", async () => {
      daemon.applicationRegistry.all.returns([application1, application2]);
      utilsStub.quickPickApplication.resolves(application1);
      vscodeStub.debug.activeDebugSession = {
        configuration: {
          applicationId: application1.id,
        },
      };
      vscodeStub.window.showInformationMessage.resolves(
        "Create another debug session"
      );

      await command.debugDevServer();

      const progressFunction =
        vscodeStub.window.withProgress.getCall(0).args[1];
      await progressFunction();

      sinon.assert.calledOnceWithExactly(
        vscodeStub.debug.startDebugging,
        undefined,
        {
          name: `Dart Frog: Development Server (${application1.address})`,
          request: "attach",
          type: "dart",
          vmServiceUri: application1.vmServiceUri,
          applicationId: application1.id,
        }
      );
    });
  });
});
