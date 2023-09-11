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
 * @see {@link nearestParentDartFrogProject}, to find the root of a Dart Frog
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
 * Finds the root of a Dart Frog project from a file path by traversing up the
 * directory tree.
 *
 * @param filePath The path to a file, including directories, to check.
 * @returns {string | undefined} The path to the root of the Dart Frog project,
 * or `undefined` if there is no Dart Frog project in the {@link filePath}.
 * @see {@link isDartFrogProject}, to determine if a file is a Dart Frog
 * project.
 */
export function nearestParentDartFrogProject(
  filePath: string
): string | undefined {
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
 *
 * @param filePath The path to a file, including directories, to check.
 * @param {function} _isDartFrogProject A function, used for testing,
 * that finds the root of a Dart Frog project from a file path. Defaults to
 * {@link isDartFrogProject}.
 * @returns {Set<string> | undefined} A set of paths to Dart Frog projects that
 * are children of the {@link filePath}, or `undefined` if there are no Dart
 * Frog projects in the {@link filePath}.
 */
// TODO(alestiago): Consider renaming this function to something more
// descriptive (plural).
export function nearestChildDartFrogProject(
  filePath: string
): Set<string> | undefined {
  if (!fs.existsSync(filePath) || !fs.statSync(filePath).isDirectory()) {
    return undefined;
  }

  const dartFrogProjects = new Set<string>();

  let currentSubdirectories = fs
    .readdirSync(filePath)
    .map((file: string) => path.join(filePath, file))
    .filter((file: string) => {
      console.log(`@@@ file: ${file}`);
      console.log(`@@@ statSync: ${fs.statSync(file)}`);
      return fs.statSync(file).isDirectory();
    });

  while (currentSubdirectories.length > 0) {
    for (let i = 0; i < currentSubdirectories.length; i++) {
      const subdirectory = currentSubdirectories[i];
      if (isDartFrogProject(subdirectory)) {
        dartFrogProjects.add(subdirectory);
        currentSubdirectories.splice(i, 1);
        i--;
      }
    }

    const nextSubdirectories: string[] = [];
    for (const subdirectory of currentSubdirectories) {
      const subdirectorySubdirectories = fs
        .readdirSync(subdirectory)
        .map((file: string) => path.join(subdirectory, file))
        .filter((file: string) => fs.statSync(file).isDirectory());
      nextSubdirectories.push(...subdirectorySubdirectories);
    }
    currentSubdirectories = nextSubdirectories;
  }

  if (dartFrogProjects.size === 0) {
    return undefined;
  }

  return dartFrogProjects;
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
 * @param {function} _nearestParentDartFrogProject A function, used for testing,
 * that finds the root of a Dart Frog project from a file path. Defaults to
 * {@link nearestParentDartFrogProject}.
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
  _nearestParentDartFrogProject: (
    filePath: string
  ) => string | undefined = nearestParentDartFrogProject
): string | undefined {
  if (window.activeTextEditor) {
    const currentTextEditorPath = path.normalize(
      window.activeTextEditor.document.uri.fsPath
    );
    const dartFrogProjectPath = _nearestParentDartFrogProject(
      currentTextEditorPath
    );

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
    if (_nearestParentDartFrogProject(currentWorkspaceFolder)) {
      return currentWorkspaceFolder;
    }
  }

  return undefined;
}
