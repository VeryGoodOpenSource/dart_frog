import { Uri, commands, window } from "vscode";
import {
  isDartFrogCLIInstalled,
  nearestDartFrogProject,
  resolveDartFrogProjectPathFromWorkspace,
  suggestInstallingDartFrogCLI,
} from "../utils";
import {
  DartFrogApplication,
  DartFrogApplicationRegistryEventEmitterTypes,
  DartFrogDaemon,
  StartDaemonRequest,
} from "../daemon";

/**
 * Starts the server.
 *
 * This command can be launched from the Command Palette.
 */
export const startDevServer = async (): Promise<void> => {
  if (!isDartFrogCLIInstalled()) {
    await suggestInstallingDartFrogCLI(
      "Running this command requires Dart Frog CLI to be installed."
    );
  }

  const daemon = DartFrogDaemon.instance;
  if (!daemon.isReady) {
    await commands.executeCommand("dart-frog.start-daemon");
  }

  const runningServers = daemon.applicationRegistry.all();

  if (runningServers.length > 0) {
    const message =
      runningServers.length > 1
        ? `There are ${runningServers.length} servers already running, would you like to start another server?`
        : "A server is already running, would you like to start another server?";

    const selection = await window.showInformationMessage(
      message,
      "Start another server",
      "Cancel"
    );
    switch (selection) {
      case "Start another server":
        break;
      case "Cancel":
        return;
      default:
        return;
    }
  }

  const workingDirectory = nearestDartFrogProject(
    resolveDartFrogProjectPathFromWorkspace() ?? ""
  );
  if (!workingDirectory) {
    await window.showErrorMessage(
      "Failed to find a Dart Frog project within the current workspace."
    );
    return;
  }

  const usedPorts = [];
  for (const server of runningServers) {
    usedPorts.push(server.port);
    usedPorts.push(server.vmServicePort);
  }

  const portNumber = await promptPortNumber(
    "Which port number the server should start on",
    "8080",
    runningServers.length === 0 ? "8080" : undefined,
    usedPorts
  );
  if (!portNumber) {
    return;
  }
  usedPorts.push(Number(portNumber));

  console.log("@@@@ portNumber", portNumber);

  const vmServicePortNumber = await promptPortNumber(
    "Which port number the Dart VM service should listen on",
    "8181",
    runningServers.length === 0 ? "8181" : undefined,
    usedPorts
  );
  if (!vmServicePortNumber) {
    return;
  }

  const startDaemonRequest = new StartDaemonRequest(
    daemon.requestIdentifierGenerator.generate(),
    workingDirectory,
    Number(portNumber),
    Number(vmServicePortNumber)
  );

  const applicationRegistryPromise = new Promise<DartFrogApplication>(
    (resolve) => {
      const listener = (application: DartFrogApplication) => {
        if (
          application.port === startDaemonRequest.params.port &&
          application.vmServicePort ===
            startDaemonRequest.params.dartVmServicePort &&
          application.projectPath === startDaemonRequest.params.workingDirectory
        ) {
          daemon.applicationRegistry.off(
            DartFrogApplicationRegistryEventEmitterTypes.add,
            listener
          );
          resolve(application);
        }
      };
      daemon.applicationRegistry.on(
        DartFrogApplicationRegistryEventEmitterTypes.add,
        listener
      );
    }
  );

  await window.withProgress(
    {
      location: 15,
    },
    async function (progress) {
      progress.report({ message: `Starting server...` });

      const startDaemonResponse = await daemon.send(startDaemonRequest);
      if (startDaemonResponse.error) {
        progress.report({ message: startDaemonResponse.error.message });
        return;
      }

      progress.report({
        message: `Registering server...`,
        increment: 75,
      });

      const application = await applicationRegistryPromise;

      progress.report({
        message: `Server successfully started`,
        increment: 100,
      });

      commands.executeCommand("vscode.open", Uri.parse(application.address!));
    }
  );
};

function promptPortNumber(
  prompt: string,
  placeHolder: string,
  value: string | undefined = undefined,
  usedPorts: number[]
): Thenable<string | undefined> {
  return window.showInputBox({
    prompt: prompt,
    placeHolder: placeHolder,
    value: value,
    ignoreFocusOut: true,
    validateInput: (value) => {
      if (value.trim().length === 0) {
        return "Port number cannot be empty";
      }

      const port = Number(value);
      if (Number.isNaN(port)) {
        return "Port number must be a number";
      }
      if (port < 0 || port > 65535) {
        return "Port number must be between 0 and 65535";
      }
      if (usedPorts.includes(port)) {
        return "Port number is already in use by another server";
      }

      return undefined;
    },
  });
}
