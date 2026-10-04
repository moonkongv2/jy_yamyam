# 첫 출시 전 수정 계획

작성일: 2026-10-04

## 범위와 현재 상태

- 대상: IOS-01, IAP-01/02, TIM-01. 결제 수정에 직접 필요한
  IAP-03의 작업 직렬화와 요청 중복 방지도 포함한다.
- REL-01: 사용자 승인으로 최소 iOS 15 및 Xcode 27 무서명 Release 빌드 검증 완료.
- 릴리스 문서는 `873855e`로 커밋했다. 현재 미커밋된 iOS 프로젝트에는 사용자가
  의도한 서명 팀 변경과 기존 Xcode 변경, 최소 iOS 15 변경이 함께 있다.
- 이번 단계는 계획 작성·검토만 수행한다. 구현 코드와 테스트는 수정하지 않는다.
- 구현은 아래 순서로 진행한다. 각 코드 커밋에 해당 회귀 테스트를 함께 넣는다.
  실패하면 다음 커밋으로 넘어가지 않고 원인을 해결한다.
- 버전 `1.0.0+1`, 앱·상품 ID, 구매 후 오프라인 사용, 보호자 게이트를 유지한다.
  의존성 업그레이드, 서버 도입, 보류 기능 활성화, P2 아바타 작업과 성능 개선은 제외한다.

## 커밋 1 — iOS Scene 초기화 정리

제안 메시지: `fix(ios): register plugins after implicit engine initialization`

목표: Xcode 27 환경에서 Scene 설정과 Flutter 플러그인 등록 시점을 일치시킨다.

파일:
- `ios/Runner/AppDelegate.swift`
- 필요할 경우 기존 최소 iOS 15 변경만 별도 staging한
  `ios/Runner.xcodeproj/project.pbxproj`

변경:
- `FlutterImplicitEngineDelegate`를 채택한다.
- `GeneratedPluginRegistrant`를 `didInitializeImplicitFlutterEngine`에서
  `engineBridge.pluginRegistry`로 등록한다. 이전 위치의 중복 등록을 제거한다.
- Scene manifest는 이미 있으므로 불필요하게 다시 작성하지 않는다.
- 프로젝트 파일의 사용자 서명 팀 변경·Xcode 정렬 변경은 이 커밋에 섞지 않는다.
  최소 OS 변경을 포함할 때는 해당 세 줄만 선택적으로 staging한다.

검증: plist 구문 검사, Xcode 27 무서명 Release 빌드. 연결 기기에서 첫 실행,
SharedPreferences 초기화, 영상, 사진 선택, StoreKit 구매·복원은 별도 확인한다.

위험: 중간. 모든 네이티브 플러그인의 초기화 시점에 영향을 준다.
되돌리기: AppDelegate 수정만 복원 가능하나, 기존 IOS-01 위험도 돌아온다.

## 커밋 2 — Android 구매 상태를 보존하는 어댑터

제안 메시지: `fix(iap): preserve pending state when restoring Android purchases`

목표: 실제 결제 완료 전 차량팩이 해제되거나 승인 처리되지 않게 한다.

파일:
- `lib/services/iap_purchase_client.dart`
- `lib/services/in_app_purchase_client.dart`
- 필요하면 작은 `lib/services/android_purchase_adapter.dart`
- `pubspec.yaml`, `pubspec.lock` (플랫폼 API를 직접 참조하는 경우에만)
- 어댑터 테스트, `test/fakes/fake_iap_purchase_client.dart`

변경:
- 설치된 Android 플러그인의 `queryPastPurchases`는 원래 상태를 보존하지만
  일반 `restorePurchases`는 조회 결과의 상태를 모두 `restored`로 바꾼다.
  Android 복원은 상태를 보존하는 조회 경로를 사용한다.
- Android 실제 `PurchaseWrapper.purchaseState`를 검사한다. pending은
  pending으로 유지하고 해제·acknowledge하지 않는다. purchased만 해제 대상으로 만든다.
- 스트림에서 들어오는 Android 거래에도 같은 방어를 적용한다.
- 명시적 복원과 자동 동기화용 조회 결과를 호출자에게 전달하는 인터페이스를 정한다.
  조회 실패는 빈 목록과 구분하고, iOS의 수동 restore 경로는 유지한다.
- 플랫폼 패키지 import가 필요하면 lockfile에 설치된
  `in_app_purchase_android 0.5.1`을 직접 의존성으로 선언한다. 패키지를 업그레이드하지 않는다.

검증: 실제 Android 구매 객체를 사용한 pending/purchased/canceled/error 매핑,
이미 acknowledge된 거래, 조회 오류, iOS 분기 미변경 테스트.
기존 IAP·차량 entitlement 테스트를 실행한다.

위험: 중간. 플랫폼별 분기와 어댑터 계약 변경이 fake에도 영향을 준다.
되돌리기: 어댑터·의존성 선언을 함께 되돌린다. 다음 결제 커밋은 이 변경에 의존한다.

## 커밋 3 — 거래 처리를 직렬화하고 복원·구매 UI 상태 정리

제안 메시지: `fix(iap): serialize transaction handling and purchase requests`

목표: 중첩 이벤트, 늦은 저장, 연속 탭이 잘못된 구매·복원 상태를 만들지 않게 한다.

파일:
- `lib/controllers/vehicle_pack_purchase_controller.dart`
- `lib/widgets/purchases/vehicle_pack_purchase_sheet.dart`
- 필요 시 `lib/screens/settings_screen.dart`
- controller·purchase sheet·settings purchase 테스트와 fake

변경:
- 구매 이벤트 배치를 직렬 처리하고 오류를 개별 거래 단위로 처리한다.
  구독 취소·dispose 이후 비동기 응답이 notifier를 갱신하지 않게 한다.
- 상품 조회와 구매 요청의 진행 상태를 즉시 표시하고 중복 진입을 차단한다.
  구매 시작 API의 false 반환, 예외, 취소에서 다시 시도할 수 있게 한다.
- Android 복원은 조회 목록 처리와 entitlement 저장 완료 후 결과를 판정한다.
- iOS는 restore API 반환과 이벤트 저장 완료를 구분한다. 먼저 도착한 이벤트는
  처리 큐를 기다리고, 늦은 이벤트를 허용할 대기 경로를 둔다. 명확한 완료 신호가
  없으면 제한 시간 종료를 빈 구매 내역으로 단정하지 않고 재시도 가능한 상태로 처리한다.
  임의의 짧은 delay를 넣어 race를 숨기지 않는다.
- 늦은 상품 조회 응답이 pending·성공·복원 결과를 덮어쓰지 않도록 한다.

검증: 느린 entitlement 저장, 복원 반환 후 이벤트 도착, 연속 구매·복원 탭,
상품 조회 중 구매, 시작 false, 스트림 오류, 처리 중 dispose 테스트.
기존 복원 내역 없음·재시도·보호자 게이트 UI 동작을 유지한다.

위험: 중간. 버튼 활성 조건과 복원 상태 전환이 달라진다.
되돌리기: 커밋 2는 유지한 채 이 커밋만 되돌릴 수 있다.

## 커밋 4 — 앱 시작·복귀 시 미완료 Android 거래 복구

제안 메시지: `fix(iap): reconcile Android purchases on startup and resume`

목표: 앱 종료 중 완료된 구매 및 실패한 거래 승인을 다시 처리한다.

파일:
- `lib/app.dart`
- `lib/controllers/vehicle_pack_purchase_controller.dart`
- `lib/services/in_app_purchase_client.dart`와 Android 어댑터
- app purchase wiring·controller·어댑터 테스트

변경:
- 앱 구매 구독 연결 뒤 시작 시, 그리고 foreground 복귀 시 Android 기존 구매를 조회한다.
  lifecycle 등록·해제를 앱 root에서 관리하고 중복 동기화를 합친다.
- 조회 응답은 커밋 3의 처리 큐에 넣는다. 수동 복원 UI나 보호자 게이트를 자동으로 열지 않는다.
- entitlement 저장 후 거래를 승인한다. Android acknowledge의 반환 코드도 확인한다.
  generic Future<void>가 반환 오류를 숨기는 경로를 성공으로 취급하지 않는다.
  `pendingCompletePurchase`와 Android `isAcknowledged`를 확인하여 이미 승인된
  거래는 성공으로 처리하고 재승인·재시도하지 않는다. 설치된 패키지의
  `InAppPurchaseAndroidPlatform.completePurchase` 반환값을 어댑터에서 검사한다.
  해당 메서드도 이미 승인된 거래를 성공으로 반환한다. PlatformAddition에
  존재하지 않는 `acknowledgePurchase` API를 사용하지 않는다.
- 완료 실패 거래는 재조회·재처리할 수 있게 한다. 앱 실행 중에는 제한된 지연 재시도를
  사용하고, 재시도 중복을 차단하며 dispose 시 timer를 해제한다.
- iOS는 기존 미완료 거래 스트림을 유지하고 실패 거래의 제한된 재시도를 지원한다.
  App Store 인증을 유발할 수 있는 자동 restore는 호출하지 않는다.
- 이미 저장한 구매·중복 이벤트도 필요한 거래 완료는 처리한다. 조회 실패·빈 응답·환불을
  이유로 기존 오프라인 entitlement를 자동 삭제하지 않는다. 환불 추적은 이번 범위 밖이다.

검증: 시작·복귀 조회, 조회 중 연속 resume, pending에서 해제되지 않음,
완료 실패 후 재시도 성공, acknowledge 오류 코드, 앱 재시작 후 미완료 거래,
이미 승인된 중복 거래에서 재승인·retry 없음, 미승인 중복 거래,
오프라인 캐시 유지, dispose 후 retry 없음.

위험: 중간. background 구매 완료·오프라인 사용을 함께 확인해야 한다.
되돌리기: 커밋 2/3은 유지한 채 자동 동기화·재시도를 제거할 수 있다.
외부 검증: Play 내부 테스트의 지연 결제 승인·취소, 네트워크 단절, 앱 종료 후 복구.

## 커밋 5 — 완료 결과 저장의 중복 방지와 부분 저장 복구

제안 메시지: `fix(progress): recover interrupted meal result writes`

목표: 기록·스티커·목표를 여러 key에 저장하는 도중 종료되어도 같은 결과를 안전하게 복구한다.

파일:
- `lib/services/local_meal_progress_service.dart`
- 필요 시 `lib/models/meal_session_result.dart`, `lib/models/meal_history_entry.dart`
- `test/local_meal_progress_service_test.dart`

변경:
- 기존 식사 기록은 유지하면서 안정적인 완료 식별자를 도입한다. 실제 타이머는
  기존 active session ID를 사용하고, 기존 호출·구버전 기록에는 호환 가능한 식별자를 제공한다.
- 완료 반영은 직렬화한다. 동일 session 재처리는 기록·스티커·목표를 다시 증가시키지 않는다.
- 반영 후의 history/inventory/active goals/earned goals를 하나의 pending-write
  journal로 먼저 저장하고, 기존 key들에 적용한 뒤 journal을 제거한다.
- 실패/재시작 시 같은 journal을 재적용한다. history 존재 여부만 보고 부분 저장을
  성공으로 판단하지 않는다. SharedPreferences 쓰기의 false 반환도 실패로 처리한다.
- 읽기 및 보상 변경 진입 전에 pending journal을 복구하고, 다른 쓰기와 경합하지 않게 한다.
  읽기·쓰기 순서 제어는 이 서비스 범위에 한정한다. 저장소 전체 재설계는 하지 않는다.
- 중복 결과 반환도 기존 결과 UI에 필요한 지급 내역을 제공한다.

검증: 같은 session 동시·반복 반영, journal 저장 전 실패, history 저장 후 종료,
inventory 또는 goal 저장 후 종료, journal 제거 실패, 새 서비스로 재실행 복구,
복구 직후 보상 변경, 구버전 기록·목표 migration.
플랫폼 저장 fake로 단계별 예외와 false 반환을 주입한다.

위험: 중간. 보상 영속성 변경이므로 기존 progress·history·reward 테스트 전체 실행.
되돌리기: 미반영 journal이 있으면 복구를 마친 뒤 되돌린다. 새 저장 key를 바로 삭제하지 않는다.

## 커밋 6 — 완료 연출 전에 결과를 보존하고 재시작 복구 연결

제안 메시지: `fix(timer): persist completion before finish animation`

목표: 완료 확인 뒤 연출·결과 화면 진입 중 종료되어도 식사와 보상을 보존한다.

파일:
- `lib/models/active_meal_timer_session.dart`
- `lib/services/active_meal_timer_session_store.dart`
- `lib/controllers/timer_active_session_controller.dart`
- `lib/controllers/timer_completion_flow_controller.dart`
- `lib/screens/timer_screen.dart`, `lib/screens/home_screen.dart`, `lib/screens/result_screen.dart`
- 저장 오류·재시도 안내가 새로 필요하면 `lib/l10n/text_sets.dart`와 다섯 언어의
  timer/home 문구. 기존에 적합한 문구가 있으면 재사용한다.
- active-session·timer completion/session·home restore·result 테스트

변경:
- 기존 활성 세션 key에 완료 대기 결과와 완료 당시 config를 함께 저장한다.
  결과에는 session ID, 종료 시각, completion status, 선택 재료, 보상 차량 ID를 보존한다.
- 완료 중 중복 진입을 막고, 완료 대기 저장을 확인한 뒤 커밋 5의 기록 반영을 수행한다.
  기록 반영 성공 뒤 활성 세션을 삭제하고 기존 연출을 이어간다.
- 완료 대기 저장 실패 시 활성 세션을 지우거나 완료 연출을 진행하지 않는다.
  저장 실패 안내와 재시도 경로를 마련하고 최초 완료 결과의 ID·시각을 유지한다.
- 활성 세션 쓰기도 직렬화하여 이전 pause/background 저장이 완료 대기 데이터를
  덮어쓰거나 삭제 후 세션을 다시 생성하지 못하게 한다.
- 재실행 시 완료 대기 세션은 기록 반영·정리한 뒤 홈을 보여준다. 완료된 타이머를
  다시 실행할 세션으로 제시하지 않는다. 기존 24시간 stale 폐기 전에 완료 복구를 한다.
  기록 반영 완료 후 연출 중 종료된 경우에도 식사·스티커·목표는 저장되어 있다.
  재실행에서 완료 연출·ResultScreen을 자동 재생하는 기능은 추가하지 않는다.
- Home의 progress/active-session 병렬 로딩을 완료 복구 뒤 일관된 조회로 연결한다.
  복구 실패 시 세션을 유지하고 새 타이머 시작으로 덮어쓰지 않게 한다.
- ResultScreen은 이미 저장한 RecordedMealSession을 받을 수 있게 해 중복 저장을 피한다.
  직접 ResultScreen을 생성하는 기존 호출은 커밋 5의 중복 방지 저장을 사용한다.
- 기존 미완료 판정·목표 보상 규칙·orientation handoff·finish audio를 유지한다.

검증: 조기 완료/도착 성공/미완료, 완료 연출 중 종료, 결과 진입 직전 종료,
각 저장 단계 실패와 재시도, 종료 직전 background 저장 경합, 오래된 완료 대기 세션,
복원 후 스티커·목표 한 번만 증가, 재시작·새 식사 시작, 다국어 저장 오류 안내,
orientation/audio 회귀.

위험: 중간. 완료·복원·홈 조회 연결을 함께 검증한다.
되돌리기: 커밋 5를 유지하고 완료 대기 세션을 반영한 뒤 wiring을 되돌린다.
외부 검증: iPhone/Android에서 완료 연출 중 강제 종료 후 기록·스티커·목표 확인.

## 영상 리소스 — 사용자 작업

MED-01은 구현 범위에서 제외한다. 사용자가 비행기 영상을 무음 리소스로 교체한다.

## 최종 검증과 역할

- Codex: 변경별 format/analyze/회귀 테스트, 마지막 전체 analyze·test,
  Xcode 27 무서명 Release 빌드, 앱 최소 OS·SDK·버전 및 응원 미디어 제외 확인.
- 사용자: iPhone 11 Pro에서 첫 실행·사진·영상·결제 확인. Play 상품·테스터 설정과
  지연 결제 시험. 서명된 Archive/AAB, App Store Connect/Play 업로드 검증은 별도 진행.
- Android 서명 비밀정보를 읽거나 출력하지 않는다. 서명된 Release 빌드가 불가능하면
  미검증으로 보고하고 사용자가 수행할 명령과 확인 항목을 제공한다.
- 코드 커밋 메시지는 위 경계를 기준으로 사용한다. 원격 push·태그·스토어 제출은 하지 않는다.
  문서의 알려진 상태 갱신은 관련 코드 커밋에 포함하되 기존 문서 전체를 다시 쓰지 않는다.

## 계획 리뷰

`agy-plan-review-loop` compact 기본 1회 검토 후 유효한 지적만 이 계획에 반영한다.
이 계획 단계에서 구현 코드 변경이나 추가 커밋은 하지 않는다.

2026-10-04 검토 완료: Antigravity 지적 3개 중 1개를 반영했다.
- 반영: 이미 승인된 거래의 재승인·retry 제외를 명시하고 실제 플랫폼 API를 확인했다.
- 미반영: 연출 종료까지 활성 세션을 보존하라는 제안. 저장 완료 후 종료되어도
  기록·보상은 유지하며, 재실행에서 결과 연출을 재생하는 것은 이번 목표가 아니다.
- 미반영: 소리 ON에서도 영상 음성을 끄라는 제안. 이번 수정은 소리 OFF 준수이며,
  기존 소리 ON의 영상·효과음 조합은 유지한다.
- 첫 파일 읽기 방식은 headless 내부 권한 거부로 리뷰 결과 없이 종료되었다.
  샌드박스를 유지하고 내용을 직접 제공하는 방식으로 검토 1회를 완료했다.
