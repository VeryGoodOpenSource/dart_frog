import {
  Command,
  Disposable,
  StatusBarAlignment,
  StatusBarItem,
  ThemeColor,
  Uri,
  window,
} from "vscode";
import {
  DartFrogApplicationRegistryEventEmitterTypes,
  DartFrogDaemon,
} from "../daemon";

export class ApplicationStatusBar implements Disposable {
  public readonly startStopStatusBarItem: StatusBarItem;
  public readonly applicationStatusBarItem: StatusBarItem;

  constructor() {
    this.startStopStatusBarItem = window.createStatusBarItem(
      StatusBarAlignment.Left,
      10
    );
    this.applicationStatusBarItem = window.createStatusBarItem(
      StatusBarAlignment.Right,
      10
    );

    this.update();
    this.startStopStatusBarItem.show();

    const daemon = DartFrogDaemon.instance;
    daemon.applicationRegistry.on(
      DartFrogApplicationRegistryEventEmitterTypes.add,
      this.update.bind(this)
    );
    daemon.applicationRegistry.on(
      DartFrogApplicationRegistryEventEmitterTypes.remove,
      this.update.bind(this)
    );
  }

  private update(): void {
    const daemon = DartFrogDaemon.instance;
    const applications = daemon.applicationRegistry.all();

    if (applications.length === 0) {
      this.startStopStatusBarItem.text = "$(dart-frog) Start Server";
      this.startStopStatusBarItem.tooltip = "Start development server";
      // TODO(alestiago): Use start-debug-dev-server comman instead.
      this.startStopStatusBarItem.command = "dart-frog.start-dev-server";
      this.startStopStatusBarItem.backgroundColor = undefined;

      this.applicationStatusBarItem.hide();
    } else {
      this.startStopStatusBarItem.text = "$(dart-frog) Stop Server";
      this.startStopStatusBarItem.tooltip = "Stop development server";
      this.startStopStatusBarItem.command = "dart-frog.stop-dev-server";
      // TODO(alestiago): Check colors when debug is active.
      this.startStopStatusBarItem.backgroundColor = new ThemeColor(
        "statusBarItem.warningBackground"
      );

      const application = applications[0];
      this.applicationStatusBarItem.text = `$(globe) localhost:${application.port}`;
      this.applicationStatusBarItem.tooltip = `localhost:${application.port}`;
      this.applicationStatusBarItem.show();
      const openCommand: Command = {
        title: "Open application in browser",
        command: "vscode.open",
        arguments: [Uri.parse(application.address!)],
      };
      this.applicationStatusBarItem.command = openCommand;
    }
  }

  dispose() {
    this.startStopStatusBarItem.dispose();
    this.applicationStatusBarItem.dispose();

    const daemon = DartFrogDaemon.instance;
    daemon.applicationRegistry.off(
      DartFrogApplicationRegistryEventEmitterTypes.add,
      this.update.bind(this)
    );
    daemon.applicationRegistry.off(
      DartFrogApplicationRegistryEventEmitterTypes.remove,
      this.update.bind(this)
    );
  }
}
