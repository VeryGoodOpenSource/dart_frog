const sinon = require("sinon");
var proxyquire = require("proxyquire");

import * as assert from "assert";
import * as vscode from "vscode";
import { newMiddleware, newRoute } from "../../commands";
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
      extension = proxyquire("../../extension", { vscode: vscodeStub });
      context = { subscriptions: [] };
    });

    afterEach(() => {
      sinon.restore();
    });

    test("new-route", async () => {
      extension.activate(context);

      sinon.assert.calledWith(
        vscodeStub.commands.registerCommand,
        "extension.new-route",
        newRoute
      );
    });

    test("new-middleware", async () => {
      extension.activate(context);

      sinon.assert.calledWith(
        vscodeStub.commands.registerCommand,
        "extension.new-middleware",
        newMiddleware
      );
    });
  });
});
