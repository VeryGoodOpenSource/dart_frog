const sinon = require("sinon");
var proxyquire = require("proxyquire");

import {
  DaemonResponse,
  DartFrogApplication,
  StartDaemonRequest,
} from "../../../daemon";
import { afterEach, beforeEach } from "mocha";
import { Uri } from "vscode";
import * as assert from "assert";

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
      utilsStub.resolveDartFrogProjectPathFromWorkspace.returns(undefined);
      utilsStub.nearestDartFrogProject.returns(undefined);

      daemon.isReady = true;
      daemon.applicationRegistry = sinon.stub();
      daemon.applicationRegistry.all = sinon.stub().returns([]);
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

  suite("confirmation prompt before running", () => {
    beforeEach(() => {
      utilsStub.isDartFrogCLIInstalled.returns(true);
      utilsStub.resolveDartFrogProjectPathFromWorkspace.returns(undefined);
      utilsStub.nearestDartFrogProject.returns(undefined);

      daemon.isReady = true;
      daemon.applicationRegistry = sinon.stub();
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
      utilsStub.resolveDartFrogProjectPathFromWorkspace.returns("path");
      utilsStub.nearestDartFrogProject.returns("path");

      daemon.isReady = true;
      daemon.applicationRegistry = sinon.stub();
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
      utilsStub.resolveDartFrogProjectPathFromWorkspace.returns("path");
      utilsStub.nearestDartFrogProject.returns("path");

      daemon.isReady = true;
      daemon.applicationRegistry = sinon.stub();

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
    const startRequest = new StartDaemonRequest(
      "test",
      "workingDirectory",
      8080,
      8181
    );

    beforeEach(() => {
      utilsStub.isDartFrogCLIInstalled.returns(true);
      utilsStub.resolveDartFrogProjectPathFromWorkspace.returns(
        startRequest.params.workingDirectory
      );
      utilsStub.nearestDartFrogProject.returns(
        startRequest.params.workingDirectory
      );

      daemon.send = sinon.stub();
      daemon.isReady = true;
      daemon.applicationRegistry = sinon.stub();
      daemon.applicationRegistry.all = sinon.stub();
    });

    test("when there is already a running server and user cancelled confirmation prompt", async () => {
      daemon.applicationRegistry.all.returns([
        new DartFrogApplication(
          "test",
          startRequest.params.port + 1,
          startRequest.params.dartVmServicePort + 1
        ),
      ]);
      vscodeStub.window.showInformationMessage.resolves("Cancel");

      await command.startDevServer();

      sinon.assert.neverCalledWith(daemon.send, startRequest);
    });

    test("when there is already a running server and user dismissed confirmation prompt", async () => {
      daemon.applicationRegistry.all.returns([
        new DartFrogApplication(
          "test",
          startRequest.params.port + 1,
          startRequest.params.dartVmServicePort + 1
        ),
      ]);
      vscodeStub.window.showInformationMessage.resolves(undefined);

      await command.startDevServer();

      sinon.assert.neverCalledWith(daemon.send, startRequest);
    });

    test("when there is already more than one running server and user cancelled confirmation prompt", async () => {
      daemon.applicationRegistry.all.returns([
        new DartFrogApplication(
          "test1",
          startRequest.params.port + 1,
          startRequest.params.dartVmServicePort + 1
        ),
        new DartFrogApplication(
          "test2",
          startRequest.params.port + 2,
          startRequest.params.dartVmServicePort + 2
        ),
      ]);
      vscodeStub.window.showInformationMessage.resolves("Cancel");

      await command.startDevServer();

      sinon.assert.neverCalledWith(daemon.send, startRequest);
    });

    test("when Dart Frog project path failed to be retrieved", async () => {
      daemon.applicationRegistry.all.returns([]);
      utilsStub.resolveDartFrogProjectPathFromWorkspace.returns(undefined);

      await command.startDevServer();

      sinon.assert.neverCalledWith(daemon.send, startRequest);
    });

    test("when Dart Frog project root path failed to be retrieved", async () => {
      daemon.applicationRegistry.all.returns([]);
      utilsStub.resolveDartFrogProjectPathFromWorkspace.returns(
        startRequest.params.workingDirectory
      );
      utilsStub.nearestDartFrogProject.returns(undefined);

      await command.startDevServer();

      sinon.assert.neverCalledWith(daemon.send, startRequest);
    });

    test("when port number is dismissed", async () => {
      daemon.applicationRegistry.all.returns([]);
      utilsStub.resolveDartFrogProjectPathFromWorkspace.returns(
        startRequest.params.workingDirectory
      );
      vscodeStub.window.showInputBox
        .withArgs({
          prompt: "Which port number the server should start on",
          placeHolder: "8080",
          value: sinon.match.any,
          ignoreFocusOut: true,
          validateInput: sinon.match.any,
        })
        .resolves(undefined);

      await command.startDevServer();

      sinon.assert.neverCalledWith(daemon.send, startRequest);
    });

    test("when Dart VM service port number is dismissed", async () => {
      daemon.applicationRegistry.all.returns([]);
      utilsStub.resolveDartFrogProjectPathFromWorkspace.returns(
        startRequest.params.workingDirectory
      );
      vscodeStub.window.showInputBox
        .withArgs({
          prompt: "Which port number the server should start on",
          placeHolder: "8080",
          value: sinon.match.any,
          ignoreFocusOut: true,
          validateInput: sinon.match.any,
        })
        .resolves(startRequest.params.port.toString());
      vscodeStub.window.showInputBox
        .withArgs({
          prompt: "Which port number the Dart VM service should listen on",
          placeHolder: "8181",
          value: sinon.match.any,
          ignoreFocusOut: true,
          validateInput: sinon.match.any,
        })
        .resolves(undefined);

      await command.startDevServer();

      sinon.assert.neverCalledWith(daemon.send, startRequest);
    });
  });

  suite("sends start request", () => {
    const startRequest = new StartDaemonRequest(
      "test",
      "workingDirectory",
      8080,
      8181
    );
    const startResponse: DaemonResponse = {
      id: startRequest.id,
      result: "success",
      error: undefined,
    };

    beforeEach(() => {
      utilsStub.isDartFrogCLIInstalled.returns(true);
      utilsStub.resolveDartFrogProjectPathFromWorkspace.returns(
        startRequest.params.workingDirectory
      );
      utilsStub.nearestDartFrogProject.returns(
        startRequest.params.workingDirectory
      );

      daemon.send = sinon.stub();
      daemon.isReady = true;
      daemon.applicationRegistry = sinon.stub();
      daemon.applicationRegistry.all = sinon.stub();
      daemon.applicationRegistry.on = sinon.stub();
      daemon.applicationRegistry.off = sinon.stub();
      daemon.requestIdentifierGenerator = sinon.stub();
      daemon.requestIdentifierGenerator.generate = sinon
        .stub()
        .returns(startRequest.id);
      daemon.send.withArgs(startRequest).resolves(startResponse);

      vscodeStub.window.showInputBox
        .withArgs({
          prompt: "Which port number the server should start on",
          placeHolder: "8080",
          value: sinon.match.any,
          ignoreFocusOut: true,
          validateInput: sinon.match.any,
        })
        .resolves(startRequest.params.port.toString());
      vscodeStub.window.showInputBox
        .withArgs({
          prompt: "Which port number the Dart VM service should listen on",
          placeHolder: "8181",
          value: sinon.match.any,
          ignoreFocusOut: true,
          validateInput: sinon.match.any,
        })
        .resolves(startRequest.params.dartVmServicePort.toString());
    });

    test("when there are no running applications", async () => {
      daemon.applicationRegistry.all.returns([]);

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

    test("when there is already a running server and user confirmed confirmation prompt", async () => {
      daemon.applicationRegistry.all.returns([
        new DartFrogApplication(
          "test",
          startRequest.params.port + 1,
          startRequest.params.dartVmServicePort + 1
        ),
      ]);
      vscodeStub.window.showInformationMessage.resolves("Start another server");

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

    test("when there is already more than one running server and user confirmed confirmation prompt", async () => {
      daemon.applicationRegistry.all.returns([
        new DartFrogApplication(
          "test1",
          startRequest.params.port + 1,
          startRequest.params.dartVmServicePort + 1
        ),
        new DartFrogApplication(
          "test2",
          startRequest.params.port + 2,
          startRequest.params.dartVmServicePort + 2
        ),
      ]);
      vscodeStub.window.showInformationMessage.resolves("Start another server");

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

    test("then opens application", async () => {
      daemon.applicationRegistry.all.returns([]);

      await command.startDevServer();

      const application = new DartFrogApplication(
        startRequest.params.workingDirectory,
        startRequest.params.port,
        startRequest.params.dartVmServicePort
      );
      application.address = `https://localhost:${application.port}`;
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
      sinon.assert.calledOnceWithMatch(
        vscodeStub.commands.executeCommand,
        "vscode.open",
        Uri.parse(application.address)
      );
    });
  });

  suite("progress", () => {
    const startRequest = new StartDaemonRequest(
      "test",
      "workingDirectory",
      8080,
      8181
    );

    beforeEach(() => {
      utilsStub.isDartFrogCLIInstalled.returns(true);
      utilsStub.resolveDartFrogProjectPathFromWorkspace.returns(
        startRequest.params.workingDirectory
      );
      utilsStub.nearestDartFrogProject.returns(
        startRequest.params.workingDirectory
      );

      daemon.send = sinon.stub();
      daemon.isReady = true;
      daemon.applicationRegistry = sinon.stub();
      daemon.applicationRegistry.all = sinon.stub().returns([]);
      daemon.applicationRegistry.on = sinon.stub();
      daemon.applicationRegistry.off = sinon.stub();
      daemon.requestIdentifierGenerator = sinon.stub();
      daemon.requestIdentifierGenerator.generate = sinon
        .stub()
        .returns(startRequest.id);

      vscodeStub.window.showInputBox
        .withArgs({
          prompt: "Which port number the server should start on",
          placeHolder: "8080",
          value: sinon.match.any,
          ignoreFocusOut: true,
          validateInput: sinon.match.any,
        })
        .resolves(startRequest.params.port.toString());
      vscodeStub.window.showInputBox
        .withArgs({
          prompt: "Which port number the Dart VM service should listen on",
          placeHolder: "8181",
          value: sinon.match.any,
          ignoreFocusOut: true,
          validateInput: sinon.match.any,
        })
        .resolves(startRequest.params.dartVmServicePort.toString());
    });

    test("is shown when starting server", async () => {
      const startResponse: DaemonResponse = {
        id: startRequest.id,
        result: "success",
        error: undefined,
      };
      daemon.send.withArgs(startRequest).resolves(startResponse);

      await command.startDevServer();

      sinon.assert.calledOnceWithExactly(
        vscodeStub.window.withProgress,
        {
          location: 15,
        },
        sinon.match.any
      );

      const application = new DartFrogApplication(
        startRequest.params.workingDirectory,
        startRequest.params.port,
        startRequest.params.dartVmServicePort
      );
      application.address = `https://localhost:${application.port}`;
      const registrationListener = daemon.applicationRegistry.on
        .withArgs("add", sinon.match.any)
        .getCall(0).args[1];
      registrationListener(application);

      const progressFunction =
        vscodeStub.window.withProgress.getCall(0).args[1];
      const progress = sinon.stub();
      progress.report = sinon.stub();
      await progressFunction(progress);

      sinon.assert.calledWith(progress.report.getCall(0), {
        message: "Starting server...",
      });
      sinon.assert.calledWith(progress.report.getCall(1), {
        message: `Registering server...`,
        increment: 75,
      });
      sinon.assert.calledWith(progress.report.getCall(2), {
        message: `Server successfully started`,
        increment: 100,
      });
    });

    test("reports error when server fails to start", async () => {
      const startResponse: DaemonResponse = {
        id: startRequest.id,
        result: undefined,
        error: {
          message: "error",
        },
      };
      daemon.send.withArgs(startRequest).resolves(startResponse);

      await command.startDevServer();

      const progressFunction =
        vscodeStub.window.withProgress.getCall(0).args[1];
      const progress = sinon.stub();
      progress.report = sinon.stub();
      await progressFunction(progress);

      sinon.assert.calledOnce(
        progress.report.withArgs({
          message: startResponse.error.message,
        })
      );
    });

    test("returns application when complete", async () => {
      const startResponse: DaemonResponse = {
        id: startRequest.id,
        result: "success",
        error: undefined,
      };
      daemon.send.withArgs(startRequest).resolves(startResponse);

      const application = new DartFrogApplication(
        startRequest.params.workingDirectory,
        startRequest.params.port,
        startRequest.params.dartVmServicePort
      );
      application.address = `https://localhost:${application.port}`;
      const registrationListener = daemon.applicationRegistry.on
        .withArgs("add", sinon.match.any)
        .getCall(0).args[1];
      registrationListener(application);

      const progressFunction =
        vscodeStub.window.withProgress.getCall(0).args[1];
      const progress = sinon.stub();
      progress.report = sinon.stub();
      const result = await progressFunction(progress);

      assert.strictEqual(result, application);
    });
  });
});
