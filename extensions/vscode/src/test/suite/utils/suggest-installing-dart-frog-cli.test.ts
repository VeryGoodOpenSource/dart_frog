const sinon = require("sinon");
var proxyquire = require("proxyquire");

import { afterEach, beforeEach } from "mocha";

suite("suggestInstallingDartFrogCLI", () => {
  let vscodeStub: any;
  let utilsStub: any;
  let commandsStub: any;
  let suggestInstallingDartFrogCLI: any;

  beforeEach(() => {
    vscodeStub = {
      window: {
        showWarningMessage: sinon.stub(),
      },
    };

    utilsStub = {
      isDartFrogCLIInstalled: sinon.stub(),
    };
    utilsStub.isDartFrogCLIInstalled.returns(false);

    commandsStub = {
      installCLI: sinon.stub(),
    };

    suggestInstallingDartFrogCLI = proxyquire(
      "../../../utils/suggest-installing-dart-frog-cli",
      {
        vscode: vscodeStub,
        // eslint-disable-next-line @typescript-eslint/naming-convention
        ".": utilsStub,
        // eslint-disable-next-line @typescript-eslint/naming-convention
        "../commands": commandsStub,
      }
    );
  });

  afterEach(() => {
    sinon.restore();
  });

  suite("shows warning suggesting to install Dart Frog CLI", () => {
    test("with default message", async () => {
      await suggestInstallingDartFrogCLI.suggestInstallingDartFrogCLI();

      sinon.assert.calledOnceWithExactly(
        vscodeStub.window.showWarningMessage,
        "Dart Frog CLI is not installed. Install Dart Frog CLI to use this extension.",
        "Install Dart Frog CLI",
        "Ignore"
      );
    });

    test("with provided message", async () => {
      const message = "This is a test message.";
      await suggestInstallingDartFrogCLI.suggestInstallingDartFrogCLI(message);

      sinon.assert.calledOnceWithExactly(
        vscodeStub.window.showWarningMessage,
        message,
        "Install Dart Frog CLI",
        "Ignore"
      );
    });
  });

  test("installs Dart Frog CLI when selected", async () => {
    vscodeStub.window.showWarningMessage.returns("Install Dart Frog CLI");

    await suggestInstallingDartFrogCLI.suggestInstallingDartFrogCLI();

    sinon.assert.calledOnce(commandsStub.installCLI);
  });

  test("does not install Dart Frog CLI when ignored", async () => {
    vscodeStub.window.showWarningMessage.returns("Ignore");

    await suggestInstallingDartFrogCLI.suggestInstallingDartFrogCLI();

    sinon.assert.notCalled(commandsStub.installCLI);
  });
});
