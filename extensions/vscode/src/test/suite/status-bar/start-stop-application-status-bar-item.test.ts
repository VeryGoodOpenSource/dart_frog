const sinon = require("sinon");
var proxyquire = require("proxyquire");

import {
  DartFrogApplication,
  DartFrogApplicationRegistryEventEmitterTypes,
} from "../../../daemon";
import { afterEach, beforeEach } from "mocha";

suite("StartStopApplicationStatusBarItem", () => {
  const application1 = new DartFrogApplication("workingDirectory", 8080, 8181);
  application1.address = "http://localhost:8080";

  const application2 = new DartFrogApplication("workingDirectory", 8081, 8182);
  application2.address = "http://localhost:8081";

  let vscodeStub: any;
  let utilsStub: any;
  let daemon: any;
  // eslint-disable-next-line @typescript-eslint/naming-convention
  let StartStopApplicationStatusBarItem: any;
  let statusBarItem: any;
  let onDidChangeActiveTextEditor: any;
  let onDidChangeWorkspaceFolders: any;

  beforeEach(() => {
    vscodeStub = {
      window: {
        createStatusBarItem: sinon.stub(),
        onDidChangeActiveTextEditor: sinon.stub(),
      },
      workspace: {
        onDidChangeWorkspaceFolders: sinon.stub(),
      },
    };
    onDidChangeActiveTextEditor = sinon.stub();
    vscodeStub.window.onDidChangeActiveTextEditor.returns(
      onDidChangeActiveTextEditor
    );
    onDidChangeActiveTextEditor.dispose = sinon.stub();

    onDidChangeWorkspaceFolders = sinon.stub();
    vscodeStub.workspace.onDidChangeWorkspaceFolders.returns(
      onDidChangeWorkspaceFolders
    );
    onDidChangeWorkspaceFolders.dispose = sinon.stub();

    vscodeStub.window.createStatusBarItem.returns(
      (statusBarItem = sinon.stub())
    );
    statusBarItem.show = sinon.stub();
    statusBarItem.hide = sinon.stub();
    statusBarItem.text = sinon.stub();
    statusBarItem.tooltip = sinon.stub();
    statusBarItem.command = sinon.stub();
    statusBarItem.dispose = sinon.stub();

    utilsStub = {
      canResolveDartFrogProjectPath: sinon.stub(),
    };
    utilsStub.canResolveDartFrogProjectPath.returns(true);

    const dartFrogDaemon = {
      // eslint-disable-next-line @typescript-eslint/naming-convention
      DartFrogDaemon: sinon.stub(),
    };
    dartFrogDaemon.DartFrogDaemon.instance = sinon.stub();
    daemon = dartFrogDaemon.DartFrogDaemon.instance;
    daemon.applicationRegistry = sinon.stub();
    daemon.applicationRegistry.on = sinon.stub();
    daemon.applicationRegistry.off = sinon.stub();
    daemon.applicationRegistry.all = sinon.stub();

    const dartFrogStatusBarItem = proxyquire(
      "../../../status-bar/dart-frog-status-bar-item",
      {
        vscode: vscodeStub,
        // eslint-disable-next-line @typescript-eslint/naming-convention
        "../utils": utilsStub,
      }
    );

    StartStopApplicationStatusBarItem = proxyquire(
      "../../../status-bar/start-stop-application-status-bar-item",
      {
        // eslint-disable-next-line @typescript-eslint/naming-convention
        "../daemon": dartFrogDaemon,
        // eslint-disable-next-line @typescript-eslint/naming-convention
        "./dart-frog-status-bar-item": dartFrogStatusBarItem,
      }
    ).StartStopApplicationStatusBarItem;
  });

  afterEach(() => {
    sinon.restore();
  });

  suite("is shown", () => {
    test("upon start when in a Dart Frog project", () => {
      utilsStub.canResolveDartFrogProjectPath.returns(true);
      daemon.applicationRegistry.all.returns([]);

      const startStopApplicationStatusBarItem =
        new StartStopApplicationStatusBarItem();

      sinon.assert.calledOnce(
        startStopApplicationStatusBarItem.statusBarItem.show
      );
    });

    test("upon workspace folder change to a Dart Frog project", () => {
      utilsStub.canResolveDartFrogProjectPath.returns(false);
      daemon.applicationRegistry.all.returns([]);

      const startStopApplicationStatusBarItem =
        new StartStopApplicationStatusBarItem();

      utilsStub.canResolveDartFrogProjectPath.returns(true);
      vscodeStub.workspace.onDidChangeWorkspaceFolders.callArg(0);

      sinon.assert.calledOnce(
        startStopApplicationStatusBarItem.statusBarItem.show
      );
    });

    test("upon active file change to a Dart Frog project", () => {
      utilsStub.canResolveDartFrogProjectPath.returns(false);
      daemon.applicationRegistry.all.returns([]);

      const startStopApplicationStatusBarItem =
        new StartStopApplicationStatusBarItem();

      utilsStub.canResolveDartFrogProjectPath.returns(true);
      vscodeStub.window.onDidChangeActiveTextEditor.callArg(0);

      sinon.assert.calledOnce(
        startStopApplicationStatusBarItem.statusBarItem.show
      );
    });
  });

  suite("shows", () => {
    suite("start server", () => {
      const text = "$(dart-frog-start) Start Server";
      const tooltip = "Start development server";
      const command = "dart-frog.start-debug-dev-server";

      test("when there are no registered applications", () => {
        daemon.applicationRegistry.all.returns([]);

        const startStopApplicationStatusBarItem =
          new StartStopApplicationStatusBarItem();

        sinon.assert.match(startStopApplicationStatusBarItem.statusBarItem, {
          text,
          tooltip,
          command,
        });
      });

      test("when there is a registered applications that gets unregistered", () => {
        daemon.applicationRegistry.all.returns([application1]);

        const startStopApplicationStatusBarItem =
          new StartStopApplicationStatusBarItem();

        daemon.applicationRegistry.all.returns([]);
        const applicationDeregistrationListener = daemon.applicationRegistry.on
          .withArgs(
            DartFrogApplicationRegistryEventEmitterTypes.remove,
            sinon.match.any
          )
          .getCall(0).args[1];
        applicationDeregistrationListener(application1);

        sinon.assert.match(startStopApplicationStatusBarItem.statusBarItem, {
          text,
          tooltip,
          command,
        });
      });
    });

    suite("stop server", () => {
      const text = "$(dart-frog-stop) Stop Server";
      const tooltip = "Stop development server";
      const command = "dart-frog.stop-dev-server";

      test("when there are registered applications", () => {
        daemon.applicationRegistry.all.returns([application1, application2]);

        const startStopApplicationStatusBarItem =
          new StartStopApplicationStatusBarItem();

        sinon.assert.match(startStopApplicationStatusBarItem.statusBarItem, {
          text,
          tooltip,
          command,
        });
      });

      test("when there are no registered applications but application gets registered", () => {
        daemon.applicationRegistry.all.returns([]);

        const startStopApplicationStatusBarItem =
          new StartStopApplicationStatusBarItem();

        daemon.applicationRegistry.all.returns([application1]);
        const applicationRegistrationListener = daemon.applicationRegistry.on
          .withArgs(
            DartFrogApplicationRegistryEventEmitterTypes.add,
            sinon.match.any
          )
          .getCall(0).args[1];
        applicationRegistrationListener(application1);

        sinon.assert.match(startStopApplicationStatusBarItem.statusBarItem, {
          text,
          tooltip,
          command,
        });
      });
    });
  });

  suite("is hidden", () => {
    suite("when not in a Dart Frog project", () => {
      test("upon start", () => {
        utilsStub.canResolveDartFrogProjectPath.returns(false);
        daemon.applicationRegistry.all.returns([]);

        const startStopApplicationStatusBarItem =
          new StartStopApplicationStatusBarItem();

        sinon.assert.calledOnce(
          startStopApplicationStatusBarItem.statusBarItem.hide
        );
      });

      test("upon workspace folder change", () => {
        utilsStub.canResolveDartFrogProjectPath.returns(true);
        daemon.applicationRegistry.all.returns([]);

        const startStopApplicationStatusBarItem =
          new StartStopApplicationStatusBarItem();

        utilsStub.canResolveDartFrogProjectPath.returns(false);
        vscodeStub.workspace.onDidChangeWorkspaceFolders.callArg(0);

        sinon.assert.calledOnce(
          startStopApplicationStatusBarItem.statusBarItem.hide
        );
      });

      test("upon active file change", () => {
        utilsStub.canResolveDartFrogProjectPath.returns(true);
        daemon.applicationRegistry.all.returns([]);

        const startStopApplicationStatusBarItem =
          new StartStopApplicationStatusBarItem();

        utilsStub.canResolveDartFrogProjectPath.returns(false);
        vscodeStub.window.onDidChangeActiveTextEditor.callArg(0);

        sinon.assert.calledOnce(
          startStopApplicationStatusBarItem.statusBarItem.hide
        );
      });
    });
  });

  suite("dispose", () => {
    beforeEach(() => {
      daemon.applicationRegistry.all.returns([application1]);
    });

    test("disposes status bar item", () => {
      const startStopApplicationStatusBarItem =
        new StartStopApplicationStatusBarItem();

      startStopApplicationStatusBarItem.dispose();

      sinon.assert.calledOnce(
        startStopApplicationStatusBarItem.statusBarItem.dispose
      );
    });

    test("disposes workspace folder change listener", () => {
      new StartStopApplicationStatusBarItem().dispose();

      sinon.assert.calledOnce(onDidChangeWorkspaceFolders.dispose);
    });

    test("disposes active file change listener", () => {
      new StartStopApplicationStatusBarItem().dispose();

      sinon.assert.calledOnce(onDidChangeActiveTextEditor.dispose);
    });

    test("removes application registration listener", () => {
      new StartStopApplicationStatusBarItem().dispose();

      sinon.assert.calledWith(
        daemon.applicationRegistry.on,
        DartFrogApplicationRegistryEventEmitterTypes.add,
        sinon.match.any
      );

      const applicationRegistrationListener = daemon.applicationRegistry.on
        .withArgs(
          DartFrogApplicationRegistryEventEmitterTypes.add,
          sinon.match.any
        )
        .getCall(0).args[1];

      sinon.assert.calledWith(
        daemon.applicationRegistry.off,
        DartFrogApplicationRegistryEventEmitterTypes.add,
        applicationRegistrationListener
      );
    });

    test("removes application deregistration listener", () => {
      new StartStopApplicationStatusBarItem().dispose();

      sinon.assert.calledWith(
        daemon.applicationRegistry.on,
        DartFrogApplicationRegistryEventEmitterTypes.remove,
        sinon.match.any
      );

      const applicationDeregistrationListener = daemon.applicationRegistry.on
        .withArgs(
          DartFrogApplicationRegistryEventEmitterTypes.remove,
          sinon.match.any
        )
        .getCall(0).args[1];

      sinon.assert.calledWith(
        daemon.applicationRegistry.off,
        DartFrogApplicationRegistryEventEmitterTypes.remove,
        applicationDeregistrationListener
      );
    });
  });
});
