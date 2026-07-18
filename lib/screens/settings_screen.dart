import 'dart:async';

import 'package:flutter/material.dart';

import '../catalogs/meal_course_catalog.dart';
import '../constants/child_name_limits.dart';
import '../constants/legal_support_links.dart';
import '../controllers/vehicle_pack_purchase_controller.dart';
import '../l10n/app_texts.dart';
import '../l10n/text_sets.dart';
import '../models/meal_timer_config.dart';
import '../models/purchase_entitlement.dart';
import '../services/app_version_service.dart';
import '../services/external_link_launcher.dart';
import '../theme/app_colors.dart';
import '../widgets/app/app_help_sheet.dart';
import '../widgets/purchases/guardian_gate_sheet.dart';
import '../widgets/purchases/purchase_entitlement_scope.dart';
import '../widgets/purchases/vehicle_pack_purchase_sheet.dart';
import 'user_guide_screen.dart';

const _ingredientGuideImageAssetPath = 'assets/images/ingredient_markers.png';
const _motivationVideoIntervalOptions = [
  Duration(minutes: 3),
  Duration(minutes: 5),
  Duration(minutes: 10),
];

int _normalizedMotivationVideoIntervalMinutes(Duration interval) {
  if (_motivationVideoIntervalOptions.contains(interval)) {
    return interval.inMinutes;
  }

  return _motivationVideoIntervalOptions.first.inMinutes;
}

String _courseIngredientModeLabel(
  SettingsTextSet texts,
  CourseIngredientMode mode,
) {
  return switch (mode) {
    CourseIngredientMode.off => texts.courseIngredientModeOff,
    CourseIngredientMode.manual => texts.courseIngredientModeManual,
    CourseIngredientMode.random => texts.courseIngredientModeRandom,
  };
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.config,
    required this.onConfigChanged,
    this.externalLinkLauncher,
    this.appVersionService,
  });

  final MealTimerConfig config;
  final ValueChanged<MealTimerConfig> onConfigChanged;
  final ExternalLinkLauncher? externalLinkLauncher;
  final AppVersionService? appVersionService;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late MealTimerConfig _config = widget.config;
  late final TextEditingController _childNameController = TextEditingController(
    text: widget.config.childName,
  );
  late final ExternalLinkLauncher _externalLinkLauncher;
  late Future<String> _appVersionLabel;

  @override
  void initState() {
    super.initState();
    _externalLinkLauncher =
        widget.externalLinkLauncher ?? const UrlLauncherExternalLinkLauncher();
    _appVersionLabel = _loadAppVersionLabel();
  }

  @override
  void didUpdateWidget(covariant SettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config.childName != widget.config.childName &&
        _childNameController.text != widget.config.childName) {
      _childNameController.text = widget.config.childName;
    }
  }

  @override
  void dispose() {
    _childNameController.dispose();
    super.dispose();
  }

  void _update(MealTimerConfig config) {
    setState(() => _config = config);
    widget.onConfigChanged(config);
  }

  void _saveChildName() {
    final texts = AppTexts.of(context);
    final childName = _childNameController.text.trim();
    if (childName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(texts.settings.childNameRequiredMessage)),
      );
      return;
    }
    _update(_config.copyWith(childName: childName));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texts.settings.childNameSavedMessage)),
    );
  }

  void _showIngredientHelp() {
    final texts = AppTexts.of(context).mealIngredient;
    showAppHelpSheet(
      context: context,
      title: texts.helpTitle,
      imageAssetPath: _ingredientGuideImageAssetPath,
      bodyParagraphs: texts.helpBodyParagraphs,
      bulletItems: texts.helpBulletItems,
    );
  }

  void _showMotivationVideoHelp() {
    final texts = AppTexts.of(context).settings;
    showAppHelpSheet(
      context: context,
      title: texts.motivationVideoHelpTitle,
      bodyParagraphs: texts.motivationVideoHelpBodyParagraphs,
      bulletItems: texts.motivationVideoHelpBulletItems,
    );
  }

  Future<String> _loadAppVersionLabel() {
    return (widget.appVersionService ?? PackageInfoAppVersionService())
        .loadVersionLabel();
  }

  void _openUserGuide() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const UserGuideScreen()));
  }

  void _openGuardianProtectedLink(Uri uri) {
    unawaited(
      showGuardianGateSheet(
        context,
        onPassed: () {
          unawaited(_externalLinkLauncher.open(uri));
        },
      ),
    );
  }

  void _openVehiclePackPurchaseSheet(VehiclePackPurchaseController controller) {
    unawaited(
      showGuardianGateSheet(
        context,
        onPassed: () {
          unawaited(
            showVehiclePackPurchaseSheet(
              context,
              purchaseController: controller,
            ),
          );
        },
      ),
    );
  }

  void _restoreVehiclePackPurchase(VehiclePackPurchaseController controller) {
    unawaited(
      showGuardianGateSheet(
        context,
        onPassed: () {
          unawaited(
            showVehiclePackPurchaseSheet(
              context,
              purchaseController: controller,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppTexts.of(context);
    final purchaseScope = PurchaseEntitlementScope.maybeOf(context);
    final motivationVideoIntervalMinutes =
        _normalizedMotivationVideoIntervalMinutes(
          _config.motivationVideoInterval,
        );
    final sectionTitleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontSize: 20,
      fontWeight: FontWeight.w700,
    );

    return Scaffold(
      appBar: AppBar(title: Text(texts.settings.title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(texts.settings.childNameTitle, style: sectionTitleStyle),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _childNameController,
                    maxLength: childNameMaxLength,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: texts.settings.childNameFieldLabel,
                      hintText: texts.common.defaultChildName,
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _saveChildName(),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _saveChildName,
                    child: Text(texts.settings.saveChildName),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    texts.settings.defaultMealDuration,
                    style: sectionTitleStyle,
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<int>(
                    segments: [
                      for (final minutes in MealCourseCatalog.presetMinutes)
                        ButtonSegment(
                          value: minutes,
                          label: Text(
                            texts.settings.durationSegmentLabel(minutes),
                          ),
                        ),
                    ],
                    selected: {
                      if (MealCourseCatalog.isPresetMinutes(
                        _config.duration.inMinutes,
                      ))
                        _config.duration.inMinutes,
                    },
                    emptySelectionAllowed: true,
                    onSelectionChanged: (selected) {
                      if (selected.isEmpty) {
                        return;
                      }
                      _update(
                        _config.copyWith(
                          duration: Duration(minutes: selected.first),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          texts.settings.courseIngredientModeTitle,
                          style: sectionTitleStyle,
                        ),
                      ),
                      IconButton(
                        key: const ValueKey('courseIngredientModeHelpButton'),
                        tooltip: texts.mealIngredient.helpLinkLabel,
                        onPressed: _showIngredientHelp,
                        icon: const Icon(Icons.help_outline_rounded),
                        color: AppColors.brown700,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return SizedBox(
                        width: constraints.maxWidth,
                        child: SegmentedButton<CourseIngredientMode>(
                          key: const ValueKey(
                            'courseIngredientModeSegmentedButton',
                          ),
                          showSelectedIcon: false,
                          style: const ButtonStyle(
                            padding: WidgetStatePropertyAll(
                              EdgeInsets.symmetric(horizontal: 2),
                            ),
                            textStyle: WidgetStatePropertyAll(
                              TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          segments: [
                            for (final mode in CourseIngredientMode.values)
                              ButtonSegment(
                                value: mode,
                                label: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    _courseIngredientModeLabel(
                                      texts.settings,
                                      mode,
                                    ),
                                    maxLines: 1,
                                    softWrap: false,
                                  ),
                                ),
                              ),
                          ],
                          selected: {_config.courseIngredientMode},
                          onSelectionChanged: (selected) {
                            if (selected.isEmpty) {
                              return;
                            }
                            _update(
                              _config.copyWith(
                                courseIngredientMode: selected.first,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  Text(
                    texts.settings.courseIngredientModeDescription,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(texts.settings.showRemainingTime),
                  value: _config.showRemainingTime,
                  onChanged: (value) {
                    _update(_config.copyWith(showRemainingTime: value));
                  },
                ),
                SwitchListTile(
                  title: Text(texts.settings.soundEnabled),
                  subtitle: Text(texts.settings.savedOnlySubtitle),
                  value: _config.soundEnabled,
                  onChanged: (value) {
                    _update(_config.copyWith(soundEnabled: value));
                  },
                ),
                SwitchListTile(
                  title: Text(texts.settings.keepScreenAwake),
                  subtitle: Text(texts.settings.keepScreenAwakeSubtitle),
                  value: _config.keepScreenAwake,
                  onChanged: (value) {
                    _update(_config.copyWith(keepScreenAwake: value));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          texts.settings.motivationVideoHelpTitle,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                      IconButton(
                        key: const ValueKey('motivationVideoHelpButton'),
                        tooltip: texts.settings.motivationVideoHelpTitle,
                        onPressed: _showMotivationVideoHelp,
                        icon: const Icon(Icons.help_outline_rounded),
                        color: AppColors.brown700,
                      ),
                    ],
                  ),
                ),
                SwitchListTile(
                  key: const ValueKey('motivationVideoEnabledSwitch'),
                  title: Text(texts.settings.motivationVideoEnabled),
                  value: _config.motivationVideoEnabled,
                  onChanged: (value) {
                    _update(_config.copyWith(motivationVideoEnabled: value));
                  },
                ),
                SwitchListTile(
                  key: const ValueKey('motivationVideoCustomIntervalSwitch'),
                  title: Text(texts.settings.motivationVideoCustomInterval),
                  value: _config.motivationVideoUseCustomInterval,
                  onChanged: _config.motivationVideoEnabled
                      ? (value) {
                          _update(
                            _config.copyWith(
                              motivationVideoUseCustomInterval: value,
                            ),
                          );
                        }
                      : null,
                ),
                if (_config.motivationVideoEnabled &&
                    _config.motivationVideoUseCustomInterval)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          texts.settings.motivationVideoInterval,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SegmentedButton<int>(
                            key: const ValueKey(
                              'motivationVideoIntervalSegmentedButton',
                            ),
                            segments: [
                              for (final interval
                                  in _motivationVideoIntervalOptions)
                                ButtonSegment(
                                  value: interval.inMinutes,
                                  label: Text(
                                    texts.settings
                                        .motivationVideoIntervalSegmentLabel(
                                          interval.inMinutes,
                                        ),
                                  ),
                                ),
                            ],
                            selected: {motivationVideoIntervalMinutes},
                            onSelectionChanged: (selected) {
                              if (selected.isEmpty) {
                                return;
                              }
                              _update(
                                _config.copyWith(
                                  motivationVideoInterval: Duration(
                                    minutes: selected.first,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (purchaseScope != null) ...[
            _SettingsVehiclePackCard(
              cardKey: purchaseScope.entitlement.vehiclePackUnlocked
                  ? const ValueKey('settingsUnlockedVehiclePackCard')
                  : const ValueKey('settingsVehiclePackCard'),
              entitlement: purchaseScope.entitlement,
              purchaseController: purchaseScope.purchaseController,
              onUnlockPressed:
                  purchaseScope.entitlement.vehiclePackUnlocked ||
                      purchaseScope.purchaseController == null
                  ? null
                  : () => _openVehiclePackPurchaseSheet(
                      purchaseScope.purchaseController!,
                    ),
            ),
            const SizedBox(height: 20),
          ],
          _SettingsListSection(
            key: const ValueKey('settingsHelpSupportSection'),
            title: texts.settings.helpSupportTitle,
            children: [
              ListTile(
                key: const ValueKey('userGuideSettingsTile'),
                leading: const Icon(Icons.menu_book_rounded),
                title: Text(texts.settings.userGuide),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: _openUserGuide,
              ),
              ListTile(
                key: const ValueKey('settingsRestorePurchaseTile'),
                leading: const Icon(Icons.restore_rounded),
                title: Text(texts.settings.restorePurchase),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: purchaseScope?.purchaseController == null
                    ? null
                    : () => _restoreVehiclePackPurchase(
                        purchaseScope!.purchaseController!,
                      ),
              ),
              ListTile(
                key: const ValueKey('settingsContactSupportTile'),
                leading: const Icon(Icons.support_agent_rounded),
                title: Text(texts.settings.contactSupport),
                trailing: const Icon(Icons.open_in_new_rounded),
                onTap: () =>
                    _openGuardianProtectedLink(LegalSupportLinks.supportUri),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SettingsListSection(
            key: const ValueKey('settingsAboutSection'),
            title: texts.settings.aboutTitle,
            children: [
              ListTile(
                key: const ValueKey('settingsPrivacyPolicyTile'),
                leading: const Icon(Icons.privacy_tip_rounded),
                title: Text(texts.settings.privacyPolicy),
                trailing: const Icon(Icons.open_in_new_rounded),
                onTap: () => _openGuardianProtectedLink(
                  LegalSupportLinks.privacyPolicyUri,
                ),
              ),
              ListTile(
                key: const ValueKey('settingsAppVersionRow'),
                leading: const Icon(Icons.info_outline_rounded),
                title: Text(texts.settings.appVersion),
                trailing: FutureBuilder<String>(
                  future: _appVersionLabel,
                  builder: (context, snapshot) {
                    return Text(
                      snapshot.data ?? '',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsListSection extends StatelessWidget {
  const _SettingsListSection({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _SettingsVehiclePackCard extends StatelessWidget {
  const _SettingsVehiclePackCard({
    this.cardKey = const ValueKey('settingsVehiclePackCard'),
    required this.entitlement,
    required this.purchaseController,
    required this.onUnlockPressed,
  });

  final Key cardKey;
  final PurchaseEntitlement entitlement;
  final VehiclePackPurchaseController? purchaseController;
  final VoidCallback? onUnlockPressed;

  @override
  Widget build(BuildContext context) {
    final texts = AppTexts.of(context).purchases;
    final textTheme = Theme.of(context).textTheme;
    final isUnlocked = entitlement.vehiclePackUnlocked;

    return Card(
      key: cardKey,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  isUnlocked
                      ? Icons.lock_open_rounded
                      : Icons.lock_outline_rounded,
                  color: AppColors.brown700,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    texts.vehiclePackTitle,
                    style: textTheme.titleMedium?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              isUnlocked
                  ? texts.settingsVehiclePackUnlockedBody
                  : texts.settingsVehiclePackLockedBody,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
            if (purchaseController == null) ...[
              const SizedBox(height: 10),
              Text(
                texts.settingsVehiclePackUnavailableBody,
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
            ],
            if (!isUnlocked) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                key: const ValueKey('settingsVehiclePackUnlockButton'),
                onPressed: onUnlockPressed,
                icon: const Icon(Icons.lock_open_rounded),
                label: Text(texts.settingsVehiclePackUnlockButton),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
