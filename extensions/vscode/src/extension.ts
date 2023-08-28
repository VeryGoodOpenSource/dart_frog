import * as vscode from "vscode";
import {
  create,
  debugDevServer,
  installCLI,
  newMiddleware,
  newRoute,
  startDaemon,
  startDevServer,
  stopDevServer,
  updateCLI,
} from "./commands";
import {
  isCompatibleDartFrogCLIVersion,
  isDartFrogCLIInstalled,
  openChangelog,
  readDartFrogCLIVersion,
  readLatestDartFrogCLIVersion,
  suggestInstallingDartFrogCLI,
} from "./utils";
import { RunOnRequestCodeLensProvider } from "./code-lens";

/**
 * This method is called when the extension is activated.
 *
 * The extension is activated the very first time a command is executed or
 * if the workspace contains a pubspec.yaml file.
 *
 * @param {vscode.ExtensionContext} context
 * @returns The same instance of the extension context passed in.
 * @see {@link https://code.visualstudio.com/api/references/activation-events} for further details about
 * extension activation events.
 */
export function activate(
  context: vscode.ExtensionContext,
  ensureCompatibleCLI: () => Promise<void> = ensureCompatibleDartFrogCLI
): vscode.ExtensionContext {
  if (!isDartFrogCLIInstalled()) {
    suggestInstallingDartFrogCLI();
  } else {
    ensureCompatibleCLI();
  }

  vscode.languages.registerCodeLensProvider(
    "*",
    new RunOnRequestCodeLensProvider()
  );

  context.subscriptions.push(
    vscode.commands.registerCommand("dart-frog.create", create),
    vscode.commands.registerCommand("dart-frog.install-cli", installCLI),
    vscode.commands.registerCommand("dart-frog.update-cli", updateCLI),
    vscode.commands.registerCommand("dart-frog.new-route", newRoute),
    vscode.commands.registerCommand("dart-frog.new-middleware", newMiddleware),
    vscode.commands.registerCommand("dart-frog.start-daemon", startDaemon),
    vscode.commands.registerCommand(
      "dart-frog.start-dev-server",
      startDevServer
    ),
    vscode.commands.registerCommand("dart-frog.stop-dev-server", stopDevServer),
    vscode.commands.registerCommand(
      "dart-frog.debug-dev-server",
      debugDevServer
    )
  );
  return context;
}

/**
 * Checks if the version of Dart Frog CLI installed in the user's system is
 * compatible with this extension, suggesting to install if it is not.
 *
 * This method should be called upon activation of the extension to ensure that
 * the version of Dart Frog CLI installed in the user's system is compatible
 * with this extension.
 *
 * If the version of Dart Frog CLI installed in the user's system is not
 * compatible with this extension, the user is prompted to update Dart Frog CLI
 * or ignore the warning. If the user chooses to update Dart Frog CLI, the
 * extension will attempt to update Dart Frog CLI. Otherwise, the user will
 * proceed to use the extension at their own risk.
 *
 * If Dart Frog CLI is not installed in the user's system, this method will
 * do nothing and returns immediately.
 *
 * @see {@link isCompatibleDartFrogCLIVersion}, to check if the version of
 * Dart Frog CLI installed in the user's system is compatible with this
 * extension.
 */
export async function ensureCompatibleDartFrogCLI(): Promise<void> {
  const version = readDartFrogCLIVersion();
  if (!version) {
    return;
  }

  const versionIsCompatible = isCompatibleDartFrogCLIVersion(version);
  if (versionIsCompatible) {
    return;
  }

  const latestVersion = readLatestDartFrogCLIVersion();
  if (!latestVersion) {
    return;
  }

  const options = ["Update Dart Frog CLI", "Changelog", "Ignore"];
  const shouldUpdate = isCompatibleDartFrogCLIVersion(latestVersion);
  if (!shouldUpdate) {
    options.shift();
  }

  const selection = await vscode.window.showWarningMessage(
    `Dart Frog CLI version ${version} is not compatible with this extension.`,
    ...options
  );
  switch (selection) {
    case "Update Dart Frog CLI":
      updateCLI();
      break;
    case "Changelog":
      openChangelog(latestVersion);
      break;
    case "Ignore":
      break;
    default:
      break;
  }
}
