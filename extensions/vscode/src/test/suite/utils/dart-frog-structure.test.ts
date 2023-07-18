const sinon = require("sinon");
var proxyquire = require("proxyquire");
const path = require("node:path");

import { afterEach, beforeEach } from "mocha";
import * as assert from "assert";

suite("isDartFrogProject", () => {
  let fsStub: any;
  let isDartFrogProject: any;

  beforeEach(() => {
    fsStub = {
      existsSync: sinon.stub(),
      readFileSync: sinon.stub(),
    };

    isDartFrogProject = proxyquire("../../../utils/dart-frog-structure", {
      fs: fsStub,
    }).isDartFrogProject;
  });

  afterEach(() => {
    sinon.restore();
  });

  test("returns true if the file is at the root of a Dart Frog project", () => {
    const filePath = "/home/user";
    const routesPath = path.join(filePath, "routes");
    const pubspecPath = path.join(filePath, "pubspec.yaml");

    fsStub.existsSync.withArgs(routesPath).returns(true);
    fsStub.existsSync.withArgs(pubspecPath).returns(true);
    fsStub.readFileSync
      .withArgs(pubspecPath, "utf-8")
      .returns(validPubspecYaml);

    const result = isDartFrogProject(filePath);
    assert.equal(result, true);
  });

  suite("returns false", () => {
    test("if the file is missing a routes directory", () => {
      const filePath = "/home/user";
      const routesPath = path.join(filePath, "routes");
      const pubspecPath = path.join(filePath, "pubspec.yaml");

      fsStub.existsSync.withArgs(routesPath).returns(false);
      fsStub.existsSync.withArgs(pubspecPath).returns(true);

      const result = isDartFrogProject(filePath);
      assert.equal(result, false);
    });

    test("if the file is missing a pubspec.yaml file", () => {
      const filePath = "/home/user";
      const routesPath = path.join(filePath, "routes");
      const pubspecPath = path.join(filePath, "pubspec.yaml");

      fsStub.existsSync.withArgs(routesPath).returns(true);
      fsStub.existsSync.withArgs(pubspecPath).returns(false);

      const result = isDartFrogProject(filePath);
      assert.equal(result, false);
    });

    test("if the file is missing a dart_frog dependency", () => {
      const filePath = "/home/user";
      const routesPath = path.join(filePath, "routes");
      const pubspecPath = path.join(filePath, "pubspec.yaml");

      fsStub.existsSync.withArgs(routesPath).returns(true);
      fsStub.existsSync.withArgs(pubspecPath).returns(true);
      fsStub.readFileSync
        .withArgs(pubspecPath, "utf-8")
        .returns(invalidPubspecYaml);

      const result = isDartFrogProject(filePath);
      assert.equal(result, false);
    });

    test("if the file is missing a routes directory and a pubspec.yaml file", () => {
      const filePath = "/home/user";
      const routesPath = path.join(filePath, "routes");
      const pubspecPath = path.join(filePath, "pubspec.yaml");

      fsStub.existsSync.withArgs(routesPath).returns(false);
      fsStub.existsSync.withArgs(pubspecPath).returns(false);

      const result = isDartFrogProject(filePath);
      assert.equal(result, false);
    });
  });
});

/**
 * Example of a pubspec.yaml file that depends on Dart Frog.
 *
 * This is used to verify that the `isDartFrogProject` function works as
 * expected. Which uses a heuristic to determine if a file is in a Dart Frog
 * project based on it containing a `dart_frog` subsstring.
 */
const validPubspecYaml = `
name: sample
description: An new Dart Frog application
version: 1.0.0+1
publish_to: none

environment:
  sdk: ">=2.19.0 <3.0.0"

dependencies:
  dart_frog: ^0.3.0

dev_dependencies:
  test: ^1.19.2
  very_good_analysis: ^4.0.0
`;

/**
 * Example of a pubspec.yaml file, that does not depend on Dart Frog.
 *
 * This is used to verify that the `isDartFrogProject` function works as
 * expected. Which uses a heuristic to determine if a file is in a Dart Frog
 * project based on it containing a `dart_frog` subsstring.
 */
const invalidPubspecYaml = `
name: sample
description: An new Dart Frog application
version: 1.0.0+1
publish_to: none

environment:
  sdk: ">=2.19.0 <3.0.0"

dependencies:
  dart_bird: ^0.3.0

dev_dependencies:
  test: ^1.19.2
  very_good_analysis: ^4.0.0
`;
