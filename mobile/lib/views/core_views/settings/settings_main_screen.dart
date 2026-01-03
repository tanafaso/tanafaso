import 'package:azkar/services/service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SettingsMainScreen extends StatefulWidget {
  const SettingsMainScreen({super.key});

  @override
  State<SettingsMainScreen> createState() => _SettingsMainScreenState();
}

class _SettingsMainScreenState extends State<SettingsMainScreen> {
  RepeatInterval? _currentlySelectedRepeatValue;
  String? _currentlySelectedAzkarAndQuranFontFamily;
  String? _currentlySelectedNonAzkarAndNonQuranFontFamily;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final repeatInterval = await ServiceProvider.localNotificationsService
        .getCurrentNudgeInterval();
    final azkarFont =
        await ServiceProvider.fontService.getPreferredAzkarAndQuranFontFamily();
    final nonAzkarFont = await ServiceProvider.fontService
        .getPreferredNonAzkarAndNonQuranFontFamily();

    if (mounted) {
      setState(() {
        _currentlySelectedRepeatValue = repeatInterval;
        _currentlySelectedAzkarAndQuranFontFamily = azkarFont;
        _currentlySelectedNonAzkarAndNonQuranFontFamily = nonAzkarFont;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              centerTitle: true,
              backgroundColor: theme.scaffoldBackgroundColor,
              title: Text(
                "الإعدادات",
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _SettingsCard(
                    icon: Icons.notifications_outlined,
                    title: "التنبيهات",
                    child: _NotificationIntervalDropdown(
                      value: _currentlySelectedRepeatValue,
                      onChanged: (value) {
                        if (value != null) {
                          ServiceProvider.localNotificationsService
                              .setNudgeInterval(value);
                          setState(() {
                            _currentlySelectedRepeatValue = value;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SettingsCard(
                    icon: Icons.font_download_outlined,
                    title: "خط الأذكار والقرآن",
                    child: _FontFamilyDropdown(
                      value: _currentlySelectedAzkarAndQuranFontFamily,
                      previewText: 'بِسْمِ اللَّـهِ الرَّحْمَـٰنِ الرَّحِيمِ',
                      fontOptions: ServiceProvider.fontService
                          .getAllAzkarAndQuranFontFamilyOptions(),
                      onChanged: (value) {
                        if (value != null) {
                          ServiceProvider.fontService
                              .setPreferredAzkarAndQuranFontFamily(
                                  context, value);
                          setState(() {
                            _currentlySelectedAzkarAndQuranFontFamily = value;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SettingsCard(
                    icon: Icons.text_fields_outlined,
                    title: "خط ما دون الأذكار والقرآن",
                    child: _FontFamilyDropdown(
                      value: _currentlySelectedNonAzkarAndNonQuranFontFamily,
                      previewText: 'مثال على الخط العام',
                      fontOptions: ServiceProvider.fontService
                          .getAllNonAzkarAndNonQuranFontFamilyOptions(),
                      onChanged: (value) {
                        if (value != null) {
                          ServiceProvider.fontService
                              .setPreferredNonAzkarAndNonQuranFontFamily(
                                  context, value);
                          setState(() {
                            _currentlySelectedNonAzkarAndNonQuranFontFamily =
                                value;
                          });
                        }
                      },
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      color: colorScheme.surface,
      shadowColor: colorScheme.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: colorScheme.secondaryContainer,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _NotificationIntervalDropdown extends StatelessWidget {
  final RepeatInterval? value;
  final ValueChanged<RepeatInterval?> onChanged;

  const _NotificationIntervalDropdown({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.tertiary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.tertiaryContainer,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<RepeatInterval>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: colorScheme.onTertiary),
          borderRadius: BorderRadius.circular(12),
          dropdownColor: colorScheme.surface,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onTertiary,
          ),
          onChanged: onChanged,
          items: [
            RepeatInterval.daily,
            RepeatInterval.weekly,
          ].map((interval) {
            return DropdownMenuItem<RepeatInterval>(
              value: interval,
              child: Text(
                ServiceProvider.localNotificationsService
                    .nudgeIntervalToString(interval),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _FontFamilyDropdown extends StatelessWidget {
  final String? value;
  final String previewText;
  final List<String> fontOptions;
  final ValueChanged<String?> onChanged;

  const _FontFamilyDropdown({
    required this.value,
    required this.previewText,
    required this.fontOptions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.tertiary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.tertiaryContainer,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: colorScheme.onTertiary),
          borderRadius: BorderRadius.circular(12),
          dropdownColor: colorScheme.surface,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onTertiary,
          ),
          onChanged: onChanged,
          items: fontOptions.map((fontFamily) {
            return DropdownMenuItem<String>(
              value: fontFamily,
              child: Text(
                previewText,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: fontFamily,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
