![Flutter Chrome](https://firebasestorage.googleapis.com/v0/b/monkey-make-pub.appspot.com/o/Flutter%20Chrome.png?alt=media&token=acdf17f6-bf4a-4023-90a1-a8b116b36cce) 

![Pub Version](https://img.shields.io/pub/v/flutter_chrome) [![GitHub Repo](https://img.shields.io/badge/GitHub-Repo-blue?logo=github)](https://github.com/monkey-make-banana/flutter_chrome)


### 🌐 Use Flutter to develop a Chrome Extension 🌐


## 1️⃣ Installation 

### Choose one of the options for installing this package:

### 🚀 Global Usage

```shell
dart pub global activate flutter_chrome
```
To make it **easier** to use this package across multiple Flutter projects, run the command above. After this one-time setup, the **flutter_chrome** commands will be available across all of your Flutter projects. 

If it doesn't work, you might need to [set up your path](https://dart.dev/tools/pub/cmd/pub-global#running-a-script-from-your-path)

### 📍 Local Usage

```shell
dart pub add dev:flutter_chrome
```
This package will be added to your dev dependencies and can only be used within the Flutter project it was added to. It's ideal for **project-specific** usage.


## 2️⃣ Setup

```shell
# If you did a Global Install
fc_setup

# If you did a Local Install
dart run flutter_chrome:setup
```

- This command prepares your project for Chrome extension development by creating a `chrome/` directory, if it doesn't already exist.
- It automatically generates all the necessary files such as `manifest.json`, `icons`, and `popup.html`.

- If certain files already exist (e.g., `manifest.json`, `index.html`), the setup command only adds the missing files.

The directory structure created by the setup command will look like this:

```shell
chrome
├── icons
│   ├── icon128.png
│   ├── icon16.png
│   ├── icon24.png
│   ├── icon32.png
│   ├── icon48.png
│   ├── icon64.png
│   └── icon96.png
├── manifest.json
└── popup.html
```

## 3️⃣ Build

```shell
# If you did a Global Install
fc_build

# If you did a Local Install 
dart run flutter_chrome:build
```

- This command creates a build that is ready to be used in a Chrome extension and places it in the `build/chrome/` directory. It derives files from the `chrome/` directory, uses the HTML Renderer, and satisfies Content Security Policy (CSP) restrictions.

- Once you create a build, you can test it out in your Chrome browser. Use `build/chrome/` as the extension directory. Learn more about loading and testing your extension [here](https://developer.chrome.com/docs/extensions/mv3/getstarted/development-basics/#load-unpacked)

- Every time you make a change in your code, run the build command again and click the reload button next to the extension in **chrome://extensions** to see the updated changes in your extension.


## 📂 Files

These are the files generated when you run **fc_setup** or **dart run flutter_chrome:setup**.

### 🛠️ manifest.json

**name**, **version**, **description**, and **default_title** fields are all derived from `pubspec.yaml` when generated.

```json
{
  "manifest_version": 3,
  "name": "BananaMania",
  "version": "1.0.0.1",
  "description":"Who doesn't love bananas?",
  "action": {
    "default_popup": "popup.html",
    "default_title": "BananaMania",
    "default_icon": {
      "16": "icons/icon16.png",
      "24": "icons/icon24.png",
      "32": "icons/icon32.png",
      "48": "icons/icon48.png",
      "64": "icons/icon64.png",
      "96": "icons/icon96.png",
      "128": "icons/icon128.png"
    }
  },
  "icons": {
    "16": "icons/icon16.png",
    "24": "icons/icon24.png",
    "32": "icons/icon32.png",
    "48": "icons/icon48.png",
    "64": "icons/icon64.png",
    "96": "icons/icon96.png",
    "128": "icons/icon128.png"
  }
}
```

### 🖼️ Icons 

Generates Icons in sizes: **16x16**, **24x24**, **32x32**, **48x48**, **64x64**, **96x96**, **128x128** in **png** format. Also creates a `favicon.ico` file, which encodes all these image sizes.

### 🔍 popup.html

The window that "pops up" when you click on the extension icon is referred to as a popup. This file ensures that your Flutter code is executed when the popup is activated.

```html
<!DOCTYPE html>
<!-- Size of your Extension -->
<html style="height: 600px; width: 350px">
   <head>
      <!-- Base Configuration -->
      <meta charset="UTF-8">
      <meta content="IE=Edge" http-equiv="X-UA-Compatible">
      <title>BananaMania</title>
      <link rel="manifest" href="manifest.json">
      
      <!-- Favicon -->
      <link rel="icon" type="image/x-icon" href="favicon.ico">
      
      <!-- Main Flutter Code -->
      <script src="main.dart.js" type="application/javascript"></script>
   </head>
   <body></body>
</html>
```

# ❤️ Thanks!

**Thank you** for using **flutter_chrome**. We sincerely hope it simplifies your Chrome extension development. Your feedback and suggestions are always welcome!