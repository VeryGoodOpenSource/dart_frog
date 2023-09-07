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
      nearestDartFrogProject: sinon.stub(),
      normalizeRoutePath: sinon.stub(),
      resolveDartFrogProjectPathFromWorkspace: sinon.stub(),
      isDartFrogCLIInstalled: sinon.stub(),
      suggestInstallingDartFrogCLI: sinon.stub(),
    };
    utilsStub.isDartFrogCLIInstalled.returns(true);

    utilsStub.nearestDartFrogProject
      .withArgs(invalidUri.fsPath)
      .returns(undefined);
    utilsStub.nearestDartFrogProject
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

  suite("file open dialog", () => {
    test("is shown when Uri is undefined and fails to resolve a path from workspace", async () => {
      vscodeStub.window.showOpenDialog.resolves();
      utilsStub.resolveDartFrogProjectPathFromWorkspace.returns(undefined);

      await command.newMiddleware();

      sinon.assert.calledWith(vscodeStub.window.showOpenDialog, {
        canSelectMany: false,
        openLabel: "Select a folder or file to create the middleware in",
        canSelectFolders: true,
        canSelectFiles: true,
      });
    });

    test("is not shown when Uri is undefined but resolves a path from workspace", async () => {
      utilsStub.resolveDartFrogProjectPathFromWorkspace.returns(
        "/home/dart_frog/routes"
      );
      utilsStub.nearestDartFrogProject.returns("/home/dart_frog/");
      utilsStub.normalizeRoutePath.returns("/");

      await command.newMiddleware();

      sinon.assert.notCalled(vscodeStub.window.showOpenDialog);
    });

    test("is not shown when Uri is defined", async () => {
      await command.newMiddleware(invalidUri);

      sinon.assert.notCalled(vscodeStub.window.showOpenDialog);
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
    test("is shown when Uri is undefined and selected file is valid", async () => {
      vscodeStub.window.showInputBox.returns("animals/frog");
      utilsStub.resolveDartFrogProjectPathFromWorkspace.returns(
        "home/routes/animals/frog"
      );
      utilsStub.nearestDartFrogProject.returns("home/routes/animals/frog");
      utilsStub.normalizeRoutePath.returns("/animals/frog");

      await command.newMiddleware();

      sinon.assert.calledWith(vscodeStub.window.showInputBox, {
        prompt: "Middleware's route path",
        value: "/animals/frog",
        placeHolder: "_middleware",
      });
    });

    test("is not shown when Uri is defined and selected file is valid", async () => {
      utilsStub.nearestDartFrogProject.returns("home/routes/animals/frog");
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
      utilsStub.resolveDartFrogProjectPathFromWorkspace.returns(
        "home/routes/animals/frog"
      );
      utilsStub.nearestDartFrogProject.returns("home/routes/animals/frog");
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
      vscodeStub.window.showInputBox.returns(undefined);

      await command.newMiddleware();

      sinon.assert.calledWith(vscodeStub.window.showErrorMessage, errorMessage);
    });
  });

  test("shows progess on middleware creation", async () => {
    const routePath = "food/pizza";
    const selectedUri = {
      fsPath: `${validUri.fsPath}${routePath}`,
    };
    utilsStub.nearestDartFrogProject.returns(selectedUri);
    utilsStub.normalizeRoutePath.returns(routePath);

    await command.newMiddleware(validUri);

    sinon.assert.calledOnceWithMatch(vscodeStub.window.withProgress, {
      location: 15,
      title: `Creating '${routePath}' middleware...`,
    });
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
      utilsStub.nearestDartFrogProject.returns(selectedUri);
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
      utilsStub.nearestDartFrogProject.returns(selectedUri);
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
      utilsStub.nearestDartFrogProject.returns(selectedUri);
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
      utilsStub.resolveDartFrogProjectPathFromWorkspace.returns(
        "home/routes/animals/frog"
      );
      utilsStub.nearestDartFrogProject.returns("home/routes/animals/frog");
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

    utilsStub.nearestDartFrogProject.returns(validUri);
    utilsStub.normalizeRoutePath.returns("/");

    await command.newMiddleware(validUri);
    const progressFunction = vscodeStub.window.withProgress.getCall(0).args[1];
    await progressFunction();

    sinon.assert.calledWith(vscodeStub.window.showErrorMessage, error.message);
  });
});
