# Release Process

## Version policy

- 사용자 버전: `major.minor.patch`
- 스토어에 빌드를 업로드할 때마다 build number를 1 증가한다.
- Android와 iOS의 build number는 동일하게 유지한다.
- 첫 출시 전에는 `1.0.0`을 유지한다.
- 버그 수정 출시: `1.0.1`
- 기능 추가 출시: `1.1.0`

## Build examples

- `1.0.0+1`: 최초 내부 테스트
- `1.0.0+2`: IAP 테스트 빌드
- `1.0.0+3`: 스토어 심사 제출
- `1.0.0+4`: 심사 대응 수정

## iOS release environment

2026-10-03 확인 기준, App Store Connect 제출에는 Xcode 26 이상과
iOS 26 SDK 이상이 필요하다. Xcode 16.4에서 로컬 빌드가 성공하더라도
해당 바이너리는 이 제출 요건을 충족하지 않는다.

- 제출 요건: https://developer.apple.com/news/upcoming-requirements/
- Xcode별 macOS 요구 사항: https://developer.apple.com/xcode/system-requirements
- Xcode 다운로드: https://developer.apple.com/download/all/

2026-10-04 환경 전환 확인: macOS 27.0.1 / Xcode 27.0 / iPhoneOS SDK 27.0.
Xcode는 `/Applications/Xcode.app/Contents/Developer`가 선택되어 있다.
사용자 승인에 따라 최소 지원 버전을 iOS 15.0으로 변경했다.
Xcode 27에서 무서명 Release 빌드가 성공했고, 생성된 앱의 `MinimumOSVersion`
15.0 및 `DTSDKName` `iphoneos27.0`을 확인했다. REL-01의 로컬 도구·SDK
요건 문제는 해결되었다. 서명된 Archive와 App Store Connect 업로드 검증은
별도로 수행해야 한다. iOS 13·14는 지원하지 않는다.

1. 사용자가 macOS를 설치할 Xcode의 지원 버전으로 업데이트한다.
   Sequoia를 유지하는 경우 macOS 15.6 이상과 Xcode 26.2 조합을 사용할 수 있다.
   다른 Xcode 버전을 선택하면 위 호환성 표에서 필요한 macOS 버전을 확인한다.
2. 사용자가 정식 Xcode를 설치하고 한 번 실행해 라이선스와 필요한 플랫폼
   구성 요소 설치를 완료한다. 기존 Xcode를 병행 설치해도 된다.
3. 아래 명령으로 이 터미널에서 사용할 Xcode와 iPhoneOS SDK를 확인한다.
   병행 설치했다면 `DEVELOPER_DIR` 경로를 새 Xcode의 실제 경로로 바꾼다.

```bash
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
sw_vers -productVersion
xcodebuild -version
xcrun --sdk iphoneos --show-sdk-version
```

Xcode와 SDK가 모두 26 이상인지 확인한 후 같은 터미널에서 빌드한다.
이 확인만으로 서명이나 스토어 심사 통과가 보장되지는 않는다.
환경 전환 자체를 위해 앱 버전, 빌드 번호, 서명 팀을 변경하지 않는다.

## Release commands

```bash
flutter test
flutter analyze
flutter build appbundle --release
# iOS는 위 환경 확인을 마친 터미널에서 실행한다.
flutter build ipa --release
```

서명 설정 전 iOS 컴파일만 검사하려면 다음 명령을 사용한다.

```bash
flutter build ios --release --no-codesign
```

제출 전에는 최종 Archive의 앱 `Info.plist`에서 `DTSDKName`이
`iphoneos26.*` 이상인지 확인하고, App Store Connect 업로드 검증을 수행한다.
새 환경에서 연결된 iPhone의 첫 실행, 영상 재생, 사진 선택, 로컬 StoreKit
구매·복원을 확인한다. 실제 스토어 결제 검증은 별도로 수행한다.
