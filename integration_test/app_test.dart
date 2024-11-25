import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:code_and_tree/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('full app flow test', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 폴더 선택 버튼 찾기 및 클릭
      final browseButton = find.text('Browse');
      expect(browseButton, findsOneWidget);
      await tester.tap(browseButton);
      await tester.pumpAndSettle();

      // 파일 검색
      final searchField = find.byType(TextField).first;
      await tester.enterText(searchField, 'test');
      await tester.pumpAndSettle();

      // 파일 선택
      final fileNode = find.byIcon(Icons.insert_drive_file).first;
      await tester.tap(fileNode);
      await tester.pumpAndSettle();

      // 텍스트 파일 생성 버튼 확인
      final generateButton = find.text('Generate Text File');
      expect(generateButton, findsOneWidget);
    });
  });
}
