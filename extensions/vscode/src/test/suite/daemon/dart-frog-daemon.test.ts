const sinon = require("sinon");
var proxyquire = require("proxyquire");

import { afterEach, beforeEach } from "mocha";
import { EventEmitter } from "events";
import assert = require("assert");
import { RequestVersionDaemonRequest } from "../../../daemon";

suite("DartFrogDaemon", () => {
  let childProcessStub: any;
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
          shell: true,
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
          shell: true,
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
          shell: true,
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

    const event = `[{"event":"testEvent","params":{}}]`;
    const response = `[{"id":"1","result":{}}]`;
    const request = `[{"id":"1","method":"testRequest","params":{}}]`;

    beforeEach(() => {
      const workingDirectory = "workingDirectory";

      const daemonProcess = sinon.stub();
      const daemonStdoutEventEmitter = new EventEmitter();
      daemonProcess.stdout = stdout = daemonStdoutEventEmitter;
      childProcessStub.spawn
        .withArgs("dart_frog", ["daemon"], {
          cwd: workingDirectory,
          shell: true,
        })
        .returns(daemonProcess);

      daemon = new dartFrogDaemon.DartFrogDaemon();

      const invokePromise = daemon.invoke(workingDirectory);

      const readyMessage = `[{"event":"daemon.ready","params":{"version":"0.0.1","processId":94799}}]`;
      daemonStdoutEventEmitter.emit("data", readyMessage);

      return invokePromise;
    });

    suite("invokes callback", () => {
      test("when request is emitted", () => {
        const callback = sinon.stub();
        daemon.on(
          dartFrogDaemon.DartFrogDaemonEventEmitterTypes.request,
          callback
        );

        stdout.emit("data", request);

        sinon.assert.calledOnce(callback);
      });

      test("when response is emitted", () => {
        const callback = sinon.stub();
        daemon.on(
          dartFrogDaemon.DartFrogDaemonEventEmitterTypes.response,
          callback
        );

        stdout.emit("data", response);

        sinon.assert.calledOnce(callback);
      });

      test("when event is emitted", () => {
        const callback = sinon.stub();
        daemon.on(
          dartFrogDaemon.DartFrogDaemonEventEmitterTypes.event,
          callback
        );

        stdout.emit("data", event);

        sinon.assert.calledOnce(callback);
      });
    });

    suite("doesn't invoke callback", () => {
      test("when listening to events and received request and response", () => {
        const callback = sinon.stub();
        daemon.on(
          dartFrogDaemon.DartFrogDaemonEventEmitterTypes.event,
          callback
        );

        stdout.emit("data", request);
        stdout.emit("data", response);

        sinon.assert.notCalled(callback);
      });

      test("when listening to requests and received event and response", () => {
        const callback = sinon.stub();
        daemon.on(
          dartFrogDaemon.DartFrogDaemonEventEmitterTypes.request,
          callback
        );

        stdout.emit("data", event);
        stdout.emit("data", response);

        sinon.assert.notCalled(callback);
      });

      test("when listening to responses and received request and events", () => {
        const callback = sinon.stub();
        daemon.on(
          dartFrogDaemon.DartFrogDaemonEventEmitterTypes.response,
          callback
        );

        stdout.emit("data", request);
        stdout.emit("data", event);

        sinon.assert.notCalled(callback);
      });
    });
  });

  suite("off", () => {
    let daemon: any;
    let stdout: any;

    const event = `[{"event":"testEvent","params":{}}]`;
    const response = `[{"id":"1","result":{}}]`;
    const request = `[{"id":"1","method":"testRequest","params":{}}]`;

    beforeEach(() => {
      const workingDirectory = "workingDirectory";

      const daemonProcess = sinon.stub();
      const daemonStdoutEventEmitter = new EventEmitter();
      daemonProcess.stdout = stdout = daemonStdoutEventEmitter;
      childProcessStub.spawn
        .withArgs("dart_frog", ["daemon"], {
          cwd: workingDirectory,
          shell: true,
        })
        .returns(daemonProcess);

      daemon = new dartFrogDaemon.DartFrogDaemon();

      const invokePromise = daemon.invoke(workingDirectory);

      const readyMessage = `[{"event":"daemon.ready","params":{"version":"0.0.1","processId":94799}}]`;
      daemonStdoutEventEmitter.emit("data", readyMessage);

      return invokePromise;
    });

    test("disposes events callback", () => {
      const callback = sinon.stub();
      daemon.on(dartFrogDaemon.DartFrogDaemonEventEmitterTypes.event, callback);
      daemon.off(
        dartFrogDaemon.DartFrogDaemonEventEmitterTypes.event,
        callback
      );

      stdout.emit("data", event);

      sinon.assert.notCalled(callback);
    });

    test("disposes requests callback", () => {
      const callback = sinon.stub();
      daemon.on(
        dartFrogDaemon.DartFrogDaemonEventEmitterTypes.request,
        callback
      );
      daemon.off(
        dartFrogDaemon.DartFrogDaemonEventEmitterTypes.request,
        callback
      );

      stdout.emit("data", request);

      sinon.assert.notCalled(callback);
    });

    test("disposes responses callback", () => {
      const callback = sinon.stub();
      daemon.on(
        dartFrogDaemon.DartFrogDaemonEventEmitterTypes.response,
        callback
      );
      daemon.off(
        dartFrogDaemon.DartFrogDaemonEventEmitterTypes.response,
        callback
      );

      stdout.emit("data", response);

      sinon.assert.notCalled(callback);
    });
  });

  suite("send", () => {
    test("throws a DartFrogDaemonNotInvokedError when not invoked", async () => {
      const daemon = new dartFrogDaemon.DartFrogDaemon();

      const request = new RequestVersionDaemonRequest("1");

      assert.throws(
        () => daemon.send(request),
        new dartFrogDaemon.DartFrogDaemonNotInvokedError()
      );
    });

    test("throws a DartFrogDaemonReadyError when invoked but not ready", async () => {
      const daemon = new dartFrogDaemon.DartFrogDaemon();

      const daemonProcess = sinon.stub();
      const daemonStdoutEventEmitter = new EventEmitter();

      daemonProcess.stdout = daemonStdoutEventEmitter;
      const workingDirectory = "workingDirectory";

      childProcessStub.spawn
        .withArgs("dart_frog", ["daemon"], {
          cwd: workingDirectory,
          shell: true,
        })
        .returns(daemonProcess);

      daemon.invoke(workingDirectory);

      const request = new RequestVersionDaemonRequest("1");

      assert.throws(
        () => daemon.send(request),
        new dartFrogDaemon.DartFrogDaemonReadyError()
      );
    });

    suite("when ready", () => {
      let daemon: any;
      let stdout: any;
      let stdin: any;

      beforeEach(() => {
        const workingDirectory = "workingDirectory";

        const daemonProcess = sinon.stub();

        const daemonStdoutEventEmitter = new EventEmitter();
        daemonProcess.stdout = stdout = daemonStdoutEventEmitter;

        daemonProcess.stdin = stdin = {
          write: sinon.stub(),
        };

        childProcessStub.spawn
          .withArgs("dart_frog", ["daemon"], {
            cwd: workingDirectory,
            shell: true,
          })
          .returns(daemonProcess);

        daemon = new dartFrogDaemon.DartFrogDaemon();

        const invokePromise = daemon.invoke(workingDirectory);

        const readyMessage = `[{"event":"daemon.ready","params":{"version":"0.0.1","processId":94799}}]`;
        daemonStdoutEventEmitter.emit("data", readyMessage);

        return invokePromise;
      });

      test("writes request in stdin", async () => {
        const request = new RequestVersionDaemonRequest("1");

        daemon.send(request);

        sinon.assert.calledOnceWithExactly(
          stdin.write,
          `${JSON.stringify([request])}\n`
        );
      });

      test("emits request event", async () => {
        const request = new RequestVersionDaemonRequest("1");

        const callback = sinon.stub();
        daemon.on(
          dartFrogDaemon.DartFrogDaemonEventEmitterTypes.request,
          callback
        );

        daemon.send(request);

        sinon.assert.calledOnceWithExactly(callback, request);
      });

      test("resolves correct response", async () => {
        const request = new RequestVersionDaemonRequest("1");

        const responsePromise = daemon.send(request);

        const anotherResponse = `[{"id":"2","result":{"version":"0.0.1"}}]`;
        stdout.emit("data", anotherResponse);

        const response = `[{"id":"1","result":{"version":"0.0.1"}}]`;
        stdout.emit("data", response);

        const actualResponse = await responsePromise;

        const expectedResponse = {
          id: "1",
          result: {
            version: "0.0.1",
          },
        };

        assert.deepEqual(actualResponse, expectedResponse);
      });

      test("resolves correct response upon error", async () => {
        const request = new RequestVersionDaemonRequest("1");

        const responsePromise = daemon.send(request);

        const anotherResponse = `[{"id":"2","result":{"version":"0.0.1"}}]`;
        stdout.emit("data", anotherResponse);

        const response = `[{"id":"1","error":{"version":"0.0.1"}}]`;
        stdout.emit("data", response);

        const actualResponse = await responsePromise;

        const expectedResponse = {
          id: "1",
          error: {
            version: "0.0.1",
          },
        };

        assert.deepEqual(actualResponse, expectedResponse);
      });
    });
  });
});
