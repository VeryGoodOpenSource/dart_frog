const sinon = require("sinon");
var proxyquire = require("proxyquire");

import { afterEach, beforeEach } from "mocha";
import * as assert from "assert";

suite("install-cli command", () => {
  let vscodeStub: any;
  let childProcessStub: any;
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

    command = proxyquire("../../../commands/install-cli", {
      vscode: vscodeStub,
      // eslint-disable-next-line @typescript-eslint/naming-convention
      child_process: childProcessStub,
    });
  });

  afterEach(() => {
    sinon.restore();
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

      sinon.assert.calledWith(
        childProcessStub.exec,
        `dart pub global activate dart_frog_cli`
      );
    });

    test("shows progress", async () => {
      await command.installCLI();

      const progressOptions = vscodeStub.window.withProgress.getCall(0).args[0];
      assert.strictEqual(progressOptions.title, "Installing Dart Frog CLI...");
      assert.strictEqual(progressOptions.location, 15);
    });

    test("shows error message on installation failure", async () => {
      const error = new Error("Command failed");
      childProcessStub.exec
        .withArgs("dart pub global activate dart_frog_cli")
        .yields(error);

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

  suite("updating", () => {
    beforeEach(() => {
      childProcessStub.execSync
        .withArgs("dart_frog --version")
        .returns("0.0.0");
    });

    test("updates Dart Frog CLI if already installed", async () => {
      await command.installCLI();

      let progressFunction = vscodeStub.window.withProgress.getCall(0).args[1];
      await progressFunction();

      sinon.assert.calledWith(childProcessStub.exec, `dart_frog update`);
    });

    test("shows progress", async () => {
      await command.installCLI();

      let progressOptions = vscodeStub.window.withProgress.getCall(0).args[0];

      assert.strictEqual(progressOptions.title, "Updating Dart Frog CLI...");
      assert.strictEqual(progressOptions.location, 15);
    });

    test("shows error message on updating failure", async () => {
      const error = new Error("Command failed");
      childProcessStub.exec.withArgs("dart_frog update").yields(error);

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
