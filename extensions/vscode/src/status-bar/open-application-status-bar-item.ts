import { Command, StatusBarAlignment, Uri } from "vscode";
import {
  DartFrogApplicationRegistryEventEmitterTypes,
  DartFrogDaemon,
} from "../daemon";
import { DartFrogStatusBarItem } from "./dart-frog-status-bar-item";
import { currentRoutePath } from "../utils";

export class OpenApplicationStatusBarItem extends DartFrogStatusBarItem {
  private updateFunction: () => void;

  constructor() {
    super(StatusBarAlignment.Right, 10);

    this.updateFunction = this.update.bind(this);

    const daemon = DartFrogDaemon.instance;
    daemon.applicationRegistry.on(
      DartFrogApplicationRegistryEventEmitterTypes.add,
      this.updateFunction
    );
    daemon.applicationRegistry.on(
      DartFrogApplicationRegistryEventEmitterTypes.remove,
      this.updateFunction
    );
  }

  public update(): void {
    const daemon = DartFrogDaemon.instance;
    const applications = daemon.applicationRegistry.all();
    if (applications.length === 0) {
      this.statusBarItem.hide();
      return;
    }

    const application = applications[0];
    this.statusBarItem.text = `$(dart-frog-globe) localhost:${application.port}`;
    this.statusBarItem.tooltip = "Open application in browser";

    const openCommand: Command = {
      title: "Open application in browser",
      command: "vscode.open",
      arguments: [Uri.parse(application.address! + currentRoutePath())],
    };
    this.statusBarItem.command = openCommand;
    this.statusBarItem.show();
  }

  public dispose(): void {
    const daemon = DartFrogDaemon.instance;
    daemon.applicationRegistry.off(
      DartFrogApplicationRegistryEventEmitterTypes.add,
      this.updateFunction
    );
    daemon.applicationRegistry.off(
      DartFrogApplicationRegistryEventEmitterTypes.remove,
      this.updateFunction
    );
    super.dispose();
  }
}
