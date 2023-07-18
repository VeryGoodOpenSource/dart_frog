/**
 * @file Provides utilities for inspecting and dealing with a Dart Frog
 * project's structure.
 */

const fs = require("fs");
const path = require("node:path");

/**
 * Converts a file path to a route path.
 *
 * @param {string} filePath The path to a file, including directories,
 * to convert.
 * @returns {string | undefined} The route path, or `undefined` if the
 * {@link filePath} is not in a Dart Frog project.
 */
export function filePathToRoutePath(filePath: String): String | undefined {
  const projectRoot = nearestDartFrogProject(filePath);
  if (projectRoot === undefined) {
    return undefined;
  }

  const routesPath = path.join(projectRoot, "routes");
  if (!filePath.startsWith(routesPath)) {
    return undefined;
  }

  const relativePath = path.relative(routesPath, filePath);
  const parsedRelativePath = path.parse(relativePath);

  const isFile = parsedRelativePath.ext !== "";
  if (!isFile) {
    return relativePath;
  } else if (parsedRelativePath.ext !== ".dart") {
    return undefined;
  } else if (parsedRelativePath.name === "index") {
    return parsedRelativePath.dir === "" ? path.sep : parsedRelativePath.dir;
  } else {
    return path.join(parsedRelativePath.dir, parsedRelativePath.name);
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
    return pubspec.includes("dart_frog");
  }

  return false;
}
