// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:cli';
import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:test/test.dart';

import 'pub_utils.dart';

String _encodeJson(Object input) =>
    const JsonEncoder.withIndent(' ').convert(input);

Matcher _throwsParsedYamlException(String prettyValue) =>
    throwsA(const TypeMatcher<ParsedYamlException>().having((e) {
      var message = e.formattedMessage;
      printOnFailure("Actual error format:\nr'''\n$message'''");
      _printDebugParsedYamlException(e);
      return message;
    }, 'formattedMessage', prettyValue));

void _printDebugParsedYamlException(ParsedYamlException e) {
  var innerError = e.innerError;
  var innerStack = e.innerStack;

  if (e.innerError is CheckedFromJsonException) {
    var cfje = e.innerError as CheckedFromJsonException;
    if (cfje.innerError != null) {
      innerError = cfje.innerError;
      innerStack = cfje.innerStack;
    }
  }

  if (innerError != null) {
    var items = [innerError];
    if (innerStack != null) {
      items.add(Trace.format(innerStack, terse: true));
    }

    var content =
        LineSplitter.split(items.join('\n')).map((e) => '  $e').join('\n');

    printOnFailure('Inner error details:\n$content');
  }
}

Pubspec parse(Object content, {bool quietOnError = false}) {
  quietOnError ??= false;

  var encoded = _encodeJson(content);

  var pubResult = waitFor(tryPub(encoded));

  try {
    var value = new Pubspec.parse(encoded);

    addTearDown(() {
      expect(pubResult.cleanParse, isTrue,
          reason:
              'On success, parsing from the pub client should also succeed.');
    });
    return value;
  } catch (e) {
    addTearDown(() {
      expect(pubResult.cleanParse, isFalse,
          reason: 'On failure, parsing from the pub client should also fail.');
    });
    if (e is ParsedYamlException) {
      if (!quietOnError) {
        _printDebugParsedYamlException(e);
      }
    }
    rethrow;
  }
}

void expectParseThrows(Object content, String expectedError) => expect(
    () => parse(content, quietOnError: true),
    _throwsParsedYamlException(expectedError));
