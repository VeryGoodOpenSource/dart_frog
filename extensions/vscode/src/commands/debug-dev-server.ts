import {
  DartFrogApplication,
  DartFrogApplicationRegistry,
  DartFrogApplicationRegistryEventEmitterTypes,
  DartFrogDaemon,
} from "../daemon";
import { Uri, commands, debug, extensions, window } from "vscode";
import {
  isDartFrogCLIInstalled,
  quickPickApplication,
  suggestInstallingDartFrogCLI,
} from "../utils";

export interface DebugDevServerOptions {
  application: DartFrogApplication;
}

export const debugDevServer = async (
  options?: DebugDevServerOptions | undefined
): Promise<void> => {
  if (!isDartFrogCLIInstalled()) {
    await suggestInstallingDartFrogCLI(
      "Running this command requires Dart Frog CLI to be installed."
    );
  }

  const dartExtension = extensions.getExtension("Dart-Code.dart-code");
  if (!dartExtension) {
    const selection = await window.showErrorMessage(
      "Running this command requires the Dart extension.",
      "Install Dart extension",
      "Cancel"
    );
    switch (selection) {
      case "Install Dart extension":
        const dartCodeMarketplaceUri =
          "https://marketplace.visualstudio.com/items?itemName=Dart-Code.dart-code";
        commands.executeCommand(
          "vscode.open",
          Uri.parse(dartCodeMarketplaceUri)
        );
        return;
      case "Cancel":
      default:
        return;
    }
    /* c8 ignore start */
  }
  /* c8 ignore stop */

  if (!dartExtension.isActive) {
    await window.withProgress(
      {
        location: 15,
        title: "Activating Dart extension...",
      },
      dartExtension.activate
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

  let application: DartFrogApplication;
  if (
    options &&
    options.application.id &&
    daemon.applicationRegistry.get(options.application.id)
  ) {
    application = options.application;
  } else if (applications.length === 1) {
    application = applications[0];
  } else {
    const selection = await quickPickApplication(
      {
        placeHolder: "Select a server to debug",
      },
      applications
    );
    if (!selection) {
      return;
    }

    application = selection;
  }

  const debugSession = debug.activeDebugSession;
  if (
    debugSession &&
    debugSession.configuration.applicationId === application.id
  ) {
    const selection = await window.showInformationMessage(
      "A debug session is already running for this application.",
      "Create another debug session",
      "Cancel"
    );
    switch (selection) {
      case "Create another debug session":
        break;
      case "Cancel":
      default:
        return;
    }
  }

  onApplicationDettached(daemon.applicationRegistry, application.id!).then(() =>
    detachFromDebugSession(application.id!)
  );

  await attachToDebugSession(application);
};

/**
 * Attaches to a Dart debug session for the given application.
 *
 * @param application The application to attach the debug session to.
 */
async function attachToDebugSession(
  application: DartFrogApplication
): Promise<void> {
  await window.withProgress(
    {
      location: 15,
      title: "Attaching to debug session...",
    },
    async function () {
      return await debug.startDebugging(undefined, {
        name: `Dart Frog: Development Server (${application.address})`,
        request: "attach",
        type: "dart",
        vmServiceUri: application.vmServiceUri,
        source: "dart-frog",
        applicationId: application.id,
      });
    }
  );
}

/**
 * Detaches from the current Dart debug session.
 *
 * @param applicationId The application attached to the debug session to.
 */
async function detachFromDebugSession(applicationId: string): Promise<void> {
  const debugSession = debug.activeDebugSession;

  if (
    debugSession &&
    debugSession.configuration.source === "dart-frog" &&
    debugSession.configuration.applicationId === applicationId
  ) {
    debugSession.customRequest("disconnect");
  }
}

/**
 * Waits for a {@link DartFrogApplication} to be detached from the active
 * debug session.
 *
 * This may happen if the user manually detaches from the debug session, or if
 * the application is exited prematurely.
 *
 * @param registry The {@link DartFrogApplicationRegistry} to listen to.
 * @param applicationId The application to wait for.
 * @returns A promise that resolves when the application has been deregistered.
 */
function onApplicationDettached(
  registry: DartFrogApplicationRegistry,
  applicationId: string
): Promise<void> {
  return new Promise<void>((resolve) => {
    const dispose = () => {
      registry.off(
        DartFrogApplicationRegistryEventEmitterTypes.remove,
        listener
      );
      resolve();
    };

    const listener = (application: DartFrogApplication) => {
      if (application.id === applicationId) {
        dispose();
      }
    };

    debug.onDidTerminateDebugSession((session) => {
      if (
        session &&
        session.configuration.source === "dart-frog" &&
        session.configuration.applicationId === applicationId
      ) {
        dispose();
      }
    });

    registry.on(DartFrogApplicationRegistryEventEmitterTypes.remove, listener);
  });
}
