const sinon = require("sinon");
var proxyquire = require("proxyquire");

import { afterEach, beforeEach } from "mocha";
import * as assert from "assert";

suite("install-cli command", () => {
  const installCommand = `dart pub global activate dart_frog_cli`;

  let vscodeStub: any;
  let childProcessStub: any;
  let command: any;
  let utilsStub: any;

  beforeEach(() => {
    vscodeStub = {
      window: {
        showErrorMessage: sinon.stub(),
        withProgress: sinon.stub(),
      },
    };
    childProcessStub = {
      execSync: sinon.stub(),
    };
    utilsStub = {
      isDartFrogCLIInstalled: sinon.stub(),
    };

    command = proxyquire("../../../commands/install-cli", {
      vscode: vscodeStub,
      // eslint-disable-next-line @typescript-eslint/naming-convention
      child_process: childProcessStub,
      // eslint-disable-next-line @typescript-eslint/naming-convention
      "../utils": utilsStub,
    });
  });

  afterEach(() => {
    sinon.restore();
  });

  test("does not install if Dart Frog CLI is already installed", async () => {
    utilsStub.isDartFrogCLIInstalled.returns(true);

    await command.installCLI();

    sinon.assert.notCalled(childProcessStub.execSync);
  });

  suite("installs Dart Frog CLI", () => {
    beforeEach(() => {
      utilsStub.isDartFrogCLIInstalled.returns(false);
    });

    test("when not already installed", async () => {
      await command.installCLI();

      let progressFunction = vscodeStub.window.withProgress.getCall(0).args[1];
      await progressFunction();

      sinon.assert.calledWith(childProcessStub.execSync, installCommand);
    });

    test("shows progress", async () => {
      await command.installCLI();

      const progressOptions = vscodeStub.window.withProgress.getCall(0).args[0];

      assert.strictEqual(progressOptions.title, "Installing Dart Frog CLI...");
      assert.strictEqual(progressOptions.location, 15);
    });

    test("shows error message on failure", async () => {
      const error = new Error("Command failed");
      childProcessStub.execSync.withArgs(installCommand).throws(error);

      await command.installCLI();

      const progressFunction =
        vscodeStub.window.withProgress.getCall(0).args[1];
      await progressFunction();

      sinon.assert.calledWith(
        vscodeStub.window.showErrorMessage,
        error.message
      );
    });

    test("shows unknown error message on unknown failure", async () => {
      const error = 2;
      childProcessStub.execSync.withArgs(installCommand).throws(error);

      await command.installCLI();

      const progressFunction =
        vscodeStub.window.withProgress.getCall(0).args[1];
      await progressFunction();

      sinon.assert.calledWith(
        vscodeStub.window.showErrorMessage,
        `An error occurred while installing Dart Frog CLI: ${error}`
      );
    });
  });
});
