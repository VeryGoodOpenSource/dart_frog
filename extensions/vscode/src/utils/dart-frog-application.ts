/**
 * @file Provides utilities for inspecting and managing Dart Frog applications.
 */

import {
  QuickInputButton,
  QuickPickItem,
  QuickPickItemKind,
  QuickPickOptions,
  window,
} from "vscode";
import { DartFrogApplication } from "../daemon";

/**
 * Prompts the user to select a {@link DartFrogApplication} from a list of
 * running {@link DartFrogApplication}s.
 *
 * @param options The options for the {@link QuickPick}.
 * @param applications The running {@link DartFrogApplication}s to choose from.
 * @returns The selected {@link DartFrogApplication} or `undefined` if the user
 * cancelled the selection.
 */
export async function quickPickApplication(
  options: QuickPickOptions,
  applications: DartFrogApplication[]
): Promise<DartFrogApplication | undefined> {
  const quickPick = window.createQuickPick<PickableDartFrogApplication>();
  quickPick.placeholder = options.placeHolder;
  quickPick.busy = false;
  quickPick.ignoreFocusOut = options.ignoreFocusOut ?? true;
  quickPick.canSelectMany = options.canPickMany ?? false;
  quickPick.items = applications.map(
    (application) => new PickableDartFrogApplication(application)
  );
  quickPick.show();

  return new Promise<DartFrogApplication | undefined>((resolve) => {
    quickPick.onDidChangeSelection((value) => {
      quickPick.dispose();

      const selection =
        !value || value.length === 0 ? undefined : value[0]!.application;
      if (selection) {
        options.onDidSelectItem?.(value[0]);
      }

      resolve(selection);
    });
  });
}

/**
 * A {@link QuickPickItem} that represents a {@link DartFrogApplication}.
 *
 * @see {@link quickPickApplication}
 */
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
