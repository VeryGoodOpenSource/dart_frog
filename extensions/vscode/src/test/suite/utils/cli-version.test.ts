const sinon = require("sinon");
var proxyquire = require("proxyquire");

import { afterEach, beforeEach } from "mocha";
import * as assert from "assert";

suite("readCLIVersion", () => {
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

  test("returns the version of Dart Frog CLI installed in the user's system", () => {
    const dartFrogVersionCommandResult = "0.3.7\n";
    const encoededDartFrogVersionCommandResult = new TextEncoder().encode(
      dartFrogVersionCommandResult
    );
    cpStub.execSync.returns(encoededDartFrogVersionCommandResult);

    assert.strictEqual(cliVersion.readCLIVersion(), "0.3.7");
  });

  test("returns undefined if Dart Frog CLI is not installed", () => {
    cpStub.execSync.throws();

    assert.strictEqual(cliVersion.readCLIVersion(), undefined);
  });
});

suite("isCompatibleCLIVersion", () => {
  let cliVersion: any;

  beforeEach(() => {
    cliVersion = proxyquire("../../../utils/cli-version", {});
  });

  test("returns true if the version of Dart Frog CLI installed in the user's system is compatible with this extension", () => {
    assert.strictEqual(cliVersion.isCompatibleCLIVersion("0.3.8"), true);
    assert.strictEqual(cliVersion.isCompatibleCLIVersion("0.3.7"), true);
  });

  test("returns false if the version of Dart Frog CLI installed in the user's system is not compatible with this extension", () => {
    assert.strictEqual(cliVersion.isCompatibleCLIVersion("1.0.0"), false);
    assert.strictEqual(cliVersion.isCompatibleCLIVersion("0.3.6"), false);
  });
});
