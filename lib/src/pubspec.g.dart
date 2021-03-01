// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: deprecated_member_use_from_same_package, lines_longer_than_80_chars, prefer_expression_function_bodies

part of 'pubspec.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pubspec _$PubspecFromJson(Map json) {
  return $checkedNew('Pubspec', json, () {
    $checkKeys(json,
        requiredKeys: const ['name'], disallowNullValues: const ['name']);
    final val = Pubspec(
      $checkedConvert(json, 'name', (v) => v as String),
      version: $checkedConvert(
          json, 'version', (v) => _versionFromString(v as String?)),
      publishTo: $checkedConvert(json, 'publish_to', (v) => v as String?),
      author: $checkedConvert(json, 'author', (v) => v as String?),
      authors: $checkedConvert(json, 'authors',
          (v) => (v as List<dynamic>?)?.map((e) => e as String).toList()),
      environment: $checkedConvert(
          json, 'environment', (v) => _environmentMap(v as Map?)),
      homepage: $checkedConvert(json, 'homepage', (v) => v as String?),
      repository: $checkedConvert(
          json, 'repository', (v) => v == null ? null : Uri.parse(v as String)),
      issueTracker: $checkedConvert(json, 'issue_tracker',
          (v) => v == null ? null : Uri.parse(v as String)),
      documentation:
          $checkedConvert(json, 'documentation', (v) => v as String?),
      description: $checkedConvert(json, 'description', (v) => v as String?),
      dependencies:
          $checkedConvert(json, 'dependencies', (v) => parseDeps(v as Map?)),
      devDependencies: $checkedConvert(
          json, 'dev_dependencies', (v) => parseDeps(v as Map?)),
      dependencyOverrides: $checkedConvert(
          json, 'dependency_overrides', (v) => parseDeps(v as Map?)),
      flutter: $checkedConvert(
          json,
          'flutter',
          (v) => (v as Map?)?.map(
                (k, e) => MapEntry(k as String, e),
              )),
    );
    return val;
  }, fieldKeyMap: const {
    'publishTo': 'publish_to',
    'issueTracker': 'issue_tracker',
    'devDependencies': 'dev_dependencies',
    'dependencyOverrides': 'dependency_overrides'
  });
}
