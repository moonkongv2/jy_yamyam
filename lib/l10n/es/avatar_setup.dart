// ignore_for_file: annotate_overrides

import '../text_sets.dart';

class EsAvatarSetupTexts implements AvatarSetupTextSet {
  const EsAvatarSetupTexts();

  String get title => 'Crear el rider del peque';
  String get intro =>
      'Crea y sube la imagen del rider que se usará en Yamyam Rider.';
  String get selectedVehicleTitle => 'Vehículo seleccionado';
  String get currentAvatarModeTitle => 'Modo de imagen del rider';
  String get defaultImageMode => 'Usar imagen predeterminada';
  String get customAvatarMode => 'Usar rider personalizado';
  String get copyPromptMessage =>
      'Prompt copiado. Pégalo en un servicio externo de IA para usarlo.';
  String get avatarSaveFailureMessage =>
      'No se pudo guardar la imagen del rider.';
  String get avatarSavedMessage => 'Rider guardado.';
  String get defaultImageSavedMessage =>
      'Se cambió a la imagen predeterminada.';
  String get missingAvatarWarning =>
      'No se encontró la imagen del rider, así que se muestra la predeterminada.';
  String get vehicleSelectionTitle => 'Vehículo para el rider';
  String get vehicleSelectionSubtitle => 'Referencia del prompt';
  String get compositePreviewTitle => 'Vista previa';
  String get compositePreviewSubtitle => '¿Usar este aspecto en Yamyam Rider?';
  String get defaultPreviewTitle => 'Vista previa predeterminada';
  String get useDefaultImageButton => 'Usar imagen predeterminada';
  String get adjustmentTitle => 'Ajustar posición del rider';
  String get faceSizeLabel => 'Tamaño de la cara';
  String get horizontalPositionLabel => 'Posición horizontal';
  String get verticalPositionLabel => 'Posición vertical';
  String get rotationLabel => 'Inclinación';
  String get resetPositionButton => 'Restablecer posición';
  String get confirmAvatarButton => 'Usar este rider';
  String get guideTitle => 'Guía de imagen del rider';
  String get guideIntro =>
      'La app no recorta la cara automáticamente. Prepara una imagen del rider con uno de estos métodos.';
  String get promptCopyTitle => 'Prompt de imagen del rider (ejemplo)';
  String get promptHelperText =>
      'Si usas un servicio de IA, copia y pega el prompt adaptado al vehículo elegido.';
  String get promptGuideHint =>
      'Copia el prompt de ejemplo y pégalo en un servicio de IA.';
  String get promptExpandLabel => 'Abrir prompt';
  String get promptCollapseLabel => 'Cerrar prompt';
  String get promptToggleSemanticLabel => 'Abrir y cerrar prompt del rider';
  String get copyPromptButton => 'Copiar prompt';
  String get uploadTitle => 'Subir imagen del rider';
  String get uploadInstructions =>
      'Sube una imagen cuadrada del rider creada con un servicio externo de IA.\n'
      'Se verá más natural si la cara está centrada y el fondo es transparente.';
  String get uploadingButton => 'Subiendo';
  String get reuploadButton => 'Subir otra vez';
  String get uploadButton => 'Subir imagen del rider';
  String get selectedImageFallback => 'Imagen de rider seleccionada';
  String get privacyNote =>
      'La app no crea imágenes de IA ni sube fotos del peque por su cuenta.\n'
      'La selección de fotos/imágenes solo se abre cuando un adulto la inicia, y la imagen elegida se guarda solo en este dispositivo.\n'
      'Crea la imagen en el servicio externo que elijas y añade a Yamyam Rider solo la imagen final del rider.\n'
      'Antes de usar un servicio externo, revisa cómo trata fotos y datos personales.';

  String get guidePopupTitle => 'Guía para crear el rider';
  String get guideReplayTooltip => 'Ver guía de nuevo';
  String get guidePopupMethodTitle => '📸 Cómo preparar la imagen';
  String get guidePopupMethodIntro =>
      'La app no tiene recorte automático de cara. Prepara una imagen del rostro del peque que encaje en el vehículo, como en el ejemplo.';
  String get guidePopupMethod1Title => '1. Usar la app de fotos del teléfono';
  String get guidePopupMethod1Body =>
      'Usa la función de recortar sujeto o quitar fondo de Galaxy, iPhone u otra app de fotos para guardar solo la cara del peque en un formato cercano al cuadrado.';
  String get guidePopupMethod2Title => '2. Usar un servicio de IA';
  String get guidePopupMethod2Body =>
      '“Sube una imagen cuadrada del rider creada con un servicio externo de IA.”';
  String get guidePopupPrivacyTitle =>
      '🔒 ¿Por qué la app no procesa la imagen automáticamente?';
  String get guidePopupPrivacyBody =>
      'Como la app no recorta ni transforma fotos dentro de sus servidores, no envía la foto original a un servidor externo para procesarla. La selección solo se abre cuando la inicia un adulto y la imagen elegida se guarda solo en este dispositivo.';
  String get guidePopupSafetyTitle => '🛡️ Solo se usa en este dispositivo';
  String get guidePopupSafetyBody =>
      'La imagen preparada por el adulto y registrada en la app se guarda dentro del teléfono. Se usa localmente, sin servidor, inicio de sesión, publicidad ni analítica.';
  String get guidePopupConfirmButton => 'Confirmar';
}
