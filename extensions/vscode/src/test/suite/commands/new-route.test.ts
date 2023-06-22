const sinon = require("sinon");
var proxyquire = require("proxyquire");

import { afterEach, beforeEach } from "mocha";
import * as assert from "assert";

suite("new-route command", () => {
  const validRouteName = "frog";
  const invalidRouteUri = { fsPath: "/home/dart_frog" };

  let vscodeStub: any;
  let childProcessStub: any;
  let command: any;

  beforeEach(() => {
    vscodeStub = {
      window: {
        showErrorMessage: sinon.stub(),
        showInputBox: sinon.stub(),
        showOpenDialog: sinon.stub(),
      },
    };
    childProcessStub = {
      exec: sinon.stub(),
    };

    command = proxyquire("../../../commands/new-route", {
      vscode: vscodeStub,
      // eslint-disable-next-line @typescript-eslint/naming-convention
      child_process: childProcessStub,
    });
  });

  afterEach(() => {
    sinon.restore();
  });

  test("shows input box to input route name", async () => {
    vscodeStub.window.showInputBox.returns("");

    await command.newRoute();

    sinon.assert.calledWith(vscodeStub.window.showInputBox, {
      prompt: "Route name",
      placeHolder: "index",
    });
  });

  suite("invalid route name error message", () => {
    const errorMessage = "Please enter a valid route name";

    beforeEach(() => {
      vscodeStub.window.showErrorMessage.returns({});
    });

    test("is shown when prompt is empty", async () => {
      vscodeStub.window.showInputBox.returns("");

      await command.newRoute();

      sinon.assert.calledWith(vscodeStub.window.showErrorMessage, errorMessage);
    });

    test("is shown when prompt is white spaced", async () => {
      vscodeStub.window.showInputBox.returns("  ");

      await command.newRoute();

      sinon.assert.calledWith(vscodeStub.window.showErrorMessage, errorMessage);
    });

    test("is shown when prompt is undefined", async () => {
      vscodeStub.window.showInputBox.returns(undefined);

      await command.newRoute();

      sinon.assert.calledWith(vscodeStub.window.showErrorMessage, errorMessage);
    });

    test("is not shown when prompt is valid", async () => {
      vscodeStub.window.showInputBox.returns(validRouteName);

      await command.newRoute(invalidRouteUri);

      const wantedCalls = vscodeStub.window.showErrorMessage
        .getCalls()
        .filter((call: any) => call.args[0] === errorMessage);
      assert.equal(wantedCalls.length, 0);
    });
  });

  suite("file open dialog", () => {
    test("is shown when Uri is undefined", async () => {
      vscodeStub.window.showInputBox.returns(validRouteName);
      vscodeStub.window.showOpenDialog.returns(Promise.resolve(undefined));

      await command.newRoute();

      sinon.assert.calledWith(vscodeStub.window.showOpenDialog, {
        canSelectMany: false,
        openLabel: "Select a folder or file to create the Route in",
        canSelectFolders: true,
        canSelectFiles: true,
      });
    });

    test("is not shown when Uri is defined", async () => {
      vscodeStub.window.showInputBox.returns(validRouteName);

      await command.newRoute(invalidRouteUri);

      sinon.assert.notCalled(vscodeStub.window.showOpenDialog);
    });
  });

  suite("select a valid directory error message", () => {
    const errorMessage = "Please select a valid directory";

    test("is shown when Uri is undefined and selected file is undefined", async () => {
      vscodeStub.window.showInputBox.returns(validRouteName);
      vscodeStub.window.showOpenDialog.returns(Promise.resolve(undefined));

      await command.newRoute();

      sinon.assert.calledWith(vscodeStub.window.showErrorMessage, errorMessage);
    });

    test("is not shown when Uri is undefined and selected file is given", async () => {
      vscodeStub.window.showInputBox.returns(validRouteName);
      vscodeStub.window.showOpenDialog.returns(
        Promise.resolve([invalidRouteUri])
      );

      await command.newRoute();

      const wantedCalls = vscodeStub.window.showErrorMessage
        .getCalls()
        .filter((call: any) => call.args[0] === errorMessage);
      assert.equal(wantedCalls.length, 0);
    });
  });

  suite(
    "no 'routes' directory found in the selected directory error message",
    () => {
      const errorMessage =
        "No 'routes' directory found in the selected directory";

      test("is shown when Uri is undefined and selected file is invalid", async () => {
        vscodeStub.window.showInputBox.returns(validRouteName);
        vscodeStub.window.showOpenDialog.returns(
          Promise.resolve([invalidRouteUri])
        );

        await command.newRoute();

        sinon.assert.calledWith(
          vscodeStub.window.showErrorMessage,
          errorMessage
        );
      });

      test("is shown when Uri is invalid", async () => {
        vscodeStub.window.showInputBox.returns(validRouteName);

        await command.newRoute(invalidRouteUri);

        sinon.assert.calledWith(
          vscodeStub.window.showErrorMessage,
          errorMessage
        );
      });
    }
  );

  suite("runs dart_frog new route command with route", () => {
    test("runs as expected when Uri is project root directory", async () => {
      vscodeStub.window.showInputBox.returns(validRouteName);

      await command.newRoute({
        fsPath: "/home/dart_frog/routes/",
      });

      sinon.assert.calledWith(
        childProcessStub.exec,
        `dart_frog new route '${validRouteName}'`
      );
    });

    test("runs as expected when Uri is not project root directory", async () => {
      vscodeStub.window.showInputBox.returns(validRouteName);

      const nestedDirectory = "about";
      await command.newRoute({
        fsPath: `/home/dart_frog/routes/${nestedDirectory}`,
      });

      sinon.assert.calledWith(
        childProcessStub.exec,
        `dart_frog new route '${nestedDirectory}/${validRouteName}'`
      );
    });

    test("runs as expected when Uri is a valid non-index nested file", async () => {
      vscodeStub.window.showInputBox.returns(validRouteName);

      const nestedDirectory = "about";
      const nestedFileName = "vgv";
      await command.newRoute({
        fsPath: `/home/dart_frog/routes/${nestedDirectory}/${nestedFileName}.dart`,
      });

      sinon.assert.calledWith(
        childProcessStub.exec,
        `dart_frog new route '${nestedDirectory}/${nestedFileName}/${validRouteName}'`
      );
    });

    test("runs as expected when Uri is a valid index nested file", async () => {
      vscodeStub.window.showInputBox.returns(validRouteName);

      const nestedDirectory = "about";
      const nestedFileName = "index";
      await command.newRoute({
        fsPath: `/home/dart_frog/routes/${nestedDirectory}/${nestedFileName}.dart`,
      });

      sinon.assert.calledWith(
        childProcessStub.exec,
        `dart_frog new route '${nestedDirectory}/${validRouteName}'`
      );
    });
  });

  test("shows error message when dart_frog new route fails", async () => {
    vscodeStub.window.showInputBox.returns(validRouteName);
    const error = Error("Failed to run dart_frog new route");
    childProcessStub.exec.yields(error);

    await command.newRoute({
      fsPath: "/home/dart_frog/routes/",
    });

    sinon.assert.calledWith(vscodeStub.window.showErrorMessage, error.message);
  });
});
