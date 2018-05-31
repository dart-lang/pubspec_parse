// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

export 'src/dependency.dart'
    show
        Dependency,
        HostedDependency,
        GitDependency,
        SdkDependency,
        PathDependency;
export 'src/errors.dart' show ParsedYamlException;
export 'src/functions.dart' show parsePubspec;
export 'src/pubspec.dart' show Pubspec;
