const sinon = require("sinon");

import * as assert from "assert";
import {
  ApplicationStartingDaemonEvent,
  DartFrogApplication,
  DartFrogApplicationRegistry,
  DartFrogApplicationRegistryEventEmitterTypes,
  DartFrogDaemonEventEmitterTypes,
  LoggerInfoDaemonEvent,
  ProgressCompleteDaemonEvent,
  StartDaemonRequest,
} from "../../../daemon";
import { EventEmitter } from "events";

suite("DartFrogApplicationRegistry", () => {
  suite("get", () => {
    test("returns undefined when application is not registered", () => {
      const daemon = sinon.stub();
      daemon.on = sinon.stub();
      daemon.off = sinon.stub();

      const registry = new DartFrogApplicationRegistry(daemon);

      const application = registry.get("some-id");

      assert.equal(application, undefined);
    });

    test("returns the registered application", async () => {
      const daemon = sinon.stub();

      const daemonEventEmitter = new EventEmitter();
      daemon.on = daemonEventEmitter.on.bind(daemonEventEmitter);
      daemon.off = daemonEventEmitter.off.bind(daemonEventEmitter);

      const registry = new DartFrogApplicationRegistry(daemon);

      const expectedApplication = new DartFrogApplication(
        "workingDirectory",
        8080,
        8081
      );
      expectedApplication.id = "a";
      expectedApplication.vmServiceUri = "http://127.0.0.1:8081/2xwOzt-QUmY=/";
      expectedApplication.address = "http://localhost:8080";

      const applicationPromise = new Promise((resolve) => {
        const addedListener = (application: DartFrogApplication) => {
          if (application.id === expectedApplication.id) {
            registry.off(
              DartFrogApplicationRegistryEventEmitterTypes.add,
              addedListener
            );
            resolve(application);
          }
        };
        registry.on(
          DartFrogApplicationRegistryEventEmitterTypes.add,
          addedListener
        );
      });

      simulateApplicationStart(expectedApplication, daemonEventEmitter);
      await applicationPromise;

      const actualApplication = registry.get(expectedApplication.id);

      assert.deepEqual(actualApplication, expectedApplication);
    });
  });

  suite("all", () => {
    test("returns empty array when no application is registered", () => {
      const daemon = sinon.stub();
      daemon.on = sinon.stub();
      daemon.off = sinon.stub();

      const registry = new DartFrogApplicationRegistry(daemon);

      const application = registry.all();

      assert.equal(application.length, 0);
    });

    test("returns all registered applications", async () => {
      const daemon = sinon.stub();

      const daemonEventEmitter = new EventEmitter();
      daemon.on = daemonEventEmitter.on.bind(daemonEventEmitter);
      daemon.off = daemonEventEmitter.off.bind(daemonEventEmitter);

      const registry = new DartFrogApplicationRegistry(daemon);

      const expectedApplication1 = new DartFrogApplication(
        "workingDirectory",
        8080,
        8081
      );
      expectedApplication1.id = "a";
      expectedApplication1.vmServiceUri = "http://127.0.0.1:8081/2xwOzt-QUmY=/";
      expectedApplication1.address = "http://localhost:8080";

      const expectedApplication2 = new DartFrogApplication(
        "workingDirectory2",
        8082,
        8083
      );
      expectedApplication2.id = "b";
      expectedApplication2.vmServiceUri = "http://127.0.0.1:8082/2xwOzt-QUmY=/";
      expectedApplication2.address = "http://localhost:8083";

      const application1Promise = new Promise((resolve) => {
        const addedListener = (application: DartFrogApplication) => {
          if (application.id === expectedApplication1.id) {
            registry.off(
              DartFrogApplicationRegistryEventEmitterTypes.add,
              addedListener
            );
            resolve(application);
          }
        };
        registry.on(
          DartFrogApplicationRegistryEventEmitterTypes.add,
          addedListener
        );
      });
      const application2Promise = new Promise((resolve) => {
        const addedListener = (application: DartFrogApplication) => {
          if (application.id === expectedApplication2.id) {
            registry.off(
              DartFrogApplicationRegistryEventEmitterTypes.add,
              addedListener
            );
            resolve(application);
          }
        };
        registry.on(
          DartFrogApplicationRegistryEventEmitterTypes.add,
          addedListener
        );
      });

      simulateApplicationStart(expectedApplication1, daemonEventEmitter);
      simulateApplicationStart(expectedApplication2, daemonEventEmitter);
      await Promise.all([application1Promise, application2Promise]);

      const applications = registry.all();

      assert.deepEqual(applications, [
        expectedApplication1,
        expectedApplication2,
      ]);
    });
  });

  suite("on", () => {
    test("emits add event when application is registered", async () => {
      const daemon = sinon.stub();

      const daemonEventEmitter = new EventEmitter();
      daemon.on = daemonEventEmitter.on.bind(daemonEventEmitter);
      daemon.off = daemonEventEmitter.off.bind(daemonEventEmitter);

      const registry = new DartFrogApplicationRegistry(daemon);

      const application = new DartFrogApplication(
        "workingDirectory",
        8080,
        8081
      );
      application.id = "a";
      application.vmServiceUri = "http://127.0.0.1:8081/2xwOzt-QUmY=/";
      application.address = "http://localhost:8080";

      const callback = sinon.stub();
      registry.on(DartFrogApplicationRegistryEventEmitterTypes.add, callback);

      const applicationPromise = new Promise((resolve) => {
        const addedListener = (registeredApplication: DartFrogApplication) => {
          if (registeredApplication.id === registeredApplication.id) {
            registry.off(
              DartFrogApplicationRegistryEventEmitterTypes.add,
              addedListener
            );
            resolve(registeredApplication);
          }
        };
        registry.on(
          DartFrogApplicationRegistryEventEmitterTypes.add,
          addedListener
        );
      });

      simulateApplicationStart(application, daemonEventEmitter);
      await applicationPromise;

      sinon.assert.calledOnceWithExactly(callback, application);
    });

    test("only emits add event once when application with the same id is already registered", async () => {
      const daemon = sinon.stub();

      const daemonEventEmitter = new EventEmitter();
      daemon.on = daemonEventEmitter.on.bind(daemonEventEmitter);
      daemon.off = daemonEventEmitter.off.bind(daemonEventEmitter);

      const registry = new DartFrogApplicationRegistry(daemon);

      const application = new DartFrogApplication(
        "workingDirectory",
        8080,
        8081
      );
      application.id = "a";
      application.vmServiceUri = "http://127.0.0.1:8081/2xwOzt-QUmY=/";
      application.address = "http://localhost:8080";

      const callback = sinon.stub();
      registry.on(DartFrogApplicationRegistryEventEmitterTypes.add, callback);

      const applicationPromise = new Promise((resolve) => {
        const addedListener = (registeredApplication: DartFrogApplication) => {
          if (registeredApplication.id === registeredApplication.id) {
            registry.off(
              DartFrogApplicationRegistryEventEmitterTypes.add,
              addedListener
            );
            resolve(registeredApplication);
          }
        };
        registry.on(
          DartFrogApplicationRegistryEventEmitterTypes.add,
          addedListener
        );
      });

      simulateApplicationStart(application, daemonEventEmitter);
      simulateApplicationStart(application, daemonEventEmitter);
      await applicationPromise;

      sinon.assert.calledOnceWithExactly(callback, application);
    });
  });

  suite("off", () => {
    test("doesn't emit add event when application is registered", async () => {
      const daemon = sinon.stub();

      const daemonEventEmitter = new EventEmitter();
      daemon.on = daemonEventEmitter.on.bind(daemonEventEmitter);
      daemon.off = daemonEventEmitter.off.bind(daemonEventEmitter);

      const registry = new DartFrogApplicationRegistry(daemon);

      const application = new DartFrogApplication(
        "workingDirectory",
        8080,
        8081
      );
      application.id = "a";
      application.vmServiceUri = "http://127.0.0.1:8081/2xwOzt-QUmY=/";
      application.address = "http://localhost:8080";

      const callback = sinon.stub();
      registry.on(DartFrogApplicationRegistryEventEmitterTypes.add, callback);
      registry.off(DartFrogApplicationRegistryEventEmitterTypes.add, callback);

      const applicationPromise = new Promise((resolve) => {
        const addedListener = (registeredApplication: DartFrogApplication) => {
          if (registeredApplication.id === registeredApplication.id) {
            registry.off(
              DartFrogApplicationRegistryEventEmitterTypes.add,
              addedListener
            );
            resolve(registeredApplication);
          }
        };
        registry.on(
          DartFrogApplicationRegistryEventEmitterTypes.add,
          addedListener
        );
      });

      simulateApplicationStart(application, daemonEventEmitter);
      await applicationPromise;

      sinon.assert.notCalled(callback);
    });
  });
});

let requestIdentifier = 0;

/**
 * Simulates the start of a Dart Frog application so that it can be registered.
 *
 * @param application The application that should be started. The address, VM
 * service URI and ID should already be set.
 */
function simulateApplicationStart(
  application: DartFrogApplication,
  daemonEventEmitter: EventEmitter
) {
  if (!application.id || !application.vmServiceUri || !application.address) {
    throw new Error(
      "To simulate the start of a Dart Frog application, the application must already have an ID, VM service URI and address."
    );
  }

  const requestId = `${requestIdentifier++}`;

  const startRequest = new StartDaemonRequest(
    requestId,
    application.projectPath,
    application.port,
    application.vmServicePort
  );
  daemonEventEmitter.emit(
    DartFrogDaemonEventEmitterTypes.request,
    startRequest
  );
  const applicationStartingEvent: ApplicationStartingDaemonEvent = {
    event: "dev_server.applicationStarting",
    params: {
      requestId: startRequest.id,
      applicationId: application.id,
    },
  };
  daemonEventEmitter.emit(
    DartFrogDaemonEventEmitterTypes.event,
    applicationStartingEvent
  );
  const progressCompleteEvent: ProgressCompleteDaemonEvent = {
    event: "dev_server.progressComplete",
    params: {
      requestId: startRequest.id,
      applicationId: applicationStartingEvent.params.applicationId,
      workingDirectory: startRequest.params.workingDirectory,
      progressId: requestId,
      progressMessage: formatRunningOnMessage(application.address),
    },
  };
  daemonEventEmitter.emit(
    DartFrogDaemonEventEmitterTypes.event,
    progressCompleteEvent
  );
  const loggerInfoEvent: LoggerInfoDaemonEvent = {
    event: "dev_server.loggerInfo",
    params: {
      requestId: startRequest.id,
      applicationId: applicationStartingEvent.params.applicationId,
      workingDirectory: startRequest.params.workingDirectory,
      message: formatVmServiceMessage(application.vmServiceUri),
    },
  };
  daemonEventEmitter.emit(
    DartFrogDaemonEventEmitterTypes.event,
    loggerInfoEvent
  );
}

/**
 * Formats the "running on" message to appear as the Dart Frog Daemon would
 * send it.
 *
 * @example
 * `Running on \u001b]8;;http://localhost:8080\u001b\\http://localhost:8080\u001b]8;;\u001b\\`
 * @param address The HTTP address that should be used in the message.
 * @returns The formatted message, just like the Dart Frog Daemon would send it.
 */
function formatRunningOnMessage(address: string) {
  return `Running on \u001b]8;;${address}\u001b\\${address}\u001b]8;;\u001b\\`;
}

/**
 * Formats the "vmService" message to appear as the Dart Frog Daemon would
 * send it.
 *
 * @example
 * `The Dart VM service is listening on http://127.0.0.1:8081/2xwOzt-QUmY=/`
 * @param address The HTTP address that should be used in the message.
 * @returns The formatted messag, just like the Dart Frog Daemon would send it.
 */
function formatVmServiceMessage(address: string) {
  return `The Dart VM service is listening on ${address}`;
}
