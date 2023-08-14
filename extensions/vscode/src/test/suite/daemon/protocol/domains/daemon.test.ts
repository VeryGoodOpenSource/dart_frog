import * as assert from "assert";
import {
  DaemonMessage,
  KillDaemonRequest,
  RequestVersionDaemonRequest,
  isKillDaemonRequest,
  isReadyDaemonEvent,
  isRequestVersionDaemonRequest,
} from "../../../../../daemon";

suite("RequestVersionDaemonRequest", () => {
  test("is a valid requestVersion request", () => {
    const request = new RequestVersionDaemonRequest("1");

    assert.equal(request.id, "1");
    assert.equal(request.method, "daemon.requestVersion");
    assert.equal(request.params, undefined);
  });
});

suite("isRequestVersionDaemonRequest", () => {
  test("returns true when it is a RequestVersionDaemonRequest", () => {
    const request = Buffer.from(
      `[{"method": "daemon.requestVersion", "id": "1"}]\n`,
      "utf8"
    );
    const requestObject = DaemonMessage.decode(request)[0];
    assert.equal(isRequestVersionDaemonRequest(requestObject), true);
  });

  test("returns false when it is not a RequestVersionDaemonRequest", () => {
    const request = Buffer.from(
      `[{"method": "daemon.notARequestVersion", "id": "1"}]\n`,
      "utf8"
    );
    const requestObject = DaemonMessage.decode(request)[0];
    assert.equal(isRequestVersionDaemonRequest(requestObject), false);
  });
});

suite("KillDaemonRequest", () => {
  test("is a valid kill request", () => {
    const request = new KillDaemonRequest("1");

    assert.equal(request.id, "1");
    assert.equal(request.method, "daemon.kill");
    assert.equal(request.params, undefined);
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

  test("returns false when it is not a KillDaemonRequest", () => {
    const request = Buffer.from(
      `[{"method": "daemon.notAKill", "id": "1"}]\n`,
      "utf8"
    );
    const requestObject = DaemonMessage.decode(request)[0];
    assert.equal(isKillDaemonRequest(requestObject), false);
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

  test("returns false when it is not a KillDaemonRequest", () => {
    const event = Buffer.from(
      `[{"event":"daemon.notAReady","params":{"version":"0.0.1","processId":8623}}]\n`,
      "utf8"
    );
    const eventObject = DaemonMessage.decode(event)[0];
    assert.equal(isReadyDaemonEvent(eventObject), false);
  });
});
