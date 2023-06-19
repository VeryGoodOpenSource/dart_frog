import * as assert from "assert";

import * as vscode from "vscode";

suite("activate", () => {
  test("subcribes to one command", async () => {
    const ext = vscode.extensions.getExtension(
      "VeryGoodVentures.dart-frog"
    ) as vscode.Extension<any>;

    const context = await ext.activate();

    assert.strictEqual(context.subscriptions.length, 1);
  });
});
