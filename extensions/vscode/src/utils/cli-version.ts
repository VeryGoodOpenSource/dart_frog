import * as vscode from "vscode";
const cp = require("child_process");
const semver = require("semver");

/**
 * The semantic version constraints for Dart Frog CLI to be compatible with this
 * extension.
 */
const compatibleCLIVersion = ">=0.3.7 <1.0.0";

/**
 * Collects the version of Dart Frog CLI installed in the user's system.
 *
 * @returns {String | undefined} The semantic version of Dart Frog CLI installed
 * in the user's system, or null if Dart Frog CLI is not installed.
 */
export function readDartFrogCLIVersion(): String | undefined {
  try {
    const result = cp.execSync(`dart_frog --version`);
    const decodedResult = new TextDecoder().decode(result);
    return decodedResult.split("\n", 1).at(0);
  } catch (error) {
    return undefined;
  }
}

/**
 * Collects the latest available version of Dart Frog CLI.
 *
 * @returns {String | undefined} The latest available semantic version of
 * Dart Frog CLI, or null if Dart Frog CLI is not installed.
 */
export function readLatestDartFrogCLIVersion(): String | undefined {
  try {
    const result = cp.execSync(`dart_frog --version`);
    const decodedResult = new TextDecoder().decode(result);
    const lines = decodedResult.split("\n");
    if (lines.length <= 2) {
      return lines.at(0);
    }
    return lines.at(2)?.split(" ").at(-1);
  } catch (error) {
    return undefined;
  }
}

/**
 * Checks if the version of Dart Frog CLI installed in the user's system is
 * compatible with this extension.
 *
 * @param {String} version The semantic version of Dart Frog CLI installed in
 * the user's system.
 * @returns {Boolean} True if the version of Dart Frog CLI installed in the
 * user's system is compatible with this extension, false otherwise.
 * @see {@link readDartFrogCLIVersion}, to collect the version of Dart Frog CLI.
 */
export function isCompatibleDartFrogCLIVersion(version: String): Boolean {
  return semver.satisfies(version, compatibleCLIVersion);
}

/**
 * Whether the user has Dart Frog CLI installed in their system.
 *
 * @returns {boolean} True if the user has Dart Frog CLI installed in their
 * system, false otherwise.
 */
export function isDartFrogCLIInstalled(): boolean {
  return readDartFrogCLIVersion() !== undefined;
}

/**
 * Opens the changelog for the specified version in a browser.
 *
 * @param {String} version The semantic version of Dart Frog CLI which changelog
 * is requested to open.
 */
export async function openChangelog(version: String): Promise<void> {
  vscode.commands.executeCommand(
    "vscode.open",
    vscode.Uri.parse(
      `https://github.com/verygoodopensource/dart_frog/releases/tag/dart_frog_cli-v${version}`
    )
  );
}
