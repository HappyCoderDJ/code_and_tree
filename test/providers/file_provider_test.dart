import 'package:flutter_test/flutter_test.dart';
import 'package:code_and_tree/providers/file_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

void main() {
  late FileProvider fileProvider;
  late Directory tempDir;

  setUp(() async {
    fileProvider = FileProvider();
    tempDir = await Directory.systemTemp.createTemp('test_dir_');

    // 테스트용 파일 구조 생성
    await File(path.join(tempDir.path, 'test1.txt'))
        .writeAsString('Test content 1');
    await File(path.join(tempDir.path, 'test2.dart'))
        .writeAsString('Test content 2');
    await Directory(path.join(tempDir.path, 'subdir')).create();
    await File(path.join(tempDir.path, 'subdir', 'test3.txt'))
        .writeAsString('Test content 3');
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  group('FileProvider basic operations', () {
    test('initial state should be empty', () {
      expect(fileProvider.folderPath, isEmpty);
      expect(fileProvider.selectedFiles, isEmpty);
      expect(fileProvider.treeNodes, isEmpty);
    });

    test('setFolderPath should update folder path and create tree nodes',
        () async {
      await fileProvider.setFolderPath(tempDir.path);

      expect(fileProvider.folderPath, equals(tempDir.path));
      expect(fileProvider.treeNodes, isNotEmpty);
    });

    test('toggleFileSelection should add and remove files from selection',
        () async {
      await fileProvider.setFolderPath(tempDir.path);
      final testFilePath = path.join(tempDir.path, 'test1.txt');

      fileProvider.toggleFileSelection(testFilePath);
      expect(fileProvider.selectedFiles, contains(testFilePath));

      fileProvider.toggleFileSelection(testFilePath);
      expect(fileProvider.selectedFiles, isEmpty);
    });
  });

  group('Search functionality', () {
    test('file name search should filter tree nodes', () async {
      await fileProvider.setFolderPath(tempDir.path);

      fileProvider.updateSearchQuery('test1');
      expect(fileProvider.treeNodes.length, equals(1));

      fileProvider.updateSearchQuery('');
      expect(fileProvider.treeNodes.length, greaterThan(1));
    });

    test('content search should find matching files', () async {
      await fileProvider.setFolderPath(tempDir.path);

      fileProvider.updateContentSearchQuery('content');
      await Future.delayed(
          const Duration(milliseconds: 500)); // Wait for debounce

      expect(fileProvider.contentSearchResults, hasLength(3));
    });
  });

  group('Filter functionality', () {
    test('file extension filter should work correctly', () async {
      await fileProvider.setFolderPath(tempDir.path);

      fileProvider.addFileExtensionFilter('.txt');
      expect(
        fileProvider.contentSearchResults
            .every((result) => result.fileName.endsWith('.txt')),
        isTrue,
      );
    });

    test('path filter should work correctly', () async {
      await fileProvider.setFolderPath(tempDir.path);

      fileProvider.addPathFilter('subdir');
      expect(
        fileProvider.contentSearchResults
            .every((result) => result.filePath.contains('subdir')),
        isTrue,
      );
    });
  });

  group('File generation', () {
    test('generateTextFile should create file with correct content', () async {
      await fileProvider.setFolderPath(tempDir.path);
      final testFilePath = path.join(tempDir.path, 'test1.txt');
      fileProvider.toggleFileSelection(testFilePath);

      final outputPath = path.join(tempDir.path, 'output.txt');
      await fileProvider.generateTextFile(outputPath);

      final outputContent = await File(outputPath).readAsString();
      expect(outputContent, contains('Test content 1'));
    });
  });
}
