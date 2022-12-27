[![Dart CI](https://github.com/dart-lang/pubspec_parse/actions/workflows/test-package.yml/badge.svg)](https://github.com/dart-lang/pubspec_parse/actions/workflows/test-package.yml)
[![pub package](https://img.shields.io/pub/v/pubspec_parse.svg)](https://pub.dev/packages/pubspec_parse)
[![package publisher](https://img.shields.io/pub/publisher/pubspec_parse.svg)](https://pub.dev/packages/pubspec_parse/publisher)

## What's this?

Supports parsing `pubspec.yaml` files with robust error reporting and support
for most of the documented features.

## How to use

Add the `pubspec.yaml` file to your assets in the `pubspec.yaml` file itself:

```
...
flutter:
  assets:
    [some other assets]
    - pubspec.yaml
```

Then read it and parse it:

```
var pubspecRaw = await rootBundle.loadString("pubspec.yaml");
var pubspec = Pubspec.parse(pubspecRaw);
```

## More information

Read more about the [pubspec format](https://dart.dev/tools/pub/pubspec).
