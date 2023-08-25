import {
  CancellationToken,
  CodeLens,
  CodeLensProvider,
  EventEmitter,
  Event,
  Position,
  ProviderResult,
  TextDocument,
  workspace,
} from "vscode";
import { nearestDartFrogProject } from "../utils";
import path = require("path");

abstract class ConfigurableCodeLensProvider implements CodeLensProvider {
  protected codeLenses: CodeLens[] = [];

  protected _onDidChangeCodeLenses: EventEmitter<void> =
    new EventEmitter<void>();
  public readonly onDidChangeCodeLenses: Event<void> =
    this._onDidChangeCodeLenses.event;

  constructor() {
    workspace.onDidChangeConfiguration((_) => {
      this._onDidChangeCodeLenses.fire();
    });
  }

  public provideCodeLenses(
    document: TextDocument,
    token: CancellationToken
  ): ProviderResult<CodeLens[]> {
    if (!this.hasEnabledCodeLenses()) {
      return undefined;
    }
    return this.codeLenses;
  }

  public resolveCodeLens?(
    codeLens: CodeLens,
    token: CancellationToken
  ): ProviderResult<CodeLens> {
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

  public provideCodeLenses(
    document: TextDocument,
    token: CancellationToken
  ): ProviderResult<CodeLens[]> {
    if (!super.provideCodeLenses(document, token)) {
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
  readonly regex: RegExp = /Response\s*onRequest\(RequestContext .*?\)\s*{/g;

  public provideCodeLenses(
    document: TextDocument,
    token: CancellationToken
  ): ProviderResult<CodeLens[]> {
    if (document.languageId !== "dart") {
      return undefined;
    }

    const dartFrogProjectPath = nearestDartFrogProject(document.uri.fsPath);
    if (!dartFrogProjectPath) {
      return undefined;
    }

    const routesPath = path.join(dartFrogProjectPath, "routes");
    if (!document.uri.fsPath.startsWith(routesPath)) {
      return undefined;
    }

    return super.provideCodeLenses(document, token);
  }
}

/**
 * Shows a "Run" code lens on the top of the route handlers, which allows
 * starting a development server.
 */
export class RunOnRequestCodeLensProvider extends OnRequestCodeLensProvider {
  public resolveCodeLens?(
    codeLens: CodeLens,
    token: CancellationToken
  ): ProviderResult<CodeLens> {
    if (!super.resolveCodeLens!(codeLens, token)) {
      return undefined;
    }

    codeLens.command = {
      title: "Run",
      tooltip: "Starts a development server",
      command: "dart-frog.start-dev-server",
      // TODO(alestiago): Pass the document URI to open server with route.
    };
    return codeLens;
  }
}
