import * as cp from "child_process";
import * as path from "path";
import {
  downloadAndUnzipVSCode,
  resolveCliArgsFromVSCodeExecutablePath,
  runTests,
} from "@vscode/test-electron";

async function main() {
  try {
    const extensionDevelopmentPath = path.resolve(__dirname, "../../../");
    const extensionTestsPath = path.resolve(__dirname, "./suite/index");
    const vscodeExecutablePath = await downloadAndUnzipVSCode("1.79.2");
    const [cliPath, ...args] =
      resolveCliArgsFromVSCodeExecutablePath(vscodeExecutablePath);

    // Package extension
    cp.spawnSync("vsce package --out extension.vsix");
    const vsixPath = path.resolve(__dirname, "../../", "extension.vsix");

    // Install extension
    cp.spawnSync(cliPath, [...args, "--install-extension", vsixPath], {
      encoding: "utf-8",
      stdio: "inherit",
    });

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

main().catch((err) => console.error(err));
