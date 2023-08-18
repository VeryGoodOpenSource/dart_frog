/**
 * This file is used to configure and programmatically runs the test suite.
 *
 * @see https://code.visualstudio.com/api/working-with-extensions/testing-extension#the-test-runner-script
 */

import * as path from "path";
import * as Mocha from "mocha";
import * as glob from "glob";

export function run(): Promise<void> {
  // Create the mocha test
  const mocha = new Mocha({
    ui: "tdd",
    color: true,
    timeout: 100000,
  });

  const testsRoot = path.resolve(__dirname, "..");

  return new Promise((c, e) => {
    const testFiles = new glob.Glob("**/**.test.js", { cwd: testsRoot });
    const testFileStream = testFiles.stream();

    testFileStream.on("data", (file) => {
      mocha.addFile(path.resolve(testsRoot, file));
    });
    testFileStream.on("error", (err) => {
      e(err);
    });
    testFileStream.on("end", () => {
      try {
        mocha.run((failures) => {
          if (failures > 0) {
            e(new Error(`${failures} tests failed.`));
          } else {
            c();
          }
        });
      } catch (err) {
        e(err);
      }
    });
  });
}
