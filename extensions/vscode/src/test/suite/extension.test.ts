const sinon = require("sinon");
var proxyquire = require("proxyquire");

import * as assert from "assert";
import * as vscode from "vscode";
import { newRoute } from "../../commands";
import { afterEach } from "mocha";

suite("activate", () => {
  afterEach(() => {
    sinon.restore();
  });

  test("subcribes to one disposable", async () => {
    const extension = vscode.extensions.getExtension(
      "VeryGoodVentures.dart-frog"
    ) as vscode.Extension<any>;

    const context = await extension.activate();

    assert.strictEqual(context.subscriptions.length, 2);
  });

  test("registers new-route command", async () => {
    const vscodeStub = {
      commands: {
        registerCommand: sinon.stub().returns({}),
      },
    };
    var extension = proxyquire("../../extension", { vscode: vscodeStub });
    extension.activate({ subscriptions: [] });

    sinon.assert.calledWith(
      vscodeStub.commands.registerCommand,
      "extension.new-route",
      newRoute
    );
  });
});
