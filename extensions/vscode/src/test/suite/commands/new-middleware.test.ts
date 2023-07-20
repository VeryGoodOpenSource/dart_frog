const sinon = require("sinon");
var proxyquire = require("proxyquire");

import { afterEach, beforeEach } from "mocha";
import * as assert from "assert";

suite("new-middleware command", () => {
  const invalidRouteUri = { fsPath: "/home/dart_frog" };
  const validRouteUri = { fsPath: "/home/dart_frog/routes" };

  let vscodeStub: any;
  let childProcessStub: any;
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

    command = proxyquire("../../../commands/new-middleware", {
      vscode: vscodeStub,
      // eslint-disable-next-line @typescript-eslint/naming-convention
      child_process: childProcessStub,
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
      await command.newMiddleware(invalidRouteUri);

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
      vscodeStub.window.showOpenDialog.returns(
        Promise.resolve([invalidRouteUri])
      );

      await command.newMiddleware();

      const wantedCalls = vscodeStub.window.showErrorMessage
        .getCalls()
        .filter((call: any) => call.args[0] === errorMessage);
      assert.equal(wantedCalls.length, 0);
    });

    suite("runs `dart_frog new middleware` command with route", () => {
      test("successfully when Uri is project root directory", async () => {
        await command.newMiddleware({
          fsPath: "/home/dart_frog/routes/",
        });

        sinon.assert.calledWith(
          childProcessStub.exec,
          `dart_frog new middleware '/'`
        );
      });

      test("successfully when Uri is project root index file", async () => {
        await command.newMiddleware({
          fsPath: "/home/dart_frog/routes/index.dart",
        });

        sinon.assert.calledWith(
          childProcessStub.exec,
          `dart_frog new middleware '/'`
        );
      });

      test("successfully when Uri is project root non-index file", async () => {
        await command.newMiddleware({
          fsPath: "/home/dart_frog/routes/a.dart",
        });

        sinon.assert.calledWith(
          childProcessStub.exec,
          `dart_frog new middleware 'a'`
        );
      });

      test("successfully when Uri is not project root directory", async () => {
        const nestedDirectory = "about";
        await command.newMiddleware({
          fsPath: `/home/dart_frog/routes/${nestedDirectory}`,
        });

        sinon.assert.calledWith(
          childProcessStub.exec,
          `dart_frog new middleware '${nestedDirectory}'`
        );
      });

      test("successfully when Uri is a valid non-index nested file", async () => {
        const nestedDirectory = "about";
        const nestedFileName = "vgv";
        await command.newMiddleware({
          fsPath: `/home/dart_frog/routes/${nestedDirectory}/${nestedFileName}.dart`,
        });

        sinon.assert.calledWith(
          childProcessStub.exec,
          `dart_frog new middleware '${nestedDirectory}/${nestedFileName}'`
        );
      });

      test("successfully when Uri is a valid index nested file", async () => {
        const nestedDirectory = "about";
        const nestedFileName = "index";
        await command.newMiddleware({
          fsPath: `/home/dart_frog/routes/${nestedDirectory}/${nestedFileName}.dart`,
        });

        sinon.assert.calledWith(
          childProcessStub.exec,
          `dart_frog new middleware '${nestedDirectory}'`
        );
      });
    });

    test("shows error message when `dart_frog new middleware` fails", async () => {
      const error = Error("Failed to run `dart_frog new middleware`");
      childProcessStub.exec.yields(error);

      await command.newMiddleware(validRouteUri);

      sinon.assert.calledWith(
        vscodeStub.window.showErrorMessage,
        error.message
      );
    });
  });
});
