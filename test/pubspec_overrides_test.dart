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
  some_other_package:
    git:
      url: git@github.com:org/some_other_package
      ref: some-branch
''';
    final pubspecOverrides = PubspecOverrides.parse(yaml);
    expect(pubspecOverrides.dependencyOverrides.length, 2);
    final dependency1 = pubspecOverrides.dependencyOverrides.entries.first;
    expect(dependency1.key, 'transmogrify');
    expect(dependency1.value, isA<HostedDependency>());
    expect((dependency1.value as HostedDependency).version, Version(3, 2, 1));

    final dependency2 = pubspecOverrides.dependencyOverrides.entries.last;
    expect(dependency2.key, 'some_other_package');
    expect(dependency2.value, isA<GitDependency>());
    expect(
      (dependency2.value as GitDependency).url.toString(),
      'ssh://git@github.com/org/some_other_package',
    );
    expect((dependency2.value as GitDependency).ref, 'some-branch');
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
