/**
 * Defines the protocol used by the Dart Frog daemon and custom
 * type guards to check if an object is a valid message.
 *
 * @see {@link https://github.com/VeryGoodOpenSource/dart_frog/blob/main/packages/dart_frog_cli/lib/src/daemon/protocol.dart Dart Frog dart's protocol}
 */

export interface DaemonMessage {}

export abstract class DaemonRequest implements DaemonMessage {
  abstract method: string;
  abstract id: string;
  abstract params: any;
}

export function isDeamonRequest(object: any): object is DaemonRequest {
  return typeof object.id === "string" && typeof object.method === "string";
}

export interface DeamonResponse extends DaemonMessage {
  id: string;
  result: any;
  error: any;
}

export function isDeamonResponse(object: any): object is DeamonResponse {
  return typeof object.id === "string" && !("method" in object);
}

export interface DeamonEvent extends DaemonMessage {
  event: string;
  params: any;
}

export function isDeamonEvent(object: any): object is DeamonEvent {
  return typeof object.event === "string";
}
