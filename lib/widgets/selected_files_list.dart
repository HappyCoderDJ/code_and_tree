import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:code_and_tree/providers/file_provider.dart';

class SelectedFilesList extends StatelessWidget {
  const SelectedFilesList({super.key});

  @override
  Widget build(BuildContext context) {
    final fileProvider = Provider.of<FileProvider>(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selected Files',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: fileProvider.selectedFilesRelativePaths.length,
                itemBuilder: (context, index) {
                  final filePath =
                      fileProvider.selectedFilesRelativePaths[index];
                  return ListTile(
                    dense: true,
                    visualDensity: VisualDensity(vertical: -4),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    leading: Icon(Icons.insert_drive_file,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 16),
                    title: GestureDetector(
                      onTap: () => fileProvider.toggleFileSelection(
                          fileProvider.selectedFilesSorted[index]),
                      child: Text(filePath, style: TextStyle(fontSize: 12)),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () => fileProvider.toggleFileSelection(
                          fileProvider.selectedFilesSorted[index]),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
