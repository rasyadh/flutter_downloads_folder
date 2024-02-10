import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:downloadsfolder/downloadsfolder.dart';

void main() {
  runApp(const MyExample());
}

class MyExample extends StatelessWidget {
  const MyExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _downloadsfolderPath;
  File? _pickedFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _getDownloadPath,
            child: const Center(
              child: Text('Get Download Path'),
            ),
          ),
          if (_downloadsfolderPath != null)
            Center(
              child: Text('Downloads Folder Path: $_downloadsfolderPath\n'),
            ),
          ElevatedButton(
            onPressed: _pickAFile,
            child: const Center(
              child: Text('Pick a File'),
            ),
          ),
          if (_pickedFile != null)
            Center(
              child: Text('Picked File Path: ${_pickedFile!.path}\n'),
            ),
          if (_pickedFile != null)
            ElevatedButton(
              onPressed: _saveFile,
              child: const Center(
                child: Text('Save Picked File into Downloads Folder'),
              ),
            ),
          ElevatedButton(
            onPressed: _openDownloadFolder,
            child: const Center(
              child: Text('Show Download Folder'),
            ),
          ),
        ],
      ),
    );
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> _getDownloadPath() async {
    String downloadsfolderPath;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      downloadsfolderPath = await getDownloadDirectoryPath() ?? 'Unknown';
    } on PlatformException {
      downloadsfolderPath = 'Failed to get folder path.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _downloadsfolderPath = downloadsfolderPath;
    });
  }

  Future<void> _pickAFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (!mounted) return;

    if (result != null) {
      File file = File(result.files.single.path!);
      setState(() {
        _pickedFile = file;
      });
    } else {
      ScaffoldMessenger.of(this.context).showSnackBar(
        const SnackBar(
          content: Text('No File Has been selected'),
        ),
      );
    }
  }

  Future<void> _saveFile() async {
    bool? success = await copyFileIntoDownloadFolder(
        _pickedFile!.path, basenameWithoutExtension(_pickedFile!.path));

    if (!mounted) return;

    if (success == true) {
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: const Text('File copied successfully.'),
          action: SnackBarAction(
              label: 'Show Download Folder', onPressed: _openDownloadFolder),
        ),
      );
    } else {
      ScaffoldMessenger.of(this.context).showSnackBar(
        const SnackBar(
          content: Text('Failed to copy file.'),
        ),
      );
    }
  }

  Future<void> _openDownloadFolder() => openDownloadFolder();
}
