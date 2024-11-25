import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:code_and_tree/providers/file_provider.dart';

class SearchFiltersView extends StatefulWidget {
  const SearchFiltersView({super.key});

  @override
  State<SearchFiltersView> createState() => _SearchFiltersViewState();
}

class _SearchFiltersViewState extends State<SearchFiltersView> {
  final TextEditingController _extensionController = TextEditingController();
  final TextEditingController _pathController = TextEditingController();

  @override
  void dispose() {
    _extensionController.dispose();
    _pathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fileProvider = Provider.of<FileProvider>(context);
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.filter_list),
          const SizedBox(width: 8),
          const Text('검색 필터'),
          const Spacer(),
          TextButton(
            onPressed: () {
              fileProvider.clearFilters();
              Navigator.of(context).pop();
            },
            child: const Text('필터 초기화'),
          ),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 검색 옵션
            Text(
              '검색 옵션',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('대소문자 구분'),
                  selected: fileProvider.caseSensitive,
                  onSelected: (bool value) {
                    fileProvider.toggleCaseSensitive();
                  },
                ),
                FilterChip(
                  label: const Text('정규식 사용'),
                  selected: fileProvider.useRegex,
                  onSelected: (bool value) {
                    fileProvider.toggleRegex();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 파일 확장자 필터
            Text(
              '파일 확장자 필터',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _extensionController,
                    decoration: const InputDecoration(
                      hintText: '확장자 입력 (예: .dart)',
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (_extensionController.text.isNotEmpty) {
                      fileProvider
                          .addFileExtensionFilter(_extensionController.text);
                      _extensionController.clear();
                    }
                  },
                  child: const Text('추가'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: fileProvider.fileExtensionFilter.map((ext) {
                return Chip(
                  label: Text(ext),
                  onDeleted: () => fileProvider.removeFileExtensionFilter(ext),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // 경로 필터
            Text(
              '경로 필터',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _pathController,
                    decoration: const InputDecoration(
                      hintText: '경로 패턴 입력',
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (_pathController.text.isNotEmpty) {
                      fileProvider.addPathFilter(_pathController.text);
                      _pathController.clear();
                    }
                  },
                  child: const Text('추가'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: fileProvider.pathFilter.map((pattern) {
                return Chip(
                  label: Text(pattern),
                  onDeleted: () => fileProvider.removePathFilter(pattern),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('닫기'),
        ),
      ],
    );
  }
}
