import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:code_and_tree/providers/file_provider.dart';
import 'package:code_and_tree/models/content_search_result.dart';
import 'package:path/path.dart' as path;

class SearchResultCard extends StatelessWidget {
  final ContentSearchResult result;

  const SearchResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fileProvider = Provider.of<FileProvider>(context);
    final absolutePath = path.join(fileProvider.folderPath, result.filePath);
    final isSelected = fileProvider.isNodeSelected(absolutePath);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () => fileProvider.toggleFileSelection(absolutePath),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.insert_drive_file,
                    color: isSelected ? theme.colorScheme.primary : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result.fileName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? theme.colorScheme.primary : null,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...result.matches.take(3).map((match) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      '${match.lineNumber}행: ${match.matchingLine}',
                      style: theme.textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )),
              if (result.matches.length > 3)
                Text(
                  '... 외 ${result.matches.length - 3}개의 결과',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
