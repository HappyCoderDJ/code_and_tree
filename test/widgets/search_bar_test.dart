import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:code_and_tree/providers/file_provider.dart';
import 'package:code_and_tree/widgets/search_bar.dart' as app_search;

void main() {
  testWidgets('SearchBar updates search query on input',
      (WidgetTester tester) async {
    final fileProvider = FileProvider();

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider.value(
          value: fileProvider,
          child: const Scaffold(
            body: app_search.SearchBar(),
          ),
        ),
      ),
    );

    // 검색창 찾기
    final searchField = find.byType(TextField);
    expect(searchField, findsOneWidget);

    // 텍스트 입력
    await tester.enterText(searchField, 'test');
    await tester.pump();

    // FileProvider의 searchQuery가 업데이트되었는지 확인
    expect(fileProvider.searchQuery, equals('test'));
  });

  testWidgets('SearchBar shows filter button and opens filter dialog',
      (WidgetTester tester) async {
    final fileProvider = FileProvider();

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider.value(
          value: fileProvider,
          child: const Scaffold(
            body: app_search.SearchBar(),
          ),
        ),
      ),
    );

    // 필터 버튼 찾기
    final filterButton = find.byIcon(Icons.filter_list);
    expect(filterButton, findsOneWidget);

    // 필터 버튼 클릭
    await tester.tap(filterButton);
    await tester.pumpAndSettle();

    // 필터 다이얼로그가 열렸는지 확인
    expect(find.text('검색 필터'), findsOneWidget);
  });
}
