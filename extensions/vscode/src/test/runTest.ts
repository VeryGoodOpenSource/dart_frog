/**
 * This file downloads, unzipps, and launches VS Code with extension test parameters.
 *
 * It has been modified to package and install the extension before running the tests.
 *
 * @see https://code.visualstudio.com/api/working-with-extensions/testing-extension#the-test-script
 * @see https://code.visualstudio.com/api/working-with-extensions/testing-extension#custom-setup-with-vscodetestelectron
 * @see https://github.com/prettier/prettier-vscode/blob/main/src/test/runTests.ts
 */

import * as cp from "child_process";
import * as path from "path";
import {
  downloadAndUnzipVSCode,
  resolveCliArgsFromVSCodeExecutablePath,
  runTests,
} from "@vscode/test-electron";

async function main() {
  try {
    const extensionDevelopmentPath = path.resolve(__dirname, "../../");
    const extensionTestsPath = path.resolve(__dirname, "./suite/index");
    const vscodeExecutablePath = await downloadAndUnzipVSCode("1.79.2");
    const [cliPath, ...args] =
      resolveCliArgsFromVSCodeExecutablePath(vscodeExecutablePath);

    // Install extension
    cp.spawnSync(
      cliPath,
      [...args, "--install-extension", "VeryGoodVentures.dart-frog"],
      {
        encoding: "utf-8",
        stdio: "inherit",
      }
    );

    // Download VS Code, unzip it and run the integration test
    await runTests({
      extensionDevelopmentPath,
      extensionTestsPath,
      launchArgs: ["--disable-extensions", "--no-sandbox"],
    });
  } catch (err) {
    console.error("❌ Failed to run tests");
    process.exit(1);
  }
}

main().catch((err) => console.error(err));
