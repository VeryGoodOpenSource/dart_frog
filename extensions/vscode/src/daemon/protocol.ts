/**
 * Defines the protocol used by the Dart Frog daemon and custom
 * type guards to check if an object is a valid message.
 *
 * @see {@link https://github.com/VeryGoodOpenSource/dart_frog/blob/main/packages/dart_frog_cli/lib/src/daemon/protocol.dart Dart Frog dart's protocol}
 */

export class DaemonMessage {
  /**
   * Decodes messages, that follow the protocol, sent over stdout from
   * the Dart Frog daemon.
   *
   * @param data The data to decode (from stdout of the Dart Frog daemon).
   * @returns The decoded messages received from the Dart Frog daemon.
   */
  public static decode(data: Buffer): DaemonMessage[] {
    const stringData = data.toString();
    const messages = stringData.split("\n").filter((s) => s.trim().length > 0);
    const parsedMessages = messages.map((message) => JSON.parse(message));

    let deamonMessages: DaemonMessage[] = [];
    for (const parsedMessage of parsedMessages) {
      for (const message of parsedMessage) {
        deamonMessages.push(message as DaemonMessage);
      }
    }

    return deamonMessages;
  }
}

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
