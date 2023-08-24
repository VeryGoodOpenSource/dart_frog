import {
  ProgressOptions,
  QuickInputButton,
  QuickPickItem,
  QuickPickItemKind,
  Uri,
  commands,
  debug,
  extensions,
  window,
} from "vscode";
import { isDartFrogCLIInstalled, suggestInstallingDartFrogCLI } from "../utils";
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
      : await quickPickApplication(applications);
  if (!application) {
    return;
  }

  // TODO(alestiago): Check running debug session to avoid duplicate
  // debug sessions.
  attachToDebugSession(application);
};

// TODO(alestiago): Move this to a separate file to be shared with
// src/commands/stop-dev-server.ts.
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

// TODO(alestiago): Move this to a separate file to be shared with
// src/commands/stop-dev-server.ts.
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

function attachToDebugSession(application: DartFrogApplication): void {
  const options: ProgressOptions = {
    location: 15,
    title: `Attaching to debug session...`,
  };
  window.withProgress(options, async function () {
    return await debug.startDebugging(undefined, {
      name: `Dart Frog: Development Server (${application.port})`,
      request: "attach",
      type: "dart",
      vmServiceUri: application.vmServiceUri,
    });
  });
}
