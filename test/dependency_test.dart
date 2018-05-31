// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:test/test.dart';

import 'test_utils.dart';

void main() {
  test('HostedDepedency', () {
    var dep = _dependency<HostedDependency>('^1.0.0');
    expect(dep.constraint.toString(), '^1.0.0');
    expect(dep.toString(), 'HostedDependency: ^1.0.0');
  });

  test('SdkDependency', () {
    var dep = _dependency<SdkDependency>(
        {'sdk': 'flutter', 'version': '>=1.2.3 <2.0.0'});
    expect(dep.name, 'flutter');
    expect(dep.toString(), 'SdkDependency: flutter');
  });

  test('GitDependency', () {
    var dep = _dependency<GitDependency>({'git': 'bob'});
    expect(dep.url.toString(), 'bob');
    expect(dep.toString(), 'GitDependency: url@bob');
  });

  test('HostedDepedency', () {
    var dep = _dependency<HostedDependency>('^1.0.0');
    expect(dep.constraint.toString(), '^1.0.0');
    expect(dep.toString(), 'HostedDependency: ^1.0.0');
  });

  test('PathDependency', () {
    var dep = _dependency<PathDependency>({'path': '../path'});
    expect(dep.path, '../path');
    expect(dep.toString(), 'PathDependency: path@../path');
  });

  group('errors', () {
    test('GitDependency', () {
      var dep = _dependency<GitDependency>({'git': null});
      //expect(dep.constraint.toString(), '^1.0.0');
      expect(dep.toString(), 'HostedDependency: ^1.0.0');
    });
  }, skip: 'not yet!');
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
