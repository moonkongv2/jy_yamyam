# Yamyam Rider 타이머 종료 반복 알람 구현 계획

작성일: 2026-10-30. 상태: 구현 및 자동 검증 완료. 실기기 확인 대기. 아래 구분에 따라 `work/timer-end-alarm` 브랜치에서 서비스·종료 UX·문서의 세 커밋으로 정리했다. main에는 병합하지 않았다.

## 목적과 범위

- 제공된 `assets/audio/timer_end.mp3`를 앱 활성 상태에서 시간 만료부터 사용자 응답까지 반복 재생한다.
- 자동 종료 확인창의 `완료`와 `아직이야` 모두 알람을 정지한다. 별도 알람 끄기 버튼이나 설정은 추가하지 않는다.
- 기존 `soundEnabled`, 결과/스티커 지급, 미완료 판정, 저장 재시도, 조기 완료 연출은 유지한다.
- 앱이 비활성화되면 정지하고 같은 화면으로 복귀하면 미확인 알람을 재개한다. 시스템 알림·백그라운드 재생·잠금 화면 알람은 범위 밖이다.
- Timey Rider 변경을 통째로 cherry-pick하지 않는다. 오디오의 반복/정지 방식만 참고하고 Yamyam의 기존 컨트롤러·서비스 구조를 따른다.
- 새 의존성, 버전/빌드 번호, 서명, IAP, iOS Scheme은 변경하지 않는다. 기존 `Runner.xcscheme` 변경과 사용자 제공 음원은 보존한다.

## 현재 구조와 반드시 보존할 차이

- `MealTimerController._updateElapsed()`는 만료 시 `arrived`로 바꾸지만 ticker를 계속 돌린다. `complete()`는 응답 시점의 경과 시간을 `actualDuration`으로 기록한다. Timey처럼 도착 시각으로 고정하거나 ticker를 중단하지 않는다.
- `TimerScreen._handleTimerChanged()`는 도착을 관찰한 뒤 post-frame 및 900ms 지연을 거쳐 `_confirmComplete(showFailureOnDecline: true)`를 호출한다.
- `_confirmComplete()`는 대화상자가 떠 있는 동안도 `_isCompleting = true`다. 이 값은 저장 중만 의미하지 않으므로 알람 정지 조건에 쓰지 않는다.
- 자동 만료창은 바깥 터치로 닫히지 않는다. `false`뿐 아니라 `null`도 `TimerCompletionFlowController.shouldRecordIncompleteResult()`에 따라 `notCompleted`로 저장한다. 이번 이식에서 뒤로가기/미완료 판정 규칙을 바꾸지 않는다.
- 시간 종료 전 수동 `식사 완료` 확인창의 `아직이야`와 `null`은 결과를 기록하지 않고 취소한다. 자동 만료창의 같은 버튼과 의미가 다르다.
- Yamyam은 `_preserveCompletion()` → pending 보존 → `recordMealResult()` → active 정리 이후 결과/조기 완료 연출로 이동한다. 결과 화면으로 저장 책임을 옮기지 않는다.
- `TimerAudioService`는 경로와 볼륨을 생성자에서 주입받을 수 있다. 이를 유지한다. Noop 구현 이름은 `NoOpTimerAudioService`다.

## UX 시나리오 계약

| 상황 | 알람 | 기존 결과/화면 처리 |
| --- | --- | --- |
| 앱 활성 상태에서 0 도달 | BGM·응원 정리 후 즉시 반복 | 기존 900ms 뒤 자동 만료창 |
| 자동 만료창 표시 중 | 계속 반복 | 팝업 표시나 `_isCompleting`만으로 정지하지 않음 |
| 자동 만료창 완료 | 정지 요청 후 정지 완료 대기 | 기존 completedAtArrival 저장·결과 이동 |
| 자동 만료창 아직이야 | 동일하게 정지 | 기존 notCompleted 저장·결과 이동. 시간 연장 아님 |
| 자동 만료창 null 응답 | 정지 | 기존 null→notCompleted 판정 유지 |
| 조기 완료 확인·선택이 모두 만료 전 | 재생 안 함 | 기존 빠른 주행/도착 효과음 또는 취소 |
| 수동 완료창을 연 채 만료 | 반복, 자동 확인창을 위에 중복 표시하지 않음 | 수동 창의 기존 결과 의미 유지 |
| 위 수동 창에서 완료/아직이야 명시 선택 | 반복 종료·재시작 금지 | 완료는 기존 완료 저장. 아직이야는 수동 취소만 수행하고, 보류된 자동 만료창을 뒤이어 한 번 표시 |
| 위 수동 창을 barrier/back으로 취소(null) | 미확인으로 남아 반복 | 수동 취소 자체는 기록 안 함. 보류된 자동 만료창을 뒤이어 한 번 표시 |
| 저장 지연/실패·재시도·삭제된 완료 정리 | 재생 안 함 | 결과 저장과 중복 지급 방지 로직 유지 |
| 백그라운드에서 만료 | 재생/새 팝업 표시를 보류 | 복귀 후 알람과 자동 만료창을 한 번 처리 |
| 울리는 중 inactive/hidden/paused/detached | 정지 | 기존 팝업이 있으면 유지. resumed에서 미확인 알람만 재개 |
| 음소거/다시 켜기 | 즉시 정지/미확인 상태이면 재개 | 대화상자와 완료 상태는 바꾸지 않음 |
| 나가기 창 표시/취소/확정 | 정지/미확인 재개/영구 정지 | 나가기 확인·일시정지·세션 정리 의미 유지 |
| 이미 만료한 세션을 앱 재실행으로 복원 | 과거 알람 재생 안 함 | 기존 자동 만료창은 표시 |
| 아직 남은 running 세션 복원 후 만료 | 정상 재생 | 기존 자동 만료창 |
| paused 세션 복원 | 무음, 재개 후 새로 만료하면 재생 | 기존 일시정지 시간 제외 계산 유지 |

수동창 중 만료의 질문 유실은 이번 연결 범위에서 보완한다. 현재 열린 수동창의 취소를 미완료 저장으로 바꾸지 않고, 원래 만료 시 제공해야 했던 자동 만료 질문을 보류했다가 이어서 제공한다. 명시 `아직이야`로 소리를 끈 경우 후속 자동창은 무음이며, 그 창에서 다시 선택해야 완료/미완료 기록이 확정된다. 수동창과 자동창의 문구와 버튼은 기존 것을 그대로 사용한다.

## 커밋 1 — 음원 등록과 반복 재생 서비스

제안 메시지: `feat(audio): add looping timer end alarm playback`

대상:

- `assets/audio/timer_end.mp3`
- `pubspec.yaml`
- `lib/catalogs/timer_audio_asset_catalog.dart`
- `lib/services/timer_audio_service.dart`
- `test/helpers/timer_screen_test_harness.dart` 및 다른 TimerAudioService 구현/Fake 검색 결과
- `test/timer_audio_asset_catalog_test.dart`
- 신규 `test/timer_end_alarm_service_test.dart`

구현:

1. 제공 파일을 편집/변환하지 않고 pubspec에 정확한 파일 경로로 등록한다. 약 3.408초, 48kHz 스테레오, 256kbps, 109,056바이트를 확인했다.
2. 카탈로그에 `timerEndAlarmAssetPath`, `timerEndAlarmVolume` 추가. 초기 앱 볼륨 배율은 0.24이며 실기기에서 기존 Yamyam 효과음(도착 0.11)과 체감 차이를 확인한다. 다른 소리 볼륨은 변경하지 않는다.
3. 인터페이스에 `startTimerEndAlarm()` / `stopTimerEndAlarm()` 추가. NoOp/Fake도 같은 커밋에서 확장하여 모든 호출부가 컴파일되게 한다.
4. 생성자의 경로/볼륨 주입 패턴에 맞춰 옵션을 추가하고 전용 AudioPlayer를 소유한다. `ReleaseMode.loop`, `PlayerMode.mediaPlayer`, 기존 audio context를 사용한다.
5. 전용 작업 큐, 요청 상태, 실제 재생 상태와 dispose 진입 상태를 두어 중복 시작과 start-stop-start 경합을 처리한다. 시작 준비의 await 뒤 최신 상태를 확인한다. 이미 발행한 play 이후 정지를 직렬로 보장한다.
6. BGM 정지를 기다린 뒤 알람을 시작한다. stopAll/dispose에 알람을 포함하고 dispose 진입부터 새 시작을 거부한다. 주입 서비스 소유권 규칙을 유지한다.
7. 재생/정지 오류는 catch/log하여 큐가 끊기거나 결과 처리가 실패하지 않게 한다. 매 tick 자동 재시도는 하지 않는다.

같은 커밋의 검증:

- 에셋 실제 존재 및 정확한 pubspec 등록. 개인 `.DS_Store` 파일의 존재에 의존하는 테스트는 만들지 않는다.
- 메서드 채널 또는 기존 플랫폼 Fake로 loop/mediaPlayer/경로/볼륨, 중복 시작, BGM 정지 순서, start 준비 중 stop/dispose, 빠른 start-stop-start, 오류 후 정리·재시작, stopAll/dispose 검증.
- 호출부 아직 미연결이므로 기존 UX는 그대로여야 한다.
- `flutter test --no-pub test/timer_audio_asset_catalog_test.dart test/timer_end_alarm_service_test.dart test/timer_audio_lifecycle_test.dart`
- `flutter analyze --no-pub`

## 커밋 2 — Yamyam 종료 확인 UX 연결

제안 메시지: `feat(timer): ring until the meal completion response`

대상:

- `lib/screens/timer_screen.dart`
- 필요 시 기존 `lib/controllers/timer_completion_flow_controller.dart`의 순수 판정 helper만 최소 확장
- 신규 `test/timer_end_alarm_test.dart`
- 기존 `test/timer_audio_lifecycle_test.dart`, `test/timer_screen_completion_test.dart`, `test/timer_screen_session_test.dart`의 정확한 호출 기대값

구현:

1. 만료 관찰, 알람 확인 여부, 원하는 재생 상태를 패널/팝업 예약 상태와 분리한다. 앱 초기 lifecycle은 binding의 실제 값으로 설정한다(null은 resumed로 처리). 새 영속 필드나 저장소 스키마는 추가하지 않는다.
2. 복원 직후 이미 arrived인 세션은 과거 알람으로 표시하여 무음 정책을 고정한다. running/paused 복원 후 이 화면에서 새 만료를 관찰하는 경우와 구별한다.
3. `_syncTimerAudioWithState()`의 BGM 분기 early return 이전에 별도 `_syncTimerEndAlarm()`을 호출한다. 반복 tick과 부모 재빌드가 재생을 매번 초기화하지 않게 한다. 재생 조건에 `_isCompleting == false`를 넣지 않는다.
4. 도착 시 신규 응원 스케줄을 차단하고 예약 음성을 취소하며 진행 중 영상/음성을 정리한다. 이미 로딩 중인 음성도 추적해 늦게 알람 위에 재생되지 않도록 한다. 비동기 정리 이후에는 요청 세대·mounted·현재 재생 조건을 다시 검사한다.
5. 자동 만료창은 앱 resumed, 나가기 창 없음, 다른 완료창 없음일 때만 기존 post-frame/900ms 경로로 표시한다. 백그라운드/나가기 때문에 보류된 예약은 복귀·나가기 취소 시 재평가한다. 예약 취소를 표시 완료로 간주하지 않도록 pending/표시 상태를 구분한다. 이미 열린 모달은 복귀 시 중복 생성하지 않는다.
6. 수동 완료창이 열려 있는 상태의 만료는 자동창 요청을 pending으로 보관하고 중복 모달을 띄우지 않는다. 열린 수동창의 `showFailureOnDecline`은 바꾸지 않는다. true면 기존 완료 결과로 종료하고 pending 자동창을 폐기한다. false는 알람만 확인 처리하고 수동 취소 의미를 유지하며, null에는 알람 확인을 기록하지 않는다. false/null 후 세션이 arrived로 남으면 수동창의 route 종료 애니메이션 완료 뒤, resumed/나가기 없음/다른 완료창 없음 조건에서 기존 900ms 지연으로 pending 자동 만료창을 한 번 표시한다. 명시 false 후에는 후속 자동창이 떠도 알람을 재시작하지 않는다. 이 pending은 나가기 확정·결과 확정·dispose에서 폐기한다.
7. 자동 만료창 응답은 true/false/null 모두 기존 완료 정책에 따라 결과를 생성하며 알람을 먼저 확인 처리한다. 명시 버튼 이벤트에서 정지 요청을 발행하고, await 이후 처리도 멱등하게 정리한다. `_isCompleting`이 false로 돌아가는 것만으로 알람을 재시작하지 않는다.
8. 저장이 필요한 응답의 순서는 `session = _activeSessionController.snapshot()` → 확인 상태 기록 및 `stopFuture = stopTimerEndAlarm()` 발행 → 기존 인자로 `_controller.complete(...)`를 즉시 호출해 result 생성 → `await stopFuture` → mounted 확인 → `_preserveCompletion(session, result)`로 고정한다. snapshot은 complete 전에 취득해야 null이 되지 않는다. complete도 stopFuture await 전에 실행해야 응답 시각의 endedAt/actualDuration이 확정되고 ticker가 멈춘다. 컨트롤러 상태가 정지 완료 전에 completed로 바뀌는 것은 의도된 순서이며, 저장·이동은 정지 완료 후에만 진행한다. 저장하지 않는 수동 false/null에는 complete를 호출하지 않는다. 음소거나 복원 무음 등 알람 재생 이력이 없는 경우 불필요한 플랫폼 정지 대기를 추가하지 않는다.
9. 미확인 상태에서 음소거/부모 config 변경/모든 lifecycle 전환/나가기/조기 완료/결과 이동/dispose를 기존 hook에서 동기화한다. 저장 실패·삭제된 세션 정리와 앱 복귀로 확인된 알람이 살아나지 않게 한다.
10. `_confirmExit()`의 기존 일시정지·재개, active 정리 완료 대기 규칙을 보존한다. 저장소/보상 지급 서비스는 수정하지 않는다. 실제 식사 경과 시간과 완료 상태는 기존 컨트롤러에 맡긴다.

같은 커밋의 검증:

- 새 위젯 테스트는 실제 `MealTimerPolicy`의 최소 5분을 유지한다. 기존 헬퍼/복원 세션과 `now` 콜백을 사용해 5분 타이머의 만료 직전 running 상태를 구성하고, 가짜 현재 시각을 만료 뒤로 이동한 다음 tester.pump로 ticker와 post-frame을 처리한다. 별도 pump(900ms)로 모달 지연을 검증한다. 실제 5분을 기다리거나 1초/100초 설정이 그대로 적용된다고 가정하지 않으며 정책/출시 플래그를 바꾸지 않는다.
- 0 시점 알람 시작과 900ms 자동창, 팝업이 열린 동안 계속 재생, 반복 tick에서 중복 시작 없음.
- 자동창의 true/false/null 결과·스티커 동작과 알람 정지 순서. 지연 stop/store Fake로 기록 시간과 저장 순서 검증.
- 만료 전 조기 완료의 무알람·기존 finishDrive/arrival 유지.
- 수동창 중 만료 후 true/false/null의 기존 결과 의미 및 확인 여부, true 후 자동창 폐기, false/null 후 route 종료와 900ms 뒤 자동 만료창 한 번 표시. 수동 false 후 후속창 무음, 후속 자동 false로 notCompleted 종료 가능, 수동 null 후 알람 유지, 중복 모달 없음.
- 음소거/부모 config/배경 이동·복귀/배경 만료/초기 비활성 상태, 아직 표시 전 900ms 사이 전환.
- 만료 후 나가기 창 열기/취소/확정, 저장 실패 재시도, 과거 만료 복원 무음, running/paused 복원.
- `flutter test --no-pub test/timer_end_alarm_test.dart test/timer_screen_completion_test.dart test/timer_screen_session_test.dart test/timer_screen_lifecycle_test.dart test/timer_audio_lifecycle_test.dart test/timer_completion_flow_controller_test.dart test/meal_timer_controller_test.dart`
- `flutter analyze --no-pub`

## 커밋 3 — 비동기 경계 회귀 검증과 문서

제안 메시지: `test(timer): cover end alarm races and document behavior`

대상:

- `test/timer_end_alarm_test.dart`, `test/timer_end_alarm_service_test.dart`
- 필요 시 `test/timer_screen_motivation_test.dart`, `test/helpers/timer_screen_test_harness.dart`
- `README.md`, `assets/audio/README.md`, 이 계획 문서

내용:

- 응원 음성 로딩/정지 대기 중 확인·음소거·background·dispose, 빠른 background/resumed 반복, pending 저장 실패와 재시도 등 결정적 Future 경합 검증을 보강한다. 핵심 UX 검증을 이 커밋까지 미루지 않는다.
- 실제 완료 저장·결과 미디어 순서, 식사 경과 시간 계산, 중복 스티커 미지급 회귀를 확인한다.
- README/음원 안내에 앱 내 반복, 확인·소리 설정·복귀·과거 복원 정책과 시스템 알람 미지원 범위를 기록한다. 라이선스 출처는 추정하지 않는다.
- 이 문서에 실제 실행한 검증, 남은 실기기 항목을 구분해서 기록한다. 커밋별로 분석·관련 테스트가 통과하는 상태를 유지한다.
- 최종 `flutter test --no-pub`, `flutter analyze --no-pub`, `git diff --check` 실행. 실패하면 원인과 영향 범위를 구분한다.

## 수동 확인과 완료 기준

- Android/iOS 실제 기기에서 30초 이상 반복, 반복 경계·음량과 다른 효과음 대비 체감 확인.
- 자동 만료창의 완료/아직이야, 뒤로가기 및 바깥 터치 동작. 아직이야가 시간 연장이 아닌 기존 미완료 결과인지 확인.
- 수동 완료창을 연 채 만료 후 true/false/null, 화면 회전·큰 글씨에서 모달 중복/버튼 접근 확인.
- 만료 전후 홈 이동·잠금·복귀, 900ms 표시 지연 중 전환, 나가기 취소/확정, 음소거 후 재개.
- 저장 지연·실패·재시도 후 무음, 결과 영상·환호와 겹침 없음, 앱 재실행 시 과거 알람 무음.
- 조기 완료·정상 완료·미완료의 실제 시간, 결과 상태, 스티커 수가 기존 정책과 일치.

완료 기준: 자동 확인창 응답까지 foreground에서 반복하고 선택 시 정지한다. 경과 시간·완료/취소 의미·보상 및 저장 복구 정책이 유지되고, 비활성 상태·확인 후·화면 이탈 후 오래된 비동기 작업이 알람을 켜지 않는다. 자동 검증 완료와 실기기/출시 확인 완료는 별도로 보고한다.

## 구현·검증 결과 (2026-10-30)

- 커밋 1~3의 변경을 구현하고 `work/timer-end-alarm` 브랜치에 분리했다. main 병합이나 스토어 업로드는 수행하지 않았다.
- 제공된 음원은 그대로 사용했다. 경로·볼륨 생성자 주입, 전용 반복 플레이어, 직렬 시작/정지와 dispose 처리를 추가했다.
- 만료 관찰/자동창 예약/알람 확인 상태를 분리했다. 자동창 중에는 반복을 유지하고, 수동 false/null 후에는 창 종료 애니메이션과 900ms 지연을 거쳐 보류된 자동 만료창을 한 번 표시한다.
- 창 종료가 프레임 사이에 완료되어도 예약이 진행되도록 post-frame 등록 시 visual update를 요청한다. 확인 응답의 결과 생성은 알람 정지 await 전에 끝내고 저장/이동만 이후로 미룬다.
- `test/timer_end_alarm_test.dart` 23개, `test/timer_end_alarm_service_test.dart` 7개로 새 시나리오/경합/서비스 설정을 검증했다. 기존 완료 테스트에는 오디오 Fake를 주입하여 네이티브 초기화와 격리했다.

| 검증 | 결과 |
| --- | --- |
| `flutter test --no-pub` | 전체 639개 통과, 실패 0 |
| `flutter analyze --no-pub` | No issues found |
| `git diff --check` | 공백 오류 없음 |

실제 기기 재생 음량·반복 경계·OS 뒤로가기/잠금·배포 데이터 업데이트 및 위 수동 확인 항목은 아직 수행하지 않았다. 앱 빌드·서명·배포 검증 완료를 의미하지 않는다. 저장소/보상 서비스·경과 시간 컨트롤러·버전/빌드 번호·서명/IAP 설정은 변경하지 않았고, 기존 iOS Run Scheme 변경은 보존했다.
