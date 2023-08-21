import { window } from "vscode";
import { DartFrogDaemon } from "../daemon";
import {
  isDartFrogCLIInstalled,
  resolveDartFrogProjectPathFromWorkspace,
  suggestInstallingDartFrogCLI,
} from "../utils";

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
