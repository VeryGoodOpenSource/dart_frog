const cp = require("child_process");
const semver = require("semver");

/**
 * The version constraints for Dart Frog CLI to be compatible with this
 * extension.
 */
const compatibleCLIVersion = ">=0.3.7";

/**
 * Collects the version of Dart Frog CLI installed in the user's system.
 *
 * @returns {String | undefined} The semantic version of Dart Frog CLI installed
 * in the user's system, or null if Dart Frog CLI is not installed.
 */
export function readDartFrogVersion(): String | undefined {
  try {
    return cp.execSync(`dart_frog --version`);
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
 * @see {@link readDartFrogVersion}, to collect the version of Dart Frog CLI.
 */
export function isCompatibleCLIVersion(version: String): Boolean {
  return semver.satisfies(version, compatibleCLIVersion);
}
