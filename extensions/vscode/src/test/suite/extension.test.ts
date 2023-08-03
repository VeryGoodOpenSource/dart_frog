const sinon = require("sinon");
var proxyquire = require("proxyquire");

import * as assert from "assert";
import * as vscode from "vscode";
import { installCLI, newMiddleware, newRoute, updateCLI } from "../../commands";
import { afterEach, beforeEach } from "mocha";

suite("activate", () => {
  test("does not throw", async () => {
    const extension = vscode.extensions.getExtension(
      "VeryGoodVentures.dart-frog"
    ) as vscode.Extension<any>;

    assert.doesNotThrow(async () => await extension.activate());
  });

  suite("registers command", () => {
    let vscodeStub: any;
    let extension: any;
    let context: any;

    beforeEach(() => {
      vscodeStub = {
        commands: {
          registerCommand: sinon.stub(),
        },
      };

      const utilsStub = {
        readDartFrogCLIVersion: sinon.stub(),
        isCompatibleDartFrogCLIVersion: sinon.stub(),
        isDartFrogCLIInstalled: sinon.stub(),
      };
      utilsStub.readDartFrogCLIVersion.returns("0.0.0");
      utilsStub.isCompatibleDartFrogCLIVersion.returns(true);
      utilsStub.isDartFrogCLIInstalled.returns(true);

      const childProcessStub = {
        execSync: sinon.stub(),
      };

      extension = proxyquire("../../extension", {
        vscode: vscodeStub,
        // eslint-disable-next-line @typescript-eslint/naming-convention
        child_process: childProcessStub,
        // eslint-disable-next-line @typescript-eslint/naming-convention
        "./utils": utilsStub,
      });
      context = { subscriptions: [] };
    });

    afterEach(() => {
      sinon.restore();
    });

    test("install-cli", () => {
      extension.activate(context);

      sinon.assert.calledWith(
        vscodeStub.commands.registerCommand,
        "extension.install-cli",
        installCLI
      );
    });

    test("update-cli", () => {
      extension.activate(context);

      sinon.assert.calledWith(
        vscodeStub.commands.registerCommand,
        "extension.update-cli",
        updateCLI
      );
    });

    test("new-route", () => {
      extension.activate(context);

      sinon.assert.calledWith(
        vscodeStub.commands.registerCommand,
        "extension.new-route",
        newRoute
      );
    });

    test("new-middleware", () => {
      extension.activate(context);

      sinon.assert.calledWith(
        vscodeStub.commands.registerCommand,
        "extension.new-middleware",
        newMiddleware
      );
    });
  });

  test("calls suggestInstallingDartFrogCLI when Dart Frog CLI is not installed", () => {
    const vscodeStub = {
      commands: {
        registerCommand: sinon.stub(),
      },
    };

    const utilsStub = {
      isDartFrogCLIInstalled: sinon.stub(),
      suggestInstallingDartFrogCLI: sinon.stub(),
    };
    utilsStub.isDartFrogCLIInstalled.returns(false);

    const extension = proxyquire("../../extension", {
      vscode: vscodeStub,
      // eslint-disable-next-line @typescript-eslint/naming-convention
      "./utils": utilsStub,
    });

    const context = { subscriptions: [] };
    const ensureCompatibleCLI = sinon.stub();
    extension.activate(context, ensureCompatibleCLI);

    sinon.assert.calledOnce(utilsStub.suggestInstallingDartFrogCLI);
  });

  test("calls ensureCompatibleDartFrogCLI when Dart Frog CLI is installed", () => {
    const vscodeStub = {
      commands: {
        registerCommand: sinon.stub(),
      },
    };

    const utilsStub = {
      isDartFrogCLIInstalled: sinon.stub(),
      suggestInstallingCLI: sinon.stub(),
    };
    utilsStub.isDartFrogCLIInstalled.returns(true);

    const extension = proxyquire("../../extension", {
      vscode: vscodeStub,
      // eslint-disable-next-line @typescript-eslint/naming-convention
      "./utils": utilsStub,
    });

    const context = { subscriptions: [] };
    const ensureCompatibleCLI = sinon.stub();
    extension.activate(context, ensureCompatibleCLI);

    sinon.assert.calledOnce(ensureCompatibleCLI);
  });
});

suite("ensureCompatibleDartFrogCLI", () => {
  let vscodeStub: any;
  let utilsStub: any;
  let commandsStub: any;
  let extension: any;

  beforeEach(() => {
    vscodeStub = {
      window: {
        showWarningMessage: sinon.stub(),
      },
      commands: {
        executeCommand: sinon.stub(),
      },
    };

    utilsStub = {
      readDartFrogCLIVersion: sinon.stub(),
      isCompatibleDartFrogCLIVersion: sinon.stub(),
      readLatestDartFrogCLIVersion: sinon.stub(),
      openChangelog: sinon.stub(),
    };
    commandsStub = {
      updateCLI: sinon.stub(),
    };

    extension = proxyquire("../../extension", {
      vscode: vscodeStub,
      // eslint-disable-next-line @typescript-eslint/naming-convention
      "./utils": utilsStub,
      // eslint-disable-next-line @typescript-eslint/naming-convention
      "./commands": commandsStub,
    });
  });

  afterEach(() => {
    sinon.restore();
  });

  test("does not show warning when CLI is not installed", async () => {
    utilsStub.readDartFrogCLIVersion.returns(undefined);

    await extension.ensureCompatibleDartFrogCLI();

    sinon.assert.notCalled(vscodeStub.window.showWarningMessage);
  });

  test("does not show warning when CLI is compatible", async () => {
    utilsStub.readDartFrogCLIVersion.returns("1.0.0");
    utilsStub.isCompatibleDartFrogCLIVersion.returns(true);

    await extension.ensureCompatibleDartFrogCLI();

    sinon.assert.notCalled(vscodeStub.window.showWarningMessage);
  });

  test("does not show warning when latest version cannot be retrieved", async () => {
    utilsStub.readDartFrogCLIVersion.returns("1.0.0");
    utilsStub.isCompatibleDartFrogCLIVersion.returns(false);
    utilsStub.readLatestDartFrogCLIVersion.returns(undefined);

    await extension.ensureCompatibleDartFrogCLI();

    sinon.assert.notCalled(vscodeStub.window.showWarningMessage);
  });

  suite("incompatible CLI", () => {
    const version = "0.0.0";

    beforeEach(() => {
      utilsStub.readDartFrogCLIVersion.returns(version);
      utilsStub.isCompatibleDartFrogCLIVersion.returns(false);
      utilsStub.readLatestDartFrogCLIVersion.returns(version);
    });

    afterEach(() => {
      sinon.restore();
    });

    test("shows warning", async () => {
      await extension.ensureCompatibleDartFrogCLI();

      sinon.assert.calledOnceWithExactly(
        vscodeStub.window.showWarningMessage,
        `Dart Frog CLI version ${version} is not compatible with this extension.`,
        "Update Dart Frog CLI",
        "Changelog",
        "Ignore"
      );
    });

    test("updates CLI when selected", async () => {
      vscodeStub.window.showWarningMessage.returns("Update Dart Frog CLI");

      await extension.ensureCompatibleDartFrogCLI();

      sinon.assert.calledOnce(commandsStub.updateCLI);
    });

    test("opens changelog when selected", async () => {
      vscodeStub.window.showWarningMessage.returns("Changelog");

      await extension.ensureCompatibleDartFrogCLI();

      sinon.assert.calledOnceWithExactly(utilsStub.openChangelog, version);
      sinon.assert.notCalled(commandsStub.updateCLI);
    });

    test("does not update CLI when ignored", async () => {
      vscodeStub.window.showWarningMessage.returns("Ignore");

      await extension.ensureCompatibleDartFrogCLI();

      sinon.assert.notCalled(commandsStub.updateCLI);
    });
  });
});
