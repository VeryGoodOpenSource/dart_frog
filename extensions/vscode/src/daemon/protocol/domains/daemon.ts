/**
 * Defines the protocol used by the Dart Frog daemon "deamon" domain and custom
 * type guards to check if an object is a valid message.
 *
 * @see {@link https://dartfrog.vgv.dev/docs/advanced/daemon#daemon-domain Dart Frog daemon domain}
 */

import {
  DaemonRequest,
  DaemonEvent,
  isDaemonEvent,
  isDaemonRequest,
} from "../protocol";

const domainName = "daemon";

export enum DaemonMessageName {
  requestVersion = `${domainName}.requestVersion`,
  kill = `${domainName}.kill`,
  ready = `${domainName}.ready`,
}

export class RequestVersionDaemonRequest extends DaemonRequest {
  constructor(id: string) {
    super();
    this.id = id;
  }

  public readonly method: string = DaemonMessageName.requestVersion;
  public readonly id: string;
  public readonly params: undefined = undefined;
}

export function isRequestVersionDaemonRequest(
  object: any
): object is DaemonRequest {
  return (
    isDaemonRequest(object) &&
    typeof object.id === "string" &&
    typeof object.method === DaemonMessageName.requestVersion.toString()
  );
}

export class KillDaemonRequest extends DaemonRequest {
  constructor(id: string) {
    super();
    this.id = id;
  }

  public readonly method: string = DaemonMessageName.kill;
  public readonly id: string;
  public readonly params: any = undefined;
}

export function isKillDaemonRequest(object: any): object is DaemonRequest {
  return (
    isDaemonRequest(object) &&
    typeof object.id === "string" &&
    typeof object.method === DaemonMessageName.kill.toString()
  );
}

export interface ReadyDaemonEvent extends DaemonEvent {
  event: DaemonMessageName.ready;
  params: {
    version: string;
    processId: number;
  };
}

export function isReadyDaemonEvent(object: any): object is DaemonEvent {
  return (
    isDaemonEvent(object) &&
    object.event === DaemonMessageName.ready &&
    typeof object.params.version === "string" &&
    typeof object.params.processId === "number"
  );
}
