const sinon = require("sinon");
var proxyquire = require("proxyquire");

import { afterEach, beforeEach } from "mocha";
import * as assert from "assert";

suite("readDartFrogVersion", () => {
  let cpStub: any;
  let cliVersion: any;

  beforeEach(() => {
    cpStub = {
      execSync: sinon.stub(),
    };
    const semverStub = {
      satisfies: sinon.stub(),
    };

    cliVersion = proxyquire("../../../utils/cli-version", {
      // eslint-disable-next-line @typescript-eslint/naming-convention
      child_process: cpStub,
      semver: semverStub,
    });
  });

  afterEach(() => {
    sinon.restore();
  });

  test("returns the version of Dart Frog CLI installed in the user's system", () => {
    cpStub.execSync.returns("0.3.7");

    assert.strictEqual(cliVersion.readDartFrogVersion(), "0.3.7");
  });

  test("returns undefined if Dart Frog CLI is not installed", () => {
    cpStub.execSync.throws();

    assert.strictEqual(cliVersion.readDartFrogVersion(), undefined);
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
