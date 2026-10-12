# vehicle_pack 등록 및 실제 Sandbox 테스트 안내

2026-10-13. 아직 App Store Connect 상품 등록 및 실제 Sandbox 테스트는 미완료.
테스트 기록은 [제출 체크리스트](IOS_APP_STORE_SUBMISSION_CHECKLIST.md)의 ID를 사용한다.

## 1. 상품 준비

1. App Store Connect에서 Yamyam Rider 앱과 소유 팀을 확인한다.
   Bundle ID는 `com.yamyamrider.app`, 현재 Xcode 팀은 `J3NW9PYQHA`이다.
2. Business의 유료 앱 계약·세금·은행 정보에서 미완료 조치를 확인한다.
3. 앱의 In-App Purchases에서 **Non-Consumable** 상품을 만든다.
   Reference Name 예: `Vehicle Pack`; Product ID: **`vehicle_pack`**.
   Product ID를 변형하거나 구독/소모성으로 만들지 않는다.
4. 사용자가 가격 및 판매 지역을 결정하고 설정한다. 로컬 StoreKit의 테스트
   가격은 실제 판매 가격 결정이나 등록 완료를 의미하지 않는다.
5. 아래 현지화 초안을 입력하고 심사 스크린샷·연락처·노트를 준비한다.
   스크린샷에는 보호자 확인 후 표시되는 실제 구매 화면을 사용한다.
6. 첫 IAP는 첫 앱 버전에 연결하여 함께 심사 제출한다. 상품은 등록하고
   필수 메타데이터를 준비한 뒤 Sandbox에서 테스트하며, 심사 승인까지 기다릴 필요는 없다.

| 언어 | 이름 초안 | 설명 초안 |
|---|---|---|
| 한국어 | 차량팩 | 한 번 구매하고 모든 프리미엄 라이더를 이용하세요. |
| 영어 | Vehicle Pack | Unlock all premium riders with one purchase. |
| 일본어 | 乗り物パック | 一度の購入ですべてのプレミアムライダーを利用できます。 |
| 스페인어 | Pack de vehículos | Desbloquea todos los pilotos prémium con una sola compra. |
| 포르투갈어(브라질) | Pacote de veículos | Desbloqueie todos os pilotos premium com uma única compra. |

동물 라이더도 포함되므로 설명은 차량만으로 한정하지 않았다.
실제 가격·판매 지역은 사용자 결정 사항이며 이 문서가 결정하지 않는다.

## 2. 실제 Sandbox 환경

1. App Store Connect의 Users and Access에서 테스트용 Sandbox Apple Account를 만든다.
   비밀번호나 계정 전체 정보는 Git에 기록하지 않는다.
2. 직접 설치 테스트라면 실기기의 Developer Mode를 켜고 Xcode로 설치한다.
   Runner > Edit Scheme > Run > Options의 **StoreKit Configuration = None**을 확인한다.
   기존 Debug scheme의 `VehiclePack.storekit`은 로컬 시뮬레이션용이다.
   테스트 중 로컬 설정을 바꿨다면 종료 후 diff를 확인하고 그 변경을 출시 커밋에 섞지 않는다.
3. OS에 맞는 개발자 설정의 Sandbox Apple Account에 로그인한다.
   일반 iCloud 계정 로그아웃은 필요하지 않다. 계정 경로는 아래 Apple 안내를 따른다.
4. 잠긴 라이더 → 안내 → 보호자 확인 → 실제 가격 조회를 확인한다.
   상품 등록 직후 조회가 안 되면 반영 시간을 두고 재실행한다.
5. 결제 창이 Sandbox 테스트임을 확인한다. 실제 과금 환경으로 보이면 구매를 진행하지 않는다.
   TestFlight 테스트는 직접 설치와 환경·빌드를 구분해서 기록한다.

## 3. 우선 실행 순서

1. **IAP-01**: 구매 이력이 없는 계정으로 Settings의 구매 복원을 실행한다.
   가격 조회가 정상인 환경에서 ‘복원할 구매 내역 없음’으로 끝나는지 확인한다.
   복원 시작부터 결과 표시까지 초 단위로 기록한다. 이벤트 대기는 최대 약 5초이며
   네이티브 호출·상품 재조회 시간은 별도이므로 전체 시간에 5초 상한을 가정하지 않는다.
2. **IAP-03**: 구매를 취소하고 잠금 유지 및 재시도를 확인한다.
3. **IAP-04/05**: 같은 계정으로 구매하고 연속 탭에도 중복 구매가 없는지 확인한다.
   모든 프리미엄 라이더를 선택할 수 있고 타이머에서 사용할 수 있어야 한다.
4. 구매 이력을 지우지 않고 Settings에서 다시 복원하여 성공을 확인한다.
5. **IAP-06**: 앱 종료·재시작 및 오프라인에서 구매 권한을 확인한다.
6. **IAP-07**: 같은 계정의 이력을 유지한 채 앱 삭제·재설치 후 복원한다.
   삭제하면 로컬 식사 진척도 삭제되므로 테스트용 데이터로 진행한다.
7. 나머지 IAP-02/08~13 및 FLOW-01~17을 체크리스트에 기록한다.
   구매 이력 초기화는 빈 복원 테스트용이며 복원 성공 테스트 전에 하지 않는다.

## 4. 문제가 생겼을 때

| 실제 결과 | 확인할 항목 |
|---|---|
| 상품/가격이 없음 | Bundle ID·팀·Product ID, 상품 필수 메타데이터, 계약, 판매 지역, 반영 시간, 네트워크, StoreKit None 여부 |
| 복원 내역 없음 | 현재 테스트 계정의 구매 이력, 이력 초기화 여부, 로컬 StoreKit 구매를 실제 Sandbox 구매로 혼동했는지 |
| 일반 오류 | 네트워크 및 Apple 서비스, 실제 오류 시각·화면, 다시 연결한 후 재시도 |
| 구매 성공인데 잠김 | 구매 환경·계정·앱 빌드, 재실행·복원 결과를 기록하고 코드 진단 요청 |
| pending이 계속됨 | 승인 대기/Ask to Buy 여부와 StoreKit 테스트 설정, 앱 복귀·재시작 결과 기록 |

지원 요청에는 체크리스트 ID, 소스 커밋/빌드, 기기/OS/언어, 재현 단계,
실제 화면·소요 시간을 포함한다. 개인 사진·비밀번호·영수증 원문은 보내지 않는다.

## 공식 근거

- [Apple IAP 설정 개요](https://developer.apple.com/help/app-store-connect/configure-in-app-purchase-settings/overview-for-configuring-in-app-purchases/)
- [Apple Sandbox 테스트](https://developer.apple.com/documentation/storekit/testing-in-app-purchases-with-sandbox)
- [제출 체크리스트와 심사 노트](IOS_APP_STORE_SUBMISSION_CHECKLIST.md)
