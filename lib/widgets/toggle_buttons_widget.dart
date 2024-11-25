import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:code_and_tree/providers/file_provider.dart';

class ToggleButtonsWidget extends StatelessWidget {
  const ToggleButtonsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final fileProvider = Provider.of<FileProvider>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            fileProvider.toggleAllExpansion(!fileProvider.allNodesExpanded);
          },
          icon: Icon(fileProvider.allNodesExpanded
              ? Icons.unfold_less
              : Icons.unfold_more),
          label: Text(
              fileProvider.allNodesExpanded ? 'Collapse All' : 'Expand All'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            fileProvider.toggleAllSelection(!fileProvider.allFilesSelected);
          },
          icon: Icon(fileProvider.allFilesSelected
              ? Icons.deselect
              : Icons.select_all),
          label: Text(
              fileProvider.allFilesSelected ? 'Deselect All' : 'Select All'),
        ),
      ],
    );
  }
}
