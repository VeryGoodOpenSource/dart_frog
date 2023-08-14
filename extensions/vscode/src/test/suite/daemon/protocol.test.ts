import * as assert from "assert";
import {
  DaemonMessage,
  isDaemonEvent,
  isDaemonRequest,
  isDaemonResponse,
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

suite("isDaemonRequest", () => {
  suite("returns true when object is a valid DaemonRequest", () => {
    test("with all fields", () => {
      const request = {
        id: "1",
        method: "method",
        params: {},
      };

      assert.equal(isDaemonRequest(request), true);
    });

    test("when missing params only", () => {
      const request = {
        id: "1",
        method: "method",
      };

      assert.equal(isDaemonRequest(request), true);
    });
  });

  suite("returns false", () => {
    test("when missing id only", () => {
      const request = {
        method: "method",
        params: {},
      };

      assert.equal(isDaemonRequest(request), false);
    });

    test("when missing method only", () => {
      const request = {
        id: "1",
        params: {},
      };

      assert.equal(isDaemonRequest(request), false);
    });

    test("when object is a valid DaemonResponse", () => {
      const response = {
        id: "1",
        result: {},
        error: {},
      };

      assert.equal(isDaemonResponse(response), true);
      assert.equal(isDaemonRequest(response), false);
    });

    test("when object is a valid DaemonEvent", () => {
      const event = {
        event: "event",
        params: {},
      };

      assert.equal(isDaemonEvent(event), true);
      assert.equal(isDaemonRequest(event), false);
    });
  });
});

suite("isDaemonResponse", () => {
  suite("returns true when object is a valid DaemonResponse", () => {
    test("with all fields", () => {
      const response = {
        id: "1",
        result: {},
        error: {},
      };

      assert.equal(isDaemonResponse(response), true);
    });

    test("when missing error only", () => {
      const response = {
        id: "1",
        result: {},
      };

      assert.equal(isDaemonResponse(response), true);
    });

    test("when missing result only", () => {
      const response = {
        id: "1",
        error: {},
      };

      assert.equal(isDaemonResponse(response), true);
    });

    test("when missing result and errror only", () => {
      const response = {
        id: "1",
      };

      assert.equal(isDaemonResponse(response), true);
    });
  });

  suite("returns false", () => {
    test("when missing id only", () => {
      const response = {
        result: {},
        error: {},
      };

      assert.equal(isDaemonResponse(response), false);
    });

    test("when object is a valid DaemonRequest", () => {
      const request = {
        id: "1",
        method: "method",
        params: {},
      };

      assert.equal(isDaemonRequest(request), true);
      assert.equal(isDaemonResponse(request), false);
    });

    test("when object is a valid DaemonEvent", () => {
      const event = {
        event: "event",
        params: {},
      };

      assert.equal(isDaemonEvent(event), true);
      assert.equal(isDaemonResponse(event), false);
    });
  });
});

suite("isDaemonEvent", () => {
  suite("returns true when object is a valid DaemonEvent", () => {
    test("with all fields", () => {
      const event = {
        event: "event",
        params: {},
      };

      assert.equal(isDaemonEvent(event), true);
    });

    test("when missing params only", () => {
      const event = {
        event: "event",
      };

      assert.equal(isDaemonEvent(event), true);
    });
  });

  suite("returns false", () => {
    test("when missing event only", () => {
      const event = {
        params: {},
      };

      assert.equal(isDaemonEvent(event), false);
    });

    test("when object is a valid DaemonRequest", () => {
      const request = {
        id: "1",
        method: "method",
        params: {},
      };

      assert.equal(isDaemonRequest(request), true);
      assert.equal(isDaemonEvent(request), false);
    });

    test("when object is a valid DaemonResponse", () => {
      const response = {
        id: "1",
        result: {},
        error: {},
      };

      assert.equal(isDaemonResponse(response), true);
      assert.equal(isDaemonEvent(response), false);
    });
  });
});
