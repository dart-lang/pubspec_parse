// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:pub_semver/pub_semver.dart';
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
  "dep": []
         ^^''');
    });

    test('int', () {
      _expectThrows(42, r'''
line 4, column 10: Not a valid dependency value.
  "dep": 42
         ^^^''');
    });

    test('map with too many keys', () {
      _expectThrows({'path': 'a', 'git': 'b'}, r'''
line 5, column 12: Expected only one key.
   "path": "a",
           ^^^''');
    });
  });
}

void _hostedDependency() {
  test('null', () {
    var dep = _dependency<HostedDependency>(null);
    expect(dep.version.toString(), 'any');
    expect(dep.hosted, isNull);
    expect(dep.toString(), 'HostedDependency: any');
  });

  test('empty map', () {
    var dep = _dependency<HostedDependency>({});
    expect(dep.hosted, isNull);
    expect(dep.toString(), 'HostedDependency: any');
  });

  test('string version', () {
    var dep = _dependency<HostedDependency>('^1.0.0');
    expect(dep.version.toString(), '^1.0.0');
    expect(dep.hosted, isNull);
    expect(dep.toString(), 'HostedDependency: ^1.0.0');
  });

  test('bad string version', () {
    _expectThrows('not a version', r'''
line 4, column 10: Could not parse version "not a version". Unknown text at "not a version".
  "dep": "not a version"
         ^^^^^^^^^^^^^^^''');
  });

  test('map w/ just version', () {
    var dep = _dependency<HostedDependency>({'version': '^1.0.0'});
    expect(dep.version.toString(), '^1.0.0');
    expect(dep.hosted, isNull);
    expect(dep.toString(), 'HostedDependency: ^1.0.0');
  });

  test('map w/ version and hosted as Map', () {
    var dep = _dependency<HostedDependency>({
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
line 5, column 15: Unsupported value for `version`.
   "version": "not a version",
              ^^^^^^^^^^^^^^^''');
  });

  test('map w/ unsupported keys', () {
    _expectThrows({
      'version': '^1.0.0',
      'hosted': {'name': 'hosted_name', 'url': 'hosted_url'},
      'not_supported': null
    }, r'''
line 4, column 10: Unrecognized keys: [not_supported]; supported keys: [version, hosted]
  "dep": {
         ^^''');
  });

  test('map w/ version and hosted as String', () {
    var dep = _dependency<HostedDependency>(
        {'version': '^1.0.0', 'hosted': 'hosted_name'});
    expect(dep.version.toString(), '^1.0.0');
    expect(dep.hosted.name, 'hosted_name');
    expect(dep.hosted.url, isNull);
    expect(dep.toString(), 'HostedDependency: ^1.0.0');
  });

  test('map w/ hosted as String', () {
    var dep = _dependency<HostedDependency>({'hosted': 'hosted_name'});
    expect(dep.version, VersionConstraint.any);
    expect(dep.hosted.name, 'hosted_name');
    expect(dep.hosted.url, isNull);
    expect(dep.toString(), 'HostedDependency: any');
  });

  test('map w/ null hosted should error', () {
    _expectThrows({'hosted': null}, r'''
line 5, column 14: These keys had `null` values, which is not allowed: [hosted]
   "hosted": null
             ^^^^^''');
  });

  test('map w/ null version is fine', () {
    var dep = _dependency<HostedDependency>({'version': null});
    expect(dep.version, VersionConstraint.any);
    expect(dep.hosted, isNull);
    expect(dep.toString(), 'HostedDependency: any');
  });
}

void _sdkDependency() {
  test('SdkDependency without version', () {
    var dep = _dependency<SdkDependency>({'sdk': 'flutter'});
    expect(dep.sdk, 'flutter');
    expect(dep.version, isNull);
    expect(dep.toString(), 'SdkDependency: flutter');
  });

  test('SdkDependency with version', () {
    var dep = _dependency<SdkDependency>(
        {'sdk': 'flutter', 'version': '>=1.2.3 <2.0.0'});
    expect(dep.sdk, 'flutter');
    expect(dep.version.toString(), '>=1.2.3 <2.0.0');
    expect(dep.toString(), 'SdkDependency: flutter');
  });
}

void _gitDependency() {
  test('GitDependency - string', () {
    var dep = _dependency<GitDependency>({'git': 'url'});
    expect(dep.url.toString(), 'url');
    expect(dep.path, isNull);
    expect(dep.ref, isNull);
    expect(dep.toString(), 'GitDependency: url@url');
  });

  test('GitDependency - map', () {
    var dep = _dependency<GitDependency>({
      'git': {'url': 'url', 'path': 'path', 'ref': 'ref'}
    });
    expect(dep.url.toString(), 'url');
    expect(dep.path, 'path');
    expect(dep.ref, 'ref');
    expect(dep.toString(), 'GitDependency: url@url');
  });

  test('git - null content', () {
    _expectThrows({'git': null}, r'''
line 5, column 11: Cannot be null.
   "git": null
          ^^^^^''');
  });

  test('git - int content', () {
    _expectThrows({'git': 42}, r'''
line 5, column 11: Must be a String or a Map.
   "git": 42
          ^^^''');
  });

  test('git - empty map', () {
    _expectThrows({'git': {}}, r'''
line 5, column 11: Required keys are missing: url.
   "git": {}
          ^^''');
  });

  test('git - null url', () {
    _expectThrows({
      'git': {'url': null}
    }, r'''
line 6, column 12: These keys had `null` values, which is not allowed: [url]
    "url": null
           ^^^^^''');
  });

  test('git - int url', () {
    _expectThrows({
      'git': {'url': 42}
    }, r'''
line 6, column 12: Unsupported value for `url`.
    "url": 42
           ^^^''');
  });
}

void _pathDependency() {
  test('PathDependency', () {
    var dep = _dependency<PathDependency>({'path': '../path'});
    expect(dep.path, '../path');
    expect(dep.toString(), 'PathDependency: path@../path');
  });

  test('path - null content', () {
    _expectThrows({'path': null}, r'''
line 5, column 12: Cannot be null.
   "path": null
           ^^^^^''');
  });

  test('path - int content', () {
    _expectThrows({'path': 42}, r'''
line 5, column 12: Must be a String.
   "path": 42
           ^^^''');
  });
}

void _expectThrows(Object content, String expectedError) {
  expectParseThrows({
    'name': 'sample',
    'dependencies': {'dep': content}
  }, expectedError);
}

T _dependency<T extends Dependency>(Object content) {
  var value = parse({
    'name': 'sample',
    'dependencies': {'dep': content}
  });
  expect(value.name, 'sample');
  expect(value.dependencies, hasLength(1));

  var entry = value.dependencies.entries.single;
  expect(entry.key, 'dep');

  return entry.value as T;
}
