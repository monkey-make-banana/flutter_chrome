import 'dart:io';
import 'package:test/test.dart';

void main() {
  test('setup.dart', () async {
    // Delete the 'chrome' directory to start fresh
    final chromeDir = Directory('example/chrome');
    if (chromeDir.existsSync()) {
      chromeDir.deleteSync(recursive: true);
    }

    // Delete the 'build/chrome' directory to start fresh
    final buildChromeDir = Directory('example/build/chrome');
    if (buildChromeDir.existsSync()) {
      buildChromeDir.deleteSync(recursive: true);
    }

    // Run the setup.dart script
    var process = await Process.start('dart', ['../bin/setup.dart'],
        workingDirectory: 'example');

    // Simulating user input that they do have an icon, and then providing the path to the icon
    process.stdin.writeln('y');
    process.stdin.writeln('assets/banana.png');

    // Check that the script completed successfully
    var result = await process.exitCode;
    expect(result, equals(0));

    const directory = 'example/chrome';

    // Check that the icons directory was created
    var dir = Directory('$directory/icons');
    expect(await dir.exists(), isTrue);

    // Check that each size of the icon was created
    var sizes = [16, 24, 32, 48, 64, 96, 128];
    for (var size in sizes) {
      var file = File('$directory/icons/icon$size.png');
      expect(await file.exists(), isTrue);
    }

    // Check that the favicon.ico file was created
    var file = File('$directory/favicon.ico');
    expect(await file.exists(), isTrue);

    // Check that the manifest.json file was created
    file = File('$directory/manifest.json');
    expect(await file.exists(), isTrue);

    // Check that the popup.html file was created
    file = File('$directory/popup.html');
    expect(await file.exists(), isTrue);
  });

  test('build.dart', () async {
    // Run the build.dart script
    var process = await Process.start('dart', ['../bin/build.dart'],
        workingDirectory: 'example');
    var result = await process.exitCode;

    // Check that the script completed successfully.
    expect(result, equals(0));

    const directory = 'example/build/chrome';

    // Check that the icons directory was created
    var dir = Directory('$directory/icons');
    expect(await dir.exists(), isTrue);

    // Check that each size of the icon was created
    var sizes = [16, 24, 32, 48, 64, 96, 128];
    for (var size in sizes) {
      var file = File('$directory/icons/icon$size.png');
      expect(await file.exists(), isTrue);
    }

    // Check that the favicon.ico file was created
    var file = File('$directory/favicon.ico');
    expect(await file.exists(), isTrue);

    // Check that the manifest.json file was created
    file = File('$directory/manifest.json');
    expect(await file.exists(), isTrue);

    // Check that the popup.html file was created
    file = File('$directory/popup.html');
    expect(await file.exists(), isTrue);

    // Check that the main.dart.js file was created
    file = File('$directory/main.dart.js');
    expect(await file.exists(), isTrue);
  });
}
