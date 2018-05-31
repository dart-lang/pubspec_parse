// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:pub_semver/pub_semver.dart';

abstract class Dependency {
  Dependency._();

  factory Dependency.fromJson(dynamic data) {
    if (data == null) {
      return new HostedDependency(VersionConstraint.any);
    } else if (data is String) {
      return new HostedDependency(new VersionConstraint.parse(data));
    } else {
      var mapData = data as Map;

      var path = mapData['path'] as String;
      if (path != null) {
        return new PathDependency(path);
      }

      var git = mapData['git'];
      if (git != null) {
        return new GitDependency.fromData(git);
      }

      final sdk = mapData['sdk'];
      if (sdk != null) {
        return new SdkDependency(sdk);
      }

      throw new ArgumentError.value(
          data, 'data', 'No clue how to deal with `$data`.');
    }
  }

  String get _info;

  @override
  String toString() => '$runtimeType: $_info';
}

class SdkDependency extends Dependency {
  final String name;

  factory SdkDependency(Object data) {
    if (data is String) {
      return new SdkDependency._(data);
    } else {
      throw new ArgumentError.value(
          data, 'data', 'Does not support provided value.');
    }
  }

  SdkDependency._(this.name) : super._();

  @override
  String get _info => name;
}

class GitDependency extends Dependency {
  final Uri url;
  final String ref;
  final String path;

  GitDependency(this.url, this.ref, this.path) : super._();

  factory GitDependency.fromData(Object data) {
    String url;
    String path;
    String ref;

    if (data is String) {
      url = data;
    } else if (data is Map) {
      url = data['url'] as String;
      path = data['path'] as String;
      ref = data['ref'] as String;
    } else {
      throw new ArgumentError.value(
          data, 'data', 'Does not support provided value.');
    }

    return new GitDependency(Uri.parse(url), ref, path);
  }

  @override
  String get _info => 'url@$url';
}

class PathDependency extends Dependency {
  final String path;

  PathDependency(this.path) : super._();

  @override
  String get _info => 'path@$path';
}

// TODO: support explicit host?
class HostedDependency extends Dependency {
  final VersionConstraint constraint;

  HostedDependency(this.constraint) : super._();

  @override
  String get _info => constraint.toString();
}
