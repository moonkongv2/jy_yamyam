# iOS App Store 제출 체크리스트

작성일: 2026-10-12. 자동 검증 갱신: 2026-10-13. 체크는 확인한 결과에만 표시한다.
기존 감사에서 성공한 검증도 수정 후 최종 바이너리에 대해 다시 실행한다.

## 사용자 확인 사항

- [x] App Store Connect 카테고리: Lifestyle.
- [x] 대상 연령: 전연령으로 설정했다고 사용자 확인.
- [x] 업로드 이력 없음. 현재 소스 버전 `1.0.0+1`.
- [x] Privacy 및 Support GitHub Pages 생성 완료.
- [x] 스크린샷 및 앱 설명 자료 보관 완료(최종 내용 대조는 아래에서 확인).
- [ ] 실기기 테스트 전체 완료(일부만 수행한 상태).

## 테스트 기록 방식

각 테스트 결과를 다음 형식으로 남긴다. 실패·미실행·해당 없음도 명시한다.

| 항목 ID | 결과(PASS/FAIL/NOT RUN/N/A) | 빌드·소스 커밋 | 기기/OS·언어 | 재현 절차·실제 결과·증거 |
|---|---|---|---|---|
| 예: IAP-04 | NOT RUN | | | |

계정 비밀번호, 영수증 원문, 개인 사진 및 서명 파일은 기록하거나 커밋하지 않는다.

## 1. 코드와 최종 자동 검증 — Codex

- [x] AUTO-01 빈 iOS 복원 처리 수정 및 회귀 테스트 통과.
- [x] AUTO-02 코스 시작 중복 진입 수정 및 회귀 테스트 통과.
- [x] AUTO-03 사진 권한 설명 5개 언어 리소스 확인.
- [x] AUTO-04 `flutter analyze`: 명령·날짜·결과 기록.
- [x] AUTO-05 전체 `flutter test`: 성공/실패/건너뜀 수 기록.
- [x] AUTO-06 `flutter build ios --release`: 최종 소스에서 성공.
- [x] AUTO-07 버전·빌드 번호·Bundle ID·최소 iOS·SDK를 최종 앱 plist로 확인.
- [x] AUTO-08 Release는 5분 미만 설정을 정규화하고 개발 UI·가짜 구매를 노출하지 않음.
- [x] AUTO-09 최종 앱에 `.storekit`, 테스트 자료·스토어 자료 ZIP이 포함되지 않음.
- [ ] AUTO-10 최종 제출 코드 커밋 확정, tracked/untracked 변경과 생성 파일 확인.

## 2. App Store Connect IAP 준비 — 사용자, Codex 안내 지원

- [ ] STORE-01 앱 Bundle ID가 `com.yamyamrider.app`, Xcode 서명 팀과 앱 소유 팀 일치.
- [ ] STORE-02 유료 앱 계약·세금·은행 정보가 유효하며 조치 필요 항목 없음.
- [ ] STORE-03 Non-Consumable 상품 생성. Product ID는 정확히 `vehicle_pack`.
- [ ] STORE-04 상품 이름·설명 현지화, 가격·판매 지역 설정.
- [ ] STORE-05 IAP 심사 스크린샷과 심사 정보 입력, 제출 가능한 상태인지 확인.
- [ ] STORE-06 첫 IAP를 앱 버전과 함께 심사에 포함할 준비 완료.
- [ ] STORE-07 Sandbox Apple Account 생성. 새 구매 테스트용 계정과 구매 후 복원용
  계정 이력을 구분한다. 구매 이력을 초기화한 계정으로 복원 성공을 기대하지 않는다.

## 3. 실제 Sandbox 실행 준비 — 사용자와 Codex

1. IAP 상품과 계약 설정을 완료한다. 변경 사항의 Sandbox 반영에는 시간이 걸릴 수 있다.
2. 실기기에 Developer Mode를 활성화하고 개발용 서명 앱을 설치한다.
3. Xcode의 Runner > Edit Scheme > Run > Options에서 StoreKit Configuration을
   None으로 설정한다. 로컬 `VehiclePack.storekit` 환경과 결과를 구분한다.
4. 기기의 개발자 설정에서 Sandbox 계정을 연결한다. OS별 경로는 Apple 안내를 확인한다.
   테스트를 위해 일반 iCloud 계정 로그아웃을 요구하지 않는다.
5. 잠긴 차량 → 안내 → 보호자 확인 → 구매 화면에서 실제 상품 가격이 나오는지 확인한다.
6. TestFlight 검증을 수행할 경우 개발용 직접 설치 결과와 구분해 기록한다.

- [ ] ENV-01 실제 Sandbox 환경임을 확인(로컬 StoreKit 설정 미사용).
- [ ] ENV-02 상품 ID·가격을 조회할 수 있음. 조회 실패 시 계약/상품/계정/환경을 먼저 확인.

## 4. IAP 시나리오 — 실제 Sandbox

| ID | 수행 절차 | 기대 결과 |
|---|---|---|
| IAP-01 | 구매 이력 없는 계정에서 Settings의 복원 실행 | 내역 없음 표시, 권한 잠김 유지, 다음 구매/복원 가능 |
| IAP-02 | 잠긴 차량을 눌러 구매 진입. 게이트 오답·취소 후 정답 입력 | 오답/취소 시 구매 화면 미표시, 정답 후 가격·구매·복원 표시 |
| IAP-03 | 결제 시스템 화면에서 취소 | 잠금 유지, 실패와 구분된 취소 안내, 재시도 가능 |
| IAP-04 | `vehicle_pack` 신규 구매 | 결제 완료 후 프리미엄 차량 선택·타이머 사용 가능 |
| IAP-05 | 구매 버튼 연속 탭 | 구매 요청이 중복되지 않음 |
| IAP-06 | 구매 후 앱 종료·재실행, 이후 오프라인 실행 | 구매 권한 유지, 프리미엄 차량 사용 가능 |
| IAP-07 | 앱 삭제·재설치 후 같은 구매 계정으로 복원 | 복원 성공 및 프리미엄 차량 해제. 로컬 진척은 삭제되는 것이 정상 |
| IAP-08 | 다른 지원 기기에서 같은 구매 계정으로 복원 | 해당 기기도 해제. 복원 결과가 지연되어도 정상 반영 |
| IAP-09 | 재설치 후 복원 전에 이미 소유한 상품의 구매 시도 | 이미 소유한 상품 처리 후 사용 가능, 구매 UI가 영구 pending에 갇히지 않음 |
| IAP-10 | 오프라인/상품 조회 실패 후 연결을 회복하고 재시도 | 오류 안내, 잘못된 권한 부여 없음, 재시도 가능 |
| IAP-11 | 지원되는 환경에서 pending/Ask to Buy → 승인·거절 | pending 동안 잠김, 최종 승인 후 해제, 거절 시 재시도 가능 |
| IAP-12 | 거래 완료 전 앱 중단 후 재실행·복원 | 거래 재전달/복원 후 권한 확보, 완료 처리 오류가 영구적으로 막지 않음 |
| IAP-13 | 복원 버튼 연속 탭, 상품 조회·구매와 교차 조작 | 중복 요청 방지, 잘못된 성공/권한 취소 없음 |

IAP-11/12는 실제 Sandbox에서 강제로 재현하기 어려울 수 있다. 가능한 로컬 StoreKit
진단으로 보완하고 환경·제한을 기록한다. 로컬 결과를 Sandbox 통과로 표시하지 않는다.

- [ ] 위 시나리오별 결과 기록 완료. FAIL은 해결 후 재검증하고,
  강제 재현 불가능한 항목은 제한과 출시 판단을 명시.

## 5. 실기기 앱 흐름 — 사용자

- [ ] FLOW-01 신규 설치: splash 종료, 온보딩·이름 입력 후 홈 진입.
- [ ] FLOW-02 무료 차량 선택, 잠긴 차량 동작, 설정 저장·앱 재시작 후 유지.
- [ ] FLOW-03 기본·프리셋·커스텀 코스. 최소 5분·최대 60분 설정 확인.
- [ ] FLOW-04 빠른 연속 탭: 식재료 화면 하나만 열림. 취소 후 다시 시작 가능.
- [ ] FLOW-05 식재료 수동 선택·자동·끄기, 도로 표시와 수동 선택 기록 확인.
- [ ] FLOW-06 타이머 시작·진행·일시정지·재개, 소리 켜기/끄기와 화면 유지 설정.
- [ ] FLOW-07 타이머 중 잠금·백그라운드 후 복귀: 실제 경과시간 반영, 소리 중복 없음.
- [ ] FLOW-08 실행 중·일시정지 중 앱 강제 종료 후 재실행: 활성 타이머 재개/취소 정상.
- [ ] FLOW-09 조기 완료·도착 시 완료·미완료: 결과 기록·영상·스티커 지급 규칙 정상.
- [ ] FLOW-10 완료 저장 후 재시작·반복 조작: 스티커/식사 기록이 중복되지 않음.
- [ ] FLOW-11 보상 목표 생성·수정·달성·사용·취소와 재시작 후 저장 확인.
- [ ] FLOW-12 식사 이력·스티커 앨범 표시, 기록 삭제 후 앱 동작 확인.
- [ ] FLOW-13 사진 선택 취소·거부·정상 선택·아바타 저장 후 재시작.
- [ ] FLOW-14 사진 선택 후 화면을 나가도 오류 없음. 권한 설명이 표시되면 OS 언어 확인.
- [ ] FLOW-15 설정의 Privacy/Support 링크: 보호자 확인 후 열리고 앱으로 복귀 가능.
- [ ] FLOW-16 작은 iPhone·iPad, 세로/가로 및 글자 확대: 결과 스티커·보상·재시작 버튼 접근 가능.
- [ ] FLOW-17 한국어·영어·일본어·스페인어·포르투갈어에서 핵심 화면·구매 문구 확인.

실제 테스트한 기기/OS/언어를 기록한다. 지원 OS의 가장 낮은 버전을 검증할
기기가 없으면 미검증 범위를 명시한다. 고의 저장 실패 등은 자동 테스트로 보완한다.

## 6. 개인정보와 심사 자료 — 사용자, Codex 조사 지원

- [ ] PRIV-01 최종 Archive Privacy Report와 manifest를 확인.
- [ ] PRIV-02 `path_provider` FFI 구현의 manifest 적용 조사 결론 및 제출 검증 결과 기록.
- [ ] PRIV-03 Required-reason API 및 binary SDK 서명 관련 검증 오류 없음.
- [ ] PRIV-04 App Privacy 설문이 로컬 저장, 선택적 사진, StoreKit 및 지원 이메일 처리와 일치.
- [ ] META-01 Privacy/Support URL을 App Store Connect에 입력하고 접근 가능 확인.
- [ ] META-02 기존 스크린샷·설명이 최종 UI·지원 기기·기능과 일치. 디버그 UI/가짜 가격 없음.
- [ ] META-03 아바타 이미지는 외부에서 준비하여 가져옴을 설명. 앱 내부 AI 생성으로 광고하지 않음.
- [ ] META-04 현재 Age Rating 설문과 Lifestyle 설정을 최종 확인.
- [ ] META-05 App Review 연락처·심사 노트·IAP 접근 경로 입력.

심사 노트 초안(최종 UI와 대조 후 사용):

> Yamyam Rider does not require an account. To test the non-consumable Vehicle
> Pack, tap a locked vehicle on Home, continue through the information sheet,
> and complete the guardian check. Purchases use the product ID `vehicle_pack`.
> Restore Purchase is available in Settings behind the guardian check.
> Meal timers have a minimum duration of five minutes. A parent can confirm
> that the meal is finished before the timer ends to view the result and sticker.
> Custom rider images are imported from the photo library and stored locally;
> the app does not generate AI images or upload photos to a backend.

## 7. 배포 및 마지막 Go/No-Go — 사용자, Codex 검증 지원

- [ ] DIST-01 첫 업로드 번호가 미사용 `1`인지 확인. 성공 업로드 이후 새 바이너리는 번호 증가.
- [x] DIST-02 최종 소스 커밋에서 배포 Archive 생성.
- [x] DIST-03 App Store 배포 export/서명 확인. 개발용 `get-task-allow=true` 앱을 제출 산출물로 오인하지 않음.
- [ ] DIST-04 Organizer Validate 및 개인정보/SDK 관련 검증 결과 확인.
- [ ] DIST-05 사용자 업로드 지시 후 App Store Connect 업로드·처리 성공, 경고 메일 확인.
- [ ] DIST-06 업로드된 빌드를 필요한 TestFlight/실기기 테스트 결과와 연결.
- [ ] DIST-07 첫 `vehicle_pack` IAP와 앱 버전을 함께 심사에 포함.
- [ ] DIST-08 위 FAIL 및 미검증 필수 항목을 확인하고 최종 Go/No-Go 기록 후 심사 제출.

## Apple 공식 안내

- [IAP 설정](https://developer.apple.com/help/app-store-connect/configure-in-app-purchase-settings/overview-for-configuring-in-app-purchases/)
- [Sandbox 개요](https://developer.apple.com/help/app-store-connect/test-in-app-purchases/overview-of-testing-in-sandbox)
- [Sandbox 테스트](https://developer.apple.com/documentation/storekit/testing-in-app-purchases-with-sandbox)
- [SDK 개인정보 요구 사항](https://developer.apple.com/support/third-party-SDK-requirements/)

관련 계획: [커밋 단위 작업 계획](IOS_APP_STORE_RELEASE_PLAN.md).

## 이번 로컬 검증 기록

- 자동 검증 소스: `2cf2a5c`; 빌드/Archive 전후 Git 변경 없음.
- 분석 이슈 없음, 전체 테스트 542 성공·0 실패·0 건너뜀.
- Release/Archive/App Store용 export/배포 서명 검증 성공.
- DIST-04~08, PRIV-01~04, 실제 IAP/FLOW/STORE 항목은 완료로 간주하지 않는다.
- [상세 검증 결과](IOS_RELEASE_VALIDATION.md), [Sandbox 실행 가이드](IOS_IAP_SANDBOX_GUIDE.md).
