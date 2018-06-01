// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:json_annotation/json_annotation.dart';
import 'package:pub_semver/pub_semver.dart';

abstract class Dependency {
  Dependency._();

  /// Returns `null` if the data could not be parsed.
  factory Dependency.fromJson(dynamic data) {
    if (data == null) {
      return new HostedDependency(VersionConstraint.any);
    } else if (data is String) {
      return new HostedDependency(new VersionConstraint.parse(data));
    } else if (data is Map) {
      try {
        return new Dependency._fromMap(data);
      } on ArgumentError catch (e) {
        throw new CheckedFromJsonException(
            data, e.name, 'Dependency', e.message.toString());
      }
    }

    return null;
  }

  factory Dependency._fromMap(Map data) {
    if (data.entries.isEmpty) {
      // TODO: provide list of supported keys?
      throw new CheckedFromJsonException(
          data, null, 'Dependency', 'Must provide at least one key.');
    }

    if (data.containsKey('sdk')) {
      return new SdkDependency.fromData(data);
    }

    if (data.entries.length > 1) {
      throw new CheckedFromJsonException(
          data,
          data.keys.skip(1).first as String,
          'Dependency',
          'Expected only one key.');
    }

    var entry = data.entries.single;
    var key = entry.key as String;

    if (entry.value == null) {
      throw new CheckedFromJsonException(
          data, key, 'Dependency', 'Cannot be null.');
    }

    switch (key) {
      case 'path':
        return new PathDependency.fromData(entry.value);
      case 'git':
        return new GitDependency.fromData(entry.value);
    }

    return null;
  }

  String get _info;

  @override
  String toString() => '$runtimeType: $_info';
}

class SdkDependency extends Dependency {
  final String name;
  final VersionConstraint version;

  SdkDependency(this.name, {this.version}) : super._();

  factory SdkDependency.fromData(Map data) {
    VersionConstraint version;
    if (data.containsKey('version')) {
      version = new VersionConstraint.parse(data['version'] as String);
    }
    return new SdkDependency(data['sdk'] as String, version: version);
  }

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
      throw new ArgumentError.value(data, 'git', 'Must be a String or a Map.');
    }

    // TODO: validate `url` is a valid URI
    return new GitDependency(Uri.parse(url), ref, path);
  }

  @override
  String get _info => 'url@$url';
}

class PathDependency extends Dependency {
  final String path;

  PathDependency(this.path) : super._();

  factory PathDependency.fromData(Object data) {
    if (data is String) {
      return new PathDependency(data);
    }
    throw new ArgumentError.value(data, 'path', 'Must be a String.');
  }

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
