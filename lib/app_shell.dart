import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/auth_cubit.dart';
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
          SizedBox(width: 260, child: _DrawerContent(onNav: (_) {})),
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
        child: _DrawerContent(onNav: (_) => Navigator.of(context).pop()),
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
    final isHome = location == '/';
    final isWorkflows = location.startsWith('/workflows');
    final langCode = context.watch<LocaleCubit>().state.locale.languageCode;
    final themeMode = context.watch<ThemeCubit>().state.mode;

    return Material(
      color: colorScheme.surface,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primaryContainer,
                  colorScheme.primaryContainer.withValues(alpha: 0.7),
                ],
              ),
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                onNav('/');
                context.go('/');
              },
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.onPrimaryContainer.withValues(
                        alpha: 0.1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.asset(
                      'assets/logo.png',
                      height: 36,
                      width: 36,
                    ),
                  ),
                  const SizedBox(width: 16),
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
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: ListTile(
                    selected: isHome,
                    selectedTileColor: colorScheme.primaryContainer.withValues(
                      alpha: 0.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    leading: Icon(
                      Icons.home_outlined,
                      color: isHome
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                    title: Text(
                      l.home,
                      style: TextStyle(
                        fontWeight: isHome ? FontWeight.w600 : FontWeight.w400,
                        color: isHome
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                      ),
                    ),
                    onTap: isHome
                        ? null
                        : () {
                            onNav('/');
                            context.go('/');
                          },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: ListTile(
                    selected: isWorkflows,
                    selectedTileColor: colorScheme.primaryContainer.withValues(
                      alpha: 0.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    leading: Icon(
                      Icons.account_tree_outlined,
                      color: isWorkflows
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                    title: Text(
                      l.workflows,
                      style: TextStyle(
                        fontWeight: isWorkflows
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isWorkflows
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                      ),
                    ),
                    onTap: () {
                      onNav('/workflows');
                      context.go('/workflows');
                    },
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: const Icon(Icons.language),
                  title: Text(l.language),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      langCode == 'en' ? 'عربي' : 'EN',
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  onTap: () => context.read<LocaleCubit>().toggleLocale(),
                ),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: Icon(
                    themeMode == ThemeMode.dark
                        ? Icons.light_mode
                        : Icons.dark_mode,
                  ),
                  title: Text(
                    themeMode == ThemeMode.dark ? l.lightMode : l.darkMode,
                  ),
                  onTap: () => context.read<ThemeCubit>().toggleTheme(),
                ),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: const Icon(Icons.logout),
                  title: Text(l.logout),
                  onTap: () {
                    context.read<AuthCubit>().logout();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
