const sinon = require("sinon");
var proxyquire = require("proxyquire");
const path = require("node:path");

import * as assert from "assert";
import { afterEach, beforeEach } from "mocha";

suite("normalizeRoutePath", () => {
  let fsStub: any;
  let normalizeRoutePath: any;

  beforeEach(() => {
    fsStub = {
      existsSync: sinon.stub(),
      readFileSync: sinon.stub(),
    };

    normalizeRoutePath = proxyquire("../../../utils/dart-frog-structure", {
      fs: fsStub,
    }).normalizeRoutePath;
  });

  afterEach(() => {
    sinon.restore();
  });

  test("returns the route path", () => {
    const dartFrogPath = "/home/user";
    const routesPath = path.join(dartFrogPath, "routes");
    const pubspecPath = path.join(dartFrogPath, "pubspec.yaml");

    fsStub.existsSync.withArgs(routesPath).returns(true);
    fsStub.existsSync.withArgs(pubspecPath).returns(true);
    fsStub.readFileSync
      .withArgs(pubspecPath, "utf-8")
      .returns(validPubspecYaml);

    assert.equal(
      normalizeRoutePath(`${dartFrogPath}/routes`, dartFrogPath),
      "/"
    );
    assert.equal(
      normalizeRoutePath(`${dartFrogPath}/routes/index.dart`, dartFrogPath),
      "/"
    );
    assert.equal(
      normalizeRoutePath(`${dartFrogPath}/routes/z.py`, dartFrogPath),
      "z"
    );
    assert.equal(
      normalizeRoutePath(`${dartFrogPath}/routes/tennis.dart`, dartFrogPath),
      "tennis"
    );
    assert.equal(
      normalizeRoutePath(
        `${dartFrogPath}/routes/sports/tennis.dart`,
        dartFrogPath
      ),
      "sports/tennis"
    );
    assert.equal(
      normalizeRoutePath(
        `${dartFrogPath}/routes/sports/tennis/players/[id]/spanish/nadal.dart`,
        dartFrogPath
      ),
      "sports/tennis/players/[id]/spanish/nadal"
    );
    assert.equal(
      normalizeRoutePath(
        `${dartFrogPath}/routes/a/routes/b/index.dart`,
        dartFrogPath
      ),
      "a/routes/b"
    );
    assert.equal(
      normalizeRoutePath(`${dartFrogPath}/routes/a/b/`, dartFrogPath),
      "a/b"
    );
    assert.equal(
      normalizeRoutePath(`${dartFrogPath}/routes/a/routes/b/`, dartFrogPath),
      "a/routes/b"
    );
    assert.equal(
      normalizeRoutePath(`${dartFrogPath}/routes/a/[id]/b/`, dartFrogPath),
      "a/[id]/b"
    );
    assert.equal(
      normalizeRoutePath(`${dartFrogPath}/tennis.dart`, dartFrogPath),
      "/"
    );
    assert.equal(
      normalizeRoutePath(
        `${dartFrogPath}/routes/a/b/_middleware.dart`,
        dartFrogPath
      ),
      "a/b"
    );
  });
});

suite("nearestParentDartFrogProject", () => {
  let fsStub: any;
  let nearestParentDartFrogProject: any;

  beforeEach(() => {
    fsStub = {
      existsSync: sinon.stub(),
      readFileSync: sinon.stub(),
    };

    nearestParentDartFrogProject = proxyquire(
      "../../../utils/dart-frog-structure",
      {
        fs: fsStub,
      }
    ).nearestParentDartFrogProject;
  });

  afterEach(() => {
    sinon.restore();
  });

  test("returns the path to the root of the Dart Frog project", () => {
    const dartFrogPath = "/home/user";
    const routesPath = path.join(dartFrogPath, "routes");
    const pubspecPath = path.join(dartFrogPath, "pubspec.yaml");

    fsStub.existsSync.withArgs(routesPath).returns(true);
    fsStub.existsSync.withArgs(pubspecPath).returns(true);
    fsStub.readFileSync
      .withArgs(pubspecPath, "utf-8")
      .returns(validPubspecYaml);

    assert.equal(
      nearestParentDartFrogProject(
        `${dartFrogPath}/routes/a/routes/b/index.dart`
      ),
      dartFrogPath
    );
    assert.equal(
      nearestParentDartFrogProject(`${dartFrogPath}/routes/index.dart`),
      dartFrogPath
    );
    assert.equal(
      nearestParentDartFrogProject(`${dartFrogPath}/routes/z.py`),
      dartFrogPath
    );
    assert.equal(
      nearestParentDartFrogProject(`${dartFrogPath}/tennis.dart`),
      dartFrogPath
    );
  });

  test("returns the path to the root of the Dart Frog project when nested", () => {
    const dartFrogPath1 = "/home/user";
    const routesPath1 = path.join(dartFrogPath1, "routes");
    const pubspecPath1 = path.join(dartFrogPath1, "pubspec.yaml");

    const dartFrogPath2 = "home/user/Developer/myserver";
    const routesPath2 = path.join(dartFrogPath2, "routes");
    const pubspecPath2 = path.join(dartFrogPath2, "pubspec.yaml");

    fsStub.existsSync.withArgs(routesPath1).returns(true);
    fsStub.existsSync.withArgs(pubspecPath1).returns(true);
    fsStub.readFileSync
      .withArgs(pubspecPath1, "utf-8")
      .returns(validPubspecYaml);

    fsStub.existsSync.withArgs(routesPath2).returns(true);
    fsStub.existsSync.withArgs(pubspecPath2).returns(true);
    fsStub.readFileSync
      .withArgs(pubspecPath2, "utf-8")
      .returns(validPubspecYaml);

    assert.equal(
      nearestParentDartFrogProject(
        `${dartFrogPath2}/routes/a/routes/b/index.dart`
      ),
      dartFrogPath2
    );
    assert.equal(
      nearestParentDartFrogProject(`${dartFrogPath1}/routes/index.dart`),
      dartFrogPath1
    );
  });

  test("returns undefined when there is no Dart Frog project", () => {
    const dartFrogPath = "/home/user";
    const routesPath = path.join(dartFrogPath, "routes");
    const pubspecPath = path.join(dartFrogPath, "pubspec.yaml");

    fsStub.existsSync.withArgs(routesPath).returns(false);
    fsStub.existsSync.withArgs(pubspecPath).returns(false);
    fsStub.readFileSync
      .withArgs(pubspecPath, "utf-8")
      .returns(invalidPubspecYaml);

    const result = nearestParentDartFrogProject(
      `${dartFrogPath}/fruits/pineapple.dart`
    );
    assert.equal(result, undefined);
  });
});

suite("nearestChildDartFrogProject", () => {
  let fsStub: any;
  let nearestChildDartFrogProject: any;

  beforeEach(() => {
    fsStub = {
      existsSync: sinon.stub(),
      readFileSync: sinon.stub(),
      statSync: sinon.stub(),
      readdirSync: sinon.stub(),
    };

    nearestChildDartFrogProject = proxyquire(
      "../../../utils/dart-frog-structure",
      {
        fs: fsStub,
      }
    ).nearestChildDartFrogProject;
  });

  afterEach(() => {
    sinon.restore();
  });

  test("returns a single path when the file path is a Dart Frog project", () => {
    const filePath = "/home/project";

    const dartFrogPubspecRoutesPath = path.join(filePath, "routes");
    const dartFrogPubspecPath = path.join(filePath, "pubspec.yaml");
    fsStub.existsSync.withArgs(filePath).returns(true);
    fsStub.statSync.withArgs(filePath).returns({
      isDirectory: () => true,
    });
    fsStub.readdirSync.withArgs(filePath).returns([]);
    fsStub.existsSync.withArgs(dartFrogPubspecRoutesPath).returns(true);
    fsStub.existsSync.withArgs(dartFrogPubspecPath).returns(true);
    fsStub.readFileSync
      .withArgs(dartFrogPubspecPath, "utf-8")
      .returns(validPubspecYaml);

    const result = nearestChildDartFrogProject(filePath);

    assert.deepEqual(Array.from(result), [filePath]);
  });

  test("returns the path to all the child Dart Frog projects", () => {
    fsStub.existsSync.returns(false);

    const filePath = "/home/project";
    fsStub.existsSync.withArgs(filePath).returns(true);
    fsStub.statSync.withArgs(filePath).returns({
      isDirectory: () => true,
    });
    fsStub.readdirSync
      .withArgs(filePath)
      .returns(["file.dart", "frog1", "frog2", "subdirectory", "flutter"]);

    const fileDartPath = "/home/project/file.dart";
    fsStub.existsSync.withArgs(fileDartPath).returns(true);
    fsStub.statSync.withArgs(fileDartPath).returns({
      isDirectory: () => false,
    });

    const dartFrogPath1 = "/home/project/frog1";
    const dartFrogPubspecRoutesPath1 = path.join(dartFrogPath1, "routes");
    const dartFrogPubspecPath1 = path.join(dartFrogPath1, "pubspec.yaml");
    fsStub.existsSync.withArgs(dartFrogPath1).returns(true);
    fsStub.statSync.withArgs(dartFrogPath1).returns({
      isDirectory: () => true,
    });
    fsStub.readdirSync.withArgs(dartFrogPath1).returns([]);
    fsStub.existsSync.withArgs(dartFrogPubspecRoutesPath1).returns(true);
    fsStub.existsSync.withArgs(dartFrogPubspecPath1).returns(true);
    fsStub.readFileSync
      .withArgs(dartFrogPubspecPath1, "utf-8")
      .returns(validPubspecYaml);

    const dartFrogPath2 = "/home/project/frog2";
    const dartFrogPubspecRoutesPath2 = path.join(dartFrogPath2, "routes");
    const dartFrogPubspecPath2 = path.join(dartFrogPath2, "pubspec.yaml");
    fsStub.existsSync.withArgs(dartFrogPath2).returns(true);
    fsStub.statSync.withArgs(dartFrogPath2).returns({
      isDirectory: () => true,
    });
    fsStub.readdirSync.withArgs(dartFrogPath2).returns([]);
    fsStub.existsSync.withArgs(dartFrogPubspecRoutesPath2).returns(true);
    fsStub.existsSync.withArgs(dartFrogPubspecPath2).returns(true);
    fsStub.readFileSync
      .withArgs(dartFrogPubspecPath2, "utf-8")
      .returns(validPubspecYaml);

    const subdirectory = "/home/project/subdirectory";
    fsStub.existsSync.withArgs(subdirectory).returns(true);
    fsStub.statSync.withArgs(subdirectory).returns({
      isDirectory: () => true,
    });
    fsStub.readdirSync.withArgs(subdirectory).returns(["frog3"]);

    const dartFrogPath3 = "/home/project/subdirectory/frog3";
    const dartFrogPubspecRoutesPath3 = path.join(dartFrogPath3, "routes");
    const dartFrogPubspecPath3 = path.join(dartFrogPath3, "pubspec.yaml");
    fsStub.existsSync.withArgs(dartFrogPath3).returns(true);
    fsStub.statSync.withArgs(dartFrogPath3).returns({
      isDirectory: () => true,
    });
    fsStub.readdirSync.withArgs(dartFrogPath3).returns([]);
    fsStub.existsSync.withArgs(dartFrogPubspecRoutesPath3).returns(true);
    fsStub.existsSync.withArgs(dartFrogPubspecPath3).returns(true);
    fsStub.readFileSync
      .withArgs(dartFrogPubspecPath3, "utf-8")
      .returns(validPubspecYaml);

    const flutterPath = "/home/project/flutter";
    const flutterPubspecPath = path.join(flutterPath, "pubspec.yaml");
    fsStub.existsSync.withArgs(flutterPath).returns(true);
    fsStub.statSync.withArgs(flutterPath).returns({
      isDirectory: () => true,
    });
    fsStub.readdirSync.withArgs(flutterPath).returns([]);
    fsStub.existsSync.withArgs(flutterPubspecPath).returns(true);
    fsStub.readFileSync
      .withArgs(flutterPubspecPath, "utf-8")
      .returns(invalidPubspecYaml);

    const result = nearestChildDartFrogProject(filePath);

    assert.deepEqual(Array.from(result), [
      dartFrogPath1,
      dartFrogPath2,
      dartFrogPath3,
    ]);
  });

  suite("returns undefined", () => {
    test("when path does not exist", () => {
      const filePath = "/home/project/routes/animals/frog.dart";
      fsStub.existsSync.withArgs(filePath).returns(false);

      const result = nearestChildDartFrogProject(filePath);

      assert.equal(result, undefined);
    });

    test("when path is not a directory", () => {
      const filePath = "/home/project/routes/animals/frog.dart";
      fsStub.existsSync.withArgs(filePath).returns(true);
      fsStub.statSync.withArgs(filePath).returns({
        isDirectory: () => false,
      });

      const result = nearestChildDartFrogProject(filePath);

      assert.equal(result, undefined);
    });

    test("when subdirectory is not a Dart Frog project", () => {
      const filePath = "/home/project";
      fsStub.existsSync.withArgs(filePath).returns(true);
      fsStub.statSync.withArgs(filePath).returns({
        isDirectory: () => true,
      });
      fsStub.readdirSync.withArgs(filePath).returns(["frog"]);

      const dartFrogPath = "/home/project/frog";
      const dartFrogPubspecRoutesPath = path.join(dartFrogPath, "routes");
      const dartFrogPubspecPath = path.join(dartFrogPath, "pubspec.yaml");
      fsStub.existsSync.withArgs(dartFrogPath).returns(true);
      fsStub.statSync.withArgs(dartFrogPath).returns({
        isDirectory: () => true,
      });
      fsStub.readdirSync.withArgs(dartFrogPath).returns([]);
      fsStub.existsSync.withArgs(dartFrogPubspecRoutesPath).returns(true);
      fsStub.existsSync.withArgs(dartFrogPubspecPath).returns(true);
      fsStub.readFileSync
        .withArgs(dartFrogPubspecPath, "utf-8")
        .returns(invalidPubspecYaml);

      const result = nearestChildDartFrogProject(filePath);

      assert.equal(result, undefined);
    });
  });
});

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

suite("resolveDartFrogProjectPathFromWorkspace", () => {
  let vscodeStub: any;
  let resolveDartFrogProjectPathFromWorkspace: any;

  beforeEach(() => {
    vscodeStub = {
      workspace: {
        workspaceFolders: sinon.stub(),
      },
      window: {
        activeTextEditor: sinon.stub(),
      },
    };

    resolveDartFrogProjectPathFromWorkspace = proxyquire(
      "../../../utils/dart-frog-structure",
      {
        vscode: vscodeStub,
      }
    ).resolveDartFrogProjectPathFromWorkspace;
  });

  afterEach(() => {
    sinon.restore();
  });

  test("returns the file path of the active route Dart file", () => {
    vscodeStub.window.activeTextEditor = {
      document: {
        uri: {
          fsPath: `home/user/routes/index.dart`,
        },
      },
    };

    const result = resolveDartFrogProjectPathFromWorkspace(
      sinon.stub().returns("home/user/")
    );

    sinon.assert.match(result, "home/user/routes/index.dart");
  });

  suite("returns the directory path of the active workspace folder", () => {
    test("when there is no active text editor", () => {
      vscodeStub.window.activeTextEditor = undefined;
      vscodeStub.workspace.workspaceFolders = [
        {
          uri: {
            fsPath: `home/user/routes/animals`,
          },
        },
      ];

      const result = resolveDartFrogProjectPathFromWorkspace(
        sinon.stub().returns("home/user/")
      );

      sinon.assert.match(result, "home/user/routes/animals");
    });

    test("when the active text editor is not a route", () => {
      vscodeStub.window.activeTextEditor = {
        document: {
          uri: {
            fsPath: `home/user/pubspec.yaml`,
          },
        },
      };
      vscodeStub.workspace.workspaceFolders = [
        {
          uri: {
            fsPath: `home/user/`,
          },
        },
      ];

      const result = resolveDartFrogProjectPathFromWorkspace(
        sinon.stub().returns("home/user/")
      );

      sinon.assert.match(result, "home/user/");
    });

    test("when the active text editor is not a Dart route", () => {
      vscodeStub.window.activeTextEditor = {
        document: {
          uri: {
            fsPath: `home/user/routes/hello.yaml`,
          },
        },
      };
      vscodeStub.workspace.workspaceFolders = [
        {
          uri: {
            fsPath: `home/user/`,
          },
        },
      ];

      const result = resolveDartFrogProjectPathFromWorkspace(
        sinon.stub().returns("home/user/")
      );

      sinon.assert.match(result, "home/user/");
    });

    test("when the active text editor is not a Dart Frog project", () => {
      vscodeStub.window.activeTextEditor = {
        document: {
          uri: {
            fsPath: `/home/bin/routes/animals/frog.dart`,
          },
        },
      };
      vscodeStub.workspace.workspaceFolders = [
        {
          uri: {
            fsPath: `home/user/`,
          },
        },
      ];

      const nearestParentDartFrogProject = sinon.stub();
      nearestParentDartFrogProject
        .withArgs("/home/bin/routes/animals")
        .returns(undefined);
      nearestParentDartFrogProject.withArgs("home/user/").returns("home/user/");

      const result = resolveDartFrogProjectPathFromWorkspace(
        nearestParentDartFrogProject
      );

      sinon.assert.match(result, "home/user/");
    });
  });

  suite("returns undefined", () => {
    test("when there is no active workspace folder nor text editor", () => {
      vscodeStub.window.activeTextEditor = undefined;
      vscodeStub.workspace.workspaceFolders = undefined;

      const result = resolveDartFrogProjectPathFromWorkspace(
        sinon.stub().returns(undefined)
      );

      sinon.assert.match(result, undefined);
    });

    test("when there is not an active workspace folder nor text editor that are Dart Frog projects", () => {
      vscodeStub.window.activeTextEditor = {
        document: {
          uri: {
            fsPath: `home/user/routes/animals/frog.dart`,
          },
        },
      };
      vscodeStub.workspace.workspaceFolders = [
        {
          uri: {
            fsPath: `home/user/`,
          },
        },
      ];

      const result = resolveDartFrogProjectPathFromWorkspace(
        sinon.stub().returns(undefined)
      );

      sinon.assert.match(result, undefined);
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
  very_good_analysis: ^5.0.0
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
  very_good_analysis: ^5.0.0
`;
