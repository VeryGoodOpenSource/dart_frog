const sinon = require("sinon");
var proxyquire = require("proxyquire");

import { afterEach, beforeEach } from "mocha";
import * as assert from "assert";

suite("install-cli command", () => {
  let vscodeStub: any;
  let childProcessStub: any;
  let command: any;

  const updateCommand = `dart pub global activate dart_frog_cli`;

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

    command = proxyquire("../../../commands/install-cli", {
      vscode: vscodeStub,
      // eslint-disable-next-line @typescript-eslint/naming-convention
      child_process: childProcessStub,
    });
  });

  afterEach(() => {
    sinon.restore();
  });

  test("does not install if Dart Frog CLI is already installed", async () => {
    childProcessStub.execSync.withArgs("dart_frog --version").returns("0.0.0");

    await command.installCLI();

    const wantedCalls = childProcessStub.exec
      .getCalls()
      .filter((call: any) => call.args[0] === updateCommand);
    assert.equal(wantedCalls.length, 0);
  });

  suite("installing", () => {
    beforeEach(() => {
      childProcessStub.execSync
        .withArgs("dart_frog --version")
        .throws("Command failed");
    });

    test("installs Dart Frog CLI if not already installed", async () => {
      await command.installCLI();

      let progressFunction = vscodeStub.window.withProgress.getCall(0).args[1];
      await progressFunction();

      sinon.assert.calledWith(childProcessStub.exec, updateCommand);
    });

    test("shows progress", async () => {
      await command.installCLI();

      const progressOptions = vscodeStub.window.withProgress.getCall(0).args[0];
      assert.strictEqual(progressOptions.title, "Installing Dart Frog CLI...");
      assert.strictEqual(progressOptions.location, 15);
    });

    test("shows error message on installation failure", async () => {
      const error = new Error("Command failed");
      childProcessStub.exec.withArgs(updateCommand).yields(error);

      await command.installCLI();

      const progressFunction =
        vscodeStub.window.withProgress.getCall(0).args[1];
      await progressFunction();

      sinon.assert.calledWith(
        vscodeStub.window.showErrorMessage,
        error.message
      );
    });
  });
});
