import * as assert from "assert";
import * as vscode from "vscode";
import { afterEach } from "mocha";

suite("activate", () => {
  test("subcribes to zero disposables", async () => {
    const extension = vscode.extensions.getExtension(
      "VeryGoodVentures.dart-frog"
    ) as vscode.Extension<any>;

    const context = await extension.activate();

    assert.strictEqual(context.subscriptions.length, 0);
  });
});
