const sinon = require("sinon");
var proxyquire = require("proxyquire");

import { afterEach, beforeEach } from "mocha";
import * as assert from "assert";

suite("readDartFrogCLIVersion", () => {
  let cpStub: any;
  let cliVersion: any;

  beforeEach(() => {
    cpStub = {
      execSync: sinon.stub(),
    };

    cliVersion = proxyquire("../../../utils/cli-version", {
      // eslint-disable-next-line @typescript-eslint/naming-convention
      child_process: cpStub,
    });
  });

  afterEach(() => {
    sinon.restore();
  });

  test(
    "returns the version of Dart Frog CLI installed in the user's system " +
      "when is last version",
    () => {
      const dartFrogVersionCommandResult = "0.3.7\n";
      const encodedDartFrogVersionCommandResult = new TextEncoder().encode(
        dartFrogVersionCommandResult
      );
      cpStub.execSync.returns(encodedDartFrogVersionCommandResult);

      assert.strictEqual(cliVersion.readDartFrogCLIVersion(), "0.3.7");
    }
  );

  test(
    "returns the version of Dart Frog CLI installed in the user's system " +
      "when new version is available",
    () => {
      const dartFrogVersionCommandResult =
        "0.3.7\n\n" +
        "Update available! 0.3.7 → 0.3.9\n" +
        "Changelog: \u001b]8;;https://github.com/verygoodopensource/dart_frog/releases/tag/dart_frog_cli-v0.3.9\u001b\\https://github.com/verygoodopensource/dart_frog/releases/tag/dart_frog_cli-v0.3.9\u001b]8;;\u001b\\\n" +
        "Run dart_frog update to update\n";
      const encodedDartFrogVersionCommandResult = new TextEncoder().encode(
        dartFrogVersionCommandResult
      );
      cpStub.execSync.returns(encodedDartFrogVersionCommandResult);

      assert.strictEqual(cliVersion.readDartFrogCLIVersion(), "0.3.7");
    }
  );

  test("returns undefined if Dart Frog CLI is not installed", () => {
    cpStub.execSync.throws();

    assert.strictEqual(cliVersion.readDartFrogCLIVersion(), undefined);
  });
});

suite("isCompatibleDartFrogCLIVersion", () => {
  let cliVersion: any;

  beforeEach(() => {
    cliVersion = proxyquire("../../../utils/cli-version", {});
  });

  test("returns true if the version of Dart Frog CLI installed in the user's system is compatible with this extension", () => {
    assert.strictEqual(
      cliVersion.isCompatibleDartFrogCLIVersion("0.3.8"),
      true
    );
    assert.strictEqual(
      cliVersion.isCompatibleDartFrogCLIVersion("0.3.7"),
      true
    );
  });

  test("returns false if the version of Dart Frog CLI installed in the user's system is not compatible with this extension", () => {
    assert.strictEqual(
      cliVersion.isCompatibleDartFrogCLIVersion("1.0.0"),
      false
    );
    assert.strictEqual(
      cliVersion.isCompatibleDartFrogCLIVersion("0.3.6"),
      false
    );
  });
});
