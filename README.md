코드 앤 트리 (Code and Tree)

Code and Tree는 Flutter로 개발된 데스크톱 애플리케이션으로, 사용자가 특정 폴더를 선택하여 디렉토리 트리를 시각적으로 탐색하고, 원하는 파일을 선택하여 하나의 텍스트 파일로 생성할 수 있도록 도와줍니다. 추가로, 파일 내용에 사용자 지정 텍스트를 포함하거나 디렉토리 구조를 포함하는 등의 기능을 제공합니다.

주요 기능

	•	폴더 선택 및 탐색: 원하는 폴더를 선택하여 그 안의 디렉토리 구조를 시각적으로 탐색할 수 있습니다.
	•	파일 검색: 파일명 또는 파일 내용을 기반으로 검색하여 원하는 파일을 빠르게 찾을 수 있습니다.
	•	파일 선택 및 관리:
	•	개별 파일 선택 및 선택 해제
	•	모든 파일 한 번에 선택 또는 해제
	•	파일 확장자 및 경로 기반 필터링
	•	디렉토리 트리 관리:
	•	모든 노드 확장 또는 축소
	•	무시할 항목(파일 또는 폴더) 관리
	•	추가 기능:
	•	선택한 파일의 내용과 추가 텍스트를 포함하여 하나의 텍스트 파일로 생성
	•	디렉토리 구조를 텍스트 파일에 포함 여부 선택
	•	바이너리 파일은 자동으로 건너뛰고 파일명만 표시

시작하기

전제 조건

	•	Flutter SDK가 설치되어 있어야 합니다.
	•	데스크톱 개발 환경이 설정되어 있어야 합니다.
	•	Windows: Windows 데스크톱 설정
	•	macOS: macOS 데스크톱 설정
	•	Linux: Linux 데스크톱 설정

설치

	1.	이 저장소를 클론합니다:

git clone https://github.com/djchang-hdj/code_and_tree_flutter.git
cd code-and-tree_flutter


	2.	의존성을 설치합니다:

flutter pub get



실행

flutter run -d windows   # Windows에서 실행
flutter run -d macos     # macOS에서 실행
flutter run -d linux     # Linux에서 실행

사용 방법

	1.	폴더 선택: 앱 실행 후 좌측 상단의 Browse 버튼을 클릭하여 탐색할 폴더를 선택합니다.
	2.	파일 트리 탐색: 좌측 패널에서 디렉토리 트리를 확장하여 파일과 폴더를 탐색합니다.
	3.	파일 검색: 상단의 검색 바를 이용하여 파일명 또는 내용으로 검색할 수 있습니다.
	•	검색 필터: 검색 바 옆의 필터 아이콘을 클릭하여 대소문자 구분, 정규식 사용, 파일 확장자 및 경로 필터를 설정할 수 있습니다.
	4.	파일 선택:
	•	파일명을 클릭하여 개별적으로 선택하거나 해제할 수 있습니다.
	•	전부선택 또는 전부해제 버튼을 이용하여 모든 파일을 한 번에 선택 또는 해제할 수 있습니다.
	5.	선택한 파일 확인: 우측 패널의 Selected Files 섹션에서 현재 선택된 파일들의 목록을 확인할 수 있습니다.
	6.	무시할 항목 관리:
	•	Ignore Items 섹션에서 무시할 파일이나 폴더 이름을 추가하거나 제거할 수 있습니다.
	•	기본적으로 .git, node_modules 등 일반적으로 무시되는 항목들이 설정되어 있습니다.
	7.	추가 텍스트 입력: Additional Text 입력란에 생성될 텍스트 파일의 끝에 추가할 내용을 입력합니다.
	8.	디렉토리 구조 포함 여부 선택: Include Directory Tree 체크박스를 통해 생성되는 파일에 디렉토리 구조를 포함할지 결정합니다.
	9.	텍스트 파일 생성: 우측 하단의 Generate Text File 버튼을 클릭하여 텍스트 파일을 생성하고 저장 위치를 지정합니다.
	•	바이너리 파일의 내용은 자동으로 건너뛰고 파일명만 포함됩니다.

빌드

Windows

	1.	Windows용으로 프로젝트를 설정합니다:

flutter create --platforms=windows .


	2.	DPI 설정을 위해 windows/runner/main.cpp 파일에 다음 줄을 추가합니다:

SetProcessDPIAware();

wWinMain 함수의 시작 부분에 추가하세요.

	3.	앱을 빌드합니다:

flutter build windows



macOS

	1.	macOS용으로 프로젝트를 설정합니다:

flutter create --platforms=macos .


	2.	파일 접근 권한을 설정하기 위해 macos/Runner/DebugProfile.entitlements와 macos/Runner/Release.entitlements 파일에 다음 키를 추가합니다:

<key>com.apple.security.files.user-selected.read-write</key>
<true/>


	3.	앱을 빌드합니다:

flutter build macos

