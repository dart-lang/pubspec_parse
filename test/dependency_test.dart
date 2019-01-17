// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:test/test.dart';

import 'test_utils.dart';

void main() {
  group('hosted', _hostedDependency);
  group('git', _gitDependency);
  group('sdk', _sdkDependency);
  group('path', _pathDependency);

  group('errors', () {
    test('List', () {
      _expectThrows([], r'''
line 4, column 10: Not a valid dependency value.
  ╷
4 │   "dep": []
  │          ^^
  ╵''');
    });

    test('int', () {
      _expectThrows(42, r'''
line 4, column 10: Not a valid dependency value.
  ╷
4 │     "dep": 42
  │ ┌──────────^
5 │ │  }
  │ └─^
  ╵''');
    });

    test('map with too many keys', () {
      _expectThrows({'path': 'a', 'git': 'b'}, r'''
line 5, column 12: A dependency may only have one source.
  ╷
5 │    "path": "a",
  │            ^^^
  ╵''');
    });

    test('map with unsupported keys', () {
      _expectThrows({'bob': 'a', 'jones': 'b'}, r'''
line 6, column 4: Unsupported dependency key.
  ╷
6 │    "jones": "b"
  │    ^^^^^^^
  ╵''');
    });
  });
}

void _hostedDependency() {
  test('null', () {
    final dep = _dependency<HostedDependency>(null);
    expect(dep.version.toString(), 'any');
    expect(dep.hosted, isNull);
    expect(dep.toString(), 'HostedDependency: any');
  });

  test('empty map', () {
    final dep = _dependency<HostedDependency>({});
    expect(dep.hosted, isNull);
    expect(dep.toString(), 'HostedDependency: any');
  });

  test('string version', () {
    final dep = _dependency<HostedDependency>('^1.0.0');
    expect(dep.version.toString(), '^1.0.0');
    expect(dep.hosted, isNull);
    expect(dep.toString(), 'HostedDependency: ^1.0.0');
  });

  test('bad string version', () {
    _expectThrows('not a version', r'''
line 4, column 10: Could not parse version "not a version". Unknown text at "not a version".
  ╷
4 │   "dep": "not a version"
  │          ^^^^^^^^^^^^^^^
  ╵''');
  });

  test('map w/ just version', () {
    final dep = _dependency<HostedDependency>({'version': '^1.0.0'});
    expect(dep.version.toString(), '^1.0.0');
    expect(dep.hosted, isNull);
    expect(dep.toString(), 'HostedDependency: ^1.0.0');
  });

  test('map w/ version and hosted as Map', () {
    final dep = _dependency<HostedDependency>({
      'version': '^1.0.0',
      'hosted': {'name': 'hosted_name', 'url': 'hosted_url'}
    });
    expect(dep.version.toString(), '^1.0.0');
    expect(dep.hosted.name, 'hosted_name');
    expect(dep.hosted.url.toString(), 'hosted_url');
    expect(dep.toString(), 'HostedDependency: ^1.0.0');
  });

  test('map w/ bad version value', () {
    _expectThrows({
      'version': 'not a version',
      'hosted': {'name': 'hosted_name', 'url': 'hosted_url'}
    }, r'''
line 5, column 15: Could not parse version "not a version". Unknown text at "not a version".
  ╷
5 │    "version": "not a version",
  │               ^^^^^^^^^^^^^^^
  ╵''');
  });

  test('map w/ extra keys should fail', () {
    _expectThrows({
      'version': '^1.0.0',
      'hosted': {'name': 'hosted_name', 'url': 'hosted_url'},
      'not_supported': null
    }, r'''
line 10, column 4: Unsupported dependency key.
  ╷
10│    "not_supported": null
  │    ^^^^^^^^^^^^^^^
  ╵''');
  });

  test('map w/ version and hosted as String', () {
    final dep = _dependency<HostedDependency>(
        {'version': '^1.0.0', 'hosted': 'hosted_name'});
    expect(dep.version.toString(), '^1.0.0');
    expect(dep.hosted.name, 'hosted_name');
    expect(dep.hosted.url, isNull);
    expect(dep.toString(), 'HostedDependency: ^1.0.0');
  });

  test('map w/ hosted as String', () {
    final dep = _dependency<HostedDependency>({'hosted': 'hosted_name'});
    expect(dep.version, VersionConstraint.any);
    expect(dep.hosted.name, 'hosted_name');
    expect(dep.hosted.url, isNull);
    expect(dep.toString(), 'HostedDependency: any');
  });

  test('map w/ null hosted should error', () {
    _expectThrows({'hosted': null}, r'''
line 5, column 14: These keys had `null` values, which is not allowed: [hosted]
  ╷
5 │      "hosted": null
  │ ┌──────────────^
6 │ │   }
  │ └──^
  ╵''');
  });

  test('map w/ null version is fine', () {
    final dep = _dependency<HostedDependency>({'version': null});
    expect(dep.version, VersionConstraint.any);
    expect(dep.hosted, isNull);
    expect(dep.toString(), 'HostedDependency: any');
  });
}

void _sdkDependency() {
  test('without version', () {
    final dep = _dependency<SdkDependency>({'sdk': 'flutter'});
    expect(dep.sdk, 'flutter');
    expect(dep.version, isNull);
    expect(dep.toString(), 'SdkDependency: flutter');
  });

  test('with version', () {
    final dep = _dependency<SdkDependency>(
        {'sdk': 'flutter', 'version': '>=1.2.3 <2.0.0'});
    expect(dep.sdk, 'flutter');
    expect(dep.version.toString(), '>=1.2.3 <2.0.0');
    expect(dep.toString(), 'SdkDependency: flutter');
  });

  test('null content', () {
    _expectThrows({'sdk': null}, r'''
line 5, column 11: These keys had `null` values, which is not allowed: [sdk]
  ╷
5 │      "sdk": null
  │ ┌───────────^
6 │ │   }
  │ └──^
  ╵''');
  });

  test('number content', () {
    _expectThrows({'sdk': 42}, r'''
line 5, column 11: Unsupported value for `sdk`.
  ╷
5 │      "sdk": 42
  │ ┌───────────^
6 │ │   }
  │ └──^
  ╵''');
  });
}

void _gitDependency() {
  test('string', () {
    final dep = _dependency<GitDependency>({'git': 'url'});
    expect(dep.url.toString(), 'url');
    expect(dep.path, isNull);
    expect(dep.ref, isNull);
    expect(dep.toString(), 'GitDependency: url@url');
  });

  test('string with version key is ignored', () {
    // Regression test for https://github.com/dart-lang/pubspec_parse/issues/13
    final dep = _dependency<GitDependency>({'git': 'url', 'version': '^1.2.3'});
    expect(dep.url.toString(), 'url');
    expect(dep.path, isNull);
    expect(dep.ref, isNull);
    expect(dep.toString(), 'GitDependency: url@url');
  });

  test('string with user@ URL', () {
    final skipTryParse = Platform.environment.containsKey('TRAVIS');
    if (skipTryParse) {
      print('FYI: not validating git@ URI on travis due to failure');
    }
    final dep = _dependency<GitDependency>({'git': 'git@localhost:dep.git'},
        skipTryPub: skipTryParse);
    expect(dep.url.toString(), 'ssh://git@localhost/dep.git');
    expect(dep.path, isNull);
    expect(dep.ref, isNull);
    expect(dep.toString(), 'GitDependency: url@ssh://git@localhost/dep.git');
  });

  test('string with random extra key fails', () {
    _expectThrows({'git': 'url', 'bob': '^1.2.3'}, r'''
line 6, column 4: Unsupported dependency key.
  ╷
6 │    "bob": "^1.2.3"
  │    ^^^^^
  ╵''');
  });

  test('map', () {
    final dep = _dependency<GitDependency>({
      'git': {'url': 'url', 'path': 'path', 'ref': 'ref'}
    });
    expect(dep.url.toString(), 'url');
    expect(dep.path, 'path');
    expect(dep.ref, 'ref');
    expect(dep.toString(), 'GitDependency: url@url');
  });

  test('git - null content', () {
    _expectThrows({'git': null}, r'''
line 5, column 11: Must be a String or a Map.
  ╷
5 │      "git": null
  │ ┌───────────^
6 │ │   }
  │ └──^
  ╵''');
  });

  test('git - int content', () {
    _expectThrows({'git': 42}, r'''
line 5, column 11: Must be a String or a Map.
  ╷
5 │      "git": 42
  │ ┌───────────^
6 │ │   }
  │ └──^
  ╵''');
  });

  test('git - empty map', () {
    _expectThrows({'git': {}}, r'''
line 5, column 11: Required keys are missing: url.
  ╷
5 │    "git": {}
  │           ^^
  ╵''');
  });

  test('git - null url', () {
    _expectThrows({
      'git': {'url': null}
    }, r'''
line 6, column 12: These keys had `null` values, which is not allowed: [url]
  ╷
6 │       "url": null
  │ ┌────────────^
7 │ │    }
  │ └───^
  ╵''');
  });

  test('git - int url', () {
    _expectThrows({
      'git': {'url': 42}
    }, r'''
line 6, column 12: Unsupported value for `url`.
  ╷
6 │       "url": 42
  │ ┌────────────^
7 │ │    }
  │ └───^
  ╵''');
  });
}

void _pathDependency() {
  test('valid', () {
    final dep = _dependency<PathDependency>({'path': '../path'});
    expect(dep.path, '../path');
    expect(dep.toString(), 'PathDependency: path@../path');
  });

  test('valid with version key is ignored', () {
    final dep =
        _dependency<PathDependency>({'path': '../path', 'version': '^1.2.3'});
    expect(dep.path, '../path');
    expect(dep.toString(), 'PathDependency: path@../path');
  });

  test('valid with random extra key fails', () {
    _expectThrows({'path': '../path', 'bob': '^1.2.3'}, r'''
line 6, column 4: Unsupported dependency key.
  ╷
6 │    "bob": "^1.2.3"
  │    ^^^^^
  ╵''');
  });

  test('null content', () {
    _expectThrows({'path': null}, r'''
line 5, column 12: Must be a String.
  ╷
5 │      "path": null
  │ ┌────────────^
6 │ │   }
  │ └──^
  ╵''');
  });

  test('int content', () {
    _expectThrows({'path': 42}, r'''
line 5, column 12: Must be a String.
  ╷
5 │      "path": 42
  │ ┌────────────^
6 │ │   }
  │ └──^
  ╵''');
  });
}

void _expectThrows(Object content, String expectedError) {
  expectParseThrows({
    'name': 'sample',
    'dependencies': {'dep': content}
  }, expectedError);
}

T _dependency<T extends Dependency>(Object content, {bool skipTryPub = false}) {
  final value = parse({
    'name': 'sample',
    'dependencies': {'dep': content}
  }, skipTryPub: skipTryPub);
  expect(value.name, 'sample');
  expect(value.dependencies, hasLength(1));

  final entry = value.dependencies.entries.single;
  expect(entry.key, 'dep');

  return entry.value as T;
}
