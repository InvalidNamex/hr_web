import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/auth_cubit.dart';
import '../features/requests/presentation/request_types_cubit.dart';
import '../core/localization/app_localizations.dart';
import '../core/localization/locale_cubit.dart';
import '../core/theme/theme_cubit.dart';

const double _kDrawerBreakpoint = 800;

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isPermanent = constraints.maxWidth >= _kDrawerBreakpoint;
        if (isPermanent) {
          return _PermanentShell(child: child);
        } else {
          return _CollapsibleShell(child: child);
        }
      },
    );
  }
}

// ── Wide screen: sidebar always visible ──────────────────────────────────────

class _PermanentShell extends StatelessWidget {
  const _PermanentShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 260,
            child: _DrawerContent(onNav: (_) {}),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}

// ── Narrow screen: hamburger drawer ──────────────────────────────────────────

class _CollapsibleShell extends StatelessWidget {
  const _CollapsibleShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.appTitle)),
      drawer: Drawer(
        child: _DrawerContent(
          onNav: (_) => Navigator.of(context).pop(),
        ),
      ),
      body: child,
    );
  }
}

// ── Shared drawer content ─────────────────────────────────────────────────────

class _DrawerContent extends StatelessWidget {
  const _DrawerContent({required this.onNav});

  final void Function(String route) onNav;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final location = GoRouterState.of(context).uri.toString();
    final langCode = context.watch<LocaleCubit>().state.locale.languageCode;
    final themeMode = context.watch<ThemeCubit>().state.mode;

    return Material(
      color: colorScheme.surface,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: colorScheme.primaryContainer),
            child: Row(
              children: [
                Icon(Icons.admin_panel_settings_rounded,
                    size: 40, color: colorScheme.onPrimaryContainer),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l.appTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<RequestTypesCubit, RequestTypesState>(
              builder: (context, state) {
                if (state is RequestTypesLoaded) {
                  return ListView(
                    padding: EdgeInsets.zero,
                    children: state.types.map((type) {
                      final route = '/requests/${type.id}';
                      final selected = location.startsWith(route);
                      return ListTile(
                        selected: selected,
                        leading: const Icon(Icons.folder_outlined),
                        title: Text(type.localizedName(langCode)),
                        onTap: () {
                          onNav(route);
                          context.go(route);
                        },
                      );
                    }).toList(),
                  );
                }
                if (state is RequestTypesLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is RequestTypesError) {
                  return Center(
                    child: TextButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: Text(l.retry),
                      onPressed: () =>
                          context.read<RequestTypesCubit>().loadTypes(),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          const Divider(height: 1),
          // Language toggle
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l.language),
            trailing: Text(
              langCode == 'en' ? 'عربي' : 'EN',
              style: TextStyle(
                  color: colorScheme.primary, fontWeight: FontWeight.bold),
            ),
            onTap: () => context.read<LocaleCubit>().toggleLocale(),
          ),
          // Theme toggle
          ListTile(
            leading: Icon(themeMode == ThemeMode.dark
                ? Icons.light_mode
                : Icons.dark_mode),
            title: Text(themeMode == ThemeMode.dark ? l.lightMode : l.darkMode),
            onTap: () => context.read<ThemeCubit>().toggleTheme(),
          ),
          // Logout
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(l.logout),
            onTap: () {
              context.read<AuthCubit>().logout();
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
