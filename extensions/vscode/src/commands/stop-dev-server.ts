import { commands, window } from "vscode";
import { isDartFrogCLIInstalled, suggestInstallingDartFrogCLI } from "../utils";
import {
  DartFrogApplication,
  DartFrogApplicationRegistry,
  DartFrogApplicationRegistryEventEmitterTypes,
  DartFrogDaemon,
  StopDaemonRequest,
} from "../daemon";

/**
 * Stops a Dart Frog development server on the current workspace.
 *
 * This command can be launched from the command palette.
 *
 * The user requires to have Dart Frog CLI installed in order to run this
 * command. If they opt out of installing Dart Frog CLI, the command will
 * run at their own risk.
 *
 * If there are no running servers or the daemon is not ready, the user will
 * be prompted to start a server and this command will not run.
 *
 * If there is more than one server running, the user will be prompted to
 * select which server to stop.
 */
export const stopDevServer = async (): Promise<void> => {
  if (!isDartFrogCLIInstalled()) {
    await suggestInstallingDartFrogCLI(
      "Running this command requires Dart Frog CLI to be installed."
    );
  }

  const daemon = DartFrogDaemon.instance;
  const runningApplications = daemon.applicationRegistry.all();
  if (!daemon.isReady || runningApplications.length === 0) {
    const selection = await window.showInformationMessage(
      "No running servers found.",
      "Start server",
      "Cancel"
    );
    switch (selection) {
      case "Start server":
        commands.executeCommand("dart-frog.start-dev-server");
        return;
      case "Cancel":
      default:
        return;
    }
  }

  const application =
    runningApplications.length === 1
      ? runningApplications[0]
      : await quickPickApplication();

  const stopRequest = new StopDaemonRequest(
    daemon.requestIdentifierGenerator.generate(),
    application.id!
  );

  const deregisterPromise = onApplicationDeregistered(
    daemon.applicationRegistry,
    application
  );

  await window.withProgress(
    {
      location: 15,
    },
    async (progress) => {
      progress.report({
        message: `Stopping server...`,
      });

      const stopDaemonResponse = await daemon.send(stopRequest);
      if (stopDaemonResponse.error) {
        progress.report({
          message: stopDaemonResponse.error.message,
        });
        return;
      }

      progress.report({
        message: `Deregistering server...`,
        increment: 75,
      });

      await deregisterPromise;

      progress.report({
        message: `Server stopped successfully`,
        increment: 100,
      });

      // Add a small delay to allow the user to read the message.
      await new Promise((resolve) => setTimeout(resolve, 250));
    }
  );
};

async function quickPickApplication(): Promise<DartFrogApplication> {
  throw new Error("Not implemented");
}

/**
 * Waits for a {@link DartFrogApplication} to be deregistered.
 *
 * @param registry The {@link DartFrogApplicationRegistry} to listen to.
 * @param application The {@link DartFrogApplication} to wait for.
 * @returns
 */
function onApplicationDeregistered(
  registry: DartFrogApplicationRegistry,
  application: DartFrogApplication
): Promise<void> {
  return new Promise<void>((resolve) => {
    const listener = (oldApplication: DartFrogApplication) => {
      if (
        application.port === oldApplication.port &&
        application.vmServicePort === oldApplication.vmServicePort &&
        application.projectPath === oldApplication.projectPath
      ) {
        registry.off(
          DartFrogApplicationRegistryEventEmitterTypes.remove,
          listener
        );
        resolve();
      }
    };
    registry.on(DartFrogApplicationRegistryEventEmitterTypes.remove, listener);
  });
}
