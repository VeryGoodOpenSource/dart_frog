import * as assert from "assert";
import {
  DaemonMessage,
  isKillDaemonRequest,
  isReadyDaemonEvent,
  isRequestVersionDaemonRequest,
} from "../../../../../daemon";

suite("isRequestVersionDaemonRequest", () => {
  test("returns true when it is a RequestVersionDaemonRequest", () => {
    const request = Buffer.from(
      `[{"method": "daemon.requestVersion", "id": "1"}]\n`,
      "utf8"
    );
    const requestObject = DaemonMessage.decode(request)[0];
    assert.equal(isRequestVersionDaemonRequest(requestObject), true);
  });
});

suite("isKillDaemonRequest", () => {
  test("returns true when it is a KillDaemonRequest", () => {
    const request = Buffer.from(
      `[{"method": "daemon.kill", "id": "1"}]\n`,
      "utf8"
    );
    const requestObject = DaemonMessage.decode(request)[0];
    assert.equal(isKillDaemonRequest(requestObject), true);
  });
});

suite("isReadyDaemonEvent", () => {
  test("returns true when it is a KillDaemonRequest", () => {
    const event = Buffer.from(
      `[{"event":"daemon.ready","params":{"version":"0.0.1","processId":8623}}]\n`,
      "utf8"
    );
    const eventObject = DaemonMessage.decode(event)[0];
    assert.equal(isReadyDaemonEvent(eventObject), true);
  });
});
