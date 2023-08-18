import {
  DaemonEvent,
  DaemonRequest,
  DartFrogApplication,
  DartFrogDaemon as DartFrogDaemon,
  DartFrogDaemonEventEmitterTypes,
  isApplicationExitDaemonEvent,
  isApplicationStartingDaemonEvent,
  isLoggerInfoDaemonEvent,
  isProgressCompleteDaemonEvent,
  isStartDaemonRequest,
} from ".";
import { EventEmitter } from "events";

/**
 * The prefix of the message that is sent by the Dart Frog Daemon when the Dart
 * VM service is listening.
 *
 * @example
 * "The Dart VM service is listening on http://127.0.0.1:8181/fQBcSu3OOc8=/"
 */
const vmServiceUriMessagePrefix = "The Dart VM service is listening on ";

/**
 * The prefix of the message that is sent by the Dart Frog Daemon when the
 * application is starting.
 *
 * @example
 * "Running on \u001b]8;;http://localhost:8080\u001b\\http://localhost:8080\u001b]8;;\u001b\\"
 */
const applicationStartingMessagePrefix = "Running on ";

/**
 * The regular expression that is used to extract an address from a message.
 *
 * @example
 * "Running on \u001b]8;;http://localhost:8080\u001b\\http://localhost:8080\u001b]8;;\u001b\\" -> "http://localhost:8080"
 */
const addressRegex = /http(s?):\/\/[^\u001b\\]+/;

/**
 * The types of events that are emitted by the
 * {@link DartFrogApplicationRegistry}.
 *
 * The possible types of events are:
 * - "add": When a new {@link DartFrogApplication} is added to the registry.
 * The {@link DartFrogApplication} is passed as an argument to the event
 * handler.
 * - "remove": When a {@link DartFrogApplication} is removed from the registry.
 * The {@link DartFrogApplication} is passed as an argument to the event
 * handler.
 */
export enum DartFrogApplicationRegistryEventEmitterTypes {
  add = "add",
  remove = "remove",
}

/**
 * The Dart Frog applications that are currently running and managed by a Dart
 * Frog daemon.
 */
export class DartFrogApplicationRegistry {
  constructor(dartFrogDaemon: DartFrogDaemon) {
    this.dartFrogDaemon = dartFrogDaemon;

    this.dartFrogDaemon.on(
      DartFrogDaemonEventEmitterTypes.request,
      this.startRequestListener.bind(this)
    );
    this.dartFrogDaemon.on(
      DartFrogDaemonEventEmitterTypes.event,
      this.applicationExitEventListener.bind(this)
    );
  }

  private readonly dartFrogDaemon: DartFrogDaemon;

  private readonly runningApplications: Map<String, DartFrogApplication> =
    new Map<String, DartFrogApplication>();

  private readonly runningApplicationsEventEmitter = new EventEmitter();

  /**
   * Retrieves all the Dart Frog applications that are currently
   * registered with this Dart Frog daemon.
   */
  public all(): DartFrogApplication[] {
    const interator = this.runningApplications.values();
    return Array.from(interator);
  }

  /**
   * Retrieves the Dart Frog application that is currently registered with this
   * Dart Frog daemon and has the given identifier.
   *
   * @param id The application identifier assigned by the Dart Frog daemon.
   * @returns The Dart Frog application that is currently registered with this
   * Dart Frog daemon and has the given identifier, or undefined if no such
   * application exists.
   */
  public get(id: string): DartFrogApplication | undefined {
    return this.runningApplications.get(id);
  }

  /**
   * Starts listening to events related to this application registry
   *
   * @returns A reference to this Dart Frog daemon, so that calls can be
   * chained.
   * @see {@link DartFrogDaemonEventEmitterTypes} for the types of events that
   * are emitted.
   */
  public on(
    type: DartFrogApplicationRegistryEventEmitterTypes,
    listener: (...args: any[]) => void
  ): DartFrogApplicationRegistry {
    this.runningApplicationsEventEmitter.on(type, listener);
    return this;
  }

  /**
   * Unsubscribes a listener from events related to this application registry.
   *
   * @param type The type of event to unsubscribe from.
   * @param listener The listener to unsubscribe.
   * @returns A reference to this Dart Frog daemon application registry,
   * so that calls can be chained.
   */
  public off(
    type: DartFrogApplicationRegistryEventEmitterTypes,
    listener: (...args: any[]) => void
  ): DartFrogApplicationRegistry {
    this.runningApplicationsEventEmitter.off(type, listener);
    return this;
  }

  private async startRequestListener(request: DaemonRequest): Promise<void> {
    if (!isStartDaemonRequest(request)) {
      return;
    }

    const application = new DartFrogApplication(
      request.params.workingDirectory,
      request.params.port,
      request.params.dartVmServicePort
    );

    const applicationId = this.retrieveApplicationId(request.id).then(
      (applicationId) => {
        application.id = applicationId;
      }
    );
    const vmServiceUri = this.retrieveVmServiceUri(request.id).then(
      (vmServiceUri) => {
        application.vmServiceUri = vmServiceUri;
      }
    );
    const address = this.retrieveAddress(request.id).then((address) => {
      application.address = address;
    });

    await Promise.all([applicationId, vmServiceUri, address]);

    this.register(application);
  }

  private async retrieveApplicationId(requestId: string): Promise<string> {
    return new Promise<string>((resolve) => {
      const applicationIdEventListener = (message: DaemonEvent) => {
        if (!isApplicationStartingDaemonEvent(message)) {
          return;
        } else if (message.params.requestId !== requestId) {
          return;
        }

        this.dartFrogDaemon.off(
          DartFrogDaemonEventEmitterTypes.event,
          applicationIdEventListener
        );
        resolve(message.params.applicationId);
      };

      this.dartFrogDaemon.on(
        DartFrogDaemonEventEmitterTypes.event,
        applicationIdEventListener.bind(this)
      );
    });
  }

  private async retrieveVmServiceUri(requestId: string): Promise<string> {
    return new Promise<string>((resolve) => {
      const vmServiceUriEventListener = (event: DaemonEvent) => {
        if (!isLoggerInfoDaemonEvent(event)) {
          return;
        } else if (event.params.requestId !== requestId) {
          return;
        }

        const message = event.params.message;
        if (!message.startsWith(vmServiceUriMessagePrefix)) {
          return;
        }

        const vmServiceUri = message.match(addressRegex)![0];

        this.dartFrogDaemon.off(
          DartFrogDaemonEventEmitterTypes.event,
          vmServiceUriEventListener
        );
        resolve(vmServiceUri);
      };

      this.dartFrogDaemon.on(
        DartFrogDaemonEventEmitterTypes.event,
        vmServiceUriEventListener.bind(this)
      );
    });
  }

  private async retrieveAddress(requestId: string): Promise<string> {
    return new Promise<string>((resolve) => {
      const addressEventListener = (message: DaemonEvent) => {
        if (!isProgressCompleteDaemonEvent(message)) {
          return;
        } else if (message.params.requestId !== requestId) {
          return;
        }

        const progressMessage = message.params.progressMessage;
        if (!progressMessage.startsWith(applicationStartingMessagePrefix)) {
          return;
        }

        const address = progressMessage.match(addressRegex)![0];
        this.dartFrogDaemon.off(
          DartFrogDaemonEventEmitterTypes.event,
          addressEventListener
        );
        resolve(address);
      };

      this.dartFrogDaemon.on(
        DartFrogDaemonEventEmitterTypes.event,
        addressEventListener.bind(this)
      );
    });
  }

  private applicationExitEventListener(event: DaemonEvent): void {
    if (!isApplicationExitDaemonEvent(event)) {
      return;
    }

    const application = this.get(event.params.applicationId);
    if (application) {
      this.deregister(application);
    }
  }

  private register(application: DartFrogApplication): void {
    if (!application.id) {
      return;
    } else if (this.runningApplications.has(application.id)) {
      return;
    }

    this.runningApplications.set(application.id, application);
    this.runningApplicationsEventEmitter.emit(
      DartFrogApplicationRegistryEventEmitterTypes.add,
      application
    );
  }

  private deregister(application: DartFrogApplication): void {
    if (!application.id) {
      return;
    } else if (!this.runningApplications.has(application.id)) {
      return;
    }

    this.runningApplications.delete(application.id);
    this.runningApplicationsEventEmitter.emit(
      DartFrogApplicationRegistryEventEmitterTypes.remove,
      application
    );
  }
}
