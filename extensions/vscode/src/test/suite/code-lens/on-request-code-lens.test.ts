const sinon = require("sinon");
var proxyquire = require("proxyquire");

import * as assert from "assert";
import { CodeLens, Position, workspace } from "vscode";
import { afterEach, beforeEach } from "mocha";

/**
 * The content of a route file.
 */
const routeContent = `
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  return Response(body: 'Welcome to Dart Frog!');
}

`;

/**
 * The content of a route file with a dynamic route.
 */
const dynamicRouteContent = `
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context, String id) {
  return Response(body: 'Welcome to Dart Frog!');
}

`;

/**
 * The content of a route file with an async route.
 */
const asyncRouteContent = `
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  return Response(body: 'Welcome to Dart Frog!');
}

`;

/**
 * The content of a route file with a possibly async route.
 */
const maybeAsyncRouteContent = `
import 'package:dart_frog/dart_frog.dart';

FutureOr<Response> onRequest(RequestContext context, String id) async {
  return Response(body: 'Welcome to Dart Frog!');
}

`;

/**
 * The content of something that looks like a route file but isn't.
 */
const invalidRouteContent = `
import 'package:dart_frog/dart_frog.dart';

Response notOnRequest(RequestContext context) {
  return Response(body: 'Welcome to Dart Frog!');
}

`;

/**
 * A very long dynamic route with multiple arguments.
 */
const longDynamicRouteContent = `
import 'package:dart_frog/dart_frog.dart';

Response onRequest(
  RequestContext context,
  String id1,
  String id2,
  String id3,
) {
  return Response(body: 'Welcome to Dart Frog!');
}

`;

suite("RunOnRequestCodeLensProvider", () => {
  let vscodeStub: any;
  let utilsStub: any;
  // eslint-disable-next-line @typescript-eslint/naming-convention
  let RunOnRequestCodeLensProvider: any;
  let document: any;
  let workspaceConfiguration: any;

  beforeEach(() => {
    vscodeStub = {
      workspace: {
        onDidChangeConfiguration: sinon.stub(),
        getConfiguration: sinon.stub(),
      },
    };
    workspaceConfiguration = sinon.stub();
    vscodeStub.workspace.getConfiguration.returns(workspaceConfiguration);
    const getConfiguration = (workspaceConfiguration.get = sinon.stub());
    getConfiguration.withArgs("enableCodeLens", true).returns(true);

    utilsStub = {
      nearestParentDartFrogProject: sinon.stub(),
    };
    utilsStub.nearestParentDartFrogProject.returns("/home/dart_frog");

    RunOnRequestCodeLensProvider = proxyquire(
      "../../../code-lens/on-request-code-lens",
      {
        vscode: vscodeStub,
        // eslint-disable-next-line @typescript-eslint/naming-convention
        "../utils": utilsStub,
      }
    ).RunOnRequestCodeLensProvider;

    document = sinon.stub();
    document.languageId = "dart";
    document.uri = {
      fsPath: "/home/dart_frog/routes/index.dart",
    };
  });

  afterEach(() => {
    sinon.restore();
  });

  test("onDidChangeCodeLenses fires when configuration changes", () => {
    const provider = new RunOnRequestCodeLensProvider();
    const onDidChangeCodeLenses = sinon.stub();
    provider.onDidChangeCodeLenses(onDidChangeCodeLenses);

    vscodeStub.workspace.onDidChangeConfiguration.callArg(0);

    sinon.assert.calledOnce(onDidChangeCodeLenses);
  });

  suite("resolveCodeLens", () => {
    test("returns the CodeLens when configuration is enabled", async () => {
      workspaceConfiguration.get.withArgs("enableCodeLens", true).returns(true);

      const provider = new RunOnRequestCodeLensProvider();
      const codeLens = new CodeLens(sinon.stub());
      const result = await provider.resolveCodeLens(codeLens, sinon.stub());

      assert.strictEqual(result, codeLens);
      sinon.assert.match(result.command, {
        title: "Run",
        tooltip: "Starts a development server",
        command: "dart-frog.start-dev-server",
      });
    });

    test("returns undefined when configuration is disabled", async () => {
      workspaceConfiguration.get
        .withArgs("enableCodeLens", true)
        .returns(false);

      const provider = new RunOnRequestCodeLensProvider();
      const codeLens = new CodeLens(sinon.stub());
      const result = await provider.resolveCodeLens(codeLens, sinon.stub());

      assert.strictEqual(result, undefined);
    });
  });

  suite("providesCodeLenses", () => {
    suite("returns undefined if the document is not", () => {
      test("a Dart file", () => {
        document.languageId = "not-dart";

        const provider = new RunOnRequestCodeLensProvider();
        const result = provider.provideCodeLenses(document);

        assert.strictEqual(result, undefined);
      });

      test("in a Dart Frog project", () => {
        utilsStub.nearestParentDartFrogProject.returns(undefined);

        const provider = new RunOnRequestCodeLensProvider();
        const result = provider.provideCodeLenses(document);

        assert.strictEqual(result, undefined);
      });

      test("in the routes folder", () => {
        document.uri = {
          fsPath: "/home/dart_frog/not-routes/route.dart",
        };

        const provider = new RunOnRequestCodeLensProvider();
        const result = provider.provideCodeLenses(document);

        assert.strictEqual(result, undefined);
      });

      test("codeLens configuration is disabled", () => {
        workspaceConfiguration.get
          .withArgs("enableCodeLens", true)
          .returns(false);

        const provider = new RunOnRequestCodeLensProvider();
        const result = provider.provideCodeLenses(document);

        assert.strictEqual(result, undefined);
      });
    });

    test("returns the correct CodeLenses", async () => {
      const content = routeContent;
      const textDocument = await workspace.openTextDocument({
        language: "text",
        content,
      });
      document.getText = textDocument.getText.bind(textDocument);
      document.positionAt = textDocument.positionAt.bind(textDocument);
      document.lineAt = textDocument.lineAt.bind(textDocument);
      document.getWordRangeAtPosition =
        textDocument.getWordRangeAtPosition.bind(textDocument);

      const provider = new RunOnRequestCodeLensProvider();
      const result = await provider.provideCodeLenses(document);

      assert.strictEqual(result.length, 1);

      const codeLens = result[0];

      const range = document.getWordRangeAtPosition(
        new Position(3, 0),
        provider.regex
      )!;

      sinon.assert.match(codeLens, new CodeLens(range));
    });

    test("returns the correct CodeLenses on a dynamic route", async () => {
      const content = dynamicRouteContent;
      const textDocument = await workspace.openTextDocument({
        language: "text",
        content,
      });
      document.getText = textDocument.getText.bind(textDocument);
      document.positionAt = textDocument.positionAt.bind(textDocument);
      document.lineAt = textDocument.lineAt.bind(textDocument);
      document.getWordRangeAtPosition =
        textDocument.getWordRangeAtPosition.bind(textDocument);

      const provider = new RunOnRequestCodeLensProvider();
      const result = await provider.provideCodeLenses(document);

      assert.strictEqual(result.length, 1);

      const codeLens = result[0];

      const range = document.getWordRangeAtPosition(
        new Position(3, 0),
        provider.regex
      )!;

      sinon.assert.match(codeLens, new CodeLens(range));
    });

    test("returns the correct CodeLenses on a long dynamic route", async () => {
      const content = longDynamicRouteContent;
      const textDocument = await workspace.openTextDocument({
        language: "text",
        content,
      });
      document.getText = textDocument.getText.bind(textDocument);
      document.positionAt = textDocument.positionAt.bind(textDocument);
      document.lineAt = textDocument.lineAt.bind(textDocument);
      document.getWordRangeAtPosition =
        textDocument.getWordRangeAtPosition.bind(textDocument);

      const provider = new RunOnRequestCodeLensProvider();
      const result = await provider.provideCodeLenses(document);

      assert.strictEqual(result.length, 1);

      const codeLens = result[0];

      const range = document.getWordRangeAtPosition(
        new Position(3, 0),
        provider.regex
      )!;

      sinon.assert.match(codeLens, new CodeLens(range));
    });

    test("returns the correct CodeLenses on an async route", async () => {
      const content = asyncRouteContent;
      const textDocument = await workspace.openTextDocument({
        language: "text",
        content,
      });
      document.getText = textDocument.getText.bind(textDocument);
      document.positionAt = textDocument.positionAt.bind(textDocument);
      document.lineAt = textDocument.lineAt.bind(textDocument);
      document.getWordRangeAtPosition =
        textDocument.getWordRangeAtPosition.bind(textDocument);

      const provider = new RunOnRequestCodeLensProvider();
      const result = await provider.provideCodeLenses(document);

      assert.strictEqual(result.length, 1);

      const codeLens = result[0];

      const range = document.getWordRangeAtPosition(
        new Position(3, 0),
        provider.regex
      )!;

      sinon.assert.match(codeLens, new CodeLens(range));
    });

    test("returns the correct CodeLenses on a possibly async route", async () => {
      const content = maybeAsyncRouteContent;
      const textDocument = await workspace.openTextDocument({
        language: "text",
        content,
      });
      document.getText = textDocument.getText.bind(textDocument);
      document.positionAt = textDocument.positionAt.bind(textDocument);
      document.lineAt = textDocument.lineAt.bind(textDocument);
      document.getWordRangeAtPosition =
        textDocument.getWordRangeAtPosition.bind(textDocument);

      const provider = new RunOnRequestCodeLensProvider();
      const result = await provider.provideCodeLenses(document);

      assert.strictEqual(result.length, 1);

      const codeLens = result[0];

      const range = document.getWordRangeAtPosition(
        new Position(3, 0),
        provider.regex
      )!;

      sinon.assert.match(codeLens, new CodeLens(range));
    });

    test("returns no CodeLenses on a non route file", async () => {
      const content = invalidRouteContent;
      const textDocument = await workspace.openTextDocument({
        language: "text",
        content,
      });
      document.getText = textDocument.getText.bind(textDocument);
      document.positionAt = textDocument.positionAt.bind(textDocument);
      document.lineAt = textDocument.lineAt.bind(textDocument);
      document.getWordRangeAtPosition =
        textDocument.getWordRangeAtPosition.bind(textDocument);

      const provider = new RunOnRequestCodeLensProvider();
      const result = await provider.provideCodeLenses(document);

      assert.strictEqual(result.length, 0);
    });
  });
});

suite("DebugOnRequestCodeLensProvider", () => {
  let vscodeStub: any;
  let utilsStub: any;
  // eslint-disable-next-line @typescript-eslint/naming-convention
  let DebugOnRequestCodeLensProvider: any;
  let document: any;
  let workspaceConfiguration: any;

  beforeEach(() => {
    vscodeStub = {
      workspace: {
        onDidChangeConfiguration: sinon.stub(),
        getConfiguration: sinon.stub(),
      },
    };
    workspaceConfiguration = sinon.stub();
    vscodeStub.workspace.getConfiguration.returns(workspaceConfiguration);
    const getConfiguration = (workspaceConfiguration.get = sinon.stub());
    getConfiguration.withArgs("enableCodeLens", true).returns(true);

    utilsStub = {
      nearestParentDartFrogProject: sinon.stub(),
    };
    utilsStub.nearestParentDartFrogProject.returns("/home/dart_frog");

    DebugOnRequestCodeLensProvider = proxyquire(
      "../../../code-lens/on-request-code-lens",
      {
        vscode: vscodeStub,
        // eslint-disable-next-line @typescript-eslint/naming-convention
        "../utils": utilsStub,
      }
    ).DebugOnRequestCodeLensProvider;

    document = sinon.stub();
    document.languageId = "dart";
    document.uri = {
      fsPath: "/home/dart_frog/routes/index.dart",
    };
  });

  afterEach(() => {
    sinon.restore();
  });

  test("onDidChangeCodeLenses fires when configuration changes", () => {
    const provider = new DebugOnRequestCodeLensProvider();
    const onDidChangeCodeLenses = sinon.stub();
    provider.onDidChangeCodeLenses(onDidChangeCodeLenses);

    vscodeStub.workspace.onDidChangeConfiguration.callArg(0);

    sinon.assert.calledOnce(onDidChangeCodeLenses);
  });

  suite("resolveCodeLens", () => {
    test("returns the CodeLens when configuration is enabled", async () => {
      workspaceConfiguration.get.withArgs("enableCodeLens", true).returns(true);

      const provider = new DebugOnRequestCodeLensProvider();
      const codeLens = new CodeLens(sinon.stub());
      const result = await provider.resolveCodeLens(codeLens, sinon.stub());

      assert.strictEqual(result, codeLens);
      sinon.assert.match(result.command, {
        title: "Debug",
        tooltip: "Starts and debugs a development server",
        command: "dart-frog.start-debug-dev-server",
      });
    });

    test("returns undefined when configuration is disabled", async () => {
      workspaceConfiguration.get
        .withArgs("enableCodeLens", true)
        .returns(false);

      const provider = new DebugOnRequestCodeLensProvider();
      const codeLens = new CodeLens(sinon.stub());
      const result = await provider.resolveCodeLens(codeLens, sinon.stub());

      assert.strictEqual(result, undefined);
    });
  });

  suite("providesCodeLenses", () => {
    suite("returns undefined if the document is not", () => {
      test("a Dart file", () => {
        document.languageId = "not-dart";

        const provider = new DebugOnRequestCodeLensProvider();
        const result = provider.provideCodeLenses(document);

        assert.strictEqual(result, undefined);
      });

      test("in a Dart Frog project", () => {
        utilsStub.nearestParentDartFrogProject.returns(undefined);

        const provider = new DebugOnRequestCodeLensProvider();
        const result = provider.provideCodeLenses(document);

        assert.strictEqual(result, undefined);
      });

      test("in the routes folder", () => {
        document.uri = {
          fsPath: "/home/dart_frog/not-routes/route.dart",
        };

        const provider = new DebugOnRequestCodeLensProvider();
        const result = provider.provideCodeLenses(document);

        assert.strictEqual(result, undefined);
      });

      test("codeLens configuration is disabled", () => {
        workspaceConfiguration.get
          .withArgs("enableCodeLens", true)
          .returns(false);

        const provider = new DebugOnRequestCodeLensProvider();
        const result = provider.provideCodeLenses(document);

        assert.strictEqual(result, undefined);
      });
    });

    test("returns the correct CodeLenses", async () => {
      const content = routeContent;
      const textDocument = await workspace.openTextDocument({
        language: "text",
        content,
      });
      document.getText = textDocument.getText.bind(textDocument);
      document.positionAt = textDocument.positionAt.bind(textDocument);
      document.lineAt = textDocument.lineAt.bind(textDocument);
      document.getWordRangeAtPosition =
        textDocument.getWordRangeAtPosition.bind(textDocument);

      const provider = new DebugOnRequestCodeLensProvider();
      const result = await provider.provideCodeLenses(document);

      assert.strictEqual(result.length, 1);

      const codeLens = result[0];

      const range = document.getWordRangeAtPosition(
        new Position(3, 0),
        provider.regex
      )!;

      sinon.assert.match(codeLens, new CodeLens(range));
    });

    test("returns the correct CodeLenses on an async route", async () => {
      const content = asyncRouteContent;
      const textDocument = await workspace.openTextDocument({
        language: "text",
        content,
      });
      document.getText = textDocument.getText.bind(textDocument);
      document.positionAt = textDocument.positionAt.bind(textDocument);
      document.lineAt = textDocument.lineAt.bind(textDocument);
      document.getWordRangeAtPosition =
        textDocument.getWordRangeAtPosition.bind(textDocument);

      const provider = new DebugOnRequestCodeLensProvider();
      const result = await provider.provideCodeLenses(document);

      assert.strictEqual(result.length, 1);

      const codeLens = result[0];

      const range = document.getWordRangeAtPosition(
        new Position(3, 0),
        provider.regex
      )!;

      sinon.assert.match(codeLens, new CodeLens(range));
    });

    test("returns the correct CodeLenses on a possibly async route", async () => {
      const content = maybeAsyncRouteContent;
      const textDocument = await workspace.openTextDocument({
        language: "text",
        content,
      });
      document.getText = textDocument.getText.bind(textDocument);
      document.positionAt = textDocument.positionAt.bind(textDocument);
      document.lineAt = textDocument.lineAt.bind(textDocument);
      document.getWordRangeAtPosition =
        textDocument.getWordRangeAtPosition.bind(textDocument);

      const provider = new DebugOnRequestCodeLensProvider();
      const result = await provider.provideCodeLenses(document);

      assert.strictEqual(result.length, 1);

      const codeLens = result[0];

      const range = document.getWordRangeAtPosition(
        new Position(3, 0),
        provider.regex
      )!;

      sinon.assert.match(codeLens, new CodeLens(range));
    });

    test("returns the correct CodeLenses on a dynamic route", async () => {
      const content = dynamicRouteContent;
      const textDocument = await workspace.openTextDocument({
        language: "text",
        content,
      });
      document.getText = textDocument.getText.bind(textDocument);
      document.positionAt = textDocument.positionAt.bind(textDocument);
      document.lineAt = textDocument.lineAt.bind(textDocument);
      document.getWordRangeAtPosition =
        textDocument.getWordRangeAtPosition.bind(textDocument);

      const provider = new DebugOnRequestCodeLensProvider();
      const result = await provider.provideCodeLenses(document);

      assert.strictEqual(result.length, 1);

      const codeLens = result[0];

      const range = document.getWordRangeAtPosition(
        new Position(3, 0),
        provider.regex
      )!;

      sinon.assert.match(codeLens, new CodeLens(range));
    });

    test("returns the correct CodeLenses on a long dynamic route", async () => {
      const content = longDynamicRouteContent;
      const textDocument = await workspace.openTextDocument({
        language: "text",
        content,
      });
      document.getText = textDocument.getText.bind(textDocument);
      document.positionAt = textDocument.positionAt.bind(textDocument);
      document.lineAt = textDocument.lineAt.bind(textDocument);
      document.getWordRangeAtPosition =
        textDocument.getWordRangeAtPosition.bind(textDocument);

      const provider = new DebugOnRequestCodeLensProvider();
      const result = await provider.provideCodeLenses(document);

      assert.strictEqual(result.length, 1);

      const codeLens = result[0];

      const range = document.getWordRangeAtPosition(
        new Position(3, 0),
        provider.regex
      )!;

      sinon.assert.match(codeLens, new CodeLens(range));
    });

    test("returns no CodeLenses on a non route file", async () => {
      const content = invalidRouteContent;
      const textDocument = await workspace.openTextDocument({
        language: "text",
        content,
      });
      document.getText = textDocument.getText.bind(textDocument);
      document.positionAt = textDocument.positionAt.bind(textDocument);
      document.lineAt = textDocument.lineAt.bind(textDocument);
      document.getWordRangeAtPosition =
        textDocument.getWordRangeAtPosition.bind(textDocument);

      const provider = new DebugOnRequestCodeLensProvider();
      const result = await provider.provideCodeLenses(document);

      assert.strictEqual(result.length, 0);
    });
  });
});
