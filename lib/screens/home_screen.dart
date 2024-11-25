import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:code_and_tree/widgets/splitter.dart';
import 'package:code_and_tree/widgets/folder_selection.dart';
import 'package:code_and_tree/widgets/file_tree_view.dart';
import 'package:code_and_tree/widgets/selected_files_list.dart';
import 'package:code_and_tree/widgets/generate_button.dart';
import 'package:code_and_tree/widgets/ignore_items_widget.dart';
import 'package:code_and_tree/widgets/additional_text_input.dart';
import 'package:code_and_tree/widgets/tree_structure_option.dart';
import 'package:code_and_tree/widgets/reset_button.dart';
import 'package:code_and_tree/widgets/search_bar.dart' as app_search;
import 'package:code_and_tree/widgets/content_search_results_view.dart';
import 'package:code_and_tree/providers/file_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mainSplitterKey = GlobalKey<SplitterState>();
    final leftPanelSplitterKey = GlobalKey<SplitterState>();
    final rightPanelSplitterKey = GlobalKey<SplitterState>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Code and Tree'),
            const SizedBox(width: 8),
            const ResetButton(),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () {
                mainSplitterKey.currentState?.resetRatio();
                leftPanelSplitterKey.currentState?.resetRatio();
                rightPanelSplitterKey.currentState?.resetRatio();
              },
              icon: const Icon(Icons.aspect_ratio),
              label: const Text('Reset Section Ratio'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Splitter(
        key: mainSplitterKey,
        axis: Axis.horizontal,
        initialFirstFraction: 0.3,
        minSizeFraction: 0.2,
        maxSizeFraction: 0.7,
        firstChild: _LeftPanel(splitterKey: leftPanelSplitterKey),
        secondChild: _RightPanel(splitterKey: rightPanelSplitterKey),
      ),
    );
  }
}

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  @override
  Widget build(BuildContext context) {
    final leftPanelSplitterKey = GlobalKey<SplitterState>();
    final rightPanelSplitterKey = GlobalKey<SplitterState>();

    return Splitter(
      axis: Axis.horizontal,
      initialFirstFraction: 0.3,
      minSizeFraction: 0.2,
      maxSizeFraction: 0.7,
      firstChild: _LeftPanel(splitterKey: leftPanelSplitterKey),
      secondChild: _RightPanel(splitterKey: rightPanelSplitterKey),
    );
  }
}

class _LeftPanel extends StatelessWidget {
  final GlobalKey<SplitterState> splitterKey;

  const _LeftPanel({required this.splitterKey});

  @override
  Widget build(BuildContext context) {
    final fileProvider = Provider.of<FileProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Splitter(
        key: splitterKey,
        axis: Axis.vertical,
        initialFirstFraction: 0.6,
        minSizeFraction: 0.3,
        maxSizeFraction: 0.8,
        firstChild: Column(
          children: [
            const FolderSelection(),
            const SizedBox(height: 16),
            const app_search.SearchBar(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    fileProvider.toggleAllNodesExpansion();
                  },
                  icon: Icon(fileProvider.allNodesExpanded
                      ? Icons.unfold_less
                      : Icons.unfold_more),
                  label: Text(fileProvider.allNodesExpanded ? '모두접기' : '모두펴기'),
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {
                    fileProvider.toggleAllFilesSelection();
                  },
                  icon: Icon(fileProvider.allFilesSelected
                      ? Icons.check_box_outlined
                      : Icons.check_box_outline_blank),
                  label: Text(fileProvider.allFilesSelected ? '전부해제' : '전부선택'),
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(child: FileTreeView()),
          ],
        ),
        secondChild: const ContentSearchResultsView(),
      ),
    );
  }
}

class _RightPanel extends StatelessWidget {
  final GlobalKey<SplitterState> splitterKey;

  const _RightPanel({required this.splitterKey});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Splitter(
        key: splitterKey,
        axis: Axis.vertical,
        initialFirstFraction: 0.8,
        minSizeFraction: 0.3,
        maxSizeFraction: 0.9,
        firstChild: Column(
          children: const [
            IgnoreItemsWidget(),
            SizedBox(height: 16),
            Expanded(child: SelectedFilesList()),
          ],
        ),
        secondChild: Column(
          children: [
            const Expanded(
              child: AdditionalTextInput(),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TreeStructureOption(),
                  SizedBox(height: 8),
                  GenerateButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
