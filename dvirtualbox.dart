#! /usr/bin/env dshell

import 'dart:io';
import 'package:dshell/dshell.dart';

/// dshell script generated by:
/// dshell create dvirtualbox.dart
/// 
/// See 
/// https://pub.dev/packages/dshell#-installing-tab-
/// 
/// For details on installing dshell.
/// 

void main() {
  'sudo modprobe vboxdrv'.run;
  'virtualbox'.start(detached: true);
}
