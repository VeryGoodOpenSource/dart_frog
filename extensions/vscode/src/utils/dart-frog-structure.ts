/**
 * @file Provides utilities for inspecting and dealing with a Dart Frog
 * project's structure.
 */

const fs = require("fs");
const path = require("node:path");
import { window, workspace } from "vscode";

/**
 * Normalizes a file path to Dart Frog route path from the root of the
 * Dart Frog project.
 *
 * @param {string} selectedPath User-selected path to a file, including
 * directories,
 * @param {string} dartFrogProjectPath The path to the root of the Dart Frog
 * project.
 * @returns {string} The Dart Frog route path. If the {@link selectedPath} is
 * not within the Dart Frog project routes, it returns "/".
 *
 * @see {@link nearestDartFrogProject}, to find the root of a Dart Frog
 * project from a file path.
 */
export function normalizeRoutePath(
  selectedPath: String,
  dartFrogProjectPath: String
): string {
  const routesPath = path.join(dartFrogProjectPath, "routes");
  if (!selectedPath.startsWith(routesPath)) {
    return "/";
  }

  const relativePath = path.relative(routesPath, selectedPath);
  const parsedRelativePath = path.parse(relativePath);

  let routePath;
  const isFile = parsedRelativePath.ext !== "";
  if (!isFile) {
    routePath = relativePath;
  } else if (parsedRelativePath.name === "index") {
    routePath = parsedRelativePath.dir;
  } else {
    routePath = path.join(parsedRelativePath.dir, parsedRelativePath.name);
  }

  if (routePath === "") {
    return "/";
  } else {
    return routePath.replace(path.sep, "/");
  }
}

/**
 * Finds the root of a Dart Frog project.
 *
 * @param filePath The path to a file, including directories, to check.
 * @returns {string | undefined} The path to the root of the Dart Frog project,
 * or `undefined` if there is no Dart Frog project in the {@link filePath}.
 * @see {@link isDartFrogProject}, to determine if a file is a Dart Frog
 * project.
 */
export function nearestDartFrogProject(filePath: String): String | undefined {
  let currentPath = filePath;
  while (currentPath !== path.sep) {
    if (isDartFrogProject(currentPath)) {
      return currentPath;
    }
    currentPath = path.dirname(currentPath);
  }

  return undefined;
}

/**
 * Determines if a {@link filePath} is a Dart Frog project.
 *
 * A file is in a Dart Frog project if it is in a directory that contains a
 * `routes` directory and, at the same level, a `pubspec.yaml` file with a
 * `dart_frog` dependency.
 *
 * To avoid parsing the `pubspec.yaml` file, we use a heuristic where we simply
 * check if the `dart_frog` string is in the `pubspec.yaml` file.
 *
 * @param {string} filePath The path to a file, including directories, to check.
 * @returns {boolean} Whether or not the {@link filePath} is the root of Dart
 * Frog project.
 */
export function isDartFrogProject(filePath: String): boolean {
  const routesPath = path.join(filePath, "routes");
  const pubspecPath = path.join(filePath, "pubspec.yaml");

  if (fs.existsSync(routesPath) && fs.existsSync(pubspecPath)) {
    const pubspec = fs.readFileSync(pubspecPath, "utf-8");
    return pubspec.includes("dart_frog:");
  }

  return false;
}

/**
 * Resolves a path in a Dart Frog project.
 *
 * Usually used for when the command is launched from the command palette, and
 * hence without a defined path.
 *
 * The resolution is done in the following order:
 * 1. If the user has a Dart file open in the editor that is under a `routes`
 * directory and within a Dart Frog project, then the path of that file is
 * returned (without the `_middleware.dart` suffix, if any).
 * 2. If the user has a workspace folder open that is within a Dart Frog
 * project, then the path of that workspace folder is returned.
 */
export async function resolveDartFrogProjectPathFromWorkspace() {
  if (window.activeTextEditor) {
    const currentTextEditorPath = window.activeTextEditor.document.uri.fsPath;

    if (
      currentTextEditorPath.includes("routes") &&
      currentTextEditorPath.endsWith(".dart") &&
      nearestDartFrogProject(currentTextEditorPath) !== undefined
    ) {
      if (currentTextEditorPath.endsWith("_middleware.dart")) {
        return currentTextEditorPath.slice(0, "_middleware.dart".length * -1);
      }
      return currentTextEditorPath;
    }
  } else if (
    workspace.workspaceFolders &&
    workspace.workspaceFolders.length > 0
  ) {
    const currentWorkspaceFolder = workspace.workspaceFolders[0].uri.fsPath;
    if (nearestDartFrogProject(currentWorkspaceFolder) !== undefined) {
      return currentWorkspaceFolder;
    }
  }

  return undefined;
}
