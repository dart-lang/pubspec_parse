// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: deprecated_member_use_from_same_package, lines_longer_than_80_chars, require_trailing_commas, unnecessary_cast

part of 'pubspec_overrides.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PubspecOverrides _$PubspecOverridesFromJson(Map json) => $checkedCreate(
      'PubspecOverrides',
      json,
      ($checkedConvert) {
        final val = PubspecOverrides(
          dependencyOverrides: $checkedConvert(
              'dependency_overrides', (v) => parseDeps(v as Map?)),
        );
        return val;
      },
      fieldKeyMap: const {'dependencyOverrides': 'dependency_overrides'},
    );
