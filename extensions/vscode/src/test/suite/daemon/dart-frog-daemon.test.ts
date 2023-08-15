const sinon = require("sinon");
var proxyquire = require("proxyquire");
import { EventEmitter } from "events";

import { afterEach, beforeEach } from "mocha";
import assert = require("assert");

suite("DartFrogDaemon", () => {
  let childProcessStub: any;
  // eslint-disable-next-line @typescript-eslint/naming-convention
  let dartFrogDaemon: any;

  beforeEach(() => {
    childProcessStub = {
      spawn: sinon.stub(),
    };

    dartFrogDaemon = proxyquire("../../../daemon/dart-frog-daemon", {
      // eslint-disable-next-line @typescript-eslint/naming-convention
      child_process: childProcessStub,
    });
  });

  afterEach(() => {
    sinon.restore();
  });

  test("instance retrieves a singleton", () => {
    const daemon = dartFrogDaemon.DartFrogDaemon.instance;
    const daemon2 = dartFrogDaemon.DartFrogDaemon.instance;

    assert.equal(daemon, daemon2);
  });

  suite("isReady", () => {
    const workingDirectory = "workingDirectory";
    const readyMessage = `[{"event":"daemon.ready","params":{"version":"0.0.1","processId":94799}}]`;

    test("initially false", () => {
      const daemon = new dartFrogDaemon.DartFrogDaemon();
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

      const daemon = new dartFrogDaemon.DartFrogDaemon();

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

      const daemon = new dartFrogDaemon.DartFrogDaemon();

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

      const daemon = new dartFrogDaemon.DartFrogDaemon();

      daemon.invoke(workingDirectory);
      daemonStdoutEventEmitter.emit("data", readyMessage);

      daemon.invoke(workingDirectory);

      sinon.assert.calledOnce(childProcessStub.spawn);
    });
  });

  suite("on", () => {
    let daemon: any;
    let stdout: any;

    beforeEach(() => {
      const workingDirectory = "workingDirectory";

      const daemonProcess = sinon.stub();
      const daemonStdoutEventEmitter = new EventEmitter();
      daemonProcess.stdout = stdout = daemonStdoutEventEmitter;
      childProcessStub.spawn
        .withArgs("dart_frog", ["daemon"], {
          cwd: workingDirectory,
        })
        .returns(daemonProcess);

      daemon = new dartFrogDaemon.DartFrogDaemon();

      const invokePromise = daemon.invoke(workingDirectory);

      const readyMessage = `[{"event":"daemon.ready","params":{"version":"0.0.1","processId":94799}}]`;
      daemonStdoutEventEmitter.emit("data", readyMessage);

      return invokePromise;
    });

    test("invokes callback when request is emitted", () => {
      const callback = sinon.stub();
      daemon.on(
        dartFrogDaemon.DartFrogDaemonEventEmitterTypes.request,
        callback
      );

      const request = `[{"id":1,"method":"testRequest","params":{}}]`;
      stdout.emit("data", request);

      sinon.assert.calledOnce(callback);
    });

    test("invokes callback when response is emitted", () => {
      const callback = sinon.stub();
      daemon.on(
        dartFrogDaemon.DartFrogDaemonEventEmitterTypes.response,
        callback
      );

      const response = `[{"id":1,"result":{}}]`;
      stdout.emit("data", response);

      sinon.assert.calledOnce(callback);
    });

    test("invokes callback when event is emitted", () => {
      const callback = sinon.stub();
      daemon.on(dartFrogDaemon.DartFrogDaemonEventEmitterTypes.event, callback);

      const event = `[{"event":"testEvent","params":{}}]`;
      stdout.emit("data", event);

      sinon.assert.calledOnce(callback);
    });
  });
});
