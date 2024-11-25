import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:code_and_tree/providers/file_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:logging/logging.dart';

final _logger = Logger('GenerateButton');

class GenerateButton extends StatelessWidget {
  const GenerateButton({super.key});

  @override
  Widget build(BuildContext context) {
    final fileProvider = Provider.of<FileProvider>(context);

    return ElevatedButton(
      onPressed: fileProvider.selectedFiles.isEmpty
          ? null
          : () async {
              final defaultDirectory = await getDownloadsDirectory();
              final folderName = path.basename(fileProvider.folderPath);
              final now = DateTime.now();
              final timestamp =
                  '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
              final defaultFileName = '${folderName}_$timestamp.txt';

              String? outputPath = await FilePicker.platform.saveFile(
                dialogTitle: 'Save Text File',
                initialDirectory: defaultDirectory,
                fileName: defaultFileName,
                type: FileType.custom,
                allowedExtensions: ['txt'],
              );
              if (outputPath != null) {
                await fileProvider.generateTextFile(outputPath);
              }
            },
      child: const Text('Generate Text File'),
    );
  }
}

Future<String?> getDownloadsDirectory() async {
  try {
    if (Platform.isMacOS || Platform.isLinux) {
      final homeDir = Platform.environment['HOME'];
      if (homeDir != null) {
        return path.join(homeDir, 'Downloads');
      }
    } else if (Platform.isWindows) {
      final userProfile = Platform.environment['USERPROFILE'];
      if (userProfile != null) {
        return path.join(userProfile, 'Downloads');
      }
    }
  } catch (e) {
    // Handle potential errors (e.g., permissions issues)
    _logger.warning('Error getting Downloads directory', e);
  }

  // If Downloads directory isn't found, return null
  return null;
}
