const sinon = require("sinon");
var proxyquire = require("proxyquire");

import { afterEach, beforeEach } from "mocha";
import {
  DaemonResponse,
  DartFrogApplication,
  StartDaemonRequest,
} from "../../../daemon";
import { Uri } from "vscode";

suite("stop-dev-server command", () => {
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

    command = proxyquire("../../../commands/stop-dev-server", {
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
      daemon.isReady = false;
      daemon.applicationRegistry = sinon.stub();
      daemon.applicationRegistry.all = sinon.stub().returns([]);
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
    suite("is shown", () => {
      test("when daemon is not ready", async () => {});

      test("when no servers are running", async () => {});
    });

    suite("is not shown", () => {
      test("when daemon is ready", async () => {});

      test("when a server is running", async () => {});
    });

    test("start server option runs start server command", async () => {});

    suite("never stops the server", () => {
      test("when `Start server` option is selected", async () => {});

      test("when `Cancel` option is selected", async () => {});

      test("when dismissied", async () => {});
    });
  });

  suite("application quick pick", () => {
    test("is not shown when there is a single running application", async () => {});

    test("is shown when there is more than a single running application", async () => {});

    test("never stops the server when dismissed", async () => {});

    test("shows appropiate items for each running applications", async () => {});

    test("is disposed after selection", async () => {});
  });

  suite("progress", () => {
    test("is shown when stopping server", async () => {});

    test("shows error message when error occurs", async () => {});

    test("stops when error occurs", async () => {});
  });

  test("stops server", async () => {});
});
