/**
 * This file downloads, unzipps, and launches VS Code with extension test parameters.
 *
 * @see https://code.visualstudio.com/api/working-with-extensions/testing-extension#the-test-script
 * @see https://code.visualstudio.com/api/working-with-extensions/testing-extension#custom-setup-with-vscodetestelectron
 * @see https://github.com/prettier/prettier-vscode/blob/main/src/test/runTests.ts
 */

import * as path from "path";
import { runTests } from "@vscode/test-electron";

async function main() {
  try {
    const extensionDevelopmentPath = path.resolve(__dirname, "../../");
    const extensionTestsPath = path.resolve(__dirname, "./suite/index");

    // Download VS Code, unzip it and run the integration test
    await runTests({
      extensionDevelopmentPath,
      extensionTestsPath,
      launchArgs: ["--disable-extensions"],
    });
  } catch (err) {
    console.error("❌ Failed to run tests");
    process.exit(1);
  }
}

main();
