import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_treeview/flutter_treeview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:async';
import 'package:async/async.dart';
import 'package:code_and_tree/models/content_search_result.dart';

// Add this extension at the top of the file, after the imports
extension NodeExtension on Node {
  bool get isLeaf => children.isEmpty;
}

class SearchParams {
  final String filePath;
  final String relativePath;
  final String searchQuery;
  final bool caseSensitive;
  final bool useRegex;

  SearchParams({
    required this.filePath,
    required this.relativePath,
    required this.searchQuery,
    this.caseSensitive = false,
    this.useRegex = false,
  });
}

class FileProvider extends ChangeNotifier {
  String _folderPath = '';
  List<Node> _treeNodes = [];
  final Set<String> _selectedFiles = {};
  final Set<String> _selectedNodeKeys = {};
  String _additionalText = '';
  String _searchQuery = '';
  String _contentSearchQuery = '';
  String _searchType = '일명'; // '파일명' or '내용'
  bool _isSearching = false;
  List<ContentSearchResult> _contentSearchResults = [];
  Timer? _debounceTimer;
  List<Node> _originalTreeNodes = [];

  final List<String> _defaultIgnoreItems = [
    '.git',
    '.vscode',
    '__pycache__',
    '.github',
    '.DS_Store',
    '.env',
    '.idea',
    '.dart_tool',
    'build',
    'ios',
    'android',
    'web',
    'test',
    'pubspec.lock',
    '.flutter-plugins-dependencies',
    '.flutter-plugins',
    '.metadata',
    '.vscode',
    '.vscodeignore',
    '.gitignore',
    'macos',
    'ios',
    'android',
    'web',
    'test',
    'windows',
    'node_modules',
    'dist',
    'coverage',
    'logs',
    'npm-debug.log*',
    'yarn-debug.log*',
    'yarn-error.log*',
    '*.log',
    '*.pid',
    '*.seed',
    '*.pid.lock',
    '.npm',
    '.eslintcache',
    '.node_repl_history',
    '*.tgz',
    '.yarn-integrity',
    '.cache',
    'package-lock.json',
    'yarn.lock',
  ];

  List<String> _ignoreItems = [];

  bool _includeTreeStructure = true;

  bool _allNodesExpanded = false;
  bool _allFilesSelected = false;

  static const int _minSearchLength = 2; // 최소 검색어 길이
  static const Duration _debounceDelay = Duration(milliseconds: 300); // 디바운스 시간
  static const int _maxSearchResults = 100; // 최대 검색 결과 수
  // static const int _maxFileSize = 1024 * 1024; // 1MB

  CancelableOperation<void>? _searchOperation;

  String _sortBy = 'fileName'; // 'fileName', 'filePath', 'lineNumber'
  bool _sortAscending = true;

  // 필터 관련 상태 추가
  final Set<String> _fileExtensionFilter = <String>{};
  final Set<String> _pathFilter = <String>{};
  bool _caseSensitive = false;
  bool _useRegex = false;

  // Getters for filters
  Set<String> get fileExtensionFilter => _fileExtensionFilter;
  Set<String> get pathFilter => _pathFilter;
  bool get caseSensitive => _caseSensitive;
  bool get useRegex => _useRegex;

  // 필터 업데이트 메서드들
  void toggleCaseSensitive() {
    _caseSensitive = !_caseSensitive;
    _performContentSearch();
    notifyListeners();
  }

  void toggleRegex() {
    _useRegex = !_useRegex;
    _performContentSearch();
    notifyListeners();
  }

  void addFileExtensionFilter(String extension) {
    if (extension.startsWith('.')) {
      _fileExtensionFilter.add(extension);
    } else {
      _fileExtensionFilter.add('.$extension');
    }
    _performContentSearch();
    notifyListeners();
  }

  void removeFileExtensionFilter(String extension) {
    _fileExtensionFilter
        .remove(extension.startsWith('.') ? extension : '.$extension');
    _performContentSearch();
    notifyListeners();
  }

  void addPathFilter(String pathPattern) {
    _pathFilter.add(pathPattern);
    _performContentSearch();
    notifyListeners();
  }

  void removePathFilter(String pathPattern) {
    _pathFilter.remove(pathPattern);
    _performContentSearch();
    notifyListeners();
  }

  void clearFilters() {
    _fileExtensionFilter.clear();
    _pathFilter.clear();
    _caseSensitive = false;
    _useRegex = false;
    _performContentSearch();
    notifyListeners();
  }

  FileProvider() {
    _folderPath = '';
    _ignoreItems = List.from(_defaultIgnoreItems);
  }

  // Getter for _folderPath
  String get folderPath => _folderPath;

  String get selectedFolderPath => _folderPath;
  List<String> get ignoreItems => List.unmodifiable(_ignoreItems);
  List<Node> get treeNodes => _treeNodes;
  List<String> get selectedFiles => _selectedFiles.toList();

  bool get includeTreeStructure => _includeTreeStructure;

  bool get allNodesExpanded => _allNodesExpanded;
  bool get allFilesSelected => _allFilesSelected;

  bool isNodeSelected(String key) => _selectedNodeKeys.contains(key);

  void toggleNodeSelection(String key) {
    if (_selectedNodeKeys.contains(key)) {
      _selectedNodeKeys.remove(key);
    } else {
      _selectedNodeKeys.add(key);
    }
    notifyListeners();
  }

  void addIgnoreItem(String item) {
    if (!_ignoreItems.contains(item)) {
      _ignoreItems.add(item);
      notifyListeners();
    }
  }

  void removeIgnoreItem(String item) {
    if (_ignoreItems.contains(item)) {
      _ignoreItems.remove(item);
      notifyListeners();
    }
  }

  void resetIgnoreItems() {
    _ignoreItems = List.from(_defaultIgnoreItems);
    notifyListeners();
  }

  void setIncludeTreeStructure(bool value) {
    _includeTreeStructure = value;
    notifyListeners();
  }

  void toggleAllNodesExpansion() {
    _allNodesExpanded = !_allNodesExpanded;
    _expandOrCollapseAllNodes(_treeNodes, _allNodesExpanded);
    notifyListeners();
  }

  void _expandOrCollapseAllNodes(List<Node> nodes, bool expand) {
    _treeNodes = _updateNodeExpansion(nodes, expand);
    notifyListeners();
  }

  List<Node> _updateNodeExpansion(List<Node> nodes, bool expand) {
    return nodes.map((node) {
      return node.copyWith(
        expanded: expand,
        children: node.children.isNotEmpty
            ? _updateNodeExpansion(node.children, expand)
            : [],
      );
    }).toList();
  }

  void toggleAllFilesSelection() {
    _allFilesSelected = !_allFilesSelected;
    _selectOrUnselectAllFiles(_treeNodes, _allFilesSelected);
    notifyListeners();
  }

  void _selectOrUnselectAllFiles(List<Node> nodes, bool select) {
    for (var node in nodes) {
      if (node.isLeaf) {
        if (select) {
          _selectedFiles.add(node.key);
          _selectedNodeKeys.add(node.key);
        } else {
          _selectedFiles.remove(node.key);
          _selectedNodeKeys.remove(node.key);
        }
      }
      if (node.children.isNotEmpty) {
        _selectOrUnselectAllFiles(node.children, select);
      }
    }
  }

  Future<void> _updateFileTree() async {
    try {
      final Directory directory = Directory(_folderPath);
      _originalTreeNodes = await _createTreeNodes(directory);
      _filterTreeNodes();
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating file tree: $e');
      _originalTreeNodes = [
        Node(key: _folderPath, label: path.basename(_folderPath))
      ];
      _treeNodes = _originalTreeNodes;
      notifyListeners();
    }
  }

  void _filterTreeNodes() {
    if (_searchQuery.isEmpty) {
      _treeNodes = _originalTreeNodes;
    } else {
      _treeNodes = _filterNodes(_originalTreeNodes, _searchQuery.toLowerCase());
    }
    notifyListeners();
  }

  List<Node> _filterNodes(List<Node> nodes, String query) {
    List<Node> filtered = [];
    for (var node in nodes) {
      if (node.label.toLowerCase().contains(query)) {
        filtered.add(node.copyWith(expanded: true));
      } else if (node.children.isNotEmpty) {
        var filteredChildren = _filterNodes(node.children, query);
        if (filteredChildren.isNotEmpty) {
          filtered.add(node.copyWith(
            children: filteredChildren,
            expanded: true,
          ));
        }
      }
    }
    return filtered;
  }

  Future<List<Node>> _createTreeNodes(Directory directory) async {
    List<Node> nodes = [];
    try {
      List<FileSystemEntity> entities = await directory.list().toList();

      // Separate directories and files
      List<Directory> directories = [];
      List<File> files = [];

      for (var entity in entities) {
        String name = path.basename(entity.path);
        if (_ignoreItems.contains(name)) continue;

        if (entity is Directory) {
          directories.add(entity);
        } else if (entity is File) {
          files.add(entity);
        }
      }

      // Sort directories and files alphabetically
      directories.sort((a, b) => path
          .basename(a.path)
          .toLowerCase()
          .compareTo(path.basename(b.path).toLowerCase()));
      files.sort((a, b) => path
          .basename(a.path)
          .toLowerCase()
          .compareTo(path.basename(b.path).toLowerCase()));

      // Process directories first
      for (var dir in directories) {
        String name = path.basename(dir.path);
        nodes.add(Node(
          key: dir.path,
          label: name,
          children: await _createTreeNodes(dir),
        ));
      }

      // Then process files
      for (var file in files) {
        String name = path.basename(file.path);
        bool isSelected = _selectedFiles.contains(file.path);
        nodes.add(Node(
          key: file.path,
          label: name,
          data: isSelected
              ? const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)
              : null,
        ));
      }
    } catch (e) {
      debugPrint('Error accessing ${directory.path}: $e');
      nodes.add(Node(
        key: directory.path,
        label: path.basename(directory.path),
      ));
    }
    return nodes;
  }

  Future<void> setFolderPath(String path) async {
    _isSelectingFolder = false;
    _folderPath = path;

    // 선택된 파일들 초기화
    _selectedFiles.clear();
    _selectedNodeKeys.clear();
    _allFilesSelected = false;

    await _updateFileTree();
    notifyListeners();
  }

  // 폴더 선택 시작 시 호출할 메서드 추가
  void startFolderSelection() {
    _isSelectingFolder = true;
    notifyListeners();
  }

  void toggleFileSelection(String filePath) {
    if (_selectedFiles.contains(filePath)) {
      _selectedFiles.remove(filePath);
      _selectedNodeKeys.remove(filePath);
    } else {
      _selectedFiles.add(filePath);
      _selectedNodeKeys.add(filePath);
    }
    notifyListeners();
  }

  List<String> get selectedFilesRelativePaths {
    return _selectedFiles.map((filePath) {
      String relativePath = path.relative(filePath, from: _folderPath);
      if (relativePath.startsWith('..')) {
        return relativePath;
      } else {
        return path.join('..', relativePath);
      }
    }).toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  }

  List<String> get selectedFilesSorted {
    return _selectedFiles.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  }

  void setAdditionalText(String text) {
    _additionalText = text;
    notifyListeners();
  }

  bool _isBinaryFile(dynamic file) {
    if (file is File) {
      try {
        final bytes = file.readAsBytesSync();
        for (var i = 0; i < bytes.length; i++) {
          if (bytes[i] == 0) return true;
        }
      } catch (e) {
        debugPrint('Error checking if file is binary: $e');
        return true;
      }
    } else if (file is String) {
      final ext = path.extension(file).toLowerCase();
      return [
        '.pdf',
        '.jpg',
        '.jpeg',
        '.png',
        '.gif',
        '.ico',
        '.svg',
        '.exe',
        '.dll',
        '.so',
        '.dylib',
        '.zip',
        '.rar',
        '.7z',
        '.tar',
        '.gz',
        '.doc',
        '.docx',
        '.xls',
        '.xlsx',
        '.ppt',
        '.pptx',
        '.mp3',
        '.mp4',
        '.avi',
        '.mov',
        '.ttf',
        '.otf',
      ].contains(ext);
    }
    return false;
  }

  Future<void> generateTextFile(String outputFile) async {
    if (_selectedFiles.isEmpty) return;

    final file = File(outputFile);
    String content = '';
    for (String filePath in _selectedFiles) {
      try {
        final currentFile = File(filePath);
        final relativePath = path.relative(filePath, from: _folderPath);

        if (_isBinaryFile(currentFile)) {
          content += '${'=' * relativePath.length}\n';
          content += 'File: $relativePath\n';
          content += '${'-' * relativePath.length}\n\n';
          content += '[Binary file contents skipped]\n\n';
        } else {
          final fileContent = await currentFile.readAsString();
          content += '${'=' * relativePath.length}\n';
          content += 'File: $relativePath\n';
          content += '${'-' * relativePath.length}\n\n';
          content += '$fileContent\n\n';
        }
      } catch (e) {
        content += 'Error reading file: $filePath\n';
        content += '${'=' * 40}\n\n';
      }
    }

    if (_includeTreeStructure) {
      content += '${'=' * 40}\n';
      content += 'Directory Tree:\n';
      content += await _generateDirectoryTree(Directory(_folderPath));
    }

    // Add the additional text at the end
    if (_additionalText.isNotEmpty) {
      content += '\n${'=' * 40}\n';
      content += 'Request:\n';
      content += '${'-' * 16}\n\n';
      content += '$_additionalText\n';
      content += '\n${'=' * 40}\n';
    }

    await file.writeAsString(content);
  }

  Future<String> _generateDirectoryTree(Directory directory,
      {String prefix = ''}) async {
    String tree = '';
    try {
      List<FileSystemEntity> entities = await directory.list().toList();

      // Separate and sort directories and files
      List<Directory> directories = [];
      List<File> files = [];

      for (var entity in entities) {
        String name = path.basename(entity.path);
        if (_ignoreItems.contains(name)) continue;

        if (entity is Directory) {
          directories.add(entity);
        } else if (entity is File) {
          files.add(entity);
        }
      }

      directories.sort((a, b) => path
          .basename(a.path)
          .toLowerCase()
          .compareTo(path.basename(b.path).toLowerCase()));
      files.sort((a, b) => path
          .basename(a.path)
          .toLowerCase()
          .compareTo(path.basename(b.path).toLowerCase()));

      List<FileSystemEntity> sortedEntities = [...directories, ...files];

      for (var i = 0; i < sortedEntities.length; i++) {
        var entity = sortedEntities[i];
        String name = path.basename(entity.path);

        bool isLast = i == sortedEntities.length - 1;
        String connector = isLast ? '└── ' : '├─ ';

        tree += '$prefix$connector$name\n';

        if (entity is Directory) {
          String newPrefix = prefix + (isLast ? '    ' : '│   ');
          tree += await _generateDirectoryTree(entity, prefix: newPrefix);
        }
      }
    } catch (e) {
      debugPrint('Error generating tree for ${directory.path}: $e');
      tree += '$prefix[Error accessing directory]\n';
    }
    return tree;
  }

  Future<void> resetAll() async {
    // Reset folder path
    _folderPath = '';
    _treeNodes = [];
    _originalTreeNodes = [];

    // Reset selections
    _selectedFiles.clear();
    _selectedNodeKeys.clear();

    // Reset search states
    _searchQuery = '';
    _contentSearchQuery = '';
    _contentSearchResults.clear();
    _isSearching = false;

    // Reset filters
    _fileExtensionFilter.clear();
    _pathFilter.clear();
    _caseSensitive = false;
    _useRegex = false;

    // Reset additional text
    _additionalText = '';

    // Reset expansion/selection states
    _allNodesExpanded = false;
    _allFilesSelected = false;

    // Reset tree structure option
    _includeTreeStructure = true;

    // Note: We're not resetting _ignoreItems here to preserve user's ignore items

    notifyListeners();
  }

  String get searchQuery => _searchQuery;
  String get searchType => _searchType;
  bool get isSearching => _isSearching;
  List<ContentSearchResult> get contentSearchResults => _contentSearchResults;

  void updateSearchType(String type) {
    if (_searchType == type) return;

    _searchType = type;
    if (type == '파일명') {
      _searchQuery = _contentSearchQuery;
      _contentSearchQuery = '';
      _contentSearchResults.clear();
      _filterTreeNodes();
    } else {
      _contentSearchQuery = _searchQuery;
      _searchQuery = '';
      _treeNodes = _originalTreeNodes;
      if (_contentSearchQuery.isNotEmpty) {
        _debounceContentSearch();
      }
    }
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    _filterTreeNodes();

    // 최소 검색 길이 조건 확인
    if (query.length >= _minSearchLength) {
      _debounceContentSearch();
    } else {
      _contentSearchResults.clear();
    }
    notifyListeners();
  }

  void _debounceContentSearch() {
    _isSearching = true;
    notifyListeners();

    _debounceTimer?.cancel();
    _searchOperation?.cancel();

    _debounceTimer = Timer(_debounceDelay, () {
      _performContentSearch();
    });
  }

  Future<void> _performContentSearch() async {
    if (_searchQuery.isEmpty || _folderPath.isEmpty) {
      _isSearching = false;
      _contentSearchResults.clear();
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    try {
      await _searchFiles();
    } catch (e) {
      _contentSearchResults.clear();
      debugPrint('Content search error: $e');
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  Future<void> _searchFiles() async {
    Map<String, List<MatchResult>> resultMap = {};

    try {
      await for (final file
          in Directory(_folderPath).list(recursive: true, followLinks: false)) {
        if (file is! File) continue;

        String relativePath = path.relative(file.path, from: _folderPath);
        if (_shouldSkipFile(file, relativePath)) continue;

        final matches = await _searchInFile(file);
        if (matches.isNotEmpty) {
          resultMap[relativePath] = matches;
        }

        if (resultMap.length >= _maxSearchResults) break;
      }
    } catch (e) {
      debugPrint('Error searching files: $e');
    }

    _contentSearchResults = resultMap.entries
        .map((entry) => ContentSearchResult(
              fileName: path.basename(entry.key),
              filePath: entry.key,
              matches: entry.value,
            ))
        .toList();

    _sortContentSearchResults();
    _isSearching = false;
    notifyListeners();
  }

  bool _shouldSkipFile(File file, String relativePath) {
    return _shouldIgnore(relativePath) ||
        _isBinaryFile(file.path) ||
        !_shouldIncludeInSearch(relativePath);
  }

  Future<List<MatchResult>> _searchInFile(File file) async {
    List<MatchResult> matches = [];
    try {
      final lines = await file.readAsLines();

      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (_isLineMatching(line)) {
          matches.add(MatchResult(
            lineNumber: i + 1,
            matchingLine: line.trim(),
          ));
        }
      }
    } catch (e) {
      debugPrint('Error reading file ${file.path}: $e');
    }
    return matches;
  }

  bool _isLineMatching(String line) {
    if (_useRegex) {
      try {
        final regex = RegExp(_searchQuery, caseSensitive: _caseSensitive);
        return regex.hasMatch(line);
      } catch (e) {
        debugPrint('Invalid regex pattern: $_searchQuery');
        return false;
      }
    }

    final lineText = _caseSensitive ? line : line.toLowerCase();
    final searchText =
        _caseSensitive ? _searchQuery : _searchQuery.toLowerCase();
    return lineText.contains(searchText);
  }

  bool _shouldIgnore(String path) {
    return _ignoreItems.any((item) =>
        path.contains(item) ||
        path.split(Platform.pathSeparator).contains(item));
  }

  // 검색 결과를 파일명, 경로, 매칭 라인 등으로 정렬는 기능 추가
  void sortContentSearchResults(String sortBy) {
    switch (sortBy) {
      case 'fileName':
        _contentSearchResults.sort((a, b) => a.fileName.compareTo(b.fileName));
        break;
      case 'filePath':
        _contentSearchResults.sort((a, b) => a.filePath.compareTo(b.filePath));
        break;
      case 'lineNumber':
        _contentSearchResults.sort((a, b) {
          if (a.matches.isEmpty || b.matches.isEmpty) return 0;
          return a.matches.first.lineNumber
              .compareTo(b.matches.first.lineNumber);
        });
        break;
    }
    notifyListeners();
  }

  // 파일 확장자, 경로 등으로 검색 결과를 필터링하는 기능 추가
  bool _shouldIncludeInSearch(String filePath) {
    // 파일 확장자 필터 체크
    if (_fileExtensionFilter.isNotEmpty) {
      final ext = path.extension(filePath).toLowerCase();
      if (!_fileExtensionFilter.contains(ext.toLowerCase())) {
        return false;
      }
    }

    // 경로 필터 체크
    if (_pathFilter.isNotEmpty) {
      bool matchesAnyPattern = false;
      for (final pattern in _pathFilter) {
        if (_useRegex) {
          try {
            final regex = RegExp(pattern, caseSensitive: _caseSensitive);
            if (regex.hasMatch(filePath)) {
              matchesAnyPattern = true;
              break;
            }
          } catch (e) {
            debugPrint('Invalid regex pattern: $pattern');
            continue;
          }
        } else {
          final normalizedPattern =
              _caseSensitive ? pattern : pattern.toLowerCase();
          final normalizedPath =
              _caseSensitive ? filePath : filePath.toLowerCase();
          if (normalizedPath.contains(normalizedPattern)) {
            matchesAnyPattern = true;
            break;
          }
        }
      }
      if (!matchesAnyPattern) {
        return false;
      }
    }

    return true;
  }

  // Getters for sort state
  String get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;

  void updateSort(String sortBy, {bool? ascending}) {
    bool changed = false;
    if (_sortBy != sortBy) {
      _sortBy = sortBy;
      changed = true;
    }
    if (ascending != null && _sortAscending != ascending) {
      _sortAscending = ascending;
      changed = true;
    }

    if (changed) {
      _sortContentSearchResults();
      notifyListeners();
    }
  }

  void _sortContentSearchResults() {
    int compareResult = _sortAscending ? 1 : -1;

    switch (_sortBy) {
      case 'fileName':
        _contentSearchResults.sort((a, b) =>
            compareResult *
            a.fileName.toLowerCase().compareTo(b.fileName.toLowerCase()));
        break;
      case 'filePath':
        _contentSearchResults.sort((a, b) =>
            compareResult *
            a.filePath.toLowerCase().compareTo(b.filePath.toLowerCase()));
        break;
      case 'lineNumber':
        _contentSearchResults.sort((a, b) {
          if (a.matches.isEmpty || b.matches.isEmpty) return 0;
          return a.matches.first.lineNumber
              .compareTo(b.matches.first.lineNumber);
        });
        break;
    }
  }

  // 모든 노드의 확장 상태를 토글하는 메서드
  void toggleAllExpansion(bool expand) {
    void updateExpansion(List<Node> nodes) {
      for (var i = 0; i < nodes.length; i++) {
        var node = nodes[i];
        if (node.children.isNotEmpty) {
          nodes[i] = node.copyWith(
            expanded: expand,
            children: node.children,
          );
          updateExpansion(nodes[i].children);
        }
      }
    }

    updateExpansion(_treeNodes);
    notifyListeners();
  }

  // 모든 파일의 택 상태를 토글하는 메서드
  void toggleAllSelection(bool select) {
    void traverseNodes(List<Node> nodes) {
      for (var node in nodes) {
        if (node.isLeaf) {
          if (select) {
            _selectedFiles.add(node.key);
            _selectedNodeKeys.add(node.key);
          } else {
            _selectedFiles.remove(node.key);
            _selectedNodeKeys.remove(node.key);
          }
        }
        if (node.children.isNotEmpty) {
          traverseNodes(node.children);
        }
      }
    }

    traverseNodes(_treeNodes);
    notifyListeners();
  }

  Future<void> saveTextFile(String content, String fileName) async {
    try {
      final path = await _getFilePath(fileName);
      final file = File(path);
      await file.writeAsString(content);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving file: $e');
      rethrow;
    }
  }

  Future<String> _getFilePath(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$fileName';
  }

  // contentSearchQuery getter 추가
  String get contentSearchQuery => _contentSearchQuery;

  // updateContentSearchQuery 메서드 추가
  void updateContentSearchQuery(String query) {
    _contentSearchQuery = query;
    if (query.length >= _minSearchLength) {
      _debounceContentSearch();
    } else {
      _contentSearchResults.clear();
    }
    notifyListeners();
  }

  bool _isSelectingFolder = false;

  bool get isSelectingFolder => _isSelectingFolder;

  String get additionalText => _additionalText;
}

Future<Directory> getHomeDirectory() async {
  if (Platform.isMacOS || Platform.isLinux) {
    return Directory(Platform.environment['HOME'] ?? '');
  } else if (Platform.isWindows) {
    return Directory(Platform.environment['USERPROFILE'] ?? '');
  }
  // Fallback to application documents directory
  return await getApplicationDocumentsDirectory();
}

// TODO: Implement file search in isolate for better performance
// List<ContentSearchResult>? _searchInFile(SearchParams params) {
//   ...
// }
