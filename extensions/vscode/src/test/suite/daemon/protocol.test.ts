import * as assert from "assert";
import {
  DaemonMessage,
  isDeamonEvent,
  isDeamonRequest,
  isDeamonResponse,
} from "../../../daemon";

suite("DaemonMessage", () => {
  suite("decode", () => {
    test("returns an empty array when data is empty", () => {
      const data = Buffer.from("");

      assert.deepEqual(DaemonMessage.decode(data), []);
    });

    test("decodes request", () => {
      const request = `[{"method": "daemon.requestVersion", "id": "12"}]`;
      const data = Buffer.from(request);

      const requestObject = {
        method: "daemon.requestVersion",
        id: "12",
      };
      assert.deepEqual(DaemonMessage.decode(data), [requestObject]);
    });

    test("decodes event", () => {
      const event = `[{"event":"daemon.ready","params":{"version":"0.0.1","processId":75941}}]`;
      const data = Buffer.from(event);

      const eventObject = {
        event: "daemon.ready",
        params: {
          version: "0.0.1",
          processId: 75941,
        },
      };
      assert.deepEqual(DaemonMessage.decode(data), [eventObject]);
    });

    test("decodes response", () => {
      const response = `[{"id":"12","result":{"version":"0.0.1"}}]`;
      const data = Buffer.from(response);

      const responseObject = {
        id: "12",
        result: {
          version: "0.0.1",
        },
      };
      assert.deepEqual(DaemonMessage.decode(data), [responseObject]);
    });

    test("decodes multiple batched messages", () => {
      const request = `{"method": "daemon.requestVersion", "id": "12"}`;
      const event = `{"event":"daemon.ready","params":{"version":"0.0.1","processId":75941}}`;
      const response = `{"id":"12","result":{"version":"0.0.1"}}`;
      const data = Buffer.from(`[${request},${event},${response}]`);

      const requestObject = {
        method: "daemon.requestVersion",
        id: "12",
      };
      const eventObject = {
        event: "daemon.ready",
        params: {
          version: "0.0.1",
          processId: 75941,
        },
      };
      const responseObject = {
        id: "12",
        result: {
          version: "0.0.1",
        },
      };
      assert.deepEqual(DaemonMessage.decode(data), [
        requestObject,
        eventObject,
        responseObject,
      ]);
    });

    test("decodes multiple buffered messages", () => {
      const request = `[{"method": "daemon.requestVersion", "id": "12"}]`;
      const event = `[{"event":"daemon.ready","params":{"version":"0.0.1","processId":75941}}]`;
      const response = `[{"id":"12","result":{"version":"0.0.1"}}]`;
      const data = Buffer.from(`${request}\n${event}\n${response}`);

      const requestObject = {
        method: "daemon.requestVersion",
        id: "12",
      };
      const eventObject = {
        event: "daemon.ready",
        params: {
          version: "0.0.1",
          processId: 75941,
        },
      };
      const responseObject = {
        id: "12",
        result: {
          version: "0.0.1",
        },
      };
      assert.deepEqual(DaemonMessage.decode(data), [
        requestObject,
        eventObject,
        responseObject,
      ]);
    });
  });
});

suite("isDeamonRequest", () => {
  suite("returns true when object is a valid DeamonRequest", () => {
    test("with all fields", () => {
      const request = {
        id: "1",
        method: "method",
        params: {},
      };

      assert.equal(isDeamonRequest(request), true);
    });

    test("when missing params only", () => {
      const request = {
        id: "1",
        method: "method",
      };

      assert.equal(isDeamonRequest(request), true);
    });
  });

  suite("returns false", () => {
    test("when missing id only", () => {
      const request = {
        method: "method",
        params: {},
      };

      assert.equal(isDeamonRequest(request), false);
    });

    test("when missing method only", () => {
      const request = {
        id: "1",
        params: {},
      };

      assert.equal(isDeamonRequest(request), false);
    });

    test("when object is a valid DeamonResponse", () => {
      const response = {
        id: "1",
        result: {},
        error: {},
      };

      assert.equal(isDeamonResponse(response), true);
      assert.equal(isDeamonRequest(response), false);
    });

    test("when object is a valid DeamonEvent", () => {
      const event = {
        event: "event",
        params: {},
      };

      assert.equal(isDeamonEvent(event), true);
      assert.equal(isDeamonRequest(event), false);
    });
  });
});

suite("isDeamonResponse", () => {
  suite("returns true when object is a valid DeamonResponse", () => {
    test("with all fields", () => {
      const response = {
        id: "1",
        result: {},
        error: {},
      };

      assert.equal(isDeamonResponse(response), true);
    });

    test("when missing error only", () => {
      const response = {
        id: "1",
        result: {},
      };

      assert.equal(isDeamonResponse(response), true);
    });

    test("when missing result only", () => {
      const response = {
        id: "1",
        error: {},
      };

      assert.equal(isDeamonResponse(response), true);
    });

    test("when missing result and errror only", () => {
      const response = {
        id: "1",
      };

      assert.equal(isDeamonResponse(response), true);
    });
  });

  suite("returns false", () => {
    test("when missing id only", () => {
      const response = {
        result: {},
        error: {},
      };

      assert.equal(isDeamonResponse(response), false);
    });

    test("when object is a valid DeamonRequest", () => {
      const request = {
        id: "1",
        method: "method",
        params: {},
      };

      assert.equal(isDeamonRequest(request), true);
      assert.equal(isDeamonResponse(request), false);
    });

    test("when object is a valid DeamonEvent", () => {
      const event = {
        event: "event",
        params: {},
      };

      assert.equal(isDeamonEvent(event), true);
      assert.equal(isDeamonResponse(event), false);
    });
  });
});

suite("isDeamonEvent", () => {
  suite("returns true when object is a valid DeamonEvent", () => {
    test("with all fields", () => {
      const event = {
        event: "event",
        params: {},
      };

      assert.equal(isDeamonEvent(event), true);
    });

    test("when missing params only", () => {
      const event = {
        event: "event",
      };

      assert.equal(isDeamonEvent(event), true);
    });
  });

  suite("returns false", () => {
    test("when missing event only", () => {
      const event = {
        params: {},
      };

      assert.equal(isDeamonEvent(event), false);
    });

    test("when object is a valid DeamonRequest", () => {
      const request = {
        id: "1",
        method: "method",
        params: {},
      };

      assert.equal(isDeamonRequest(request), true);
      assert.equal(isDeamonEvent(request), false);
    });

    test("when object is a valid DeamonResponse", () => {
      const response = {
        id: "1",
        result: {},
        error: {},
      };

      assert.equal(isDeamonResponse(response), true);
      assert.equal(isDeamonEvent(response), false);
    });
  });
});
