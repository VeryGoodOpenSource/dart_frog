const sinon = require("sinon");
var proxyquire = require("proxyquire");

import * as assert from "assert";
import { afterEach, beforeEach } from "mocha";

suite("new-route command", () => {
  const validRouteName = "frog";
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
        showInputBox: sinon.stub(),
        showOpenDialog: sinon.stub(),
        withProgress: sinon.stub(),
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

    utilsStub.nearestParentDartFrogProject
      .withArgs(validUri.fsPath)
      .returns(validUri.fsPath);
    utilsStub.isDartFrogCLIInstalled.returns(true);
    utilsStub.suggestInstallingDartFrogCLI.resolves();

    command = proxyquire("../../../commands/new-route", {
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
    utilsStub.normalizeRoutePath.returns("/");

    await command.newRoute(validUri);

    sinon.assert.calledWith(
      utilsStub.suggestInstallingDartFrogCLI,
      "Running this command requires Dart Frog CLI to be installed."
    );
  });

  test("does not suggest installing Dart Frog CLI when installed", async () => {
    utilsStub.isDartFrogCLIInstalled.returns(true);
    utilsStub.normalizeRoutePath.returns("/");

    await command.newRoute(validUri);

    sinon.assert.notCalled(utilsStub.suggestInstallingDartFrogCLI);
  });

  suite("shows input box to input route path", () => {
    test("without suffixing / when not required", async () => {
      utilsStub.normalizeRoutePath.returns("/");

      await command.newRoute(validUri);

      sinon.assert.calledWith(vscodeStub.window.showInputBox, {
        prompt: "Route path",
        value: "/",
        placeHolder: "index",
      });
    });

    test("with suffixing / when required", async () => {
      utilsStub.normalizeRoutePath.returns("/food");

      await command.newRoute(validUri);

      sinon.assert.calledWith(vscodeStub.window.showInputBox, {
        prompt: "Route path",
        value: "/food/",
        placeHolder: "index",
      });
    });
  });

  suite("invalid route path error message", () => {
    const errorMessage = "Please enter a valid route path";

    beforeEach(() => {
      vscodeStub.window.showErrorMessage.returns({});
      utilsStub.normalizeRoutePath.returns("/");
    });

    test("is shown when prompt is empty", async () => {
      vscodeStub.window.showInputBox.returns("");

      await command.newRoute(validUri);

      sinon.assert.calledWith(vscodeStub.window.showErrorMessage, errorMessage);
    });

    test("is shown when prompt is white spaced", async () => {
      vscodeStub.window.showInputBox.returns("  ");

      await command.newRoute(validUri);

      sinon.assert.calledWith(vscodeStub.window.showErrorMessage, errorMessage);
    });

    test("is shown when prompt is undefined", async () => {
      vscodeStub.window.showInputBox.returns(undefined);

      await command.newRoute(validUri);

      sinon.assert.calledWith(vscodeStub.window.showErrorMessage, errorMessage);
    });

    test("is not shown when prompt is valid", async () => {
      vscodeStub.window.showInputBox.returns(validRouteName);

      await command.newRoute(invalidUri);

      const wantedCalls = vscodeStub.window.showErrorMessage
        .getCalls()
        .filter((call: any) => call.args[0] === errorMessage);
      assert.equal(wantedCalls.length, 0);
    });
  });

  suite("quick pick project", () => {
    test("is shown when Uri and active text editor are undefined and there is more than one Dart Frog project in workspace folders", async () => {
      utilsStub.resolveDartFrogProjectPathFromActiveTextEditor.returns();
      utilsStub.resolveDartFrogProjectPathFromWorkspaceFolders.returns([
        "/home/dart_frog/routes",
        "/home/dart_frog2/routes",
      ]);

      await command.newRoute();

      sinon.assert.calledOnceWithExactly(utilsStub.quickPickProject, {}, [
        "/home/dart_frog/routes",
        "/home/dart_frog2/routes",
      ]);
    });

    suite("is not shown", () => {
      beforeEach(() => {
        utilsStub.normalizeRoutePath.returns("/");
      });

      test("when Uri is defined", async () => {
        await command.newRoute(validUri);

        sinon.assert.notCalled(utilsStub.quickPickProject);
      });

      test("when Uri is undefined but resolves a Dart Frog project from active text editor", async () => {
        utilsStub.resolveDartFrogProjectPathFromActiveTextEditor.returns(
          "/home/dart_frog/routes/index.dart"
        );

        await command.newRoute();

        sinon.assert.notCalled(utilsStub.quickPickProject);
      });
    });
  });

  suite("file open dialog", () => {
    test("is shown when Uri is undefined and fails to resolve a path from workspace", async () => {
      vscodeStub.window.showInputBox.returns(validRouteName);
      vscodeStub.window.showOpenDialog.resolves();
      utilsStub.resolveDartFrogProjectPathFromWorkspaceFolders.returns();

      await command.newRoute();

      sinon.assert.calledWith(vscodeStub.window.showOpenDialog, {
        canSelectMany: false,
        openLabel: "Select a folder or file to create the route in",
        canSelectFolders: true,
        canSelectFiles: true,
      });
    });

    suite("is not shwon", () => {
      test("when Uri is defined", async () => {
        vscodeStub.window.showInputBox.returns(validRouteName);

        await command.newRoute(invalidUri);

        sinon.assert.notCalled(vscodeStub.window.showOpenDialog);
      });

      test("when Uri is undefined but resolves a path from active text editor", async () => {
        utilsStub.resolveDartFrogProjectPathFromActiveTextEditor.returns(
          validUri.fsPath
        );
        utilsStub.normalizeRoutePath.returns("/");

        await command.newRoute();

        sinon.assert.notCalled(vscodeStub.window.showOpenDialog);
      });

      test("when Uri and active text editor are undefined but resolves a path from workspace folder", async () => {
        utilsStub.resolveDartFrogProjectPathFromActiveTextEditor.returns();
        utilsStub.resolveDartFrogProjectPathFromWorkspaceFolders.returns([
          validUri.fsPath,
        ]);
        utilsStub.normalizeRoutePath.returns("/");

        await command.newRoute();

        sinon.assert.called(
          utilsStub.resolveDartFrogProjectPathFromWorkspaceFolders
        );
        sinon.assert.notCalled(vscodeStub.window.showOpenDialog);
      });
    });
  });

  suite("select a valid directory error message", () => {
    const errorMessage = "Please select a valid directory";

    test("is shown when Uri is undefined and selected file is undefined", async () => {
      vscodeStub.window.showInputBox.returns(validRouteName);
      vscodeStub.window.showOpenDialog.resolves();

      await command.newRoute();

      sinon.assert.calledWith(vscodeStub.window.showErrorMessage, errorMessage);
    });

    test("is not shown when Uri is undefined and selected file is given", async () => {
      vscodeStub.window.showInputBox.returns(validRouteName);
      vscodeStub.window.showOpenDialog.resolves([invalidUri]);

      await command.newRoute();

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
        vscodeStub.window.showInputBox.returns(validRouteName);
        vscodeStub.window.showOpenDialog.resolves([invalidUri]);

        await command.newRoute();

        sinon.assert.calledWith(
          vscodeStub.window.showErrorMessage,
          errorMessage
        );
      });

      test("is shown when Uri is invalid", async () => {
        vscodeStub.window.showInputBox.returns(validRouteName);

        await command.newRoute(invalidUri);

        sinon.assert.calledWith(
          vscodeStub.window.showErrorMessage,
          errorMessage
        );
      });
    }
  );

  test("shows progess on route creation", async () => {
    utilsStub.normalizeRoutePath.returns("/");
    const routePath = "pizza";
    vscodeStub.window.showInputBox.returns(routePath);

    await command.newRoute(validUri);

    sinon.assert.calledOnceWithMatch(vscodeStub.window.withProgress, {
      location: 15,
      title: `Creating '${routePath}' route...`,
    });
  });

  test("does not run `dart_frog new route` command when project selection is cancelled", async () => {
    utilsStub.resolveDartFrogProjectPathFromActiveTextEditor.returns();
    utilsStub.resolveDartFrogProjectPathFromWorkspaceFolders.returns([
      "/home/dart_frog/routes",
      "/home/dart_frog2/routes",
    ]);
    utilsStub.quickPickProject.resolves();

    await command.newRoute();

    sinon.assert.notCalled(childProcessStub.exec);
  });

  suite("runs `dart_frog new route` command", () => {
    const routePath = "pizza";

    beforeEach(() => {
      utilsStub.normalizeRoutePath.returns("/");
      vscodeStub.window.showInputBox.returns(routePath);
    });

    test("with prompted route successfully", async () => {
      await command.newRoute(validUri);

      const progressFunction =
        vscodeStub.window.withProgress.getCall(0).args[1];
      await progressFunction();

      sinon.assert.calledWith(
        childProcessStub.exec,
        `dart_frog new route '${routePath}'`
      );
    });

    test("with cwd as selected project", async () => {
      utilsStub.resolveDartFrogProjectPathFromActiveTextEditor.returns();
      utilsStub.resolveDartFrogProjectPathFromWorkspaceFolders.returns([
        "/home/dart_frog/routes",
        validUri.fsPath,
      ]);
      utilsStub.quickPickProject.resolves(validUri.fsPath);

      await command.newRoute();

      const progressFunction =
        vscodeStub.window.withProgress.getCall(0).args[1];
      await progressFunction();

      sinon.assert.calledWith(
        childProcessStub.exec,
        `dart_frog new route '${routePath}'`,
        {
          cwd: validUri.fsPath,
        }
      );
    });
  });

  test("shows error message when `dart_frog new route` fails", async () => {
    vscodeStub.window.showInputBox.returns(validRouteName);

    utilsStub.normalizeRoutePath.returns("hello");

    const error = Error("Failed to run `dart_frog new route`");
    childProcessStub.exec.yields(error);

    await command.newRoute(validUri);
    const progressFunction = vscodeStub.window.withProgress.getCall(0).args[1];
    await progressFunction();

    sinon.assert.calledWith(vscodeStub.window.showErrorMessage, error.message);
  });
});
