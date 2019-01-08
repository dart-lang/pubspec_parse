## 0.1.4

- Added `lenient` named argument to `Pubspec.fromJson` to ignore format and type errors. 

## 0.1.3

- Added support for `flutter`, `issue_tracker`, `publish_to`, and `repository`
  fields.

## 0.1.2+3

- Support the latest version of `package:json_annotation`.

## 0.1.2+2

- Support `package:json_annotation` v1.

## 0.1.2+1

- Support the Dart 2 stable release.

## 0.1.2

- Allow superfluous `version` keys with `git` and `path` dependencies.
- Improve errors when unsupported keys are provided in dependencies.
- Provide better errors with invalid `sdk` dependency values.
- Support "scp-like syntax" for Git SSH URIs in the form
  `[user@]host.xz:path/to/repo.git/`.

## 0.1.1

- Fixed name collision with error type in latest `package:json_annotation`.
- Improved parsing of hosted dependencies and environment constraints.

## 0.1.0

- Initial release.
