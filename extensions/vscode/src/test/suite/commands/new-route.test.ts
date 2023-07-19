const sinon = require("sinon");
var proxyquire = require("proxyquire");

import { afterEach, beforeEach } from "mocha";
import * as assert from "assert";

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
      },
    };
    childProcessStub = {
      exec: sinon.stub(),
    };

    utilsStub = {
      nearestDartFrogProject: sinon.stub(),
      normalizeRoutePath: sinon.stub(),
    };

    utilsStub.nearestDartFrogProject
      .withArgs(invalidUri.fsPath)
      .returns(undefined);
    utilsStub.nearestDartFrogProject
      .withArgs(validUri.fsPath)
      .returns(validUri.fsPath);

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

  test("shows input box to input route name", async () => {
    vscodeStub.window.showInputBox.returns("");

    await command.newRoute();

    sinon.assert.calledWith(vscodeStub.window.showInputBox, {
      prompt: "Route name",
      placeHolder: "index",
    });
  });

  suite("invalid route name error message", () => {
    const errorMessage = "Please enter a valid route name";

    beforeEach(() => {
      vscodeStub.window.showErrorMessage.returns({});
    });

    test("is shown when prompt is empty", async () => {
      vscodeStub.window.showInputBox.returns("");

      await command.newRoute();

      sinon.assert.calledWith(vscodeStub.window.showErrorMessage, errorMessage);
    });

    test("is shown when prompt is white spaced", async () => {
      vscodeStub.window.showInputBox.returns("  ");

      await command.newRoute();

      sinon.assert.calledWith(vscodeStub.window.showErrorMessage, errorMessage);
    });

    test("is shown when prompt is undefined", async () => {
      vscodeStub.window.showInputBox.returns(undefined);

      await command.newRoute();

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

  suite("file open dialog", () => {
    test("is shown when Uri is undefined", async () => {
      vscodeStub.window.showInputBox.returns(validRouteName);
      vscodeStub.window.showOpenDialog.returns(Promise.resolve(undefined));

      await command.newRoute();

      sinon.assert.calledWith(vscodeStub.window.showOpenDialog, {
        canSelectMany: false,
        openLabel: "Select a folder or file to create the Route in",
        canSelectFolders: true,
        canSelectFiles: true,
      });
    });

    test("is not shown when Uri is defined", async () => {
      vscodeStub.window.showInputBox.returns(validRouteName);

      await command.newRoute(invalidUri);

      sinon.assert.notCalled(vscodeStub.window.showOpenDialog);
    });
  });

  suite("select a valid directory error message", () => {
    const errorMessage = "Please select a valid directory";

    test("is shown when Uri is undefined and selected file is undefined", async () => {
      vscodeStub.window.showInputBox.returns(validRouteName);
      vscodeStub.window.showOpenDialog.returns(Promise.resolve(undefined));

      await command.newRoute();

      sinon.assert.calledWith(vscodeStub.window.showErrorMessage, errorMessage);
    });

    test("is not shown when Uri is undefined and selected file is given", async () => {
      vscodeStub.window.showInputBox.returns(validRouteName);
      vscodeStub.window.showOpenDialog.returns(Promise.resolve([invalidUri]));

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
        vscodeStub.window.showOpenDialog.returns(Promise.resolve([invalidUri]));

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

  suite("runs `dart_frog new route` command with route", () => {
    test("successfully with non-index route name", async () => {
      const routeName = "pizza";
      vscodeStub.window.showInputBox.returns(routeName);
      utilsStub.normalizeRoutePath.returns("/");

      await command.newRoute(validUri);

      sinon.assert.calledWith(
        childProcessStub.exec,
        `dart_frog new route '/${routeName}'`
      );
    });

    test("successfully with deep non-index route name", async () => {
      const routeName = "pizza";
      vscodeStub.window.showInputBox.returns(routeName);

      const selectedUri = {
        fsPath: `${validUri.fsPath}/food`,
      };
      utilsStub.nearestDartFrogProject.returns(selectedUri);
      utilsStub.normalizeRoutePath.returns(`food`);

      await command.newRoute(selectedUri);

      sinon.assert.calledWith(
        childProcessStub.exec,
        `dart_frog new route 'food/${routeName}'`
      );
    });

    test("successfully with index route name", async () => {
      const routeName = "index";
      vscodeStub.window.showInputBox.returns(routeName);
      utilsStub.normalizeRoutePath.returns("/");

      await command.newRoute(validUri);

      sinon.assert.calledWith(childProcessStub.exec, `dart_frog new route '/'`);
    });

    test("successfully with deep index route name", async () => {
      const routeName = "index";
      vscodeStub.window.showInputBox.returns(routeName);

      const selectedUri = {
        fsPath: `${validUri.fsPath}/food`,
      };
      utilsStub.nearestDartFrogProject.returns(selectedUri);
      utilsStub.normalizeRoutePath.returns("food");

      await command.newRoute(selectedUri);

      sinon.assert.calledWith(
        childProcessStub.exec,
        `dart_frog new route 'food'`
      );
    });
  });

  test("shows error message when `dart_frog new route` fails", async () => {
    vscodeStub.window.showInputBox.returns(validRouteName);

    utilsStub.normalizeRoutePath.returns("hello");

    const error = Error("Failed to run `dart_frog new route`");
    childProcessStub.exec.yields(error);

    await command.newRoute(validUri);

    sinon.assert.calledWith(vscodeStub.window.showErrorMessage, error.message);
  });
});
