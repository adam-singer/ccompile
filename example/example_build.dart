library example_build;

import 'dart:io';
import 'dart:mirrors';
import 'package:ccompile/ccompile.dart';

void main() {
  var projectPath = Utils.toAbsolutePath('../example/sample_extension.yaml');
  Utils.buildProject(projectPath, {
    'start': 'Building project "$projectPath"',
    'success': 'Building complete successfully',
    'error': 'Building complete with some errors'})
    .then((exitCode) {});
}

class Utils {
  static Future<int> buildProject(projectPath, Map messages) {
    var workingDirectory = new Path.fromNative(projectPath).directoryPath.toNativePath();
    return new Future.immediate(null).chain((_) {
      var message = messages['start'];
      if(!message.isEmpty) {
        Utils.writeString(message, stdout);
      }

      var builder = new ProjectBuilder();
      return builder.loadProject(projectPath).chain((project) {
        return builder.buildAndClean(project, workingDirectory).chain((result) {
          if(result.exitCode == 0) {
            var message = messages['success'];
            if(!message.isEmpty) {
              Utils.writeString(message, stdout);
            }
          } else {
            var message = messages['error'];
            if(!message.isEmpty) {
              Utils.writeString(message, stdout);
            }

            Utils.writeString(result.stdout, stdout);
            Utils.writeString(result.stderr, stderr);
          }

          return new Future.immediate(result.exitCode == 0 ? 0 : -1);
        });
      });
    });
  }

  static String toAbsolutePath(String path) {
    return new Path.fromNative(Utils.getRootScriptDirectory()).join
        (new Path.fromNative(path)).toNativePath();
  }

  static String newline = Platform.operatingSystem == 'windows' ? '\r\n' : '\n';

  static void writeString(String string, OutputStream stream) {
    stream.writeString('$string$newline');
  }

  static String getRootScriptDirectory() {
    var reflection = currentMirrorSystem();
    var file = reflection.isolate.rootLibrary.url;
    if(Platform.operatingSystem == 'windows') {
      file = file.replaceAll('file:///', '');
    } else {
      file = file.replaceAll('file://', '');
    }

    return new Path.fromNative(file).directoryPath.toNativePath();
  }
}
