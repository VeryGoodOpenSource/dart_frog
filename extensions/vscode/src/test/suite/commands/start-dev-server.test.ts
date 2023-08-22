const sinon = require("sinon");
var proxyquire = require("proxyquire");

import { afterEach, beforeEach } from "mocha";
import {
  DaemonResponse,
  DartFrogApplication,
  StartDaemonRequest,
} from "../../../daemon";

suite("start-dev-server command", () => {
  let vscodeStub: any;
  let utilsStub: any;
  let daemon: any;
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

    const dartFrogDaemon = {
      // eslint-disable-next-line @typescript-eslint/naming-convention
      DartFrogDaemon: sinon.stub(),
    };
    dartFrogDaemon.DartFrogDaemon.instance = sinon.stub();
    daemon = dartFrogDaemon.DartFrogDaemon.instance;

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

  suite("installing Dart Frog CLI", () => {
    beforeEach(() => {
      daemon.isReady = true;
      daemon.applicationRegistry = sinon.stub();
      daemon.applicationRegistry.all = sinon.stub().returns([]);
      utilsStub.resolveDartFrogProjectPathFromWorkspace.returns(undefined);
      utilsStub.nearestDartFrogProject.returns(undefined);
    });

    test("is suggested when not installed", async () => {
      utilsStub.isDartFrogCLIInstalled.returns(false);

      await command.startDevServer();

      sinon.assert.calledOnceWithExactly(
        utilsStub.suggestInstallingDartFrogCLI,
        "Running this command requires Dart Frog CLI to be installed."
      );
    });

    test("is not suggested when already installed", async () => {
      utilsStub.isDartFrogCLIInstalled.returns(true);

      await command.startDevServer();

      sinon.assert.notCalled(utilsStub.suggestInstallingDartFrogCLI);
    });
  });

  suite("daemon", () => {
    test("is started if not ready", async () => {
      utilsStub.isDartFrogCLIInstalled.returns(true);
      daemon.isReady = false;
      daemon.applicationRegistry = sinon.stub();
      daemon.applicationRegistry.all = sinon.stub().returns([]);
      utilsStub.resolveDartFrogProjectPathFromWorkspace.returns(undefined);
      utilsStub.nearestDartFrogProject.returns(undefined);

      await command.startDevServer();

      sinon.assert.calledOnceWithExactly(
        vscodeStub.commands.executeCommand,
        "dart-frog.start-daemon"
      );
    });

    test("is not started if already ready", async () => {
      utilsStub.isDartFrogCLIInstalled.returns(true);
      daemon.isReady = true;
      daemon.applicationRegistry = sinon.stub();
      daemon.applicationRegistry.all = sinon.stub().returns([]);
      utilsStub.resolveDartFrogProjectPathFromWorkspace.returns(undefined);
      utilsStub.nearestDartFrogProject.returns(undefined);

      await command.startDevServer();

      sinon.assert.neverCalledWith(
        vscodeStub.commands.executeCommand,
        "dart-frog.start-daemon"
      );
    });
  });

  suite("confirmation information message before running", () => {
    beforeEach(() => {
      utilsStub.isDartFrogCLIInstalled.returns(true);
      daemon.isReady = true;
      daemon.applicationRegistry = sinon.stub();
      utilsStub.resolveDartFrogProjectPathFromWorkspace.returns(undefined);
      utilsStub.nearestDartFrogProject.returns(undefined);
    });

    suite("is shown", () => {
      test("when there is already a running server", async () => {
        daemon.applicationRegistry.all = sinon
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
        daemon.applicationRegistry.all = sinon
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
      daemon.applicationRegistry.all = sinon.stub().returns([]);

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

  suite("failed to find a Dart Frog project error message", () => {
    const errorMessage =
      "Failed to find a Dart Frog project within the current workspace.";

    beforeEach(() => {
      utilsStub.isDartFrogCLIInstalled.returns(true);
      daemon.isReady = true;
      daemon.applicationRegistry = sinon.stub();
      daemon.applicationRegistry.all = sinon.stub().returns([]);
    });

    test("is shown when failed to find Dart Frog project path", async () => {
      utilsStub.resolveDartFrogProjectPathFromWorkspace.returns(undefined);

      await command.startDevServer();

      sinon.assert.calledOnceWithExactly(
        vscodeStub.window.showErrorMessage,
        errorMessage
      );
    });

    test("is shown when failed to find Dart Frog root project path", async () => {
      utilsStub.resolveDartFrogProjectPathFromWorkspace.returns("path");
      utilsStub.nearestDartFrogProject.returns(undefined);

      await command.startDevServer();

      sinon.assert.calledOnceWithExactly(
        vscodeStub.window.showErrorMessage,
        errorMessage
      );
    });

    test("is not shown when found a Dart Frog project path", async () => {
      utilsStub.resolveDartFrogProjectPathFromWorkspace.returns("path");
      utilsStub.nearestDartFrogProject.returns("path");

      await command.startDevServer();

      sinon.assert.neverCalledWith(
        vscodeStub.window.showErrorMessage,
        errorMessage
      );
    });
  });

  suite("port number prompt is shown", () => {
    beforeEach(() => {
      utilsStub.isDartFrogCLIInstalled.returns(true);
      daemon.isReady = true;
      daemon.applicationRegistry = sinon.stub();
      utilsStub.resolveDartFrogProjectPathFromWorkspace.returns("path");
      utilsStub.nearestDartFrogProject.returns("path");
    });

    test("with prefilled default value when there are no running servers", async () => {
      daemon.applicationRegistry.all = sinon.stub().returns([]);

      await command.startDevServer();

      sinon.assert.calledOnceWithMatch(vscodeStub.window.showInputBox, {
        prompt: "Which port number the server should start on",
        placeHolder: "8080",
        value: "8080",
        ignoreFocusOut: true,
      });
    });

    test("without prefilled default value when there is already a running server", async () => {
      daemon.applicationRegistry.all = sinon
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

    suite("with validation", () => {
      const inputBoxArguements = {
        prompt: "Which port number the server should start on",
        placeHolder: "8080",
        value: sinon.match.any,
        ignoreFocusOut: true,
        validateInput: sinon.match.any,
      };

      beforeEach(() => {
        daemon.applicationRegistry.all = sinon.stub().returns([]);
      });

      test("that accepts valid port number", async () => {
        await command.startDevServer();

        const validateInput = vscodeStub.window.showInputBox
          .withArgs(inputBoxArguements)
          .getCall(0).args[0].validateInput;
        const result = validateInput("8080");

        sinon.assert.match(result, undefined);
      });

      suite("that rejects", () => {
        test("empty port number", async () => {
          await command.startDevServer();

          const validateInput = vscodeStub.window.showInputBox
            .withArgs(inputBoxArguements)
            .getCall(0).args[0].validateInput;
          const result = validateInput("");

          sinon.assert.match(result, "Port number cannot be empty");
        });

        test("white spaced port number", async () => {
          await command.startDevServer();

          const validateInput = vscodeStub.window.showInputBox
            .withArgs(inputBoxArguements)
            .getCall(0).args[0].validateInput;
          const result = validateInput("  ");

          sinon.assert.match(result, "Port number cannot be empty");
        });

        test("non numeric inputs", async () => {
          await command.startDevServer();

          const validateInput = vscodeStub.window.showInputBox
            .withArgs(inputBoxArguements)
            .getCall(0).args[0].validateInput;
          const result = validateInput("a");

          sinon.assert.match(result, "Port number must be a number");
        });

        suite("numeric inputs", () => {
          const message = "Port number must be between 0 and 65535";

          test("smaller than 0", async () => {
            await command.startDevServer();

            const validateInput = vscodeStub.window.showInputBox
              .withArgs(inputBoxArguements)
              .getCall(0).args[0].validateInput;
            const result = validateInput("-1");

            sinon.assert.match(result, message);
          });

          test("greater than 65535", async () => {
            await command.startDevServer();

            const validateInput = vscodeStub.window.showInputBox
              .withArgs(inputBoxArguements)
              .getCall(0).args[0].validateInput;
            const result = validateInput("65536");

            sinon.assert.match(result, message);
          });
        });

        suite("port number that are already in use", () => {
          const applications = [new DartFrogApplication("test", 8080, 8181)];
          const message = "Port number is already in use by another server";

          beforeEach(() => {
            daemon.applicationRegistry.all = sinon.stub().returns(applications);
            vscodeStub.window.showInformationMessage.resolves(
              "Start another server"
            );
          });

          test("by a running application port", async () => {
            await command.startDevServer();

            const validateInput = vscodeStub.window.showInputBox
              .withArgs(inputBoxArguements)
              .getCall(0).args[0].validateInput;
            const result = validateInput("8080");

            sinon.assert.match(result, message);
          });

          test("by a running application Dart VM service port", async () => {
            await command.startDevServer();

            const validateInput = vscodeStub.window.showInputBox
              .withArgs(inputBoxArguements)
              .getCall(0).args[0].validateInput;
            const result = validateInput("8181");

            sinon.assert.match(result, message);
          });
        });
      });
    });
  });

  suite("Dart VM service port number prompt is shown", () => {
    const portNumber = "8079";

    beforeEach(() => {
      utilsStub.isDartFrogCLIInstalled.returns(true);
      daemon.isReady = true;
      daemon.applicationRegistry = sinon.stub();
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
        .resolves(portNumber);
    });

    test("with prefilled default value when there are no running servers", async () => {
      daemon.applicationRegistry.all = sinon.stub().returns([]);

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
      daemon.applicationRegistry.all = sinon
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

    suite("with validation", () => {
      const inputBoxArguements = {
        prompt: "Which port number the Dart VM service should listen on",
        placeHolder: "8181",
        value: sinon.match.any,
        ignoreFocusOut: true,
        validateInput: sinon.match.any,
      };

      beforeEach(() => {
        daemon.applicationRegistry.all = sinon.stub().returns([]);
      });

      test("that accepts valid port number", async () => {
        await command.startDevServer();

        const validateInput = vscodeStub.window.showInputBox
          .withArgs(inputBoxArguements)
          .getCall(0).args[0].validateInput;
        const result = validateInput("8080");

        sinon.assert.match(result, undefined);
      });

      suite("that rejects", () => {
        test("empty port number", async () => {
          await command.startDevServer();

          const validateInput = vscodeStub.window.showInputBox
            .withArgs(inputBoxArguements)
            .getCall(0).args[0].validateInput;
          const result = validateInput("");

          sinon.assert.match(result, "Port number cannot be empty");
        });

        test("white spaced port number", async () => {
          await command.startDevServer();

          const validateInput = vscodeStub.window.showInputBox
            .withArgs(inputBoxArguements)
            .getCall(0).args[0].validateInput;
          const result = validateInput("  ");

          sinon.assert.match(result, "Port number cannot be empty");
        });

        test("non numeric inputs", async () => {
          await command.startDevServer();

          const validateInput = vscodeStub.window.showInputBox
            .withArgs(inputBoxArguements)
            .getCall(0).args[0].validateInput;
          const result = validateInput("a");

          sinon.assert.match(result, "Port number must be a number");
        });

        suite("numeric inputs", () => {
          const message = "Port number must be between 0 and 65535";

          test("smaller than 0", async () => {
            await command.startDevServer();

            const validateInput = vscodeStub.window.showInputBox
              .withArgs(inputBoxArguements)
              .getCall(0).args[0].validateInput;
            const result = validateInput("-1");

            sinon.assert.match(result, message);
          });

          test("greater than 65535", async () => {
            await command.startDevServer();

            const validateInput = vscodeStub.window.showInputBox
              .withArgs(inputBoxArguements)
              .getCall(0).args[0].validateInput;
            const result = validateInput("65536");

            sinon.assert.match(result, message);
          });
        });

        suite("port number that are already in use", () => {
          const applications = [new DartFrogApplication("test", 8080, 8181)];
          const message = "Port number is already in use by another server";

          beforeEach(() => {
            daemon.applicationRegistry.all = sinon.stub().returns(applications);
            vscodeStub.window.showInformationMessage.resolves(
              "Start another server"
            );
          });

          test("by a running application port", async () => {
            await command.startDevServer();

            const validateInput = vscodeStub.window.showInputBox
              .withArgs(inputBoxArguements)
              .getCall(0).args[0].validateInput;
            const result = validateInput("8080");

            sinon.assert.match(result, message);
          });

          test("by a running application Dart VM service port", async () => {
            await command.startDevServer();

            const validateInput = vscodeStub.window.showInputBox
              .withArgs(inputBoxArguements)
              .getCall(0).args[0].validateInput;
            const result = validateInput("8181");

            sinon.assert.match(result, message);
          });

          test("by the new application's port", async () => {
            await command.startDevServer();

            const validateInput = vscodeStub.window.showInputBox
              .withArgs(inputBoxArguements)
              .getCall(0).args[0].validateInput;
            const result = validateInput(portNumber);

            sinon.assert.match(result, message);
          });
        });
      });
    });
  });

  suite("does not send start request", () => {
    test("when there is already a running server and user cancelled confirmation prompt", async () => {});

    test("when there is already more than one running server and user cancelled confirmation prompt", async () => {});

    test("when Dart Frog project path failed to be retrieved", async () => {});

    test("when port number is escaped", async () => {});

    test("when Dart VM service port number is escaped", async () => {});
  });

  suite("sends start request", () => {
    const requestIdentifier = "test";
    const portNumber = "8080";
    const vmServicePortNumber = "8181";
    const workingDirectory = "path";

    beforeEach(() => {
      utilsStub.isDartFrogCLIInstalled.returns(true);
      daemon.send = sinon.stub();
      daemon.isReady = true;
      daemon.applicationRegistry = sinon.stub();
      daemon.applicationRegistry.on = sinon.stub();
      daemon.applicationRegistry.off = sinon.stub();
      daemon.requestIdentifierGenerator = sinon.stub();
      daemon.requestIdentifierGenerator.generate = sinon
        .stub()
        .returns(requestIdentifier);
      utilsStub.resolveDartFrogProjectPathFromWorkspace.returns(
        workingDirectory
      );
      utilsStub.nearestDartFrogProject.returns(workingDirectory);
      vscodeStub.window.showInputBox
        .withArgs({
          prompt: "Which port number the server should start on",
          placeHolder: "8080",
          value: sinon.match.any,
          ignoreFocusOut: true,
          validateInput: sinon.match.any,
        })
        .resolves(portNumber);
      vscodeStub.window.showInputBox
        .withArgs({
          prompt: "Which port number the Dart VM service should listen on",
          placeHolder: "8181",
          value: sinon.match.any,
          ignoreFocusOut: true,
          validateInput: sinon.match.any,
        })
        .resolves(vmServicePortNumber);
    });

    test("when there are no running applications", async () => {
      daemon.applicationRegistry.all = sinon.stub().returns([]);

      const startRequest = new StartDaemonRequest(
        requestIdentifier,
        workingDirectory,
        Number(portNumber),
        Number(vmServicePortNumber)
      );
      const startResponse: DaemonResponse = {
        id: startRequest.id,
        result: "success",
        error: undefined,
      };
      daemon.send.withArgs(startRequest).resolves(startResponse);

      await command.startDevServer();

      const application = new DartFrogApplication(
        startRequest.params.workingDirectory,
        startRequest.params.port,
        startRequest.params.dartVmServicePort
      );
      const registrationListener = daemon.applicationRegistry.on
        .withArgs("add", sinon.match.any)
        .getCall(0).args[1];
      registrationListener(application);

      const progressFunction =
        vscodeStub.window.withProgress.getCall(0).args[1];
      const progress = sinon.stub();
      progress.report = sinon.stub();
      await progressFunction(progress);

      sinon.assert.calledOnceWithExactly(daemon.send, startRequest);
    });

    test("when there is already a running server and user confirmed confirmation prompt", async () => {});

    test("when there is already more than one running server and user confirmed confirmation prompt", async () => {});
  });

  suite("progress", () => {
    const requestIdentifier = "test";
    const portNumber = "8080";
    const vmServicePortNumber = "8181";
    const workingDirectory = "path";

    beforeEach(() => {
      utilsStub.isDartFrogCLIInstalled.returns(true);
      daemon.send = sinon.stub();
      daemon.isReady = true;
      daemon.applicationRegistry = sinon.stub();
      daemon.applicationRegistry.on = sinon.stub();
      daemon.applicationRegistry.off = sinon.stub();
      daemon.requestIdentifierGenerator = sinon.stub();
      daemon.requestIdentifierGenerator.generate = sinon
        .stub()
        .returns(requestIdentifier);
      utilsStub.resolveDartFrogProjectPathFromWorkspace.returns(
        workingDirectory
      );
      utilsStub.nearestDartFrogProject.returns(workingDirectory);
      vscodeStub.window.showInputBox
        .withArgs({
          prompt: "Which port number the server should start on",
          placeHolder: "8080",
          value: sinon.match.any,
          ignoreFocusOut: true,
          validateInput: sinon.match.any,
        })
        .resolves(portNumber);
      vscodeStub.window.showInputBox
        .withArgs({
          prompt: "Which port number the Dart VM service should listen on",
          placeHolder: "8181",
          value: sinon.match.any,
          ignoreFocusOut: true,
          validateInput: sinon.match.any,
        })
        .resolves(vmServicePortNumber);
      daemon.applicationRegistry.all = sinon.stub().returns([]);
    });

    test("is shown when starting server", async () => {
      await command.startDevServer();

      sinon.assert.calledOnceWithExactly(
        vscodeStub.window.withProgress,
        {
          location: 15,
        },
        sinon.match.any
      );
    });
  });
});
