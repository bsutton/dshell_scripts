#! /usr/bin/env dshell

import 'dart:io';
import 'package:dshell/dshell.dart';

/// dshell script generated by:
/// dshell create editor.dart
/// 
/// See 
/// https://pub.dev/packages/dshell#-installing-tab-
/// 
/// For details on installing dshell.
/// 

void main() {
	//'vi'.run;

Process.run('vi', []).then((result) {
  stdout.write(result.stdout);
  stderr.write(result.stderr);
});
}
