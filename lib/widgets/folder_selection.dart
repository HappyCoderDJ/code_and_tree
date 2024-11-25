import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:code_and_tree/providers/file_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

class FolderSelection extends StatelessWidget {
  const FolderSelection({super.key});

  Future<String> _getDefaultDirectory() async {
    final home = Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'] ??
        '';
    final devPath = path.join(home, 'dev');

    // ~/dev 폴더가 존재하는지 확인
    if (await Directory(devPath).exists()) {
      return devPath;
    }

    // ~/dev가 없으면 홈 디렉토리 반환
    return home;
  }

  @override
  Widget build(BuildContext context) {
    final fileProvider = Provider.of<FileProvider>(context);

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: TextEditingController(text: fileProvider.folderPath),
            decoration: const InputDecoration(
              hintText: 'Selected Folder',
              prefixIcon: Icon(Icons.folder_open),
            ),
            readOnly: true,
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: fileProvider.isSelectingFolder
              ? null
              : () async {
                  fileProvider.startFolderSelection();
                  final defaultDir = await _getDefaultDirectory();

                  String? result = await FilePicker.platform.getDirectoryPath(
                    initialDirectory: defaultDir,
                  );

                  if (result != null) {
                    await fileProvider.setFolderPath(result);
                  } else {
                    fileProvider.setFolderPath(fileProvider.folderPath);
                  }
                },
          icon: const Icon(Icons.folder),
          label: const Text('Browse'),
        ),
      ],
    );
  }
}
