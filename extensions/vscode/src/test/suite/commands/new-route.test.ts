const sinon = require("sinon");
var proxyquire = require("proxyquire");

import { afterEach, beforeEach } from "mocha";

suite("new-route command", () => {
  let vscodeStub: any;
  let command: any;

  beforeEach(() => {
    vscodeStub = {
      window: {
        showErrorMessage: sinon.stub(),
        showInputBox: sinon.stub(),
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

  suite("shows invalid route name error message", () => {
    const errorMessage = "Please enter a valid route name";

    beforeEach(() => {
      vscodeStub.window.showErrorMessage.returns({});
    });

    test("when prompt is empty", async () => {
      vscodeStub.window.showInputBox.returns("");

      await command.newRoute();

      sinon.assert.calledWith(vscodeStub.window.showErrorMessage, errorMessage);
    });

    test("when prompt is white spaced", async () => {
      vscodeStub.window.showInputBox.returns("  ");

      await command.newRoute();

      sinon.assert.calledWith(vscodeStub.window.showErrorMessage, errorMessage);
    });

    test("when prompt is undefined", async () => {
      vscodeStub.window.showInputBox.returns(undefined);

      await command.newRoute();

      sinon.assert.calledWith(vscodeStub.window.showErrorMessage, errorMessage);
    });
  });
});
