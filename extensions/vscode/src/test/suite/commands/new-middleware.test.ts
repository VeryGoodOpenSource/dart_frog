const sinon = require("sinon");
var proxyquire = require("proxyquire");

import * as assert from "assert";
import { afterEach, beforeEach } from "mocha";

suite("new-middleware command", () => {
  const invalidUri = { fsPath: "/home/not_dart_frog/routes" };
  const validUri = { fsPath: "/home/dart_frog/routes" };

  let vscodeStub: any;
  let childProcessStub: any;
  let utilsStub: any;
  let command: any;

  beforeEach(() => {
    vscodeStub = {
      window: {
        showErrorMessage: sinon.stub(),
        showOpenDialog: sinon.stub(),
        withProgress: sinon.stub(),
        showInputBox: sinon.stub(),
      },
    };
    childProcessStub = {
      exec: sinon.stub(),
    };
    utilsStub = {
      nearestParentDartFrogProject: sinon.stub(),
      normalizeRoutePath: sinon.stub(),
      resolveDartFrogProjectPathFromActiveTextEditor: sinon.stub(),
      resolveDartFrogProjectPathFromWorkspaceFolders: sinon.stub(),
      isDartFrogCLIInstalled: sinon.stub(),
      suggestInstallingDartFrogCLI: sinon.stub(),
      quickPickProject: sinon.stub(),
    };
    utilsStub.isDartFrogCLIInstalled.returns(true);
    utilsStub.quickPickProject.resolves(validUri.fsPath);

    utilsStub.nearestParentDartFrogProject
      .withArgs(invalidUri.fsPath)
      .returns();
    utilsStub.nearestParentDartFrogProject
      .withArgs(validUri.fsPath)
      .returns(validUri.fsPath);

    command = proxyquire("../../../commands/new-middleware", {
      vscode: vscodeStub,
      // eslint-disable-next-line @typescript-eslint/naming-convention
      child_process: childProcessStub,
      // eslint-disable-next-line @typescript-eslint/naming-convention
      "../utils": utilsStub,
    });
  });

  afterEach(() => {
    sinon.restore();
  });

  test("suggests installing Dart Frog CLI when not installed", async () => {
    utilsStub.isDartFrogCLIInstalled.returns(false);

    await command.newMiddleware(validUri);

    sinon.assert.calledWith(
      utilsStub.suggestInstallingDartFrogCLI,
      "Running this command requires Dart Frog CLI to be installed."
    );
  });

  test("does not suggest installing Dart Frog CLI when installed", async () => {
    utilsStub.isDartFrogCLIInstalled.returns(true);

    await command.newMiddleware(validUri);

    sinon.assert.notCalled(utilsStub.suggestInstallingDartFrogCLI);
  });

  suite("quick pick project", () => {
    test("is shown when Uri and active text editor are undefined and there is more than one Dart Frog project in workspace folders", async () => {
      utilsStub.resolveDartFrogProjectPathFromActiveTextEditor.returns();
      utilsStub.resolveDartFrogProjectPathFromWorkspaceFolders.returns([
        "/home/dart_frog/routes",
        "/home/dart_frog2/routes",
      ]);

      await command.newMiddleware();

      sinon.assert.calledOnceWithExactly(utilsStub.quickPickProject, {}, [
        "/home/dart_frog/routes",
        "/home/dart_frog2/routes",
      ]);
    });

    suite("is not shown", () => {
      beforeEach(() => {
        utilsStub.nearestParentDartFrogProject.returns("/home/dart_frog/");
        utilsStub.normalizeRoutePath.returns("/");
      });

      test("when Uri is defined", async () => {
        await command.newMiddleware(validUri);

        sinon.assert.notCalled(utilsStub.quickPickProject);
      });

      test("when Uri is undefined but resolves a Dart Frog project from active text editor", async () => {
        utilsStub.resolveDartFrogProjectPathFromActiveTextEditor.returns(
          "/home/dart_frog/routes/index.dart"
        );

        await command.newMiddleware();

        sinon.assert.notCalled(utilsStub.quickPickProject);
      });
    });
  });

  suite("file open dialog", () => {
    test("is shown when Uri is undefined and fails to resolve a path from workspace folder", async () => {
      vscodeStub.window.showOpenDialog.resolves();
      utilsStub.resolveDartFrogProjectPathFromActiveTextEditor.returns();
      utilsStub.resolveDartFrogProjectPathFromWorkspaceFolders.returns();

      await command.newMiddleware();

      sinon.assert.calledWith(vscodeStub.window.showOpenDialog, {
        canSelectMany: false,
        openLabel: "Select a folder or file to create the middleware in",
        canSelectFolders: true,
        canSelectFiles: true,
      });
    });

    suite("is not shown", () => {
      test("when Uri is defined", async () => {
        await command.newMiddleware(invalidUri);

        sinon.assert.notCalled(vscodeStub.window.showOpenDialog);
      });

      test("when Uri is undefined but resolves a path from active text editor", async () => {
        utilsStub.resolveDartFrogProjectPathFromActiveTextEditor.returns(
          "/home/dart_frog/routes/index.dart"
        );
        utilsStub.nearestParentDartFrogProject.returns("/home/dart_frog/");
        utilsStub.normalizeRoutePath.returns("/");

        await command.newMiddleware();

        sinon.assert.notCalled(vscodeStub.window.showOpenDialog);
      });

      test("when Uri and active text editor are undefined but resolves a path from workspace folder", async () => {
        utilsStub.resolveDartFrogProjectPathFromActiveTextEditor.returns();
        utilsStub.resolveDartFrogProjectPathFromWorkspaceFolders.returns([
          "/home/dart_frog/routes",
        ]);
        utilsStub.nearestParentDartFrogProject.returns("/home/dart_frog/");
        utilsStub.normalizeRoutePath.returns("/");

        await command.newMiddleware();

        sinon.assert.called(
          utilsStub.resolveDartFrogProjectPathFromActiveTextEditor
        );
        sinon.assert.notCalled(vscodeStub.window.showOpenDialog);
      });
    });
  });

  suite("select a valid directory error message", () => {
    const errorMessage = "Please select a valid directory";

    test("is shown when Uri is undefined and selected file is undefined", async () => {
      vscodeStub.window.showOpenDialog.resolves();

      await command.newMiddleware();

      sinon.assert.calledWith(vscodeStub.window.showErrorMessage, errorMessage);
    });

    test("is not shown when Uri is undefined and selected file is given", async () => {
      vscodeStub.window.showOpenDialog.resolves([invalidUri]);

      await command.newMiddleware();

      const wantedCalls = vscodeStub.window.showErrorMessage
        .getCalls()
        .filter((call: any) => call.args[0] === errorMessage);
      assert.equal(wantedCalls.length, 0);
    });
  });

  suite(
    "'No Dart Frog project found in the selected directory' error message",
    () => {
      const errorMessage =
        "No Dart Frog project found in the selected directory";

      test("is shown when Uri is undefined and selected file is invalid", async () => {
        vscodeStub.window.showOpenDialog.resolves([invalidUri]);

        await command.newMiddleware();

        sinon.assert.calledWith(
          vscodeStub.window.showErrorMessage,
          errorMessage
        );
      });

      test("is shown when Uri is invalid", async () => {
        await command.newMiddleware(invalidUri);

        sinon.assert.calledWith(
          vscodeStub.window.showErrorMessage,
          errorMessage
        );
      });
    }
  );

  suite("prompts for route path", () => {
    suite("is shown", () => {
      test("when Uri is undefined and resolved active text editor is valid", async () => {
        vscodeStub.window.showInputBox.returns("animals/frog");
        utilsStub.resolveDartFrogProjectPathFromActiveTextEditor.returns(
          "home/routes/animals/frog"
        );
        utilsStub.nearestParentDartFrogProject.returns(
          "home/routes/animals/frog"
        );
        utilsStub.normalizeRoutePath.returns("/animals/frog");

        await command.newMiddleware();

        sinon.assert.notCalled(
          utilsStub.resolveDartFrogProjectPathFromWorkspaceFolders
        );
        sinon.assert.calledWith(vscodeStub.window.showInputBox, {
          prompt: "Middleware's route path",
          value: "/animals/frog",
          placeHolder: "_middleware",
        });
      });

      test("when Uri and resolved active text editor are undefined but resolved workspace file is valid", async () => {
        vscodeStub.window.showInputBox.returns("animals/frog");
        utilsStub.resolveDartFrogProjectPathFromWorkspaceFolders.returns([
          "home/routes/animals/frog",
        ]);
        utilsStub.nearestParentDartFrogProject.returns(
          "home/routes/animals/frog"
        );
        utilsStub.normalizeRoutePath.returns("/animals/frog");

        await command.newMiddleware();

        sinon.assert.called(
          utilsStub.resolveDartFrogProjectPathFromActiveTextEditor
        );
        sinon.assert.calledWith(vscodeStub.window.showInputBox, {
          prompt: "Middleware's route path",
          value: "/animals/frog",
          placeHolder: "_middleware",
        });
      });
    });

    test("is not shown when Uri is defined and selected file is valid", async () => {
      utilsStub.nearestParentDartFrogProject.returns(
        "home/routes/animals/frog"
      );
      utilsStub.normalizeRoutePath.returns("/animals/frog");

      await command.newMiddleware(validUri);

      sinon.assert.neverCalledWith(vscodeStub.window.showInputBox, {
        prompt: "Middleware's route path",
        value: "/animals/frog/",
        placeHolder: "_middleware",
      });
    });
  });

  suite("invalid route path error message", () => {
    const errorMessage = "Please enter a valid route path";

    beforeEach(() => {
      vscodeStub.window.showInputBox.returns("animals/frog");
      utilsStub.resolveDartFrogProjectPathFromWorkspaceFolders.returns([
        "home/routes/animals/frog",
      ]);
      utilsStub.nearestParentDartFrogProject.returns(
        "home/routes/animals/frog"
      );
      utilsStub.normalizeRoutePath.returns("/animals/frog");
    });

    test("is shown when prompt is empty", async () => {
      vscodeStub.window.showInputBox.returns("");

      await command.newMiddleware();

      sinon.assert.calledWith(vscodeStub.window.showErrorMessage, errorMessage);
    });

    test("is shown when prompt is white spaced", async () => {
      vscodeStub.window.showInputBox.returns("  ");

      await command.newMiddleware();

      sinon.assert.calledWith(vscodeStub.window.showErrorMessage, errorMessage);
    });

    test("is shown when prompt is undefined", async () => {
      vscodeStub.window.showInputBox.returns();

      await command.newMiddleware();

      sinon.assert.calledWith(vscodeStub.window.showErrorMessage, errorMessage);
    });
  });

  test("shows progess on middleware creation", async () => {
    const routePath = "food/pizza";
    const selectedUri = {
      fsPath: `${validUri.fsPath}${routePath}`,
    };
    utilsStub.nearestParentDartFrogProject.returns(selectedUri);
    utilsStub.normalizeRoutePath.returns(routePath);

    await command.newMiddleware(validUri);

    sinon.assert.calledOnceWithMatch(vscodeStub.window.withProgress, {
      location: 15,
      title: `Creating '${routePath}' middleware...`,
    });
  });

  test("does not run `dart_frog new middleware` command when project selection is cancelled", async () => {
    utilsStub.resolveDartFrogProjectPathFromActiveTextEditor.returns();
    utilsStub.resolveDartFrogProjectPathFromWorkspaceFolders.returns([
      "/home/dart_frog/routes",
      "/home/dart_frog2/routes",
    ]);
    utilsStub.quickPickProject.resolves();

    await command.newMiddleware();

    sinon.assert.notCalled(childProcessStub.exec);
  });

  suite("runs `dart_frog new middleware` command with route", () => {
    test("successfully with non-index route name", async () => {
      utilsStub.normalizeRoutePath.returns("food");

      await command.newMiddleware(validUri);
      const progressFunction =
        vscodeStub.window.withProgress.getCall(0).args[1];
      await progressFunction();

      sinon.assert.calledWith(
        childProcessStub.exec,
        `dart_frog new middleware 'food'`
      );
    });

    test("successfully with deep non-index route name", async () => {
      const selectedUri = {
        fsPath: `${validUri.fsPath}/food/pizza.dart`,
      };
      utilsStub.nearestParentDartFrogProject.returns(selectedUri);
      utilsStub.normalizeRoutePath.returns(`food/pizza`);

      await command.newMiddleware(selectedUri);
      const progressFunction =
        vscodeStub.window.withProgress.getCall(0).args[1];
      await progressFunction();

      sinon.assert.calledWith(
        childProcessStub.exec,
        `dart_frog new middleware 'food/pizza'`
      );
    });

    test("successfully with index route name", async () => {
      const selectedUri = {
        fsPath: `${validUri.fsPath}/index.dart`,
      };
      utilsStub.nearestParentDartFrogProject.returns(selectedUri);
      utilsStub.normalizeRoutePath.returns("/");

      await command.newMiddleware(validUri);
      const progressFunction =
        vscodeStub.window.withProgress.getCall(0).args[1];
      await progressFunction();

      sinon.assert.calledWith(
        childProcessStub.exec,
        `dart_frog new middleware '/'`
      );
    });

    test("successfully with deep index route name", async () => {
      const selectedUri = {
        fsPath: `${validUri.fsPath}/food/italian/index.dart`,
      };
      utilsStub.nearestParentDartFrogProject.returns(selectedUri);
      utilsStub.normalizeRoutePath.returns("food/italian");

      await command.newMiddleware(selectedUri);
      const progressFunction =
        vscodeStub.window.withProgress.getCall(0).args[1];
      await progressFunction();

      sinon.assert.calledWith(
        childProcessStub.exec,
        `dart_frog new middleware 'food/italian'`
      );
    });

    test("successfully with prompt route path", async () => {
      utilsStub.resolveDartFrogProjectPathFromWorkspaceFolders.returns([
        "home/routes/animals/frog",
      ]);
      utilsStub.nearestParentDartFrogProject.returns(
        "home/routes/animals/frog"
      );
      utilsStub.normalizeRoutePath.returns("/animals/frog");
      vscodeStub.window.showInputBox.returns("animals/lion");

      await command.newMiddleware();
      const progressFunction =
        vscodeStub.window.withProgress.getCall(0).args[1];
      await progressFunction();

      sinon.assert.calledWith(
        childProcessStub.exec,
        `dart_frog new middleware 'animals/lion'`
      );
    });
  });

  test("shows error message when `dart_frog new middleware` fails", async () => {
    const error = Error("Failed to run `dart_frog new middleware`");
    childProcessStub.exec.yields(error);

    utilsStub.nearestParentDartFrogProject.returns(validUri);
    utilsStub.normalizeRoutePath.returns("/");

    await command.newMiddleware(validUri);
    const progressFunction = vscodeStub.window.withProgress.getCall(0).args[1];
    await progressFunction();

    sinon.assert.calledWith(vscodeStub.window.showErrorMessage, error.message);
  });
});
