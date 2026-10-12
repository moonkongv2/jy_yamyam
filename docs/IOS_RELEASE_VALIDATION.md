# iOS 출시 수정 및 로컬 검증 결과

검증일: 2026-10-12~13. 확정 코드/설정 소스: `2cf2a5c898d077e5a84858f8b89a184a33a0c36b`.
후속 커밋은 릴리스 문서 갱신이며 실행 코드나 설정을 바꾸지 않는다.

**코드 수정과 로컬 배포 산출물 검증 완료. 제출 준비는 아직 미완료.**
App Store Connect IAP 미등록, 실제 Sandbox 및 전체 실기기 점검이 남아 있다.
Organizer Validate·업로드·처리 결과 역시 아직 확인하지 않았다.

## 수정

| 커밋 | 변경 | 확인한 동작 |
|---|---|---|
| `5143857` | 계획 리뷰 결과 기록 | 빈 복원 실제 확인 및 Archive 소스 일치 규칙 명시 |
| `b8125da` | IAP 이벤트 대기만 만료된 경우 구매 큐를 기다림 | 이벤트 없는 정상 복원, 늦은 복원 성공/저장/거래 완료, 반복 요청 방지/재시도, 네이티브 timeout 오류 유지 |
| `02b1242` | 코스 시작과 활성 타이머 재개의 공통 진입 잠금 | 지연 조회 중 연속 탭에도 화면 하나, 취소/조회 실패 후 재시도, 조회 중 dispose 안전 |
| `2cf2a5c` | 5개 언어 사진 권한 설명 | en/ko/ja/es/pt-BR strings 구문 및 최종 IPA 리소스 확인 |

IAP 코드: `lib/controllers/vehicle_pack_purchase_controller.dart`.
홈 코드: `lib/screens/home_screen.dart`. ID·버전·서명 설정·의존성 변경 없음.

## 실행 결과

| 실제 실행 명령/검사 | 결과 | 상세 |
|---|---|---|
| `flutter test --no-pub test/vehicle_pack_purchase_controller_test.dart test/iap_purchase_client_fake_test.dart test/settings_screen_test.dart test/vehicle_pack_purchase_sheet_test.dart` | PASS | 48 성공 |
| `flutter test --no-pub test/home_course_start_test.dart test/home_active_session_test.dart` | PASS | 24 성공 |
| `flutter analyze` | PASS | pub resolve/get 완료, No issues found |
| `flutter test --no-pub --reporter json` | PASS | 542 성공, 0 실패, 0 건너뜀; done.success=true, exit 0 |
| `plutil -lint` (5개 InfoPlist.strings) | PASS | 모두 OK |
| `flutter build ios --release` | PASS | Runner.app 84.1 MB, Xcode build 21.6초 |
| `codesign --verify --deep --strict build/ios/iphoneos/Runner.app` | PASS | exit 0; 이것만으로 배포 서명을 뜻하지 않음 |
| `flutter build ipa --release` | PASS with warning | Archive 245.2 MB, App Store IPA 85.0 MB; launch image 경고 아래 참조 |
| export IPA를 임시 폴더에 풀고 `codesign --verify --deep --strict` | PASS | exit 0 |
| export IPA의 entitlements 및 mobileprovision 검사 | PASS | team J3NW9PYQHA, get-task-allow=false, App Store profile, 기기 목록/ProvisionsAllDevices 없음 |
| Organizer Validate, Xcode Privacy Report | NOT RUN | GUI/서비스 검증 필요 |
| App Store Connect 업로드/처리 | NOT RUN | 업로드 지시 없음; 번호 1 유지 |
| 실제 Sandbox 및 전체 실기기 체크리스트 | NOT RUN | 사용자 수행 필요 |

초기 실행 실패도 구분한다. SDK 캐시 쓰기가 sandbox에서 차단된 명령은 권한을
받아 재실행했다. 첫 IAP 명령에 존재하지 않는 `test/in_app_purchase_client_test.dart`를
사용한 실행은 실패했고, 실제 adapter fake 테스트 파일명으로 바로잡았다.
새 테스트의 첫 기대값 실패는 fake의 비어 있는 상품 응답이 `productNotFound` 상태를
만드는 것이 원인이었다. 상품 응답을 제공하도록 fixture를 수정했고 최종 48개 및
전체 542개가 통과했다. 이 초기 실패를 성공 검증으로 계산하지 않았다.

## 최종 산출물과 소스 일치

- Archive 시작 Git status: tracked/untracked 변경 없음.
- Archive/export 완료 Git status: tracked/untracked 변경 없음.
- 앱 plist: `com.yamyamrider.app`, `1.0.0`, build `1`, 최소 iOS `15.0`, SDK `iphoneos27.0`.
  export IPA에서도 동일 값 확인.
- App Store export 옵션: method `app-store-connect`, destination `export`, automatic signing.
- export 앱: `get-task-allow=false`, `beta-reports-active=true`, Store provisioning profile.
- 5개 InfoPlist.strings의 사진 권한 키가 export IPA에 포함됨.
- `.storekit` 및 `.zip` 파일은 Release 앱과 export IPA에 없음.
- `lib/config/meal_timer_policy.dart`: Release는 short timer define과 무관하게 5분 하한 적용.
  기존 policy 회귀 테스트도 전체 테스트에 포함됨.
- scheme의 local StoreKit 연결은 Debug Run에 있고 Archive는 Release.

산출물은 무시되는 `build/ios/iphoneos/Runner.app`,
`build/ios/archive/Runner.xcarchive`, `build/ios/ipa/*.ipa`에 있다.
이 로컬 export 성공은 Organizer Validate나 App Store 처리 성공을 대신하지 않는다.

## launch image 경고

`flutter build ipa --release` 출력:
`Launch image is set to the default placeholder icon. Replace with unique launch image.`

실제 파일은 `ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage*.png`의
1×1 투명 이미지 3개이다. PNG decode 결과 회색값 255/alpha 0을 확인했다.
`ios/Runner/Base.lproj/LaunchScreen.storyboard`는 흰 배경에 그 이미지를 표시한다.
즉 눈에 보이는 Flutter 기본 로고가 아니라 네이티브 흰 화면이다.
앱은 별도의 `lib/screens/splash_screen.dart`로 이어진다.

분류: **비차단 로컬 경고 / 실기기 확인**. 초기 흰 화면이 과하게 지속되지 않고
앱 splash·홈으로 정상 전환하는지 FLOW-01에서 확인한다. 새로운 디자인이나
서명 변경으로 경고를 자동 제거하지 않았다.

## Privacy 조사 — PARTIAL

최종 앱/IPA에 `PrivacyInfo.xcprivacy` 8개:
Flutter, image_picker_ios, in_app_purchase_storekit, package_info_plus,
shared_preferences_foundation, url_launcher_ios, video_player_avfoundation, wakelock_plus.
전부 tracking=false, collected data 목록 비어 있음.
SharedPreferences는 UserDefaults `1C8F.1`, Flutter는 FileTimestamp `0A2A.1`/`C617.1`,
SystemBootTime `35F9.1`을 선언한다. 이 선언은 앱 전체 개인정보 적합성 인증이 아니다.

`pubspec.lock`의 `path_provider_foundation 2.6.0`은 native_build=false FFI 구현이다.
설치 패키지 CHANGELOG의 2.6.0 항목은 직접 Foundation FFI 전환을 명시한다.
`lib/src/path_provider_foundation_real.dart`는 `NSSearchPathForDirectoriesInDomains`로
기기 내 디렉터리를 구하며 패키지와 앱 번들에 전용 manifest가 없다.
이 경로에서 tracking/network 수집 코드는 확인되지 않았다.

[Apple SDK 요구 사항](https://developer.apple.com/support/third-party-SDK-requirements/)은
`path_provider`/`path_provider_ios`를 manifest 대상 목록에 포함하며, binary dependency에는
signature 요구도 적용한다(2026-10-13 재확인). 현재 FFI 구현에서 이 요구를 어떻게
충족해야 하는지는 **미해결 제출 위험**이다. 전용 manifest 부재만으로 확정 거절을
선언하지 않으며, FFI라는 이유로 면제도 선언하지 않는다.

다음 조치: Organizer에서 Archive의 Privacy Report를 생성하고 배포 검증을 수행한다.
필요하면 Apple/Flutter 공식 확인 및 처리 경고의 정확한 SDK 지명을 확보한다.
이를 확인하기 전 PRIV-02/03은 미완료로 둔다. 추가 manifest/의존성 변경이 필요하면
구체적 근거와 최소 수정안을 보고하는 별도 작업으로 진행한다.

## 생성·수정 파일 기록

- validation command에 의한 tracked/untracked 프로젝트 변경: 없음.
- 생성/갱신 대상: ignored `build/`, `.dart_tool/`, `.flutter-plugins-dependencies`,
  Flutter SDK 캐시와 빌드용 iOS 로컬 생성 리소스. 기존 캐시의 모든 개별 파일 변경은
  diff 추적 대상이 아니므로 개별 변경 여부를 인증하지 않는다.
- 출력 로그: `/private/tmp/yamyam-iap-tests.log`, `yamyam-home-tests.log`,
  `yamyam-final-analyze.log`, `yamyam-final-tests.jsonl`, `yamyam-final-ios-release.log`,
  `yamyam-final-ipa.log`.
- 소스 기록: `/private/tmp/yamyam-archive-source.txt`,
  `yamyam-archive-before-status.txt`, `yamyam-archive-after-status.txt`.
- IPA 검사 임시 복사: `/private/tmp/yamyam-export-verification/`.
- 초기 감사 진단: `/private/tmp/yamyam-release-audit/` (출시 앱에 포함되지 않음).
- 사용자 요청으로 수정한 소스/테스트/번역/릴리스 문서는 위 커밋과 후속 문서 커밋에 기록한다.
- 키·프로파일·IPA·캐시·로그를 Git에 추가하지 않았다.

## 남은 수동 확인

1. STORE-01~07: 팀 일치, 계약, 실제 `vehicle_pack` 등록, 가격/지역 결정, 심사 준비.
2. IAP-01~13: 실제 Sandbox. 우선 빈 복원 소요 시간 → 같은 계정 신규 구매 →
   복원 → 재실행/오프라인 → 삭제·재설치 복원을 확인한다.
3. FLOW-01~17: 특히 연속 코스 탭, 취소/조회 실패 후 재시작, 타이머 복귀·재개,
   사진 선택, 가로 결과 화면, 언어별 권한 문구.
4. PRIV/META/DIST: Privacy Report, SDK 요구 미해결 항목, 설문/자료 최종 대조,
   Organizer Validate 및 승인된 업로드 이후 처리/경고 확인.

실행 안내: [Sandbox 가이드](IOS_IAP_SANDBOX_GUIDE.md).
전체 결과 기록: [제출 체크리스트](IOS_APP_STORE_SUBMISSION_CHECKLIST.md).
