import { Command, StatusBarAlignment, Uri } from "vscode";
import {
  DartFrogApplicationRegistryEventEmitterTypes,
  DartFrogDaemon,
} from "../daemon";
import { DartFrogStatusBarItem } from "./dart-frog-status-bar-item";

export class OpenApplicationStatusBarItem extends DartFrogStatusBarItem {
  constructor() {
    super(StatusBarAlignment.Right, 10);

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
    const daemon = DartFrogDaemon.instance;
    const applications = daemon.applicationRegistry.all();
    if (applications.length === 0) {
      this.statusBarItem.hide();
      return;
    }

    console.log(`@@@ SHOWING`);

    const application = applications[0];
    this.statusBarItem.text = `$(dart-frog-globe) localhost:${application.port}`;
    this.statusBarItem.tooltip = "Open application in browser";
    const openCommand: Command = {
      title: "Open application in browser",
      command: "vscode.open",
      arguments: [Uri.parse(application.address!)],
    };
    this.statusBarItem.command = openCommand;
    this.statusBarItem.show();

    console.log(`@@@ FINISHED SHOWING`);
    console.log(`@@@ ${this.statusBarItem.text}`);
  }

  public dispose(): void {
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
