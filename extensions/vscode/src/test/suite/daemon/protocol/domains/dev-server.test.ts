import * as assert from "assert";
import {
  DaemonMessage,
  ReloadDaemonRequest,
  StartDaemonRequest,
  StopDaemonRequest,
  isApplicationExitDaemonEvent,
  isApplicationStartingDaemonEvent,
  isLoggerDetailDaemonEvent,
  isLoggerInfoDaemonEvent,
  isProgressCompleteDaemonEvent,
  isProgressStartDaemonEvent,
  isReloadDaemonRequest,
  isStartDaemonRequest,
  isStopDaemonRequest,
} from "../../../../../daemon";

suite("StartDaemonRequest", () => {
  test("is a valid start request", () => {
    const request = new StartDaemonRequest("1", "workingDirectory", 8080, 8081);

    assert.equal(request.id, "1");
    assert.equal(request.method, "dev_server.start");
    assert.equal(request.params.workingDirectory, "workingDirectory");
    assert.equal(request.params.port, 8080);
  });
});

suite("isStartDaemonRequest", () => {
  test("returns true when it is a StartDaemonRequest", () => {
    const request = Buffer.from(
      `[{"method": "dev_server.start", "id": "1", "params": {"workingDirectory": "workingDirectory", "port": 8080, "dartVmServicePort": 8081}}]\n`,
      "utf8"
    );
    const requestObject = DaemonMessage.decode(request)[0];
    assert.equal(isStartDaemonRequest(requestObject), true);
  });

  test("returns false when it is not a StartDaemonRequest", () => {
    const request = Buffer.from(
      `[{"method": "dev_server.notAStart", "id": "1"}]\n`,
      "utf8"
    );
    const requestObject = DaemonMessage.decode(request)[0];
    assert.equal(isStartDaemonRequest(requestObject), false);
  });
});

suite("ReloadDaemonRequest", () => {
  test("is a valid reload request", () => {
    const request = new ReloadDaemonRequest("1", "applicationId");

    assert.equal(request.id, "1");
    assert.equal(request.method, "dev_server.reload");
    assert.equal(request.params.applicationId, "applicationId");
  });
});

suite("isReloadDaemonRequest", () => {
  test("returns true when it is a ReloadDaemonRequest", () => {
    const request = Buffer.from(
      `[{"method": "dev_server.reload", "id": "1", "params": {"applicationId": "applicationId"}}]\n`,
      "utf8"
    );
    const requestObject = DaemonMessage.decode(request)[0];
    assert.equal(isReloadDaemonRequest(requestObject), true);
  });

  test("returns false when it is not a ReloadDaemonRequest", () => {
    const request = Buffer.from(
      `[{"method": "dev_server.notAReload", "id": "1"}]\n`,
      "utf8"
    );
    const requestObject = DaemonMessage.decode(request)[0];
    assert.equal(isReloadDaemonRequest(requestObject), false);
  });
});

suite("StopDaemonRequest", () => {
  test("is a valid stop request", () => {
    const request = new StopDaemonRequest("1", "applicationId");

    assert.equal(request.id, "1");
    assert.equal(request.method, "dev_server.stop");
    assert.equal(request.params.applicationId, "applicationId");
  });
});

suite("isStopDaemonRequest", () => {
  test("returns true when it is a StopDaemonRequest", () => {
    const request = Buffer.from(
      `[{"method": "dev_server.stop", "id": "1", "params": {"applicationId": "applicationId"}}]\n`,
      "utf8"
    );
    const requestObject = DaemonMessage.decode(request)[0];
    assert.equal(isStopDaemonRequest(requestObject), true);
  });

  test("returns false when it is not a StopDaemonRequest", () => {
    const request = Buffer.from(
      `[{"method": "dev_server.notAStop", "id": "1"}]\n`,
      "utf8"
    );
    const requestObject = DaemonMessage.decode(request)[0];
    assert.equal(isStopDaemonRequest(requestObject), false);
  });
});

suite("isApplicationStartingDaemonEvent", () => {
  test("returns true when it is an ApplicationStartingDaemonEvent", () => {
    const event = Buffer.from(
      `[{"event": "dev_server.applicationStarting", "params": {"applicationId": "applicationId", "requestId": "requestId"}}]\n`,
      "utf8"
    );
    const eventObject = DaemonMessage.decode(event)[0];
    assert.equal(isApplicationStartingDaemonEvent(eventObject), true);
  });

  test("returns false when it is not an ApplicationStartingDaemonEvent", () => {
    const event = Buffer.from(
      `[{"event": "dev_server.notAnApplicationStarting", "params": {}}]\n`,
      "utf8"
    );
    const eventObject = DaemonMessage.decode(event)[0];
    assert.equal(isApplicationStartingDaemonEvent(eventObject), false);
  });
});

suite("isApplicationExitDaemonEvent", () => {
  test("returns true when it is an ApplicationExitDaemonEvent", () => {
    const event = Buffer.from(
      `[{"event": "dev_server.applicationExit", "params": {"applicationId": "applicationId", "requestId": "requestId", "exitCode": 0}}]\n`,
      "utf8"
    );
    const eventObject = DaemonMessage.decode(event)[0];
    assert.equal(isApplicationExitDaemonEvent(eventObject), true);
  });

  test("returns false when it is not an ApplicationExitDaemonEvent", () => {
    const event = Buffer.from(
      `[{"event": "dev_server.notAnApplicationExit", "params": {}}]\n`,
      "utf8"
    );
    const eventObject = DaemonMessage.decode(event)[0];
    assert.equal(isApplicationExitDaemonEvent(eventObject), false);
  });
});

suite("isLoggerInfoDaemonEvent", () => {
  test("returns true when it is a LoggerInfoDaemonEvent", () => {
    const event = Buffer.from(
      `[{"event": "dev_server.loggerInfo", "params": {"applicationId": "applicationId", "requestId": "requestId", "workingDirectory": "workingDirectory", "message": "message"}}]\n`,
      "utf8"
    );
    const eventObject = DaemonMessage.decode(event)[0];
    assert.equal(isLoggerInfoDaemonEvent(eventObject), true);
  });

  test("returns false when it is not a LoggerInfoDaemonEvent", () => {
    const event = Buffer.from(
      `[{"event": "dev_server.notALoggerInfo", "params": {}}]\n`,
      "utf8"
    );
    const eventObject = DaemonMessage.decode(event)[0];
    assert.equal(isLoggerInfoDaemonEvent(eventObject), false);
  });
});

suite("isLoggerDetailDaemonEvent", () => {
  test("returns true when it is a LoggerDetailDaemonEvent", () => {
    const event = Buffer.from(
      `[{"event": "dev_server.loggerDetail", "params": {"applicationId": "applicationId", "requestId": "requestId", "workingDirectory": "workingDirectory", "message": "message"}}]\n`,
      "utf8"
    );
    const eventObject = DaemonMessage.decode(event)[0];
    assert.equal(isLoggerDetailDaemonEvent(eventObject), true);
  });

  test("returns false when it is not a LoggerDetailDaemonEvent", () => {
    const event = Buffer.from(
      `[{"event": "dev_server.notALoggerDetail", "params": {}}]\n`,
      "utf8"
    );
    const eventObject = DaemonMessage.decode(event)[0];
    assert.equal(isLoggerDetailDaemonEvent(eventObject), false);
  });
});

suite("isProgressStartDaemonEvent", () => {
  test("returns true when it is a ProgressStartDaemonEvent", () => {
    const event = Buffer.from(
      `[{"event": "dev_server.progressStart", "params": {"applicationId": "applicationId", "progressId": "progressId", "progressMessage": "progressMessage", "requestId": "requestId", "workingDirectory": "workingDirectory"}}]\n`,
      "utf8"
    );
    const eventObject = DaemonMessage.decode(event)[0];
    assert.equal(isProgressStartDaemonEvent(eventObject), true);
  });

  test("returns false when it is not a ProgressStartDaemonEvent", () => {
    const event = Buffer.from(
      `[{"event": "dev_server.notAProgressStart", "params": {}}]\n`,
      "utf8"
    );
    const eventObject = DaemonMessage.decode(event)[0];
    assert.equal(isProgressStartDaemonEvent(eventObject), false);
  });
});

suite("isProgressCompleteDaemonEvent", () => {
  test("returns true when it is a ProgressCompleteDaemonEvent", () => {
    const event = Buffer.from(
      `[{"event": "dev_server.progressComplete", "params": {"applicationId": "applicationId", "progressId": "progressId", "requestId": "requestId", "workingDirectory": "workingDirectory", "progressMessage": "progressMessage"}}]\n`,
      "utf8"
    );
    const eventObject = DaemonMessage.decode(event)[0];
    assert.equal(isProgressCompleteDaemonEvent(eventObject), true);
  });

  test("returns false when it is not a ProgressCompleteDaemonEvent", () => {
    const event = Buffer.from(
      `[{"event": "dev_server.notAProgressComplete", "params": {}}]\n`,
      "utf8"
    );
    const eventObject = DaemonMessage.decode(event)[0];
    assert.equal(isProgressCompleteDaemonEvent(eventObject), false);
  });
});
