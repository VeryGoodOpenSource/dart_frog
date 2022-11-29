---
sidebar_position: 2
title: 🐳 Custom Dockerfile
---

<!-- cSpell:ignore WORKDIR -->

# Custom Dockerfile 🐳

A `Dockerfile` is automatically generated when creating a production build via the `dart_frog build` command.

To use a custom `Dockerfile`, you can create a `Dockerfile` at the root of the project.

```
├── Dockerfile <-- NEW
├── README.md
├── analysis_options.yaml
├── pubspec.lock
├── pubspec.yaml
├── routes
│   └── index.dart
└── test
    └── routes
        └── index_test.dart
```

The following `Dockerfile` is a good starting point:

```dockerfile
# An example of using a custom Dockerfile with Dart Frog
# Official Dart image: https://hub.docker.com/_/dart
# Specify the Dart SDK base image version using dart:<version> (ex: dart:2.17)
FROM dart:stable AS build

WORKDIR /app

# Resolve app dependencies.
COPY pubspec.* ./
RUN dart pub get

# Copy app source code and AOT compile it.
COPY . .

# Generate a production build.
RUN dart pub global activate dart_frog_cli
RUN dart pub global run dart_frog_cli:dart_frog build

# Ensure packages are still up-to-date if anything has changed.
RUN dart pub get --offline
RUN dart compile exe build/bin/server.dart -o build/bin/server

# Build minimal serving image from AOT-compiled `/server` and required system
# libraries and configuration files stored in `/runtime/` from the build stage.
FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/build/bin/server /app/bin/
# Uncomment the following line if you are serving static files.
# COPY --from=build /app/build/public /public/

# Start the server.
CMD ["/app/bin/server"]
```

To build your Docker image run:

```sh
docker build . -t dart-frog-app
```

Then run your Docker container via:

```sh
docker run -i -t -p 8080:8080 dart-frog-app
```
