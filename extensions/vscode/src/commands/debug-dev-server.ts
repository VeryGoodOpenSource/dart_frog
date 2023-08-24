import { Uri, commands, debug, extensions, window } from "vscode";
import {
  isDartFrogCLIInstalled,
  quickPickApplication,
  suggestInstallingDartFrogCLI,
} from "../utils";
import { DartFrogApplication, DartFrogDaemon } from "../daemon";

export const debugDevServer = async (): Promise<void> => {
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
        await commands.executeCommand(
          "vscode.open",
          Uri.parse(dartCodeMarketplaceUri)
        );
        return;
      default:
        return;
    }
  }

  if (!dartExtension.isActive) {
    window.withProgress(
      {
        location: 15,
        title: `Activating Dart extension...`,
      },
      async () => {
        await dartExtension.activate();
      }
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
      : await quickPickApplication(
          {
            placeHolder: "Select a server to debug",
          },
          applications
        );
  if (!application) {
    return;
  }

  const debugSession = debug.activeDebugSession;
  if (
    debugSession &&
    debugSession.configuration.applicationId === application.id
  ) {
    const selection = await window.showInformationMessage(
      `A debug session is already running for this application.`,
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

  attachToDebugSession(application);
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
      title: `Attaching to debug session...`,
    },
    async function () {
      return await debug.startDebugging(undefined, {
        name: `Dart Frog: Development Server (${application.address})`,
        request: "attach",
        type: "dart",
        vmServiceUri: application.vmServiceUri,
        applicationId: application.id,
      });
    }
  );
}
