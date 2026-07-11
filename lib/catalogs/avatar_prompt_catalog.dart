import '../models/vehicle.dart';

abstract final class AvatarPromptCatalog {
  static const _koreanBasePrompt = '''
첨부한 아이 사진을 참고해서 아이의 주요 얼굴 특징은 유지해 주세요.
귀엽고 친근한 캐릭터 스타일로 만들어 주세요.
정사각형 1:1 헤드샷 구도로, 얼굴 중앙에 배치해 주세요.
머리카락 끝부터 턱 끝까지 머리 전체와 얼굴만 딱 잘라낸 이미지로 만들어 주세요.
목, 어깨, 몸통, 옷, 손, 전신, 차량 이미지는 절대 포함하지 마세요.
머리 일부가 잘리지 않게 하고, 얼굴 외곽에는 최소한의 여백만 남겨 주세요.
모바일 앱에 어울리는 단순하고 선명한 캐릭터풍 또는 부드러운 3D 캐릭터풍으로 만들어 주세요.
투명 배경을 권장합니다.
투명 배경이 어렵다면 단순한 흰색 또는 밝은 단색 배경으로 만들어 주세요.
텍스트, 로고, 워터마크 금지.
전신, 여러 사람, 복잡한 배경은 금지해 주세요.
''';

  static const _englishBasePrompt = '''
Use the attached child photo as reference and keep the child's main facial features.
Create a cute, friendly character-style square 1:1 headshot.
Create a tight cutout of only the full head and face, from the top of the hair to the bottom of the chin.
Do not include the neck, shoulders, torso, clothes, hands, full body, or vehicle image.
Do not crop off any part of the head, and leave only minimal padding around the face.
Use a simple, clear character style or a soft 3D character style suitable for a mobile app.
A transparent background is recommended.
If transparency is difficult, use a simple white or bright solid background.
Do not include text, logos, or watermarks.
Avoid full-body images, multiple people, or complex backgrounds.
''';

  static const _japaneseBasePrompt = '''
添付した子どもの写真を参考にし、子どもの主な顔の特徴を保ってください。
かわいく親しみやすいキャラクタースタイルにしてください。
正方形1:1のヘッドショット構図で、顔を中央に配置してください。
髪の上端からあごの下まで、頭全体と顔だけをきれいに切り抜いた画像にしてください。
首、肩、胴体、服、手、全身、車両画像は絶対に含めないでください。
頭の一部が切れないようにし、顔の外側には最小限の余白だけを残してください。
モバイルアプリに合う、シンプルで鮮明なキャラクター風、またはやわらかい3Dキャラクター風にしてください。
透明背景を推奨します。
透明背景が難しい場合は、シンプルな白または明るい単色背景にしてください。
文字、ロゴ、透かしは入れないでください。
全身、複数人、複雑な背景は避けてください。
''';

  static const _spanishBasePrompt = '''
Usa la foto adjunta del niño o niña como referencia y conserva sus principales rasgos faciales.
Crea un retrato cuadrado 1:1 de estilo personaje, tierno y amigable.
Haz un recorte ajustado solo de la cabeza completa y la cara, desde la parte superior del cabello hasta la parte inferior de la barbilla.
No incluyas cuello, hombros, torso, ropa, manos, cuerpo completo ni imagen de vehículo.
No cortes ninguna parte de la cabeza y deja solo un margen mínimo alrededor de la cara.
Usa un estilo de personaje simple y claro, o un estilo 3D suave adecuado para una app móvil.
Se recomienda fondo transparente.
Si el fondo transparente es difícil, usa un fondo blanco simple o un color claro liso.
No incluyas texto, logotipos ni marcas de agua.
Evita imágenes de cuerpo completo, varias personas o fondos complejos.
''';

  static const _portugueseBasePrompt = '''
Use a foto anexada da criança como referência e preserve as principais características faciais dela.
Crie um retrato quadrado 1:1 em estilo de personagem, fofo e amigável.
Faça um recorte justo apenas da cabeça completa e do rosto, do topo do cabelo até a parte inferior do queixo.
Não inclua pescoço, ombros, tronco, roupas, mãos, corpo inteiro nem imagem de veículo.
Não corte nenhuma parte da cabeça e deixe apenas uma margem mínima ao redor do rosto.
Use um estilo de personagem simples e claro, ou um estilo 3D suave adequado para um app móvel.
Fundo transparente é recomendado.
Se o fundo transparente for difícil, use um fundo branco simples ou uma cor clara sólida.
Não inclua texto, logotipos nem marcas d'água.
Evite imagens de corpo inteiro, várias pessoas ou fundos complexos.
''';

  static const _koreanAdditionsByVehicleId = {
    'motorcycle': '''
오토바이 라이더 컨셉으로 만들어 주세요.
귀여운 헬멧을 씌워 주세요.
필요하면 고글/선글라스를 추가해도 됩니다.
얼굴은 가리지 않게 해 주세요.
''',
    'fire_truck': '''
소방관 라이더 컨셉으로 만들어 주세요.
소방관 헬멧 또는 소방관 모자를 씌워 주세요.
밝고 든든한 느낌으로 만들어 주세요.
''',
    'police_car': '''
경찰관 라이더 컨셉으로 만들어 주세요.
경찰 모자 또는 경찰 헬멧을 씌워 주세요.
밝고 자신감 있는 표정으로 만들어 주세요.
''',
    'excavator': '''
포크레인 기사 컨셉으로 만들어 주세요.
노란 안전모를 씌워 주세요.
필요하면 작업복 느낌은 아주 약하게 넣어 주세요.
얼굴 중심을 유지해 주세요.
''',
    'airplane': '''
비행기 조종사 컨셉으로 만들어 주세요.
파일럿 모자 또는 항공 헬멧을 씌워 주세요.
밝고 자신감 있는 표정으로 만들어 주세요.
''',
    'bus': '''
버스 기사 컨셉으로 만들어 주세요.
운전기사 모자 또는 단정한 모자를 씌워 주세요.
친근하고 든든한 느낌으로 만들어 주세요.
''',
    'supercar': '''
레이서 드라이버 컨셉으로 만들어 주세요.
스포티한 모자 또는 가벼운 헬멧을 씌워 주세요.
신나고 활기찬 표정으로 만들어 주세요.
''',
    'train': '''
기차 기관사 컨셉으로 만들어 주세요.
기관사 모자 또는 기차 승무원 느낌의 모자를 씌워 주세요.
차분하고 믿음직한 느낌으로 만들어 주세요.
''',
    't_rex': '''
티라노 탐험가 컨셉으로 만들어 주세요.
귀여운 탐험가 모자 또는 공룡 테마 소품을 아주 약하게 넣어 주세요.
신나고 용감한 표정으로 만들어 주세요.
''',
    'shark': '''
상어 바다 탐험가 컨셉으로 만들어 주세요.
귀여운 선원 모자 또는 바다 테마 소품을 아주 약하게 넣어 주세요.
밝고 장난기 있는 표정으로 만들어 주세요.
''',
    'brachio': '''
브라키오 공룡 탐험가 컨셉으로 만들어 주세요.
귀여운 사파리 모자 또는 초록 공룡 테마 소품을 아주 약하게 넣어 주세요.
차분하고 다정한 표정으로 만들어 주세요.
''',
    'pteranodon': '''
프테라노돈 하늘 탐험가 컨셉으로 만들어 주세요.
귀여운 파일럿 고글 또는 하늘 테마 소품을 아주 약하게 넣어 주세요.
밝고 용감한 표정으로 만들어 주세요.
''',
  };

  static const _englishAdditionsByVehicleId = {
    'motorcycle': '''
Use a motorcycle rider concept.
Add a cute helmet.
Goggles or sunglasses are okay if needed.
Do not cover the face.
''',
    'fire_truck': '''
Use a firefighter rider concept.
Add a firefighter helmet or firefighter hat.
Make the character feel bright and dependable.
''',
    'police_car': '''
Use a police officer rider concept.
Add a police hat or police helmet.
Use a bright, confident expression.
''',
    'excavator': '''
Use an excavator operator concept.
Add a yellow safety helmet.
If needed, add only a very subtle workwear feeling.
Keep the face centered.
''',
    'airplane': '''
Use an airplane pilot concept.
Add a pilot hat or aviation helmet.
Use a bright, confident expression.
''',
    'bus': '''
Use a bus driver concept.
Add a driver hat or neat cap.
Make the character feel friendly and dependable.
''',
    'supercar': '''
Use a race driver concept.
Add a sporty cap or light helmet.
Use an excited, energetic expression.
''',
    'train': '''
Use a train engineer concept.
Add a train engineer hat or conductor-style cap.
Make the character feel calm and reliable.
''',
    't_rex': '''
Use a T-rex explorer concept.
Add a cute explorer hat or very subtle dinosaur-themed detail.
Use an excited, brave expression.
''',
    'shark': '''
Use a shark ocean explorer concept.
Add a cute sailor hat or very subtle ocean-themed detail.
Use a bright, playful expression.
''',
    'brachio': '''
Use a brachio dinosaur explorer concept.
Add a cute safari hat or very subtle green dinosaur-themed detail.
Use a calm, kind expression.
''',
    'pteranodon': '''
Use a pteranodon sky explorer concept.
Add cute pilot goggles or very subtle sky-themed detail.
Use a bright, brave expression.
''',
  };

  static const _japaneseAdditionsByVehicleId = {
    'motorcycle': '''
オートバイのライダーのコンセプトにしてください。
かわいいヘルメットをかぶせてください。
必要ならゴーグルやサングラスを追加してもかまいません。
顔は隠さないでください。
''',
    'fire_truck': '''
消防士のコンセプトにしてください。
消防士のヘルメットまたは帽子をかぶせてください。
明るく頼もしい雰囲気にしてください。
''',
    'police_car': '''
警察官のコンセプトにしてください。
警察の帽子またはヘルメットをかぶせてください。
明るく自信のある表情にしてください。
''',
    'excavator': '''
ショベルカーのオペレーターのコンセプトにしてください。
黄色い安全ヘルメットをかぶせてください。
必要なら作業服らしさをほんの少しだけ加えてください。
顔は中央に保ってください。
''',
    'airplane': '''
飛行機のパイロットのコンセプトにしてください。
パイロット帽または航空ヘルメットをかぶせてください。
明るく自信のある表情にしてください。
''',
    'bus': '''
バス運転手のコンセプトにしてください。
運転手の帽子またはきちんとした帽子をかぶせてください。
親しみやすく頼もしい雰囲気にしてください。
''',
    'supercar': '''
レーサーのコンセプトにしてください。
スポーティーな帽子または軽いヘルメットをかぶせてください。
わくわくした元気な表情にしてください。
''',
    'train': '''
電車の運転士のコンセプトにしてください。
運転士帽または車掌風の帽子をかぶせてください。
落ち着いて信頼できる雰囲気にしてください。
''',
    't_rex': '''
ティラノサウルスの探検家のコンセプトにしてください。
かわいい探検家の帽子、または恐竜テーマの小物をとても控えめに加えてください。
わくわくした勇敢な表情にしてください。
''',
    'shark': '''
サメの海の探検家のコンセプトにしてください。
かわいい船員帽、または海テーマの小物をとても控えめに加えてください。
明るく遊び心のある表情にしてください。
''',
    'brachio': '''
ブラキオ恐竜探検家のコンセプトにしてください。
かわいいサファリ帽、または緑の恐竜テーマの小物をとても控えめに加えてください。
落ち着いたやさしい表情にしてください。
''',
    'pteranodon': '''
プテラノドンの空の探検家のコンセプトにしてください。
かわいいパイロットゴーグル、または空テーマの小物をとても控えめに加えてください。
明るく勇敢な表情にしてください。
''',
  };

  static const _spanishAdditionsByVehicleId = {
    'motorcycle': '''
Usa un concepto de motociclista.
Añade un casco bonito.
Puedes añadir gafas o lentes de sol si hace falta.
No cubras la cara.
''',
    'fire_truck': '''
Usa un concepto de bombero.
Añade un casco o gorro de bombero.
Haz que el personaje se vea alegre y confiable.
''',
    'police_car': '''
Usa un concepto de policía.
Añade una gorra o casco de policía.
Usa una expresión alegre y segura.
''',
    'excavator': '''
Usa un concepto de operador de excavadora.
Añade un casco de seguridad amarillo.
Si hace falta, añade solo un toque muy sutil de ropa de trabajo.
Mantén la cara centrada.
''',
    'airplane': '''
Usa un concepto de piloto de avión.
Añade una gorra de piloto o casco de aviación.
Usa una expresión alegre y segura.
''',
    'bus': '''
Usa un concepto de conductor de autobús.
Añade una gorra de conductor o una gorra ordenada.
Haz que el personaje se vea amable y confiable.
''',
    'supercar': '''
Usa un concepto de piloto de carreras.
Añade una gorra deportiva o un casco ligero.
Usa una expresión emocionada y llena de energía.
''',
    'train': '''
Usa un concepto de maquinista de tren.
Añade una gorra de maquinista o de conductor de tren.
Haz que el personaje se vea tranquilo y confiable.
''',
    't_rex': '''
Usa un concepto de explorador de T-rex.
Añade un sombrero de explorador bonito o un detalle de dinosaurio muy sutil.
Usa una expresión emocionada y valiente.
''',
    'shark': '''
Usa un concepto de explorador oceánico de tiburón.
Añade un gorro de marinero bonito o un detalle marino muy sutil.
Usa una expresión alegre y juguetona.
''',
    'brachio': '''
Usa un concepto de explorador de braquiosaurio.
Añade un sombrero de safari bonito o un detalle verde de dinosaurio muy sutil.
Usa una expresión tranquila y amable.
''',
    'pteranodon': '''
Usa un concepto de explorador del cielo de pteranodón.
Añade gafas de piloto bonitas o un detalle del cielo muy sutil.
Usa una expresión alegre y valiente.
''',
  };

  static const _portugueseAdditionsByVehicleId = {
    'motorcycle': '''
Use um conceito de motociclista.
Adicione um capacete fofo.
Pode adicionar óculos de proteção ou óculos de sol se necessário.
Não cubra o rosto.
''',
    'fire_truck': '''
Use um conceito de bombeiro.
Adicione um capacete ou chapéu de bombeiro.
Faça o personagem parecer alegre e confiável.
''',
    'police_car': '''
Use um conceito de policial.
Adicione um boné ou capacete de policial.
Use uma expressão alegre e confiante.
''',
    'excavator': '''
Use um conceito de operador de escavadeira.
Adicione um capacete de segurança amarelo.
Se necessário, adicione apenas um toque muito sutil de roupa de trabalho.
Mantenha o rosto centralizado.
''',
    'airplane': '''
Use um conceito de piloto de avião.
Adicione um chapéu de piloto ou capacete de aviação.
Use uma expressão alegre e confiante.
''',
    'bus': '''
Use um conceito de motorista de ônibus.
Adicione um boné de motorista ou um boné arrumado.
Faça o personagem parecer amigável e confiável.
''',
    'supercar': '''
Use um conceito de piloto de corrida.
Adicione um boné esportivo ou capacete leve.
Use uma expressão animada e cheia de energia.
''',
    'train': '''
Use um conceito de maquinista de trem.
Adicione um boné de maquinista ou de condutor de trem.
Faça o personagem parecer calmo e confiável.
''',
    't_rex': '''
Use um conceito de explorador de T-rex.
Adicione um chapéu de explorador fofo ou um detalhe de dinossauro muito sutil.
Use uma expressão animada e corajosa.
''',
    'shark': '''
Use um conceito de explorador oceânico de tubarão.
Adicione um chapéu de marinheiro fofo ou um detalhe do oceano muito sutil.
Use uma expressão alegre e brincalhona.
''',
    'brachio': '''
Use um conceito de explorador de braquiossauro.
Adicione um chapéu de safári fofo ou um detalhe verde de dinossauro muito sutil.
Use uma expressão calma e gentil.
''',
    'pteranodon': '''
Use um conceito de explorador do céu de pteranodonte.
Adicione óculos de piloto fofos ou um detalhe do céu muito sutil.
Use uma expressão alegre e corajosa.
''',
  };

  static String promptForVehicle(
    VehicleDefinition vehicle,
    String languageCode,
  ) {
    final basePrompt = switch (languageCode) {
      'ko' => _koreanBasePrompt,
      'ja' => _japaneseBasePrompt,
      'es' => _spanishBasePrompt,
      'pt' => _portugueseBasePrompt,
      _ => _englishBasePrompt,
    };
    final additions = switch (languageCode) {
      'ko' => _koreanAdditionsByVehicleId,
      'ja' => _japaneseAdditionsByVehicleId,
      'es' => _spanishAdditionsByVehicleId,
      'pt' => _portugueseAdditionsByVehicleId,
      _ => _englishAdditionsByVehicleId,
    };
    final vehiclePrompt = additions[vehicle.id] ?? '';

    return '$basePrompt\n$vehiclePrompt'.trim();
  }
}
