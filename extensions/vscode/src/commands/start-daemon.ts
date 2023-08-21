import { window } from "vscode";
import { DartFrogDaemon } from "../daemon";
import {
  isDartFrogCLIInstalled,
  resolveDartFrogProjectPathFromWorkspace,
  suggestInstallingDartFrogCLI,
} from "../utils";

/**
 * Starts the Dart Frog daemon.
 *
 * This command can be launched from the Command Palette.
 *
 * Altough available in the Command Palette, this command is not intended to be
 * used directly by the user, unless troubleshooting. Instead, it is used
 * internally by the extension to start a Dart Frog application.
 *
 * @returns {Promise<void>} A Promise that resolves when the daemon is ready or
 * upon failing to retrieve a Dart Frog project path.
 */
export const startDaemon = async (): Promise<void> => {
  if (!isDartFrogCLIInstalled()) {
    await suggestInstallingDartFrogCLI(
      "Running this command requires Dart Frog CLI to be installed."
    );
  }

  const daemon = DartFrogDaemon.instance;

  if (daemon.isReady) {
    window.showInformationMessage("Daemon is already running.");
    return;
  }

  const dartFrogProjectPath = resolveDartFrogProjectPathFromWorkspace();
  if (!dartFrogProjectPath) {
    window.showErrorMessage(
      "Failed to find a Dart Frog project within the current workspace."
    );
    return;
  }

  return window.withProgress(
    {
      location: 15,
    },
    async function (progress) {
      progress.report({ message: `Starting daemon...` });
      await daemon.invoke(dartFrogProjectPath);
      progress.report({
        message: `Daemon successfully started.`,
        increment: 100,
      });
    }
  );
};
