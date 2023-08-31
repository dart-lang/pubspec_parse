import 'package:checked_yaml/checked_yaml.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/src/dependency.dart';
import 'package:pubspec_parse/src/pubspec_overrides.dart';
import 'package:test/test.dart';

void main() {
  test('Parsing pubspec_overrides.yaml', () {
    const yaml = '''
dependency_overrides:
  transmogrify: '3.2.1'
''';
    final pubspecOverrides = PubspecOverrides.parse(yaml);
    expect(pubspecOverrides.dependencyOverrides.length, 1);
    final dependency = pubspecOverrides.dependencyOverrides.entries.first;
    expect(dependency.key, 'transmogrify');
    expect(dependency.value, HostedDependency(version: Version(3, 2, 1)));
  });

  test('Parsing pubspec_overrides.yaml in lenient mode', () {
    const yaml = '''
dependency_overrides: true
''';
    expect(
      () => PubspecOverrides.parse(yaml),
      throwsA(isA<ParsedYamlException>()),
    );

    expect(
      PubspecOverrides.parse(yaml, lenient: true).dependencyOverrides.length,
      0,
    );
  });
}
