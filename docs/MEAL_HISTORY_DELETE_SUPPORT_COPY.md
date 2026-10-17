# 식사 기록 삭제 — 외부 지원 페이지 반영 초안

작성일: 2026-10-17. 대상 기능 커밋: `62f20ee`.

Support 페이지 소스는 이 저장소에 없다. 아래 문구는 게시용 초안이며 외부 사이트에는 아직 반영하지 않았다.
반영 대상: https://florencejyrider.github.io/app-legal-pages/support/yamyam-rider/

기존 앱 전체 데이터 삭제 안내와 별도로 다음 FAQ를 추가한다.

## ko

### 식사 기록을 삭제하면 스티커와 보상도 사라지나요?

식사 기록을 삭제할 때는 기본적으로 기록만 지워지고, 받은 스티커와 보상은 유지돼요.

연결된 스티커나 보상판 칸이 있으면 “이 식사로 받은 스티커도 함께 삭제”를 선택할 수 있어요. 선택하면 보관함과 연결된 보상판에서 차감돼요.

차감 후 목표에 못 미치는 미사용 보상은 진행 중으로 돌아가요. 이미 사용한 보상은 유지돼요.

기록만 먼저 삭제하면 나중에 그 기록을 통해 스티커를 함께 삭제할 수 없어요.

## en

### Does deleting a meal record also remove its stickers and rewards?

Deleting a meal record keeps its earned stickers and rewards by default.

If the meal has linked stickers or reward board slots, you can select “Also remove stickers earned from this meal” to remove them from the collection and linked reward boards.

Unused rewards return to an in-progress state if they fall below their goal after removal. Rewards already used stay unchanged.

If you delete only the record, you cannot later use that record to remove its stickers.

## ja

### 食事記録を削除すると、シールやごほうびも消えますか？

食事記録を削除するときは、初期設定では記録だけが削除され、もらったシールとごほうびは残ります。

その食事に紐づくシールやごほうびボードのマスがある場合は、「この食事でもらったシールも削除する」を選べます。選ぶと、コレクションと関連するボードからも減ります。

シールが減って目標に届かなくなった未使用のごほうびは、進行中に戻ります。使用済みのごほうびは残ります。

記録だけを先に削除すると、あとからその記録を使ってシールも削除することはできません。

## es

### ¿Al eliminar una comida también se eliminan sus pegatinas y recompensas?

Al eliminar una comida del historial, las pegatinas y recompensas obtenidas se conservan de forma predeterminada.

Si la comida tiene pegatinas o espacios vinculados en los tableros de recompensas, puedes marcar «Eliminar también las pegatinas de esta comida» para quitarlos de la colección y de los tableros vinculados.

Las recompensas sin usar vuelven a estar en curso si dejan de alcanzar su meta. Las recompensas ya utilizadas se conservan.

Si eliminas solo el registro, después no podrás usarlo para quitar las pegatinas de esa comida.

## pt_BR

### Excluir uma refeição também remove seus adesivos e recompensas?

Ao excluir uma refeição do histórico, os adesivos e as recompensas recebidos são mantidos por padrão.

Se a refeição tiver adesivos ou espaços vinculados nos quadros de recompensas, você pode marcar “Remover também os adesivos desta refeição” para removê-los da coleção e dos quadros vinculados.

Recompensas não usadas voltam a ficar em andamento se deixarem de atingir a meta. As recompensas já utilizadas são mantidas.

Se excluir apenas o registro, você não poderá usá-lo depois para remover os adesivos daquela refeição.

## 개인정보 안내 작성 시 주의

이번 변경은 로컬 저장 방식과 서버 전송 여부를 바꾸지 않으므로 기존 개인정보 처리방침은 유지한다.
개별 기록 삭제는 앱 전체 데이터 삭제와 구분한다. 중복 지급 방지를 위한 삭제 식사 ID와 사용한 보상 이력이 남으므로,
“식사 기록을 삭제하면 관련 데이터가 모두 완전히 제거된다”라고 안내하지 않는다.
