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
  selectedPath: string,
  dartFrogProjectPath: string
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
  } else if (
    parsedRelativePath.name === "index" ||
    parsedRelativePath.name === "_middleware"
  ) {
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
export function nearestDartFrogProject(filePath: string): string | undefined {
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
export function isDartFrogProject(filePath: string): boolean {
  const routesPath = path.join(filePath, "routes");
  const pubspecPath = path.join(filePath, "pubspec.yaml");

  if (fs.existsSync(routesPath) && fs.existsSync(pubspecPath)) {
    const pubspec = fs.readFileSync(pubspecPath, "utf-8");
    return pubspec.includes("dart_frog:");
  }

  return false;
}

/**
 * Resolves a path of a file or directory within a Dart Frog project from the
 * user's workspace.
 *
 * Usually used for when the command is launched from the command palette since
 * it lacks a defined path.
 *
 * @param {function} _nearestDartFrogProject A function, used for testing, that
 * finds the root of a Dart Frog project from a file path. Defaults to
 * {@link nearestDartFrogProject}.
 *
 * @returns {string | undefined} A path, derived from the user's workspace, that
 * is located within a Dart Frog project; or `undefined` if no such path could
 * be resolved. The resolution is done in the following order:
 *
 * 1. If the user has a Dart file open in the editor that is under a `routes`
 * directory and within a Dart Frog project, then the path of that file is
 * returned.
 * 2. If the user has a workspace folder open that is within a Dart Frog
 * project, then the path of that workspace folder is returned.
 */
export function resolveDartFrogProjectPathFromWorkspace(
  _nearestDartFrogProject: (
    filePath: string
  ) => string | undefined = nearestDartFrogProject
): string | undefined {
  if (window.activeTextEditor) {
    const currentTextEditorPath = path.normalize(
      window.activeTextEditor.document.uri.fsPath
    );
    const dartFrogProjectPath = _nearestDartFrogProject(currentTextEditorPath);

    if (dartFrogProjectPath) {
      const routesPath = path.join(dartFrogProjectPath, "routes");
      if (
        currentTextEditorPath.startsWith(routesPath) &&
        currentTextEditorPath.endsWith(".dart")
      ) {
        return currentTextEditorPath;
      }
    }
  }

  if (workspace.workspaceFolders && workspace.workspaceFolders.length > 0) {
    const currentWorkspaceFolder = path.normalize(
      workspace.workspaceFolders[0].uri.fsPath
    );
    if (_nearestDartFrogProject(currentWorkspaceFolder)) {
      return currentWorkspaceFolder;
    }
  }

  return undefined;
}

/**
 * Deduces the current route path from the active workspace file or folder of a
 * of a Dart Frog project.
 *
 * @returns {string} The current route path of a Dart Frog project. If the user
 * has a Dart file or workspace open in the editor that is under a `routes`
 * directory and within a Dart Frog project, then the path of that file is
 * returned. Otherwise, an empty string is returned.
 */
export function currentRoutePath(): string {
  const workingPath = resolveDartFrogProjectPathFromWorkspace();
  if (workingPath) {
    const dartFrogProjectPath = nearestDartFrogProject(workingPath);
    const routePath = normalizeRoutePath(workingPath, dartFrogProjectPath!);
    const isRoot = routePath === "/" || routePath === "";

    if (isRoot) {
      return "";
    } else if (!routePath.startsWith("/")) {
      return `/${routePath}`;
    } else {
      return routePath;
    }
  }

  return "";
}
