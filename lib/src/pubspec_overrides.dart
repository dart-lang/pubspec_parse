// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:checked_yaml/checked_yaml.dart';
import 'package:json_annotation/json_annotation.dart';

import 'dependency.dart';

part 'pubspec_overrides.g.dart';

@JsonSerializable()
class PubspecOverrides {
  @JsonKey(fromJson: parseDeps)
  final Map<String, Dependency> dependencyOverrides;

  PubspecOverrides({Map<String, Dependency>? dependencyOverrides})
      : dependencyOverrides = dependencyOverrides ?? const {};

  factory PubspecOverrides.fromJson(Map json, {bool lenient = false}) {
    if (lenient) {
      while (json.isNotEmpty) {
        // Attempting to remove top-level properties that cause parsing errors.
        try {
          return _$PubspecOverridesFromJson(json);
        } on CheckedFromJsonException catch (e) {
          if (e.map == json && json.containsKey(e.key)) {
            json = Map.from(json)..remove(e.key);
            continue;
          }
          rethrow;
        }
      }
    }

    return _$PubspecOverridesFromJson(json);
  }

  /// Parses source [yaml] into [PubspecOverrides].
  ///
  /// When [lenient] is set, top-level property-parsing or type cast errors are
  /// ignored and `null` values are returned.
  factory PubspecOverrides.parse(
    String yaml, {
    Uri? sourceUrl,
    bool lenient = false,
  }) =>
      checkedYamlDecode(
        yaml,
        (map) => PubspecOverrides.fromJson(map!, lenient: lenient),
        sourceUrl: sourceUrl,
      );
}
