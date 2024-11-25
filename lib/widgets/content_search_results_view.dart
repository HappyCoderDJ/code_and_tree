import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:code_and_tree/providers/file_provider.dart';
import 'package:code_and_tree/widgets/search_result_card.dart';

class ContentSearchResultsView extends StatelessWidget {
  const ContentSearchResultsView({super.key});

  @override
  Widget build(BuildContext context) {
    final fileProvider = Provider.of<FileProvider>(context);
    final theme = Theme.of(context);

    if (fileProvider.isSearching) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (fileProvider.contentSearchResults.isEmpty) {
      return Center(
        child: Text(
          '검색 결과가 없습니다.',
          style: theme.textTheme.titleMedium,
        ),
      );
    }

    return ListView.builder(
      itemCount: fileProvider.contentSearchResults.length,
      itemBuilder: (context, index) {
        final result = fileProvider.contentSearchResults[index];
        return SearchResultCard(result: result);
      },
    );
  }
}
