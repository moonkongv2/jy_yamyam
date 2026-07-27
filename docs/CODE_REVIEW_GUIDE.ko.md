# 코드 리뷰 가이드

이 문서는 Yamyam Rider 프로젝트를 처음 보는 리뷰어를 위한 가이드입니다. 어떤 코드가 어떤 행동을 담당하는지, 어떤 부분이 잘 깨지는지, 어떤 테스트가 의미 있는 신호를 주는지에 집중합니다.

## 먼저 볼 파일

처음에는 아래 파일부터 훑어보면 전체 구조를 잡기 좋습니다.

- `README.md`: 제품 요약, 앱 흐름, 자산 구조, 프로젝트 구조.
- `lib/app.dart`: 앱 루트, 테마, 로컬라이즈, 초기 라우팅.
- `lib/models/meal_timer_config.dart`: 사용자가 설정하는 타이머, 선택 차량, 아바타, 미디어 옵션.
- `lib/catalogs/vehicle_catalog.dart`: 차량 순서, 라벨, 이미지 자산, 코스 타입의 기준.
- `lib/services/local_settings_service.dart`: 앱 설정 저장/로드.
- `lib/services/local_meal_progress_service.dart`: 식사 기록, 차량 스티커 인벤토리, 보상 목표 저장/로드.
- `lib/screens/home_screen.dart`, `lib/screens/timer_screen.dart`, `lib/screens/result_screen.dart`: 핵심 사용자 흐름.

이 앱은 local-first 구조입니다. 백엔드는 없고 대부분의 상태가 `SharedPreferences`에 저장되므로, 저장/로드 변경은 특히 조심해서 리뷰해야 합니다.

## 주요 동작 지도

### 온보딩과 설정

- 첫 실행 온보딩과 아이 이름 설정 라우팅은 `lib/app.dart`에서 시작합니다.
- 장기 유지되는 사용자 설정은 `MealTimerConfig`입니다.
- 설정 저장은 `LocalSettingsService`가 담당합니다.
- 커스텀 아바타 파일은 `LocalAvatarImageService`에서 정규화하고 저장합니다.
- 커스텀 아바타 설정은 전역이 아니라 차량별로 저장됩니다.

리뷰 포인트:

- 잘못되었거나 누락된 저장 값은 안전하게 fallback 되어야 합니다.
- 새 설정을 추가할 때 기존 저장 설정을 보존해야 합니다.
- UI 문구가 바뀌면 한국어와 영어 text set을 함께 갱신해야 합니다.

### 차량 선택

- 차량 정의는 `VehicleCatalog.all`에 있습니다.
- 이 순서는 차량 선택 화면과 스티커 보관함 순서에 영향을 줍니다.
- 알 수 없는 차량 ID는 표시용으로 보통 오토바이 fallback을 사용합니다.
- 응원 영상과 결과 영상은 차량 ID로 자산을 고릅니다.

리뷰 포인트:

- 화면에서 차량 목록을 중복 하드코딩하지 말고 가능하면 `VehicleCatalog.all`을 사용해야 합니다.
- 차량을 추가할 때는 이미지 자산, 프롬프트, 응원 영상, 결과 영상, 테스트, 라벨을 함께 확인해야 합니다.
- 저장 데이터가 의존할 수 있는 차량 ID 문자열은 안정적으로 유지해야 합니다.

### 타이머 흐름

- 타이머 상태와 경과 시간 계산은 `MealTimerController`가 담당합니다.
- 진행 중인 타이머 저장은 `ActiveMealTimerSessionStore`가 담당합니다.
- 화면 오케스트레이션은 주로 `TimerScreen`에 있습니다.
- 완료 처리 분기는 `TimerCompletionFlowController`와 결과 화면 진입 로직을 함께 봐야 합니다.

리뷰 포인트:

- 경과 시간은 프레임 수가 아니라 wall-clock timestamp 기준이어야 합니다.
- 일시정지, 재개, 앱 background/foreground, 진행 중 세션 복원은 고위험 경로입니다.
- 완료 시 active session을 지우고, 선택 차량과 선택 식재료가 결과 화면까지 전달되어야 합니다.

### 결과와 보상

- `ResultScreen`은 식사 결과를 한 번 기록하고 완료 피드백을 표시합니다.
- `LocalMealProgressService.recordMealResult`는 기록 생성, 차량 스티커 지급, 인벤토리 업데이트, 보상 목표 칸 채우기를 담당합니다.
- `RewardCatalog`는 `VehicleCatalog.all`에서 차량 스티커를 생성합니다.
- 완료한 식사는 선택 차량 스티커를 정확히 1개 받습니다. 미완료 식사는 스티커를 받지 않습니다.

리뷰 포인트:

- 랜덤 스티커 지급 로직을 다시 넣으면 안 됩니다.
- 미완료 식사에 스티커가 지급되면 안 됩니다.
- 선택 차량 resolution 로직이 바뀌면 결과 화면 표시와 실제 저장된 보상이 일치하는지 확인해야 합니다.
- 인벤토리 count 누적은 기존 count와 순서를 보존해야 합니다.
- 보상 목표 칸 채우기는 실제 지급된 스티커만 사용해야 하며, 관련 없는 목표를 수정하면 안 됩니다.

### 식사 기록과 스티커 보관함

- 식사 기록 화면은 `MealHistoryScreen`입니다.
- 스티커 보관함은 `StickerCollectionScreen`입니다.
- 스티커 이미지는 `RewardStickerImage`에 집중되어 있습니다.
- 보상 이름은 `RewardDefinition.labelForLanguage`에서 가져와야 합니다.

리뷰 포인트:

- 알 수 없는 reward ID가 있어도 기록/목표 화면이 crash 나면 안 됩니다.
- 미획득 스티커도 semantic label을 유지해야 합니다.
- 스티커 보관함은 `VehicleCatalog.all` 순서를 따라야 합니다.
- 명시적인 요구가 없으면 migration이나 저장 데이터 cleanup을 추가하지 않습니다.

### 응원 미디어

- 응원 영상/음성 카탈로그는 `MotivationAssetCatalog`에 있습니다.
- 표시 타이밍 규칙은 `motivation_video_schedule.dart`에 있습니다.
- 재생 오케스트레이션은 타이머 관련 controller와 service에 흩어져 있습니다.

리뷰 포인트:

- 차량별 미디어가 없을 때 안전하게 fallback 되어야 합니다.
- sound off 상태에서는 음성이 재생되면 안 됩니다.
- 타이밍 변경 시 최소 재생 간격 테스트가 유지되어야 합니다.

## 로컬라이즈 리뷰

이 프로젝트는 ARB 기반이 아닙니다. typed text set으로 문구를 관리합니다.

- 인터페이스: `lib/l10n/text_sets.dart`
- 연결: `lib/l10n/app_texts.dart`
- 한국어: `lib/l10n/ko/`
- 영어: `lib/l10n/en/`

리뷰 체크리스트:

- text set 인터페이스가 바뀌면 한국어와 영어 구현을 모두 수정해야 합니다.
- 사용자-facing 동작이 바뀌면 가이드/도움말 문구도 필요한지 확인해야 합니다.
- 기존 패턴이 아닌 이상 화면에 표시 문구를 직접 하드코딩하지 않습니다.
- 보상 이름은 `RewardDefinition.labelForLanguage`를 사용해야 합니다.

## 저장소 리뷰

중요한 로컬 저장소:

- 설정: `LocalSettingsService`
- 진행 중 타이머: `ActiveMealTimerSessionStore`
- 진행 기록, 식사 기록, 인벤토리, 목표: `LocalMealProgressService`

리뷰 체크리스트:

- 저장 데이터 decode 경로는 가능한 범위에서 malformed local data를 견뎌야 합니다.
- 정상 저장 데이터의 동작과 순서는 유지해야 합니다.
- migration이 명시되지 않았다면 저장 데이터를 삭제하거나 재작성하지 않습니다.
- 새 저장 필드는 과거 데이터에 대한 안전한 fallback을 가져야 합니다.
- 날짜와 duration 값은 parse 가능해야 하고 테스트에서 결정적으로 검증 가능해야 합니다.

## UI 리뷰

UI는 공용 디자인 토큰과 재사용 위젯을 사용합니다.

- 색상, 간격, radius, shadow, motion: `lib/theme/`
- 공용 UI primitive: `lib/widgets/app/`

리뷰 체크리스트:

- 타이머/결과 화면 변경은 portrait와 landscape를 모두 확인해야 합니다.
- 작은 viewport에서 텍스트 overflow가 없는지 확인해야 합니다.
- 이미지나 아이콘 중심 컨트롤은 semantic label을 유지해야 합니다.
- 일회성 스타일보다 기존 app widget과 theme token을 우선 사용합니다.
- 결과, 스티커 보관함, 보상 목표, 식사 기록의 보상 이미지 표현이 일관되어야 합니다.

## 알아둘 테스트

기본 검증 명령:

```bash
dart format lib test
flutter analyze
flutter test
```

주요 테스트 파일:

- `test/meal_timer_controller_test.dart`: 타이머 복원과 경과 시간 동작.
- `test/timer_active_session_controller_test.dart`: 저장된 active session 매핑.
- `test/timer_completion_flow_controller_test.dart`: 완료 플로우 분기.
- `test/active_meal_timer_session_store_test.dart`: active session 저장.
- `test/local_avatar_image_service_test.dart`: 아바타 파일 정규화/저장.
- `test/reward_sticker_image_test.dart`: 스티커 이미지 렌더링 변형.
- `test/widget_test.dart`: 앱 흐름, 로컬라이즈, 차량 카탈로그, 결과, 보상, 기록, 화면 통합.

PR이 특정 흐름을 건드릴 때는 넓고 깨지기 쉬운 테스트보다 기존 커버리지 주변에 focused test를 추가하는 편이 좋습니다.

## 고위험 리뷰 영역

- 타이머 lifecycle: 일시정지/재개, 앱 재개, active session 복원, fast finish, 도착 처리.
- 로컬 저장 데이터 encode/decode.
- 보상 지급과 보상 목표 slot filling.
- 홈 -> 타이머 -> 결과 -> 기록으로 이어지는 vehicle ID 전달.
- 차량별 커스텀 아바타 저장과 fallback.
- 로컬라이즈 인터페이스 변경.
- 미디어 자산 카탈로그와 missing asset fallback.
- 작은 portrait 또는 landscape 결과/타이머 화면 레이아웃.

## PR 리뷰 체크리스트

- 보이는 UI뿐 아니라 제품 규칙과 실제 동작이 맞는가.
- 한국어와 영어 문구가 모두 컴파일되고 의미가 일관적인가.
- 중복 리스트 대신 공용 catalog source를 사용하는가.
- migration이 의도된 게 아니라면 로컬 저장 데이터가 backward-tolerant 한가.
- 알 수 없는 ID와 누락된 자산이 안전하게 fallback 되는가.
- 변경된 동작이 적절한 수준의 테스트로 커버되는가.
- `flutter analyze`와 관련 테스트가 통과하는가.
- 관련 없는 리팩토링이나 자산 변경이 섞이지 않았는가.

## 유용한 수동 확인

UI나 플로우 변경은 가장 작은 관련 흐름을 직접 확인하는 것이 좋습니다.

- 첫 실행: 온보딩 -> 아이 이름 -> 홈.
- 차량 변경: 차량 선택 -> 타이머 시작 -> 완료 -> 결과 스티커.
- 미완료 식사: 미완료로 종료 -> 결과 -> 기록에서 스티커 없음 확인.
- 스티커 보관함: 미획득 실루엣, 획득 count, 카탈로그 순서.
- 보상 목표: 목표 생성 -> 식사 완료 -> 목표 칸 채움 -> 목표 달성.
- 타이머 lifecycle: 시작 -> 일시정지 -> 재개 -> background/restore -> 완료.
- 로컬라이즈: 영향 받은 화면을 한국어와 영어에서 반복 확인.
