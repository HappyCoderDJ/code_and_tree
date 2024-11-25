import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:code_and_tree/providers/file_provider.dart';
import 'package:code_and_tree/widgets/file_tree_view.dart';
import 'package:flutter_treeview/flutter_treeview.dart';

void main() {
  testWidgets('FileTreeView displays files and handles selection',
      (WidgetTester tester) async {
    final fileProvider = FileProvider();

    // 테스트용 트리 노드 설정
    await fileProvider.setFolderPath('/test/path');

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider.value(
          value: fileProvider,
          child: const Scaffold(
            body: FileTreeView(),
          ),
        ),
      ),
    );

    // TreeView 위젯이 존재하는지 확인
    expect(find.byType(TreeView), findsOneWidget);

    // 파일 노드를 탭하면 선택되는지 확인
    final fileNode = find.byIcon(Icons.insert_drive_file).first;
    await tester.tap(fileNode);
    await tester.pump();

    // 선택된 파일이 있는지 확인
    expect(fileProvider.selectedFiles, isNotEmpty);
  });
}
