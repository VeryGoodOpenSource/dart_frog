import assert = require("assert");
import { DartFrogDaemon } from "../../../daemon";

suite("DartFrogDaemon", () => {
  test("instance retrieves a singleton", () => {
    const dartFrogDaemon = DartFrogDaemon.instance;
    const dartFrogDaemon2 = DartFrogDaemon.instance;

    assert.equal(dartFrogDaemon, dartFrogDaemon2);
  });
});
