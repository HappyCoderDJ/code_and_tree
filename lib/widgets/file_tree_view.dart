import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:code_and_tree/providers/file_provider.dart';
import 'package:flutter_treeview/flutter_treeview.dart';

class FileTreeView extends StatefulWidget {
  const FileTreeView({super.key});

  @override
  State<FileTreeView> createState() => _FileTreeViewState();
}

class _FileTreeViewState extends State<FileTreeView> {
  @override
  Widget build(BuildContext context) {
    final fileProvider = Provider.of<FileProvider>(context);
    final theme = Theme.of(context);

    final controller = TreeViewController(children: fileProvider.treeNodes);

    return TreeView(
      controller: controller,
      onNodeTap: (key) {
        fileProvider.toggleFileSelection(key);
      },
      theme: TreeViewTheme(
        expanderTheme: const ExpanderThemeData(
          type: ExpanderType.chevron,
          size: 20,
          color: Colors.grey,
        ),
      ),
      nodeBuilder: (context, node) {
        bool isSelected = fileProvider.isNodeSelected(node.key);
        return Container(
          decoration: isSelected
              ? BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                )
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 4.0),
            child: Row(
              children: [
                Icon(
                  node.isLeaf ? Icons.insert_drive_file : Icons.folder,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: _highlightSearchText(
                      node.label,
                      fileProvider.searchQuery,
                      theme,
                      isSelected: isSelected,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  TextSpan _highlightSearchText(
    String text,
    String query,
    ThemeData theme, {
    bool isSelected = false,
  }) {
    if (query.isEmpty) {
      return TextSpan(
        text: text,
        style: TextStyle(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      );
    }

    List<TextSpan> spans = [];
    String lowerText = text.toLowerCase();
    String lowerQuery = query.toLowerCase();
    int start = 0;

    while (true) {
      int index = lowerText.indexOf(lowerQuery, start);
      if (index == -1) {
        if (start < text.length) {
          spans.add(TextSpan(
            text: text.substring(start),
            style: TextStyle(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ));
        }
        break;
      }

      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: TextStyle(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ));
      }

      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.3),
        ),
      ));

      start = index + query.length;
    }

    return TextSpan(children: spans);
  }
}
