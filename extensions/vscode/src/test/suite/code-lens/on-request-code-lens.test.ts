const sinon = require("sinon");
var proxyquire = require("proxyquire");

import * as assert from "assert";
import { afterEach, beforeEach, before } from "mocha";
import { CodeLens, Position, TextDocument, workspace } from "vscode";

suite("RunOnRequestCodeLensProvider", () => {
  let vscodeStub: any;
  let utilsStub: any;
  // eslint-disable-next-line @typescript-eslint/naming-convention
  let RunOnRequestCodeLensProvider: any;
  let document: any;

  beforeEach(() => {
    vscodeStub = {
      workspace: {
        getConfiguration: sinon.stub(),
      },
    };
    vscodeStub.workspace.onDidChangeConfiguration = sinon.stub();
    vscodeStub.workspace.getConfiguration
      .withArgs("dart-frog")
      .returns(sinon.stub().withArgs("enableCodeLens", true).returns(true));

    utilsStub = {
      nearestDartFrogProject: sinon.stub(),
    };
    utilsStub.nearestDartFrogProject.returns("/home/dart_frog");

    RunOnRequestCodeLensProvider = proxyquire(
      "../../../code-lens/on-request-code-lens",
      {
        // TODO(alestiago): Stub vscode workspace.
        // vscode: vscodeStub,
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

  suite("resolveCodeLens", () => {
    // TODO(alestiago): Implement tests.
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
        utilsStub.nearestDartFrogProject.returns(undefined);

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
    });

    test("returns the correct code lenses", async () => {
      const textDocument = await workspace.openTextDocument({
        language: "text",
        content: routeDocumentContent,
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
        /Response onRequest\(RequestContext context\) {/
      )!;

      sinon.assert.match(codeLens, new CodeLens(range));
    });

    test("returns the correct code lenses on a dynamic route", async () => {
      const textDocument = await workspace.openTextDocument({
        language: "text",
        content: dynamicRouteDocumentContent,
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
        /Response onRequest\(RequestContext context, String id\) {/
      )!;

      sinon.assert.match(codeLens, new CodeLens(range));
    });
  });
});

const routeDocumentContent = `
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  return Response(body: 'Welcome to Dart Frog!');
}

`;

const dynamicRouteDocumentContent = `
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context, String id) {
  return Response(body: 'post id: $id');
}

`;
