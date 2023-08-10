import * as assert from "assert";
import { isDeamonEvent, isDeamonRequest, isDeamonResponse } from "../../daemon";

suite("isDeamonRequest", () => {
  suite("returns true when object is a valid isDeamonRequest", () => {
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

    test("when object is a valid isDeamonResponse", () => {
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
  suite("returns true when object is a valid isDeamonResponse", () => {
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
  suite("returns true when object is a valid isDeamonEvent", () => {
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
