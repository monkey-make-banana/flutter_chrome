import 'dart:io';
import 'package:args/args.dart';
import 'package:io/io.dart';
import 'dart:convert';

Future<void> main(List<String> arguments) async {
  // Accept arguments from user
  final parser = ArgParser.allowAnything();

  // Parse the arguments
  var argResults = parser.parse(arguments);
  List<String> flags = [];

  // Loop through all arguments
  for (var arg in argResults.arguments) {
    if (arg.startsWith('--')) {
      // It's a flag, extract it
      var parts = arg.split('=');
      var flag = parts[0]; // The flag name
      flags.add(flag); // Add the flag name

      if (parts.length > 1) {
        var value = parts[1]; // The flag's value if available
        flags.add(value); // Add the value
      }
    }
  }

  // Path to the output directory
  const outputDirectory = 'build/chrome';

  // Paths to the temporary, source, and build directories
  var tempDirName = 'web_original';
  const sourceDirName = 'chrome';
  const buildDirName = 'web';

  // Create instances of the temporary, source, and build directories
  var tempDir = Directory(tempDirName);
  final sourceDir = Directory(sourceDirName);
  final buildDir = Directory(buildDirName);

  // Check if the 'chrome' directory exists
  if (!sourceDir.existsSync()) {
    stdout.write(
        'Chrome directory does not exist. Did you do "fc_setup" or "dart run flutter_chrome:setup" first?\n');
    return;
  }

  // Check if the 'lib' directory exists
  if (!Directory('lib').existsSync()) {
    stdout.write(
        'lib directory does not exist. Please run this command from the root of your project.\n');
    return;
  }

  while (tempDir.existsSync()) {
    tempDirName = '${tempDirName}_';
    tempDir = Directory(tempDirName);
  }

  // Back up the current 'web' directory
  if (buildDir.existsSync()) {
    await buildDir.rename(tempDirName);
    var hiddenFile = File('$tempDirName/what_is_this.txt');

    hiddenFile.writeAsStringSync('''
You're viewing the original 'web' folder, temporarily renamed to 'web_original' by flutter_chrome to facilitate the Chrome extension build process. 
If you're seeing this, it seems there was an issue with the build. To resolve it:

1. Compare the contents of 'web/' and 'chrome/' folders. If they're identical:
   - Delete the 'web/' folder.
   - Rename this folder 'web_original/' back to 'web'.

2. Once resolved, please remove this file.

We apologize for the inconvenience and thank you for using flutter_chrome!
''');
  }

  // Copy contents from 'chrome' to 'web'
  await copyPath(sourceDirName, buildDirName);

  // Renaming File
  var currentPath = '$buildDirName/popup.html';
  var newPath = '$buildDirName/index.html';

  // Create a File instance for the current file
  var file = File(currentPath);

  // Check if the file exists
  if (await file.exists()) {
    // Rename the file
    await file.rename(newPath);
  } else {
    stdout.write('Error: popup.html file does not exist');
  }

  // Run 'flutter build web --web-renderer html --csp --output=build/chrome' in addition to user's flags
  final process = await Process.start(
    'flutter',
    [
      'build',
      'web',
      '--web-renderer',
      'html',
      '--csp',
      '--output=$outputDirectory',
      ...flags,
    ],
    runInShell: true,
  );

  // Pipe stdout and stderr to stdout
  process.stdout.transform(utf8.decoder).listen((data) {
    data = data.replaceAll('Compiling lib/main.dart for the Web...',
        "\u{1F6E0}\u{FE0F} Compiling lib/main.dart for a Chrome Extension \u{1F6E0}\u{FE0F}");
    stdout.write(data);
  });

  // Pipe stderr to stdout
  bool isError = false;
  process.stderr.transform(utf8.decoder).listen((data) {
    stdout.write('$data');
    isError = true;
  });

  // Wait for the process to complete
  await process.exitCode;

  // Restore the original 'web' directory`
  if (tempDir.existsSync()) {
    await deleteDirectory(buildDir);
    tempDir.renameSync(buildDirName);
    var file = File('$buildDirName/what_is_this.txt');
    if (file.existsSync()) {
      file.deleteSync();
    }
  }

  // Stops script if there was an error
  if (isError) {
    return;
  }

  // Setups up paths for renaming files
  currentPath = 'build/$sourceDirName/index.html';
  newPath = 'build/$sourceDirName/popup.html';
  file = File(currentPath);

  // Check if the file exists
  if (await file.exists()) {
    // Rename the file
    await file.rename(newPath);
  } else {
    stdout.write('Error: popup.html file does not exist');
  }
  if (exitCode != 0) {
    stdout.write('Build failed with exit code $exitCode');
  }
}

// Copy a directory from one location to another
Future<void> copyDirectory(Directory source, Directory destination) async {
  await for (var entity in source.list(recursive: false)) {
    if (entity is File) {
      File newFile =
          File('${destination.path}/${entity.uri.pathSegments.last}');
      await newFile.create(recursive: true);
      await entity.copy(newFile.path);
    } else if (entity is Directory) {
      Directory newDirectory =
          Directory('${destination.path}/${entity.uri.pathSegments.last}');
      await copyDirectory(entity, newDirectory);
    }
  }
}

// Delete a directory
Future<void> deleteDirectory(Directory dir) async {
  if (dir.existsSync()) {
    await dir.delete(recursive: true);
  }
}
