import {
  Disposable,
  StatusBarAlignment,
  StatusBarItem,
  window,
  workspace,
} from "vscode";
import { resolveDartFrogProjectPathFromWorkspace } from "../utils";

/**
 * Wraps a status bar item so that is only visible when the current workspace
 * is a Dart Frog project.
 *
 * Should be used as a base class for other status bar items.
 *
 * @see {@link StatusBarItem}, for more information on status bar items.
 */
export abstract class DartFrogStatusBarItem implements Disposable {
  public readonly statusBarItem: StatusBarItem;

  private onDidChangeWorkspaceFoldersDisposable: Disposable;
  private onDidChangeActiveTextEditorDisposable: Disposable;

  constructor(alignment: StatusBarAlignment, priority: number) {
    this.statusBarItem = window.createStatusBarItem(alignment, priority);

    this.onDidChangeWorkspaceFoldersDisposable =
      workspace.onDidChangeWorkspaceFolders(
        this.onChangeWorkingSystem.bind(this)
      );
    this.onDidChangeActiveTextEditorDisposable =
      window.onDidChangeActiveTextEditor(this.onChangeWorkingSystem.bind(this));

    this.update();
  }

  public abstract update(): any;

  private onChangeWorkingSystem(): void {
    const isDartFrogProject = resolveDartFrogProjectPathFromWorkspace();
    if (isDartFrogProject) {
      this.update();
    } else {
      this.statusBarItem.hide();
    }
  }

  public dispose(): void {
    this.onDidChangeWorkspaceFoldersDisposable.dispose();
    this.onDidChangeActiveTextEditorDisposable.dispose();
    this.statusBarItem.dispose();
  }
}
