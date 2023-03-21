---
sidebar_position: 6
title: 🔬 Debugging
---

# Debugging 🔬

Using the Dart VM URI, you can attach the dart debugger to the dart frog process and debug a running dev server in the same way you would debug any Dart application. This allows you to put breakpoints in your dart frog code and inspect the state of your server.

## Debugging with VS Code

Using the [Dart extension][dart_extension_link] for VS Code, you can create a launch configuration
to attach the debugger to the dev server. Using VS Code's tasks, you can also start and stop the dev
server automatically when the debugger is started and stopped.

When you press the debug button, the dev server will open in a new
terminal and a popup will prompt for the VM service URI. You can copy the URI from the output, it looks like this: `The Dart VM service is listening on http://127.0.0.1:8181/lLn6oHhbw-Y=/` (only copy the URI, not the message).

To setup the launch configuration, create the following files in your project's `.vscode` folder:

### launch.json

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Launch dev server",
      "request": "attach",
      "type": "dart",
      "preLaunchTask": "api: start dev server",
      "postDebugTask": "api: stop dev server",
      // Optionally, you can specify other options like the current working directory.
      "cwd": "${workspaceFolder}/api"
    }
    // Other debug configurations...
  ]
}
```

### tasks.json

```json
{
  "version": "2.0.0",
  // Optionally, you can specify other options like the current working directory
  // or environment variables.
  "options": {
    "cwd": "${workspaceFolder}/api",
    "env": {
      "API_KEY": "..."
    }
  },
  "tasks": [
    {
      "label": "api: start dev server",
      "command": "dart_frog dev",
      "type": "shell",
      "isBackground": true,
      "presentation": {
        "close": true
      },
      "problemMatcher": {
        "owner": "dart",
        "fileLocation": ["relative", "${workspaceFolder}/api"],
        "pattern": {
          "regexp": ".",
          "file": 1,
          "line": 2,
          "column": 3
        },
        "background": {
          "activeOnStart": true,
          "beginsPattern": {
            "regexp": "."
          },
          "endsPattern": {
            "regexp": "^\\[hotreload\\] (\\d{2}:\\d{2}:\\d{2} - Application reloaded\\.|Hot reload is enabled\\.)$"
          }
        }
      }
    },
    {
      "label": "api: stop dev server",
      "type": "shell",
      "command": "pkill -f \"sh $HOME/.pub-cache/bin/dart_frog dev\"",
      "presentation": {
        "reveal": "silent",
        "panel": "dedicated",
        "close": true
      }
    }
  ]
}
```

## Debugging with IntelliJ and Android Studio

Using the [Dart plugin][dart_plugin_link], you can create a new run configuration for
`Dart Remote Debug` and attach the debugger to the running dev server. When you debug the run configuration you created, it will prompt you for the VM service URI. You can copy the URI from the output, it looks like this: `The Dart VM service is listening on http://127.0.0.1:8181/lLn6oHhbw-Y=/` (only copy the URI, not the message).

[dart_extension_link]: https://marketplace.visualstudio.com/items?itemName=Dart-Code.dart-code
[dart_plugin_link]: https://plugins.jetbrains.com/plugin/6351-dart/
