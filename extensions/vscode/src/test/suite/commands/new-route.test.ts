const sinon = require("sinon");
var proxyquire = require("proxyquire");

import { afterEach, beforeEach } from "mocha";
import * as assert from "assert";

suite("new-route command", () => {
  const validRouteName = "frog";
  const invalidRoutePath = "/home/dart_frog";

  let vscodeStub: any;
  let command: any;

  beforeEach(() => {
    vscodeStub = {
      window: {
        showErrorMessage: sinon.stub(),
        showInputBox: sinon.stub(),
        showOpenDialog: sinon.stub(),
      },
    };
    command = proxyquire("../../../commands/new-route", {
      vscode: vscodeStub,
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

      await command.newRoute({
        fsPath: invalidRoutePath,
      });

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
      vscodeStub.window.showInputBox.returns("frog");

      await command.newRoute({
        fsPath: invalidRoutePath,
      });

      sinon.assert.notCalled(vscodeStub.window.showOpenDialog);
    });
  });
});
