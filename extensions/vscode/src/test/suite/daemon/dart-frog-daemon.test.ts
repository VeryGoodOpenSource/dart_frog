const sinon = require("sinon");
var proxyquire = require("proxyquire");
import { EventEmitter } from "events";

import { afterEach, beforeEach } from "mocha";
import assert = require("assert");

suite("DartFrogDaemon", () => {
  let childProcessStub: any;
  // eslint-disable-next-line @typescript-eslint/naming-convention
  let DartFrogDaemon: any;

  beforeEach(() => {
    childProcessStub = {
      spawn: sinon.stub(),
    };

    DartFrogDaemon = proxyquire("../../../daemon/dart-frog-daemon", {
      // eslint-disable-next-line @typescript-eslint/naming-convention
      child_process: childProcessStub,
    }).DartFrogDaemon;
  });

  afterEach(() => {
    sinon.restore();
  });

  test("instance retrieves a singleton", () => {
    const daemon = DartFrogDaemon.instance;
    const daemon2 = DartFrogDaemon.instance;

    assert.equal(daemon, daemon2);
  });

  suite("isReady", () => {
    const workingDirectory = "workingDirectory";
    const readyMessage = `[{"event":"daemon.ready","params":{"version":"0.0.1","processId":94799}}]`;

    test("initially false", () => {
      const daemon = new DartFrogDaemon();
      assert.equal(daemon.isReady, false);
    });

    test("true after beeing invoked", async () => {
      const daemonProcess = sinon.stub();
      const daemonStdoutEventEmitter = new EventEmitter();
      daemonProcess.stdout = daemonStdoutEventEmitter;
      childProcessStub.spawn
        .withArgs("dart_frog", ["daemon"], {
          cwd: workingDirectory,
        })
        .returns(daemonProcess);

      const daemon = new DartFrogDaemon();

      const invokePromise = daemon.invoke(workingDirectory);
      daemonStdoutEventEmitter.emit("data", readyMessage);
      await invokePromise;

      assert.equal(daemon.isReady, true);
    });
  });

  suite("invoke", () => {
    const workingDirectory = "workingDirectory";
    const readyMessage = `[{"event":"daemon.ready","params":{"version":"0.0.1","processId":94799}}]`;

    test("doesn't start daemon when already ready", async () => {
      const daemonProcess = sinon.stub();
      const daemonStdoutEventEmitter = new EventEmitter();
      daemonProcess.stdout = daemonStdoutEventEmitter;
      childProcessStub.spawn
        .withArgs("dart_frog", ["daemon"], {
          cwd: workingDirectory,
        })
        .returns(daemonProcess);

      const daemon = new DartFrogDaemon();

      const invokePromise = daemon.invoke(workingDirectory);
      daemonStdoutEventEmitter.emit("data", readyMessage);
      await invokePromise;

      daemon.invoke(workingDirectory);

      sinon.assert.calledOnce(childProcessStub.spawn);
    });

    test("doesn't start daemon when already waiting", async () => {
      const daemonProcess = sinon.stub();
      const daemonStdoutEventEmitter = new EventEmitter();
      daemonProcess.stdout = daemonStdoutEventEmitter;
      childProcessStub.spawn
        .withArgs("dart_frog", ["daemon"], {
          cwd: workingDirectory,
        })
        .returns(daemonProcess);

      const daemon = new DartFrogDaemon();

      daemon.invoke(workingDirectory);
      daemonStdoutEventEmitter.emit("data", readyMessage);

      daemon.invoke(workingDirectory);

      sinon.assert.calledOnce(childProcessStub.spawn);
    });
  });
});
