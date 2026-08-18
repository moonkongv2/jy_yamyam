# Widget Test Split Plan

## 목적

`test/widget_test.dart`에 섞여 있는 단위 테스트, 화면 테스트, 통합 테스트와
공통 fixture를 책임별 파일로 분리한다.

현재 기준:

- 전체 테스트 코드: 15,152줄
- `test/widget_test.dart`: 9,671줄(약 64%)
- `test/widget_test.dart`의 `test`/`testWidgets` callback: 259개

분리는 테스트 동작을 변경하는 리팩터링이 아니라, 각 테스트 파일을 독립적으로
실행하고 되돌릴 수 있게 만드는 구조 개선으로 한정한다.

## 원칙

- 프로덕션 코드는 변경하지 않는다.
- 테스트 설명, callback 본문과 assertion을 그대로 유지한다.
- 이동과 assertion 수정, 중복 제거, flaky 안정화를 같은 커밋에 섞지 않는다.
- helper는 소비 파일에 로컬로 두는 것을 우선한다.
- 두 개 이상의 테스트 파일에서 실제로 재사용되는 helper만 `test/helpers/`로
  추출한다.
- 각 커밋에서 대상 테스트와 전체 테스트를 모두 통과시킨다.
- 파일 크기는 약 1,000줄 이하를 권장하되 책임 경계와 독립 실행 가능성을
  우선한다.
- 초기에는 line-count CI gate를 추가하지 않는다.

## 사전 기준선

다음 작업은 커밋하지 않고 `/private/tmp`에 결과를 기록한다.

1. 작업 트리가 깨끗한지 확인한다.
2. `flutter test test/widget_test.dart --machine`을 실행한다.
3. 전체 `flutter test --machine`을 실행한다.
4. 전체 test/pass/skip/fail 수와 테스트 source 위치 목록을 기록한다.
5. 각 테스트를 `이동`, `입증된 중복으로 제거`, `smoke로 유지` 중 하나로
   추적할 수 있는 임시 목록을 만든다.

이동 과정에서는 테스트 설명을 유지한다. 파일 이동과 동시에 불필요한
`group()` 재구성은 하지 않는다.

## 커밋 계획

### 1. `test: extract shared widget test fixtures`

다음 파일을 만든다.

- `test/helpers/app_test_harness.dart`
- `test/helpers/meal_result_fixture.dart`
- `test/helpers/test_image_fixture.dart`

다음 공통 코드를 이동한다.

- `_startApp`, `_pumpYamyamApp`
- `_mealResult`
- 임시 avatar 이미지와 PNG fixture

locale, 임시 파일처럼 외부 상태를 변경한 helper가 직접 `addTearDown`을
등록한다. 도메인 전용 fake는 아직 공통화하지 않는다.

### 2. `test: split timer config and catalog coverage`

다음 파일로 순수 테스트를 이동한다.

- `test/meal_timer_config_test.dart`
- `test/meal_ingredient_catalog_test.dart`
- `test/vehicle_catalog_test.dart`
- `test/reward_catalog_test.dart`
- `test/avatar_prompt_catalog_test.dart`

기존 `vehicle_unlock_catalog_test.dart` 등과 비슷한 테스트가 있어도 assertion
동등성이 입증되지 않으면 삭제하지 않는다.

### 3. `test: split local settings service coverage`

저장·로드, duration 정규화, onboarding 상태와 avatar migration 테스트를
`test/local_settings_service_test.dart`로 이동한다.

`SharedPreferences.setMockInitialValues`는 각 테스트에서 명시적으로 유지한다.

### 4. `test: split motivation media scheduling coverage`

다음 파일로 asset, locale voice와 schedule 계산 테스트를 이동한다.

- `test/motivation_asset_catalog_test.dart`
- `test/motivation_video_schedule_test.dart`

기존 `motivation_media_availability_test.dart`와의 중복 여부만 확인하고 이
커밋에서 동작이나 assertion은 변경하지 않는다.

### 5. `test: split result screen coverage`

ResultScreen의 성공·실패·intro·help·orientation·audio 테스트를
`test/result_screen_test.dart`로 이동한다.

`_FakeResultAudioService`와 `_FakeResultIntroController`는 이 파일에 로컬로
두고 `meal_result_fixture.dart`만 재사용한다.

### 6. `test: split onboarding and app bootstrap coverage`

다음 파일로 onboarding과 앱 초기 진입 테스트를 이동한다.

- `test/first_run_onboarding_screen_test.dart`
- `test/app_bootstrap_test.dart`

첫 실행, 이름 입력 전환과 locale fallback 테스트도 여기서 담당한다. 최종 앱
smoke coverage는 `app_bootstrap_test.dart`에 남긴다.

### 7. `test: split home screen flows`

Home 관련 테스트를 다음 파일로 모두 이동한다.

- `test/home_active_session_test.dart`
- `test/home_course_start_test.dart`
- `test/home_screen_test.dart`

범위는 다음과 같다.

- 활성 세션 표시·재개·취소·만료
- 코스 시작, ingredient picker와 quick course
- avatar 표시와 CTA
- mission, 차량 선택과 설정 반영
- `_CountingMealProgressService`

이후 커밋에서 `home_screen_test.dart`를 다시 수정하지 않도록 Home 관련 블록을
비연속 커밋으로 나누지 않는다.

### 8. `test: split avatar setup screen coverage`

AvatarSetupScreen 테스트와 전용 스크롤·slider·picker helper 및 fake를
`test/avatar_setup_screen_test.dart`로 이동한다.

공통 임시 이미지만 `test_image_fixture.dart`를 사용한다.

### 9. `test: split settings and vehicle component coverage`

다음 파일로 설정과 독립 component 테스트를 이동한다.

- `test/settings_screen_test.dart`
- `test/user_guide_screen_test.dart`
- `test/vehicle_selection_card_test.dart`
- `test/vehicle_widget_test.dart`

설정 변경, child name, guide, compact/locked vehicle card와 asset fallback을
포함한다.

### 10. `test: split road rendering coverage`

다음 파일로 Road 계층 테스트를 분리한다.

- `test/road_view_test.dart`
- `test/road_painter_test.dart`
- 기존 `test/road_course_geometry_test.dart`

RoadView layout/avatar/video/ingredient 테스트와 RoadPainter palette·course
rendering 테스트를 나눈다. footprint image 생성 helper는
`road_painter_test.dart`에 로컬로 둔다.

### 11. `test: split timer session and completion coverage`

다음 파일을 만든다.

- `test/helpers/timer_screen_test_harness.dart`
- `test/timer_screen_configuration_test.dart`
- `test/timer_screen_session_test.dart`
- `test/timer_screen_completion_test.dart`

다음 범위를 이동한다.

- avatar·ingredient·duration 전달
- active session 저장·복원·pause/resume
- course overview
- early completion·finish drive·result 전환
- orientation handoff

여러 Timer 파일에서 사용하는 course-preview pump만 helper로 추출한다.
audio/orientation fake는 가능한 한 소비 파일에 로컬로 유지한다.

### 12. `test: split timer media and lifecycle coverage`

다음 파일로 남은 Timer 테스트를 이동한다.

- `test/timer_screen_motivation_test.dart`
- `test/timer_screen_lifecycle_test.dart`

motivation 영상·음성, landscape layout, screen awake, back confirmation,
dispose 시 orientation 복구와 영문 progress/paused 문구를 포함한다.

Timer harness가 binding이나 플랫폼 상태를 변경하면 해당 helper가 반드시
`addTearDown`으로 복원한다.

### 13. `test: split meal progress and reward coverage`

다음 파일로 meal progress, reward와 history 테스트를 이동한다.

- `test/local_meal_progress_service_test.dart`
- `test/home_rewards_test.dart`
- `test/result_sticker_album_test.dart`
- `test/sticker_collection_screen_test.dart`
- `test/reward_goal_screen_test.dart`
- `test/meal_history_screen_test.dart`

앞서 만든 `home_screen_test.dart`에는 reward 블록을 추가하지 않고
`home_rewards_test.dart`로 분리해 커밋 간 결합을 피한다.

### 14. `test: remove catch-all widget test`

- 비어 있는 `test/widget_test.dart`를 삭제한다.
- startup smoke coverage가 `app_bootstrap_test.dart`에 남아 있는지 확인한다.
- `test/README.md`에 subject 기반 배치, local-first helper와 약 1,000줄 이하
  권장 원칙을 기록한다.

## 커밋별 검증

각 커밋을 만들기 전에 다음을 모두 수행한다.

1. 변경한 Dart 파일을 format한다.
2. `flutter analyze`를 실행한다.
3. 새 파일과 축소 중인 `test/widget_test.dart`를 함께 실행한다.
4. 전체 `flutter test --machine`을 실행한다.
5. 기준선과 test/pass/skip/fail 수를 비교한다.
6. `git diff --check`를 실행한다.
7. 관련 없는 변경과 review 임시 파일이 없는지 확인한다.

분리 때문에 새로 발생한 순서 의존성이나 flaky failure는 해당 커밋에서
해결한다. 기존부터 존재한 flaky 테스트만 별도 작업으로 기록한다.

## 최종 수동 확인

테스트 파일만 이동하므로 프로덕션 동작 변경은 예상하지 않는다. 최종 커밋 후
다음 대표 흐름을 한 번 확인한다.

- onboarding에서 Home까지 진입
- 설정 저장과 차량·avatar 선택
- 타이머 시작·일시정지·완료
- 결과, 스티커와 식사 기록 확인
