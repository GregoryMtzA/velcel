import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:issel_code_widgets/issel_code_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velcel/core/app/navigation.dart';
import 'package:velcel/features/widgets/menu_drawer.dart';

class ConfiguracionScreen extends StatelessWidget {
  const ConfiguracionScreen({super.key});

  static const _themeModeKey = 'theme_mode';

  IsselThemeController get _themeController =>
      GetIt.instance<IsselThemeController>();

  Future<void> _persistThemeMode(ThemeMode mode) async {
    await GetIt.instance<SharedPreferences>().setString(
      _themeModeKey,
      mode.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeController = _themeController;

    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        final theme = Theme.of(context);
        final colors = theme.colorScheme;

        return Scaffold(
          drawer: const MenuDrawer(selected: MenuDestination.settings),
          appBar: AppBar(
            backgroundColor: colors.surface,
            foregroundColor: colors.onSurface,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            title: Text(
              'Configuración',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: NavigationService.appBarLeading(
              context,
            ),
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 820;
                final horizontalPadding =
                    constraints.maxWidth >= 900 ? 32.0 : 20.0;
                final availableHeight = constraints.maxHeight - 56;
                final content = ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: _appearanceCard(context, themeController),
                );

                final scrollContent = isWide
                    ? ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: availableHeight > 0 ? availableHeight : 0,
                        ),
                        child: Center(child: content),
                      )
                    : Align(
                        alignment: Alignment.topCenter,
                        child: content,
                      );

                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    24,
                    horizontalPadding,
                    32,
                  ),
                  child: scrollContent,
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _appearanceCard(
    BuildContext context,
    IsselThemeController themeController,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.palette_outlined, color: colors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Apariencia',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IsselPill(
                text: _themeModeLabel(themeController.themeMode),
                height: 30,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                color: colors.surfaceContainer,
                textColor: colors.primary,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Selecciona cómo quieres ver la aplicación.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.outline,
            ),
          ),
          const SizedBox(height: 20),
          IsselThemeSelector(
            controller: themeController,
            descriptions: const {
              ThemeMode.system: 'Sigue la preferencia de Windows.',
              ThemeMode.light: 'Una interfaz luminosa y abierta.',
              ThemeMode.dark: 'Reduce el brillo en ambientes oscuros.',
            },
            onChanged: _persistThemeMode,
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                _themeIcon(themeController.themeMode),
                size: 20,
                color: colors.outline,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _themeDescription(themeController.themeMode),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.outline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _themeIcon(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => Icons.light_mode_outlined,
      ThemeMode.dark => Icons.dark_mode_outlined,
      ThemeMode.system => Icons.brightness_auto_outlined,
    };
  }

  String _themeModeLabel(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'Claro',
      ThemeMode.dark => 'Oscuro',
      ThemeMode.system => 'Sistema',
    };
  }

  String _themeDescription(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'Se mantiene el tema claro.',
      ThemeMode.dark => 'Se mantiene el tema oscuro.',
      ThemeMode.system => 'Se adapta al tema configurado en Windows.',
    };
  }
}
