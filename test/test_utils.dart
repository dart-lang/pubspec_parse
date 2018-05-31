// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:test/test.dart';

String _encodeJson(Object input) =>
    const JsonEncoder.withIndent(' ').convert(input);

Matcher _throwsParsedYamlException(String prettyValue) => throwsA(allOf(
    const isInstanceOf<ParsedYamlException>(),
    new FeatureMatcher<ParsedYamlException>('formatMessage', (e) {
      var message = e.formatMessage;
      printOnFailure("r'''\n$message'''");
      if (e.innerStack != null) {
        printOnFailure(Trace.format(e.innerStack, terse: true));
      }
      return message;
    }, prettyValue)));

Pubspec parse(Object content) => parsePubspec(_encodeJson(content));

void expectParseThrows(Object content, String expectedError) =>
    expect(() => parse(content), _throwsParsedYamlException(expectedError));

// TODO(kevmoo) add this to pkg/matcher – is nice!
class FeatureMatcher<T> extends CustomMatcher {
  final dynamic Function(T value) _feature;

  FeatureMatcher(String name, this._feature, matcher)
      : super('`$name`', '`$name`', matcher);

  @override
  featureValueOf(covariant T actual) => _feature(actual);
}
