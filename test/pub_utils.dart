// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;
import 'package:test_process/test_process.dart';

Future<ProcResult> tryPub(String content) async {
  await d.file('pubspec.yaml', content).create();

  var proc = await TestProcess.start(_pubPath, ['get', '--offline'],
      workingDirectory: d.sandbox);

  var result = await ProcResult.fromTestProcess(proc);

  printOnFailure([
    '-----BEGIN pub output-----',
    result.toString().trim(),
    '-----END pub output-----',
  ].join('\n'));

  if (result.exitCode == 0) {
    var lockContent =
        new File(p.join(d.sandbox, 'pubspec.lock')).readAsStringSync();

    printOnFailure([
      '-----BEGIN pubspec.lock-----',
      lockContent.trim(),
      '-----END pubspec.lock-----',
    ].join('\n'));
  }

  return result;
}

class ProcResult {
  final int exitCode;
  final List<ProcLine> lines;

  bool get cleanParse => exitCode == 0 || exitCode == 66 || exitCode == 69;

  ProcResult(this.exitCode, this.lines);

  static Future<ProcResult> fromTestProcess(TestProcess proc) async {
    var items = <ProcLine>[];

    var values = await Future.wait([
      proc.exitCode,
      proc
          .stdoutStream()
          .forEach((line) => items.add(new ProcLine(false, line))),
      proc
          .stderrStream()
          .forEach((line) => items.add(new ProcLine(true, line))),
    ]);

    return new ProcResult(values[0] as int, items);
  }

  @override
  String toString() {
    var buffer = new StringBuffer('Exit code: $exitCode');
    for (var line in lines) {
      buffer.write('\n$line');
    }
    return buffer.toString();
  }
}

class ProcLine {
  final bool isError;
  final String line;

  ProcLine(this.isError, this.line);

  @override
  String toString() => '${isError ? 'err' : 'out'}  $line';
}

/// The path to the root directory of the SDK.
final String _sdkDir = (() {
  // The Dart executable is in "/path/to/sdk/bin/dart", so two levels up is
  // "/path/to/sdk".
  var aboveExecutable = p.dirname(p.dirname(Platform.resolvedExecutable));
  assert(FileSystemEntity.isFileSync(p.join(aboveExecutable, 'version')));
  return aboveExecutable;
})();

final String _pubPath =
    p.join(_sdkDir, 'bin', Platform.isWindows ? 'pub.bat' : 'pub');
