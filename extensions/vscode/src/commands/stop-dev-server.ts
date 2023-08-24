import {
  QuickInputButton,
  QuickPickItem,
  QuickPickItemKind,
  commands,
  window,
} from "vscode";
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
 * If there is more than one server running, the user will be informed so.
 */
export const stopDevServer = async (): Promise<void> => {
  if (!isDartFrogCLIInstalled()) {
    await suggestInstallingDartFrogCLI(
      "Running this command requires Dart Frog CLI to be installed."
    );
  }

  const daemon = DartFrogDaemon.instance;
  const applications = daemon.applicationRegistry.all();
  if (!daemon.isReady || applications.length === 0) {
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
    applications.length === 1
      ? applications[0]
      : await quickPickApplication(applications);
  if (!application) {
    return;
  }

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
        window.showErrorMessage(stopDaemonResponse.error.message);
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
      return await new Promise((resolve) => setTimeout(resolve, 250));
    }
  );
};

class PickableDartFrogApplication implements QuickPickItem {
  constructor(dartFrogApplication: DartFrogApplication) {
    const addressWithoutProtocol = dartFrogApplication.address!.replace(
      /.*?:\/\//g,
      ""
    );
    this.label = `$(globe) ${addressWithoutProtocol}`;
    this.description = dartFrogApplication.id!.toString();
    this.application = dartFrogApplication;
  }

  public readonly application: DartFrogApplication;

  label: string;
  kind?: QuickPickItemKind | undefined;
  description?: string | undefined;
  detail?: string | undefined;
  picked?: boolean | undefined;
  alwaysShow?: boolean | undefined;
  buttons?: readonly QuickInputButton[] | undefined;
}

/**
 * Prompts the user to select a {@link DartFrogApplication} from a list of
 * running {@link DartFrogApplication}s.
 *
 * @param applications The running {@link DartFrogApplication}s to choose from.
 * @returns The selected {@link DartFrogApplication} or `undefined` if the user
 * cancelled the selection.
 */
async function quickPickApplication(
  applications: DartFrogApplication[]
): Promise<DartFrogApplication | undefined> {
  const quickPick = window.createQuickPick<PickableDartFrogApplication>();
  quickPick.placeholder = "Select a server to stop";
  quickPick.busy = true;
  quickPick.ignoreFocusOut = true;
  quickPick.items = applications.map(
    (application) => new PickableDartFrogApplication(application)
  );
  quickPick.show();

  return new Promise<DartFrogApplication | undefined>((resolve) => {
    quickPick.onDidChangeSelection((value) => {
      quickPick.dispose();

      if (!value || value.length === 0) {
        resolve(undefined);
      } else {
        resolve(value[0]!.application);
      }
    });
  });
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
