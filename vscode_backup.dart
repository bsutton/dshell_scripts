#! /usr/bin/env dcli

import 'dart:io';
import 'package:dcli/dcli.dart';
import 'package:path/path.dart';

/// dcli script generated by:
/// dcli create vscode_backup.dart
///
/// See
/// https://pub.dev/packages/dcli#-installing-tab-
///
/// For details on installing dcli.
///

var backupfile = '.vscode_extension.bak';

void main(List<String> args) {
  var parser = ArgParser();
  parser.addCommand('backup');
  var restoreParser = parser.addCommand('restore');
  restoreParser.addFlag('latest', abbr: 'l');
  parser.addCommand('uninstall');

  var result = parser.parse(args);

  if (result.command == null) {
    usage(parser);
    exit(1);
  }

  switch (result.command!.name) {
    case 'backup':
      backup();
      break;

    case 'restore':
      restore(restoreParser, args.sublist(1));
      break;

    case 'uninstall':
      uninstall();
      break;
  }
}

void backup() {
  var extensions = 'code --show-versions --list-extensions'.toList();

  if (exists(backupfile)) {
    if (!confirm('overwrite backupfile: $backupfile?')) {
      exit(1);
    }
    backupfile.truncate();
  }

  for (var extension in extensions) {
    backupfile.append(extension);
  }

  print('extension have been backed up to $backupfile');
}

List<String> getCurrent() {
  return 'code --list-extensions'.toList();
}

void restore(ArgParser parser, List<String> args) {
  if (!exists(backupfile)) {
    print('Unable to find the backupfile ${absolute(backupfile)}');
    print('restore did not complete');
    exit(1);
  }

  var result = parser.parse(args);
  var latest = result['latest'] as bool;

  var extensions = read(backupfile).toList();

  var line = 0;
  for (var extension in extensions) {
    line++;
    var parts = extension.split('@');

    if (parts.length != 2) {
      throw ('The backupfile ${absolute(backupfile)} contains an invalid line ($line) $extension. Expected format is <name>@<version> ');
    }
    var name = parts[0];

    // if (current.contains(name)) {
    //   continue;
    // }

    if (latest) {
      print('removing $name');
      'code --install-extension $name'.run;
    } else {
      'code --install-extension $extension'.run;
    }
  }
}

void uninstall() {
  // Doing a backup is likely to over write the backup
  // with an incorrect list if extensions of the
  // uninstall had previously failed.
  // if (confirm(prompt: 'Would you like to backup your extensions first?')) {
  //   backup();
  // }

  var current = getCurrent();

  var extensions = read(backupfile).toList();

  var retries = <String>[];
  var hasRetries = false;

  do {
    hasRetries = false;
    for (var extension in extensions) {
      var parts = extension.split('@');
      var name = parts[0];
      // var version = parts[1];

      if (!current.contains(name)) {
        print('The extension $name is not installed. Skipping');
      } else {
        try {
          'code --uninstall-extension $name'.run;
        } on RunException catch (e) {
          var msg = e.message;
          if (msg.startsWith('Cannot uninstall extension') &&
              msg.endsWith('depends on this.')) {
            hasRetries = true;
            retries.add(extension);
            print('adding $name to retry list has it has a dependency');
          }
        }
      }
    }
    if (hasRetries) {
      extensions = retries;
      retries.clear();
    }
  } while (hasRetries);
}

void usage(ArgParser parser) {
  print('''Usage: 
  vscode_backup.dart backup
    backups up all your vscode extensions
  vscode_backup.dart restore <--latest>
    restores all your vscode extensions.
    If you pass --latest (or -l) then it will upgrade
    the extension to the latest version as part of the install.
  vscode_backup.dart unistall 
    uninstalls all of your vscode extensions.
  ''');
}
