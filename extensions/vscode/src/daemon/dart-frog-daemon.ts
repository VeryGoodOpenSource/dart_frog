import { ChildProcessWithoutNullStreams, spawn } from "child_process";
import {
  DaemonEvent,
  DaemonMessage,
  isDaemonEvent,
  isDaemonRequest,
  isDaemonResponse,
  isReadyDaemonEvent,
} from "./protocol";
import { EventEmitter } from "events";

/**
 * The types of events that are emitted by the {@link DartFrogDaemon}.
 *
 * The possible types of events are:
 * - "request": When a request is sent to the Dart Frog Daemon. The
 * {@link DaemonRequest} is passed as an argument to the event handler.
 * - "response": When a response is received from the Dart Frog Daemon. The
 * {@link DeamonResponse} is passed as an argument to the event handler.
 * - "event": When an event is received from the Dart Frog Daemon. The
 * {@link DaemonEvent} is passed as an argument to the event handler.
 */
export enum DartFrogDaemonEventEmitterTypes {
  request = "request",
  response = "response",
  event = "event",
}

/**
 * The Dart Frog daemon is a long-running process that is responsible for
 * managing a single or multiple Dart Frog projects simultaneously.
 *
 * @see {@link https://dartfrog.vgv.dev/docs/advanced/daemon Dart Frog daemon documentation }
 */
export class DartFrogDaemon {
  private static _instance: DartFrogDaemon;

  /**
   * A singleton instance of the Dart Frog daemon.
   *
   * A Dart Frog daemon can manage multiple Dart Frog projects simultaneously.
   */
  public static get instance() {
    return this._instance || (this._instance = new this());
  }

  private _deamonMessagesEventEmitter = new EventEmitter();

  /**
   * The process that is running the Dart Frog Daemon.
   *
   * Undefined until the Dart Frog Daemon is {@link invoke}d.
   */
  private process: ChildProcessWithoutNullStreams | undefined;

  private _isReady: boolean = false;

  /**
   * Whether the Dart Frog Daemon is ready to accept requests.
   *
   * The Dart Frog Daemon is ready to accept requests when it has emmitted
   * the "ready" event after being {@link invoke}d.
   *
   * @see {@link invoke} to invoke the Dart Frog Daemon.
   */
  public get isReady(): boolean {
    return this._isReady;
  }

  /**
   * Invokes the Dart Frog Daemon.
   *
   * If the Dart Frog Daemon is already running, this method will immediately
   * return.
   *
   * After invoking the Dart Frog Daemon, it will be ready to accept requests.
   *
   * @param workingDirectory The working directory of the Dart Frog Daemon,
   * usually the root directory of the Dart Frog project.
   */
  public async invoke(workingDirectory: string): Promise<void> {
    if (this.isReady) {
      return Promise.resolve();
    }

    let resolveReadyPromise: () => void;
    const readyPromise = new Promise<void>((resolve) => {
      resolveReadyPromise = resolve;
    });

    const readyEventListener = (message: DaemonEvent) => {
      if (!this._isReady && isReadyDaemonEvent(message)) {
        this._isReady = true;
        resolveReadyPromise();
        this.off(DartFrogDaemonEventEmitterTypes.event, readyEventListener);
      }
    };
    this.on(
      DartFrogDaemonEventEmitterTypes.event,
      readyEventListener.bind(this)
    );

    this.process = spawn("dart_frog", ["daemon"], {
      cwd: workingDirectory,
    });
    this.process.stdout.on("data", this.stdoutDataListener.bind(this));

    return readyPromise;
  }

  /**
   * Decodes the stdout and emits events accordingly via the
   * {@link deamonMessagesEventEmitter}.
   *
   * @param data The data that was received from the stdout of the Dart Frog
   * Daemon.
   * @see {@link deamonMessagesEventEmitter} for listening to the events that
   * are emitted.
   */
  private stdoutDataListener(data: Buffer): void {
    const deamonMessages = DaemonMessage.decode(data);
    for (const message of deamonMessages) {
      if (isDaemonEvent(message)) {
        this._deamonMessagesEventEmitter.emit(
          DartFrogDaemonEventEmitterTypes.event,
          message
        );
      } else if (isDaemonResponse(message)) {
        this._deamonMessagesEventEmitter.emit(
          DartFrogDaemonEventEmitterTypes.response,
          message
        );
      } else if (isDaemonRequest(message)) {
        this._deamonMessagesEventEmitter.emit(
          DartFrogDaemonEventEmitterTypes.request,
          message
        );
      }
    }
  }

  /**
   * Starts listening to events related to this Dart Frog Daemon.
   *
   * @returns A reference to this Dart Frog Daemon, so that calls can be
   * chained.
   * @see {@link DartFrogDaemonEventEmitterTypes} for the types of events that
   * are emitted.
   */
  public on(
    type: DartFrogDaemonEventEmitterTypes,
    listener: (...args: any[]) => void
  ): DartFrogDaemon {
    this._deamonMessagesEventEmitter.on(type, listener);
    return this;
  }

  /**
   * Unsubscribes a listener from events related to this Dart Frog Daemon.
   *
   * @param type The type of event to unsubscribe from.
   * @param listener The listener to unsubscribe.
   * @returns A reference to this Dart Frog Daemon, so that calls can be
   * chained.
   */
  public off(
    type: DartFrogDaemonEventEmitterTypes,
    listener: (...args: any[]) => void
  ): DartFrogDaemon {
    this._deamonMessagesEventEmitter.off(type, listener);
    return this;
  }
}
