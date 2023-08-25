const sinon = require("sinon");
var proxyquire = require("proxyquire");

import * as assert from "assert";
import { afterEach, beforeEach } from "mocha";
import { DartFrogApplication } from "../../../daemon";

suite("quickPickApplication", () => {
  let vscodeStub: any;
  let quickPickApplication: any;
  let quickPick: any;

  const application1 = new DartFrogApplication("workingDirectory1", 8080, 8181);
  const application2 = new DartFrogApplication("workingDirectory2", 8081, 8182);

  beforeEach(() => {
    vscodeStub = {
      window: {
        createQuickPick: sinon.stub(),
      },
    };

    quickPickApplication = proxyquire("../../../utils/dart-frog-application", {
      vscode: vscodeStub,
    }).quickPickApplication;

    quickPick = sinon.stub();
    vscodeStub.window.createQuickPick.returns(quickPick);
    quickPick.show = sinon.stub();
    quickPick.dispose = sinon.stub();
    quickPick.onDidChangeSelection = sinon.stub();

    application1.address = `http://localhost:${application1.port}`;
    application1.id = "application1";
    application2.address = `http://localhost:${application2.port}`;
    application2.id = "application2";
  });

  afterEach(() => {
    sinon.restore();
  });

  suite("placeholder", () => {
    test("is undefined by default", async () => {
      const application = quickPickApplication({}, [
        application1,
        application2,
      ]);

      const onDidChangeSelection =
        quickPick.onDidChangeSelection.getCall(0).args[0];
      onDidChangeSelection([]);

      await application;

      assert.strictEqual(quickPick.placeholder, undefined);
    });

    test("can be overridden", async () => {
      const placeHolder = "placeholder";
      const application = quickPickApplication(
        {
          placeHolder,
        },
        [application1, application2]
      );

      const onDidChangeSelection =
        quickPick.onDidChangeSelection.getCall(0).args[0];
      onDidChangeSelection([]);

      await application;

      assert.strictEqual(quickPick.placeholder, placeHolder);
    });
  });

  suite("ignoreFocusOut", () => {
    test("is true by default", async () => {
      const application = quickPickApplication({}, [
        application1,
        application2,
      ]);

      const onDidChangeSelection =
        quickPick.onDidChangeSelection.getCall(0).args[0];
      onDidChangeSelection([]);

      await application;

      assert.strictEqual(quickPick.ignoreFocusOut, true);
    });

    test("can be overridden", async () => {
      const ignoreFocusOut = false;
      const application = quickPickApplication(
        {
          ignoreFocusOut,
        },
        [application1, application2]
      );

      const onDidChangeSelection =
        quickPick.onDidChangeSelection.getCall(0).args[0];
      onDidChangeSelection([]);

      await application;

      assert.strictEqual(quickPick.ignoreFocusOut, ignoreFocusOut);
    });
  });

  suite("canSelectMany", () => {
    test("is false by default", async () => {
      const application = quickPickApplication({}, [
        application1,
        application2,
      ]);

      const onDidChangeSelection =
        quickPick.onDidChangeSelection.getCall(0).args[0];
      onDidChangeSelection([]);

      await application;

      assert.strictEqual(quickPick.canSelectMany, false);
    });

    test("can be overridden", async () => {
      const canPickMany = true;
      const application = quickPickApplication(
        {
          canPickMany,
        },
        [application1, application2]
      );

      const onDidChangeSelection =
        quickPick.onDidChangeSelection.getCall(0).args[0];
      onDidChangeSelection([]);

      await application;

      assert.strictEqual(quickPick.canSelectMany, canPickMany);
    });
  });

  test("busy is false by default", async () => {
    const application = quickPickApplication({}, [application1, application2]);

    const onDidChangeSelection =
      quickPick.onDidChangeSelection.getCall(0).args[0];
    onDidChangeSelection([]);

    await application;

    assert.strictEqual(quickPick.busy, false);
  });

  test("shows appropiate items for each running application", async () => {
    const application = quickPickApplication({}, [application1, application2]);

    const onDidChangeSelection =
      quickPick.onDidChangeSelection.getCall(0).args[0];
    onDidChangeSelection([]);

    await application;

    const items = quickPick.items;

    sinon.assert.match(items[0], {
      label: `$(globe) localhost:${application1.port}`,
      description: application1.id,
      application: application1,
    });
    sinon.assert.match(items[1], {
      label: `$(globe) localhost:${application2.port}`,
      description: application2.id,
      application: application2,
    });
  });

  test("shows the quick pick", async () => {
    const application = quickPickApplication({}, [application1, application2]);

    const onDidChangeSelection =
      quickPick.onDidChangeSelection.getCall(0).args[0];
    onDidChangeSelection([]);

    await application;

    sinon.assert.calledOnce(quickPick.show);
  });

  suite("onDidSelectItem", () => {
    test("is called when an item is selected", async () => {
      const onDidSelectItem = sinon.stub();
      const application = quickPickApplication(
        {
          onDidSelectItem,
        },
        [application1, application2]
      );

      const onDidChangeSelection =
        quickPick.onDidChangeSelection.getCall(0).args[0];
      onDidChangeSelection([{ application: application1 }]);

      await application;

      sinon.assert.calledOnceWithExactly(onDidSelectItem, {
        application: application1,
      });
    });

    test("is not called when an item is dismissed", async () => {
      const onDidSelectItem = sinon.stub();
      const application = quickPickApplication(
        {
          onDidSelectItem,
        },
        [application1, application2]
      );

      const onDidChangeSelection =
        quickPick.onDidChangeSelection.getCall(0).args[0];
      onDidChangeSelection(undefined);

      await application;

      sinon.assert.notCalled(onDidSelectItem);
    });
  });

  suite("dispose", () => {
    test("is called when an item is selected", async () => {
      const application = quickPickApplication({}, [
        application1,
        application2,
      ]);

      const onDidChangeSelection =
        quickPick.onDidChangeSelection.getCall(0).args[0];
      onDidChangeSelection([{ application: application1 }]);

      await application;

      sinon.assert.calledOnce(quickPick.dispose);
    });

    test("is called when an item is dismissed", async () => {
      const application = quickPickApplication({}, [
        application1,
        application2,
      ]);

      const onDidChangeSelection =
        quickPick.onDidChangeSelection.getCall(0).args[0];
      onDidChangeSelection(undefined);

      await application;

      sinon.assert.calledOnce(quickPick.dispose);
    });
  });

  suite("returns", () => {
    test("returns undefined when dismissed", async () => {
      const application = quickPickApplication({}, [
        application1,
        application2,
      ]);

      const onDidChangeSelection =
        quickPick.onDidChangeSelection.getCall(0).args[0];
      onDidChangeSelection(undefined);

      const selection = await application;

      assert.strictEqual(selection, undefined);
    });

    test("returns application when selected", async () => {
      const application = quickPickApplication({}, [
        application1,
        application2,
      ]);

      const onDidChangeSelection =
        quickPick.onDidChangeSelection.getCall(0).args[0];
      onDidChangeSelection([{ application: application1 }]);

      const selection = await application;

      assert.strictEqual(selection, application1);
    });
  });
});
