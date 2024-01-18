/// Collection of `pubspec.lock` files used as fixtures during testing.
library pubspec_locks;

/// An artificially crafted `pubspec.lock` file with:
///
/// * A transitive dependency.
/// * A direct main path dependency that is not a child of the project
/// directory.
/// * A direct main dependency that is hosted.
/// * A direct dev main dependency that is hosted.
const fooPath = '''
packages:
  args:
    dependency: transitive
    description:
      name: args
      sha256: eef6c46b622e0494a36c5a12d10d77fb4e855501a91c1b9ef9339326e58f0596
      url: "https://pub.dev"
    source: hosted
    version: "2.4.2"
  foo:
    dependency: "direct main"
    description:
      path: "../../foo"
      relative: true
    source: path
    version: "0.0.0"
  mason:
    dependency: "direct main"
    description:
      name: mason
      sha256: fdc9ea905e7c690fe39d2f9946b7aead86fd976f8edf97d2521a65d260bbf509
      url: "https://pub.dev"
    source: hosted
    version: "0.1.0-dev.50"
  test:
    dependency: "direct dev"
    description:
      name: test
      sha256: "9b0dd8e36af4a5b1569029949d50a52cb2a2a2fdaa20cebb96e6603b9ae241f9"
      url: "https://pub.dev"
    source: hosted
    version: "1.24.6"
sdks:
  dart: ">=3.0.0 <4.0.0"
''';

/// An artificially crafted `pubspec.lock` file with:
///
/// * A transitive dependency.
/// * A direct main path dependency that is not a child of the project
/// directory.
/// * A direct main path dependency that is a child of the project directory.
/// * A direct main dependency that is hosted.
/// * A direct dev main dependency that is hosted.
const fooPathWithInternalDependency = '''
packages:
  args:
    dependency: transitive
    description:
      name: args
      sha256: eef6c46b622e0494a36c5a12d10d77fb4e855501a91c1b9ef9339326e58f0596
      url: "https://pub.dev"
    source: hosted
    version: "2.4.2"
  foo:
    dependency: "direct main"
    description:
      path: "../../foo"
      relative: true
    source: path
    version: "0.0.0"
  bar:
    dependency: "direct main"
    description:
      path: "packages/bar"
      relative: true
    source: path
    version: "0.0.0"
  mason:
    dependency: "direct main"
    description:
      name: mason
      sha256: fdc9ea905e7c690fe39d2f9946b7aead86fd976f8edf97d2521a65d260bbf509
      url: "https://pub.dev"
    source: hosted
    version: "0.1.0-dev.50"
  test:
    dependency: "direct dev"
    description:
      name: test
      sha256: "9b0dd8e36af4a5b1569029949d50a52cb2a2a2fdaa20cebb96e6603b9ae241f9"
      url: "https://pub.dev"
    source: hosted
    version: "1.24.6"
sdks:
  dart: ">=3.0.0 <4.0.0"
''';

/// An artificially crafted `pubspec.lock` file with:
///
/// * A transitive dependency.
/// * A direct main dependency that is hosted.
/// * A direct dev main dependency that is hosted.
const noPathDependencies = '''
packages:
  args:
    dependency: transitive
    description:
      name: args
      sha256: eef6c46b622e0494a36c5a12d10d77fb4e855501a91c1b9ef9339326e58f0596
      url: "https://pub.dev"
    source: hosted
    version: "2.4.2"
  mason:
    dependency: "direct main"
    description:
      name: mason
      sha256: fdc9ea905e7c690fe39d2f9946b7aead86fd976f8edf97d2521a65d260bbf509
      url: "https://pub.dev"
    source: hosted
    version: "0.1.0-dev.50"
  test:
    dependency: "direct dev"
    description:
      name: test
      sha256: "9b0dd8e36af4a5b1569029949d50a52cb2a2a2fdaa20cebb96e6603b9ae241f9"
      url: "https://pub.dev"
    source: hosted
    version: "1.24.6"
sdks:
  dart: ">=3.0.0 <4.0.0"
''';
