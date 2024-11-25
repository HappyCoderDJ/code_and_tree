import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:code_and_tree/providers/file_provider.dart';

class TreeStructureOption extends StatelessWidget {
  const TreeStructureOption({super.key});

  @override
  Widget build(BuildContext context) {
    final fileProvider = Provider.of<FileProvider>(context);

    return CheckboxListTile(
      title: const Text('Include Directory Tree'),
      value: fileProvider.includeTreeStructure,
      onChanged: (bool? value) {
        if (value != null) {
          fileProvider.setIncludeTreeStructure(value);
        }
      },
    );
  }
}
