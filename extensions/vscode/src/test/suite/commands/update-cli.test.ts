const sinon = require("sinon");
var proxyquire = require("proxyquire");

import { afterEach, beforeEach } from "mocha";
import * as assert from "assert";

suite("update-cli", () => {
  const updateCommand = `dart_frog update`;

  let vscodeStub: any;
  let childProcessStub: any;
  let utilsStub: any;
  let command: any;

  beforeEach(() => {
    vscodeStub = {
      window: {
        showErrorMessage: sinon.stub(),
        withProgress: sinon.stub(),
      },
    };
    childProcessStub = {
      exec: sinon.stub(),
      execSync: sinon.stub(),
    };
    utilsStub = {
      isDartFrogCLIInstalled: sinon.stub(),
    };

    command = proxyquire("../../../commands/update-cli", {
      vscode: vscodeStub,
      // eslint-disable-next-line @typescript-eslint/naming-convention
      child_process: childProcessStub,
      // eslint-disable-next-line @typescript-eslint/naming-convention
      "../utils/utils": utilsStub,
    });
  });

  afterEach(() => {
    sinon.restore();
  });

  suite("updates Dart Frog CLI", () => {
    beforeEach(() => {
      utilsStub.isDartFrogCLIInstalled.returns(true);
    });

    test("when already installed", async () => {
      await command.updateCLI();

      let progressFunction = vscodeStub.window.withProgress.getCall(0).args[1];
      await progressFunction();

      sinon.assert.calledWith(childProcessStub.exec, updateCommand);
    });

    test("shows progress", async () => {
      await command.updateCLI();

      const progressOptions = vscodeStub.window.withProgress.getCall(0).args[0];

      assert.strictEqual(progressOptions.title, "Updating Dart Frog CLI...");
      assert.strictEqual(progressOptions.location, 15);
    });

    test("shows error message on failure", async () => {
      const error = new Error("Command failed");
      childProcessStub.exec.withArgs(updateCommand).yields(error);

      await command.updateCLI();

      const progressFunction =
        vscodeStub.window.withProgress.getCall(0).args[1];
      await progressFunction();

      sinon.assert.calledWith(
        vscodeStub.window.showErrorMessage,
        error.message
      );
    });
  });

  test("does nothing when not installed", async () => {
    utilsStub.isDartFrogCLIInstalled.returns(false);

    await command.updateCLI();

    sinon.assert.notCalled(childProcessStub.exec);
    sinon.assert.notCalled(vscodeStub.window.withProgress);
    sinon.assert.notCalled(vscodeStub.window.showErrorMessage);
  });
});
