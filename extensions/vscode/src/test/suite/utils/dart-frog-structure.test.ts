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

suite("nearestDartFrogProject", () => {
  let fsStub: any;
  let nearestDartFrogProject: any;

  beforeEach(() => {
    fsStub = {
      existsSync: sinon.stub(),
      readFileSync: sinon.stub(),
    };

    nearestDartFrogProject = proxyquire("../../../utils/dart-frog-structure", {
      fs: fsStub,
    }).nearestDartFrogProject;
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
      nearestDartFrogProject(`${dartFrogPath}/routes/a/routes/b/index.dart`),
      dartFrogPath
    );
    assert.equal(
      nearestDartFrogProject(`${dartFrogPath}/routes/index.dart`),
      dartFrogPath
    );
    assert.equal(
      nearestDartFrogProject(`${dartFrogPath}/routes/z.py`),
      dartFrogPath
    );
    assert.equal(
      nearestDartFrogProject(`${dartFrogPath}/tennis.dart`),
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
      nearestDartFrogProject(`${dartFrogPath2}/routes/a/routes/b/index.dart`),
      dartFrogPath2
    );
    assert.equal(
      nearestDartFrogProject(`${dartFrogPath1}/routes/index.dart`),
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

    const result = nearestDartFrogProject(
      `${dartFrogPath}/fruits/pineapple.dart`
    );
    assert.equal(result, undefined);
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

      const nearestDartFrogProject = sinon.stub();
      nearestDartFrogProject
        .withArgs("/home/bin/routes/animals")
        .returns(undefined);
      nearestDartFrogProject.withArgs("home/user/").returns("home/user/");

      const result = resolveDartFrogProjectPathFromWorkspace(
        nearestDartFrogProject
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
