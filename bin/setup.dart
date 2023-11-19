import 'dart:io';
import 'dart:convert';
import 'package:yaml/yaml.dart';
import 'package:image/image.dart';
import 'package:image/src/formats/ico_encoder.dart';

Future<void> main(List<String> arguments) async {
  // Path to the output directory
  const String directoryName = 'chrome';
  final Directory directory = Directory(directoryName);

  // Check if the 'pubspec.yaml' file exists
  if (!File('pubspec.yaml').existsSync()) {
    stdout.write(
        'pubspec.yaml file not found. Please run this command from the root of your project.\n');
    return;
  }

  stdout.write(
      "\u{1F6E0}\u{FE0F} Setting up for Chrome extension development \u{1F6E0}\u{FE0F}\n");

  // Create the 'chrome' directory if it doesn't exist
  try {
    if (!directory.existsSync()) {
      directory.createSync();
      stdout.write('\x1B[32m\u2713\x1B[0m Chrome directory created.\n');
    } else {
      stdout.write('\x1B[33m\u2713\x1B[0m Chrome directory already exists.\n');
    }
  } on Exception {
    stdout.write('Exception: Failed to create directory $directoryName.\n');
    return;
  } on Error {
    stdout.write('Error: Failed to create directory $directoryName.\n');
    return;
  }

  // Retrieve the contents of the pubspec.yaml file
  String content;
  try {
    final File pubspecFile = File('pubspec.yaml');
    content = pubspecFile.readAsStringSync();
  } on Exception {
    stdout.write('Exception: Failed to find pubspec.yaml.\n');
    return;
  } on Error {
    stdout.write('Error: Failed to find pubspec.yaml.\n');
    return;
  }

  // Load the pubspec.yaml file as a YAML document
  var doc = await loadYaml(content);
  int manifestVersion = 3;
  bool createdManifest = false;
  Map<String, dynamic> manifestContent = {};

  // Create the 'manifest.json' file if it doesn't exist
  final File manifestFile = File('${directory.path}/manifest.json');
  try {
    if (manifestFile.existsSync()) {
      stdout
          .write('\x1B[33m\u2713\x1B[0m manifest.json file already exists.\n');
    } else {
      createdManifest = true;
      // stdout.write(
      //     'Enter the manifest version you wish to use (e.g., 2 or 3) (defaults to 3):\n');
      // var manifestVersionInput = stdin.readLineSync()?.trim() ?? '';
      // manifestVersion = int.tryParse(manifestVersionInput) ?? 3;
    }
  } on Exception {
    stdout.write('Exception: Failed to create manifest file.\n');
    return;
  } on Error {
    stdout.write('Error: Failed to create manifest file.\n');
    return;
  }

  // Add base information to the manifest.json file
  if (createdManifest) {
    if (manifestVersion == 3) {
      manifestContent = {
        'manifest_version': manifestVersion,
        'name': doc['name'],
        'version': doc['version'].replaceAll('+', '.'),
        'description': doc['description'],
        "action": {
          "default_popup": "popup.html",
          "default_title": doc['name'],
        },
      };
    } else {
      manifestContent = {
        'manifest_version': manifestVersion,
        'name': doc['name'],
        'version': doc['version'].replaceAll('+', '.'),
        'description': doc['description'],
        'browser_action': {
          'default_popup': 'popup.html',
          'default_title': doc['name'],
        },
      };
    }
  }

  // Ask the user if they have an icon for their extension
  bool createdIcon = false;
  stdout.write(
      'Do you have an icon for your extension? (Don\'t worry if you don\'t, you can run this command again later when you do) (y/N): \n');
  final String iconInput = stdin.readLineSync()?.trim().toLowerCase() ?? '';

  if (iconInput == 'y' || iconInput == 'yes') {
    // Create the icons
    createdIcon = await createIcons();
    if (createdIcon && createdManifest) {
      // Add icons to the manifest.json file
      manifestContent['icons'] = {
        '16': 'icons/icon16.png',
        '24': 'icons/icon24.png',
        '32': 'icons/icon32.png',
        '48': 'icons/icon48.png',
        '64': 'icons/icon64.png',
        '96': 'icons/icon96.png',
        '128': 'icons/icon128.png',
      };
      manifestContent['action'] = {
        "default_popup": "popup.html",
        "default_title": doc['name'],
        "default_icon": {
          '16': 'icons/icon16.png',
          '24': 'icons/icon24.png',
          '32': 'icons/icon32.png',
          '48': 'icons/icon48.png',
          '64': 'icons/icon64.png',
          '96': 'icons/icon96.png',
          '128': 'icons/icon128.png',
        },
      };
    }
  }

  // Create the 'popup.html' file
  createIndexHtml(directory.path, doc['name'], doc['description'], createdIcon);

  // Write the manifest.json file
  const encoder = JsonEncoder.withIndent('  ');
  if (createdManifest) {
    manifestFile.writeAsStringSync(encoder.convert(manifestContent));
    stdout.write('\x1B[32m\u2713\x1B[0m manifest.json file created.\n');
  }

  stdout.write('\u{1F525} Setup complete \u{1F525}\n');
}

// Resolves the path to an absolute path
String resolvePath(String enteredPath) {
  final File path = File(enteredPath);
  return path.absolute.path;
}

// Creates the icons for the extension
Future<bool> createIcons() async {
  Image? image;
  String? iconPath;
  try {
    stdout.write("Enter the path to your icon (enter to skip):\n");
    final String enteredPath = stdin.readLineSync()?.trim() ?? '';
    if (enteredPath.isEmpty || enteredPath.toLowerCase() == 'skip') {
      // The user chose to skip
      return false;
    } else {
      // Resolve the path and proceed
      iconPath = resolvePath(enteredPath);
      image = decodeImage(File(iconPath).readAsBytesSync());
    }
  } on Exception {
    stdout.write('Exception: Failed to find image at path $iconPath.\n');
    return createIcons();
  } on Error {
    stdout.write('Error: Failed to find image at path $iconPath.\n');
    createIcons();
    return createIcons();
  }

  if (image != null) {
    try {
      final Directory iconDirectory = Directory('chrome/icons');
      String iconOverrideInput = 'y';

      // Check if the icons directory already exists
      if (iconDirectory.existsSync()) {
        String iconOverrideInput = 'n';
        stdout.write(
            'Icons directory already exists. Do you wish to override the contents inside that folder?  (y/N) \n');
        iconOverrideInput = stdin.readLineSync()?.trim().toLowerCase() ?? '';
        if (iconOverrideInput == 'y' || iconOverrideInput == 'yes') {
          iconDirectory.deleteSync(recursive: true);
        }
      }

      if (iconOverrideInput == 'y' || iconOverrideInput == 'yes') {
        // Create the icons in all the required sizes
        iconDirectory.createSync();
        const List<int> iconSizes = [16, 24, 32, 48, 64, 96, 128];
        List<Image> faviconImages = [];
        for (int size in iconSizes) {
          final Image resized = copyResize(image, width: size, height: size);
          final String newFileName = 'icon$size.png';
          File('chrome/icons/$newFileName')
              .writeAsBytesSync(encodePng(resized));
          faviconImages.add(decodeImage(
              File('chrome/icons/$newFileName').readAsBytesSync())!);
        }

        // Create the favicon.ico file
        List<int> icoData = IcoEncoder().encodeImages(faviconImages);
        File('chrome/favicon.ico').writeAsBytesSync(icoData);
        stdout.write('\x1B[32m\u2713\x1B[0m Icons created.\n');
        return true;
      } else {
        return false;
      }
    } on Exception {
      stdout.write("Exception: Failed to create icons.\n");
      return false;
    } on Error {
      stdout.write("Error: Failed to create icons.\n");
      return false;
    }
  } else {
    stdout.write('Failed to decode image.');
    return false;
  }
}

// Creates the 'popup.html' file
void createIndexHtml(String directoryPath, String appName,
    String appDescription, bool createdIcon) {
  // Path to the 'popup.html' file
  final String filePath = '$directoryPath/popup.html';

  // HTML content
  const String faviconHtml = '''

      <!-- Favicon -->
      <link rel="icon" type="image/x-icon" href="favicon.ico">
      ''';
  final String htmlContent = '''
<!DOCTYPE html>
<!-- Size of your Extension -->
<html style="height: 600px; width: 350px">
  <head>
    <!-- Base Configuration -->
    <meta charset="UTF-8" />
    <meta content="IE=Edge" http-equiv="X-UA-Compatible" />
    <title>"$appName"</title>
    <link rel="manifest" href="manifest.json" />
    ${createdIcon ? faviconHtml : ""}
    <!-- Main Flutter Code -->
    <script src="main.dart.js" type="application/javascript"></script>
  </head>
  <body></body>
</html>
''';

  // Write the HTML content to popup.html
  if (File(filePath).existsSync()) {
    stdout.write('\x1B[33m\u2713\x1B[0m popup.html file already exists.\n');
  } else {
    File(filePath).writeAsStringSync(htmlContent);
    stdout.write('\x1B[32m\u2713\x1B[0m popup.html file created.\n');
  }
}
