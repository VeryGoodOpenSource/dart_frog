const sinon = require("sinon");
var proxyquire = require("proxyquire");

import { afterEach, beforeEach } from "mocha";
import * as assert from "assert";

suite("new-middleware command", () => {
  const invalidUri = { fsPath: "/home/not_dart_frog/routes" };
  const validUri = { fsPath: "/home/dart_frog/routes" };

  let vscodeStub: any;
  let childProcessStub: any;
  let utilsStub: any;
  let command: any;

  beforeEach(() => {
    vscodeStub = {
      window: {
        showErrorMessage: sinon.stub(),
        showOpenDialog: sinon.stub(),
      },
    };
    childProcessStub = {
      exec: sinon.stub(),
    };
    utilsStub = {
      nearestDartFrogProject: sinon.stub(),
      normalizeRoutePath: sinon.stub(),
    };

    utilsStub.nearestDartFrogProject
      .withArgs(invalidUri.fsPath)
      .returns(undefined);
    utilsStub.nearestDartFrogProject
      .withArgs(validUri.fsPath)
      .returns(validUri.fsPath);

    command = proxyquire("../../../commands/new-middleware", {
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

  suite("file open dialog", () => {
    test("is shown when Uri is undefined", async () => {
      vscodeStub.window.showOpenDialog.returns(Promise.resolve(undefined));

      await command.newMiddleware();

      sinon.assert.calledWith(vscodeStub.window.showOpenDialog, {
        canSelectMany: false,
        openLabel: "Select a folder or file to create the Route in",
        canSelectFolders: true,
        canSelectFiles: true,
      });
    });

    test("is not shown when Uri is defined", async () => {
      await command.newMiddleware(invalidUri);

      sinon.assert.notCalled(vscodeStub.window.showOpenDialog);
    });
  });

  suite("select a valid directory error message", () => {
    const errorMessage = "Please select a valid directory";

    test("is shown when Uri is undefined and selected file is undefined", async () => {
      vscodeStub.window.showOpenDialog.returns(Promise.resolve(undefined));

      await command.newMiddleware();

      sinon.assert.calledWith(vscodeStub.window.showErrorMessage, errorMessage);
    });

    test("is not shown when Uri is undefined and selected file is given", async () => {
      vscodeStub.window.showOpenDialog.returns(Promise.resolve([invalidUri]));

      await command.newMiddleware();

      const wantedCalls = vscodeStub.window.showErrorMessage
        .getCalls()
        .filter((call: any) => call.args[0] === errorMessage);
      assert.equal(wantedCalls.length, 0);
    });
  });

  suite(
    "'No Dart Frog project found in the selected directory' error message",
    () => {
      const errorMessage =
        "No Dart Frog project found in the selected directory";

      test("is shown when Uri is undefined and selected file is invalid", async () => {
        vscodeStub.window.showOpenDialog.returns(Promise.resolve([invalidUri]));

        await command.newMiddleware();

        sinon.assert.calledWith(
          vscodeStub.window.showErrorMessage,
          errorMessage
        );
      });

      test("is shown when Uri is invalid", async () => {
        await command.newMiddleware(invalidUri);

        sinon.assert.calledWith(
          vscodeStub.window.showErrorMessage,
          errorMessage
        );
      });
    }
  );

  suite("runs `dart_frog new middleware` command with route", () => {
    test("successfully with non-index route name", async () => {
      const selectedUri = {
        fsPath: `${validUri.fsPath}/food`,
      };
      utilsStub.normalizeRoutePath.returns("food");

      await command.newMiddleware(validUri);

      sinon.assert.calledWith(
        childProcessStub.exec,
        `dart_frog new middleware 'food'`
      );
    });

    test("successfully with deep non-index route name", async () => {
      const selectedUri = {
        fsPath: `${validUri.fsPath}/food/pizza.dart`,
      };
      utilsStub.nearestDartFrogProject.returns(selectedUri);
      utilsStub.normalizeRoutePath.returns(`food/pizza`);

      await command.newMiddleware(selectedUri);

      sinon.assert.calledWith(
        childProcessStub.exec,
        `dart_frog new middleware 'food/pizza'`
      );
    });

    test("successfully with index route name", async () => {
      const selectedUri = {
        fsPath: `${validUri.fsPath}/index.dart`,
      };
      utilsStub.nearestDartFrogProject.returns(selectedUri);
      utilsStub.normalizeRoutePath.returns("/");

      await command.newMiddleware(validUri);

      sinon.assert.calledWith(
        childProcessStub.exec,
        `dart_frog new middleware '/'`
      );
    });

    test("successfully with deep index route name", async () => {
      const selectedUri = {
        fsPath: `${validUri.fsPath}/food/italian/index.dart`,
      };
      utilsStub.nearestDartFrogProject.returns(selectedUri);
      utilsStub.normalizeRoutePath.returns("food/italian");

      await command.newMiddleware(selectedUri);

      sinon.assert.calledWith(
        childProcessStub.exec,
        `dart_frog new middleware 'food/italian'`
      );
    });
  });

  test("shows error message when `dart_frog new middleware` fails", async () => {
    const error = Error("Failed to run `dart_frog new middleware`");
    childProcessStub.exec.yields(error);

    utilsStub.nearestDartFrogProject.returns(validUri);
    utilsStub.normalizeRoutePath.returns("/");

    await command.newMiddleware(validUri);

    sinon.assert.calledWith(vscodeStub.window.showErrorMessage, error.message);
  });
});
