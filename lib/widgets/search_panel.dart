import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:code_and_tree/providers/file_provider.dart';
import 'package:code_and_tree/widgets/file_tree_view.dart';
import 'package:code_and_tree/widgets/content_search_results_view.dart';
import 'package:code_and_tree/models/content_search_result.dart';
import 'package:path/path.dart' as path;

class SearchPanel extends StatefulWidget {
  const SearchPanel({super.key});

  @override
  State<SearchPanel> createState() => _SearchPanelState();
}

class _SearchPanelState extends State<SearchPanel> {
  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fileProvider = Provider.of<FileProvider>(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              DropdownButton<String>(
                value: fileProvider.searchType,
                items: const [
                  DropdownMenuItem(value: '파일명', child: Text('파일명')),
                  DropdownMenuItem(value: '내용', child: Text('내용')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    fileProvider.updateSearchType(value);
                    searchController.clear();
                  }
                },
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Focus(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: '${fileProvider.searchType} 검색',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                searchController.clear();
                                if (fileProvider.searchType == '파일명') {
                                  fileProvider.updateSearchQuery('');
                                } else {
                                  fileProvider.updateContentSearchQuery('');
                                }
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      if (fileProvider.searchType == '파일명') {
                        fileProvider.updateSearchQuery(value);
                      } else {
                        fileProvider.updateContentSearchQuery(value);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: fileProvider.searchType == '파일명'
              ? const FileTreeView()
              : const ContentSearchResultsView(),
        ),
      ],
    );
  }
}

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
