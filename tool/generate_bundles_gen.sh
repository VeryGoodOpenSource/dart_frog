#!/bin/bash
# Runs `mason bundle` to generate bundles for all bricks within the top level bricks directory.

# Development Dart Frog Server Brick
mason bundle -s path bricks_gen/dart_frog_dev_server -t dart -o packages/dart_frog_gen/lib/src/codegen/bundles/

# Production Dart Frog Server Brick
mason bundle -s path bricks_gen/dart_frog_prod_server -t dart -o packages/dart_frog_gen/lib/src/codegen/bundles/

dart format ./packages/dart_frog_gen/lib/src/codegen/bundles/*.dart