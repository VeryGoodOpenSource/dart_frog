import { Disposable, StatusBarAlignment, StatusBarItem, window } from "vscode";

export class ApplicationStatusBar implements Disposable {
  public readonly statusBarItem: StatusBarItem;

  constructor() {
    this.statusBarItem = window.createStatusBarItem(
      StatusBarAlignment.Left,
      100
    );

    this.statusBarItem.text = "$(play) Start Server";
    // this.statusBarItem.backgroundColor = new ThemeColor(
    //   "statusBarItem.errorBackground"
    // );
    this.statusBarItem.show();
  }

  dispose() {
    this.statusBarItem.dispose();
  }
}
