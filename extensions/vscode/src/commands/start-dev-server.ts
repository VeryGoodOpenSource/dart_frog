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
 *
 * The user requires to have Dart Frog CLI installed in order to run this
 * command. If they opt out of installing Dart Frog CLI, the command will
 * run at their own risk.
 *
 * The user can start one or more servers. If there is already a server running,
 * the user will be prompted to confirm if really want to start another server.
 *
 * To start a server the user must:
 * - Have a Dart Frog project open in the current workspace.
 * - Select a valid port number for the server to run on.
 * - Select a valid port number for the Dart VM service to listen on.
 *
 * Otherwise, the command will not start the server.
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
      default:
        return;
    }
  }

  const workingPath = resolveDartFrogProjectPathFromWorkspace();
  const workingDirectory = workingPath
    ? nearestDartFrogProject(workingPath)
    : undefined;
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

/**
 * Prompts the user for a port number.
 *
 * The input is verified to be a valid port number and that it is not already in
 * use by another Dart Frog server.
 *
 * @param prompt The prompt to display to the user.
 * @param placeHolder The placeholder to display in the input box.
 * @param value The value to prefill the input box with.
 * @param usedPorts The ports that are already in use. Usually only those that
 * are currently in use by another Dart Frog server.
 * @returns If the user cancels the prompt, `undefined` is returned. Otherwise,
 * the port number is returned as a string.
 */
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
