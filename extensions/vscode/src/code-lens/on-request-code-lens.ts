import {
  CodeLens,
  CodeLensProvider,
  Event,
  EventEmitter,
  Position,
  ProviderResult,
  TextDocument,
  workspace,
} from "vscode";
import { nearestParentDartFrogProject } from "../utils";
import path = require("path");

abstract class ConfigurableCodeLensProvider implements CodeLensProvider {
  protected codeLenses: CodeLens[] = [];

  protected _onDidChangeCodeLenses: EventEmitter<void> =
    new EventEmitter<void>();
  public readonly onDidChangeCodeLenses: Event<void> =
    this._onDidChangeCodeLenses.event;

  constructor() {
    workspace.onDidChangeConfiguration(() => {
      this._onDidChangeCodeLenses.fire();
    });
  }

  // eslint-disable-next-line no-unused-vars
  public provideCodeLenses(document: TextDocument): ProviderResult<CodeLens[]> {
    if (!this.hasEnabledCodeLenses()) {
      return undefined;
    }
    return this.codeLenses;
  }

  public resolveCodeLens?(codeLens: CodeLens): ProviderResult<CodeLens> {
    if (!this.hasEnabledCodeLenses()) {
      return undefined;
    }
    return codeLens;
  }

  private hasEnabledCodeLenses(): boolean {
    return workspace.getConfiguration("dart-frog").get("enableCodeLens", true);
  }
}

// eslint-disable-next-line max-len
abstract class RegularExpressionCodeLensProvider extends ConfigurableCodeLensProvider {
  abstract readonly regex: RegExp;

  public provideCodeLenses(document: TextDocument): ProviderResult<CodeLens[]> {
    if (!super.provideCodeLenses(document)) {
      return undefined;
    }

    this.codeLenses = [];
    const text = document.getText();
    let matches;
    while ((matches = this.regex.exec(text)) !== null) {
      const line = document.lineAt(document.positionAt(matches.index).line);
      const indexOf = line.text.indexOf(matches[0]);
      const position = new Position(line.lineNumber, indexOf);
      const range = document.getWordRangeAtPosition(
        position,
        new RegExp(this.regex)
      );
      if (range) {
        this.codeLenses.push(new CodeLens(range));
      }
    }
    return this.codeLenses;
  }
}

// eslint-disable-next-line max-len
abstract class OnRequestCodeLensProvider extends RegularExpressionCodeLensProvider {
  readonly regex: RegExp =
    /(Response|Future<Response>|FutureOr<Response>)\s*onRequest\(.*?/g;

  public provideCodeLenses(document: TextDocument): ProviderResult<CodeLens[]> {
    if (document.languageId !== "dart") {
      return undefined;
    }

    const dartFrogProjectPath = nearestParentDartFrogProject(
      document.uri.fsPath
    );
    if (!dartFrogProjectPath) {
      return undefined;
    }

    const routesPath = path.join(dartFrogProjectPath, "routes");
    if (!document.uri.fsPath.startsWith(routesPath)) {
      return undefined;
    }

    return super.provideCodeLenses(document);
  }
}

/**
 * Shows a "Run" CodeLens on route handlers, which allows starting a development
 * server.
 */
export class RunOnRequestCodeLensProvider extends OnRequestCodeLensProvider {
  public resolveCodeLens?(codeLens: CodeLens): ProviderResult<CodeLens> {
    if (!super.resolveCodeLens!(codeLens)) {
      return undefined;
    }

    codeLens.command = {
      title: "Run",
      tooltip: "Starts a development server",
      command: "dart-frog.start-dev-server",
    };
    return codeLens;
  }
}

/**
 * Shows a "Debug" CodeLens on route handlers, which allows starting and
 * debugging a development server.
 */
export class DebugOnRequestCodeLensProvider extends OnRequestCodeLensProvider {
  public resolveCodeLens?(codeLens: CodeLens): ProviderResult<CodeLens> {
    if (!super.resolveCodeLens!(codeLens)) {
      return undefined;
    }

    codeLens.command = {
      title: "Debug",
      tooltip: "Starts and debugs a development server",
      command: "dart-frog.start-debug-dev-server",
    };
    return codeLens;
  }
}
