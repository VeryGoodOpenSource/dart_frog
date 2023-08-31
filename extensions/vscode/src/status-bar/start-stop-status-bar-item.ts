import {
  DartFrogApplicationRegistryEventEmitterTypes,
  DartFrogDaemon,
} from "../daemon";
import { DartFrogStatusBarItem } from "./dart-frog-status-bar-item";
import { StatusBarAlignment } from "vscode";

export class StartStopStatusBarItem extends DartFrogStatusBarItem {
  constructor() {
    super(StatusBarAlignment.Left, 10);

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

  public update(): void {
    this.statusBarItem.show();

    const daemon = DartFrogDaemon.instance;
    const applications = daemon.applicationRegistry.all();

    if (applications.length === 0) {
      this.statusBarItem.text = "$(dart-frog-start) Start Server";
      this.statusBarItem.tooltip = "Start development server";
      this.statusBarItem.command = "dart-frog.start-debug-dev-server";
      this.statusBarItem.backgroundColor = undefined;
    } else {
      this.statusBarItem.text = "$(dart-frog-stop) Stop Server";
      this.statusBarItem.tooltip = "Stop development server";
      this.statusBarItem.command = "dart-frog.stop-dev-server";
    }
  }

  dispose() {
    super.dispose();

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
