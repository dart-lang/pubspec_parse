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
      final message = e.formattedMessage;
      printOnFailure("Actual error format:\nr'''\n$message'''");
      _printDebugParsedYamlException(e);
      return message;
    }, 'formattedMessage', prettyValue));

void _printDebugParsedYamlException(ParsedYamlException e) {
  var innerError = e.innerError;
  var innerStack = e.innerStack;

  if (e.innerError is CheckedFromJsonException) {
    final cfje = e.innerError as CheckedFromJsonException;
    if (cfje.innerError != null) {
      innerError = cfje.innerError;
      innerStack = cfje.innerStack;
    }
  }

  if (innerError != null) {
    final items = [innerError];
    if (innerStack != null) {
      items.add(Trace.format(innerStack, terse: true));
    }

    final content =
        LineSplitter.split(items.join('\n')).map((e) => '  $e').join('\n');

    printOnFailure('Inner error details:\n$content');
  }
}

Pubspec parse(
  Object content, {
  bool quietOnError = false,
  bool skipTryPub = false,
  bool lenient = false,
}) {
  quietOnError ??= false;
  skipTryPub ??= false;
  lenient ??= false;

  final encoded = _encodeJson(content);

  ProcResult pubResult;
  if (!skipTryPub) {
    pubResult = waitFor(tryPub(encoded));
    expect(pubResult, isNotNull);
  }

  try {
    final value = Pubspec.parse(encoded, lenient: lenient);

    if (pubResult != null) {
      addTearDown(() {
        expect(pubResult.cleanParse, isTrue,
            reason:
                'On success, parsing from the pub client should also succeed.');
      });
    }
    return value;
  } catch (e) {
    if (pubResult != null) {
      addTearDown(() {
        expect(pubResult.cleanParse, isFalse,
            reason:
                'On failure, parsing from the pub client should also fail.');
      });
    }
    if (e is ParsedYamlException) {
      if (!quietOnError) {
        _printDebugParsedYamlException(e);
      }
    }
    rethrow;
  }
}

void expectParseThrows(
  Object content,
  String expectedError, {
  bool skipTryPub = false,
}) =>
    expect(() => parse(content, quietOnError: true, skipTryPub: skipTryPub),
        _throwsParsedYamlException(expectedError));
