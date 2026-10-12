# iOS 첫 제출 — 커밋 단위 작업 계획

작성일: 2026-10-12. 상태: 계획 검토 단계; 아래 구현 커밋은 아직 실행하지 않음.

검토 상태: 이전 실행은 시간 초과했으나, 2026-10-12 재시도에서
`agy-plan-review-loop` 1회 완료. 지적 2건 중 기존 체크리스트에 있던 빈 복원
시나리오를 종료 조건에도 명시하고, Archive 전후 소스 일치·생성 변경 처리
규칙을 보강했다. 이는 계획 검토 완료이며 구현·제출 검증 완료를 뜻하지 않는다.

## 확정된 조건

- App Store Connect 카테고리: Lifestyle. 연령 설정: 전연령(사용자 확인).
- 버전 `1.0.0+1`, 아직 업로드한 빌드 없음. 로컬 검증 중 번호를 올리지 않는다.
- 앱 ID `com.yamyamrider.app`, 비소모성 상품 ID `vehicle_pack` 유지.
- Privacy/Support GitHub Pages 생성 완료. 스크린샷·앱 설명은 사용자 보관 중.
- App Store Connect IAP 상품은 미등록. 실기기 테스트는 일부만 수행됨.
- 승인 범위: 버그 2건, 사진 권한 문구 현지화, 릴리스 문서 갱신 및 검증.
  privacy manifest와 배포 Archive는 조사·검증 승인. 조사 결과 필요한 추가
  코드·의존성·서명 변경은 근거와 최소 수정안을 먼저 보고한다.
- 이번 요청은 기존 변경 커밋, 계획 검토 및 체크리스트 작성까지 수행한다.
  사용자가 계획을 확인할 시간을 두고 후속 구현을 시작한다.

## 기존 변경 커밋

1. 완료: `fdd165d` — `fix(result): fit landscape sticker rewards within available space`
   - 기존 결과 화면 레이아웃 수정과 관련 테스트를 함께 기록한다.
   - 기존 식재료 선택 위젯의 줄바꿈 변경도 보존한다(기능 변경 없음).
   - 검증 완료: `flutter test --no-pub test/result_screen_test.dart` 29개 성공,
     `git diff --check` 통과.
2. 완료: `b708761` — `chore(ios): record current signing team and debug run settings`
   - 사용자가 이미 바꾼 팀 `J3NW9PYQHA` 및 Xcode 정렬 변경을 기록한다.
   - 기존 Debug Metal API Validation 비활성화 설정도 기록한다.
   - 이 커밋은 App Store Connect 앱 소유 팀 일치를 보증하지 않는다.
   - 검증 완료: 프로젝트 `plutil -lint` 및 scheme XML 구문 검사 통과.
     직전 감사의 서명된 Release 빌드는
     성공했으나 App Store 배포 Archive 검증은 미완료임을 구분한다.

## 후속 커밋 1 — 빈 iOS 구매 복원 처리

메시지: `fix(iap): handle empty iOS restores without reporting an error`

대상: `lib/controllers/vehicle_pack_purchase_controller.dart`,
필요하면 `lib/services/in_app_purchase_client.dart`,
`test/vehicle_pack_purchase_controller_test.dart` 및 관련 fake/adapter 테스트.

- 실제 StoreKit 2는 구매 내역이 없으면 스트림 이벤트 없이 복원 호출을
  정상 종료한다. 앱의 5초 이벤트 대기가 일반 오류로 바뀌는 경로를 수정한다.
- 네이티브 복원 호출의 오류와 이벤트 대기 만료를 구분한다. 이벤트 대기만
  만료되면 구매 큐 처리를 확인하고 복원이 여전히 진행 중일 때에만
  `restoreNotFound`로 끝낸다. 모든 TimeoutException을 정상 결과로 덮지 않는다.
- 이벤트가 먼저 도착하거나 호출 반환 후 늦게 도착하는 경우에도 구매 권한을
  저장하고 성공 상태로 반영한다. 만료 이후 도착하는 유효 거래도 처리한다.
- 기존 권한을 취소하지 않는다. 저장·거래 완료 오류와 pending 상태를
  '내역 없음'으로 덮지 않는다. 반복 탭 방지와 상품 조회 재시도를 유지한다.
- Android의 소유 구매 조회와 상태 보존 동작은 유지한다.

검증: 이벤트 없는 정상 복원(null 반환), 빈 목록 반환, 성공 이벤트의 순서별
도착, 만료 후 유효 이벤트, 저장 실패, 네이티브 오류, 기존 권한 보존,
반복 복원·구매 재시도. 구매 controller/adapter/Settings/purchase sheet 테스트.

수동 확인: 구매 이력 없는 계정 복원, 구매 계정 복원, 취소·오프라인 오류.
실제 Sandbox에서 체크리스트 IAP-01의 빈 복원이 일반 오류 없이 끝나는지와
소요 시간을 기록한다. 이어서 같은 계정으로 IAP-04 구매 후 복원 성공을
확인한다. 로컬 StoreKit이나 fake 결과로 이 확인을 대체하지 않는다.
위험: 중간. 실제 Sandbox가 완료되기 전 코드 테스트만으로 복원 성공을 선언하지 않는다.

## 후속 커밋 2 — 코스 시작 중복 진입 방지

메시지: `fix(home): prevent repeated course navigation while starting`

대상: `lib/screens/home_screen.dart`, `test/home_course_start_test.dart`,
필요하면 `test/home_active_session_test.dart`.

- 첫 await 전에 시작 요청을 잠그고, 조회·기존 세션 확인·식재료 선택·타이머
  진입 동안 같은 요청의 재진입을 막는다. 기본·프리셋·커스텀 코스에 적용한다.
- 새 코스 시작과 활성 타이머 재개가 서로 겹칠 수 있는 진입도 확인하고
  필요한 경우 같은 잠금을 공유한다. 관련 없는 탐색은 변경하지 않는다.
- 취소·조회 오류·정상 복귀에서 finally로 잠금을 해제한다.
  dispose 이후에는 setState를 호출하지 않는다.
- 화면 이동 동안 실행 상태를 저장하는 기존 동작과 세션 복구를 유지한다.

검증: 지연된 세션 조회 중 실제 연속 탭, 화면/타이머 하나만 생성,
식재료 취소 후 재시도, 조회 실패 후 재시도, 활성 세션 확인·재개,
타이머 복귀 후 새 시작, await 중 홈 dispose.

수동 확인: 빠른 연속 탭, 식재료 취소, 기존 타이머 재개, 타이머 종료 후 재시작.
위험: 낮음~중간. 각 요청 종료 경로에서 버튼이 다시 동작하는지 확인한다.

## 후속 커밋 3 — 사진 권한 설명 현지화

메시지: `fix(ios): localize photo library usage descriptions`

대상: `ios/Runner/{en,ko,ja,es,pt-BR}.lproj/InfoPlist.strings`.

- `NSPhotoLibraryUsageDescription`을 5개 언어에 추가한다.
  보호자가 라이더 이미지를 선택하기 위한 선택적 사진 접근임을 자연스럽게 설명한다.
- 앱 이름·권한 종류·사진 선택 구현은 유지한다. plist의 기본 한국어 설명을 보존한다.

검증: strings 구문 검사, Release 번들 내 5개 언어 리소스와 키 확인.
수동 확인: 권한 상태를 초기화한 실기기에서 해당 OS 언어의 설명이 표시되는 경우
문구를 확인한다. 사진 선택기가 항상 권한 팝업을 띄운다고 가정하지 않는다.
위험: 낮음. 새 의존성이나 구현을 따라 쓰는 테스트는 추가하지 않는다.

## 조사 단계 — privacy manifest 및 배포 Archive

커밋 1~3과 독립적으로 읽기 전용 조사를 시작할 수 있다. 최종 번들 검증은
수정 후 다시 수행한다. 조사 결과는 후속 문서 커밋에 기록한다.

- `path_provider_foundation 2.6.0`의 FFI 구현, 최종 번들 manifest,
  SDK 목록과 required-reason API 선언을 대조한다.
- 전용 manifest 부재만으로 위반을 확정하지 않는다. Xcode Privacy Report와
  실제 업로드 처리의 판단을 구분하고, 실행하지 못한 검증은 미완료로 둔다.
- 기존 팀·인증서 설정으로 `flutter build ipa --release` 또는 Xcode Archive를
  시도한다. 최종 검증용 Archive는 추적 소스 변경이 없는 확정 커밋에서 시작하고,
  커밋 해시와 시작 시 Git 상태를 기록한다. 빌드 전후 diff를 비교한다.
- 무시되는 캐시·빌드 산출물은 커밋하지 않는다. 추적 파일의 자동 변경은
  이번 명령에서 생긴 변경만 식별하고, 빌드 전 상태를 보존한 뒤 처리한다.
  불필요한 사용자별 설정·자동 정렬 변경만 해당 범위에서 원복하며 기존 사용자
  변경을 일괄 되돌리지 않는다. 재현에 필요한 설정·의존성 변경이면 먼저 근거와
  최소 수정안을 보고하고 승인 후 별도 커밋한다.
- Archive 도중 추적 소스 내용이 바뀌었다면 기존 커밋의 검증 산출물로 기록하지
  않는다. 필요한 변경을 확정하거나 불필요한 변경을 원복한 뒤 깨끗한 소스에서
  다시 Archive하고, 최종 해시·명령·버전을 기록한다.
- Archive 생성, App Store 배포 export, 서명 검증, Organizer Validate,
  App Store Connect 업로드/처리 결과를 각각 구분한다.
- 서명 팀·인증서·권한을 바꿔 빌드를 강제로 통과시키지 않는다.
  로그인·서명 자격 증명 또는 외부 업로드가 필요하면 구체적인 결과와 함께 보고한다.
- 업로드·심사 제출은 별도 사용자 지시를 받은 뒤 수행한다.

## 후속 커밋 4 — 최종 검증·릴리스 문서 갱신

메시지: `docs(release): record validation and remaining submission checks`

대상: `docs/release_iap_checklist.md`, `docs/release_process.md`,
`docs/IOS_APP_STORE_SUBMISSION_CHECKLIST.md`, 필요하면 본 계획의 실행 상태.

- 현재 코드와 다른 과거 테스트·복원 UI 설명을 갱신한다. Lifecycle과 기존
  구매 보호자 확인은 Lifestyle에서도 유지한다. 카테고리 변경을 제안하지 않는다.
- 실행한 명령·날짜·소스 커밋·테스트 수·결과·생성 파일을 기록한다.
- 개발용 Release 서명과 App Store 배포 서명을 구분한다.
- 조사와 Sandbox·실기기 결과는 확인한 항목만 완료 처리한다.

검증 순서: 관련 테스트 → `flutter analyze` → 전체 `flutter test` →
`flutter build ios --release` → 배포 Archive 조사. 각 필수 검증 실패는
원인과 영향을 보고하며, 실패를 해결하기 전 해당 단계 완료로 기록하지 않는다.
진단용 임시 테스트가 결함을 재현하며 통과한 결과는 회귀 테스트 통과와 구분한다.

## 사용자와 함께 진행할 외부 준비

- 사용자: `vehicle_pack` 비소모성 IAP 생성, 가격·판매 지역 결정,
  계약·세금·은행 정보 확인, Sandbox 계정과 기기 준비.
- Codex: 상품 현지화 초안·심사 노트·테스트 안내 작성, 오류 결과 해석 지원.
- Sandbox는 실제 App Store Connect 상품을 사용한다. Xcode Run의
  `VehiclePack.storekit`을 None으로 바꾼 테스트 환경을 사용하고, 이 로컬
  테스트용 설정 변경을 출시 소스에 불필요하게 커밋하지 않는다.
- 첫 비소모성 IAP는 앱 버전과 함께 심사 제출한다. 상품 심사 승인 전에도
  준비된 상품과 계정으로 Sandbox 테스트를 진행할 수 있다.
- 사용자는 기존 스크린샷·설명 자료를 최종 화면과 대조하고 실기기 체크를 수행한다.
- 첫 업로드에 `1.0.0+1`을 사용한다. 성공적으로 업로드한 번호는 다음 바이너리에
  재사용하지 않는다. 번호 변경은 실제 새 업로드 바이너리 준비 단계에서만 수행한다.

## 종료 기준

코드·자동 검증 완료와 제출 준비 완료는 별도로 판단한다. 전체 자동 검증,
privacy/배포 검증, 실제 Sandbox 구매·재설치 복원 및 실기기 체크리스트,
App Store Connect IAP·메타데이터 준비가 완료된 뒤 최종 Go/No-Go를 보고한다.
실제 Sandbox의 구매 이력 없는 정상 복원(IAP-01, 소요 시간 포함)과 같은
계정의 구매 후 복원 성공도 필수 확인에 포함한다.
확인되지 않은 항목을 통과로 기록하지 않는다.

참조: [제출 체크리스트](IOS_APP_STORE_SUBMISSION_CHECKLIST.md),
[릴리스 절차](release_process.md), [IAP 문서](release_iap_checklist.md).
