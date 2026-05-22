import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../presentation/request_types_cubit.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/localization/locale_cubit.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Trigger load if the cubit is idle — handles cases where the auth
    // stream event was missed (e.g., hot reload, browser refresh timing).
    final cubit = context.read<RequestTypesCubit>();
    if (cubit.state is RequestTypesInitial) {
      cubit.loadTypes();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final langCode = context.watch<LocaleCubit>().state.locale.languageCode;

    return BlocBuilder<RequestTypesCubit, RequestTypesState>(
      builder: (context, state) {
        if (state is RequestTypesLoading || state is RequestTypesInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is RequestTypesError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 12),
                Text(state.message),
                const SizedBox(height: 12),
                FilledButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: Text(l.retry),
                  onPressed: () =>
                      context.read<RequestTypesCubit>().loadTypes(),
                ),
              ],
            ),
          );
        }

        if (state is RequestTypesLoaded) {
          if (state.types.isEmpty) {
            return Center(child: Text(l.noData));
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth < 500
                  ? 2
                  : constraints.maxWidth < 900
                      ? 3
                      : 4;

              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        l.allRequests,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.2,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final type = state.types[index];
                          return _TypeCard(
                            name: type.localizedName(langCode),
                            index: index,
                            onTap: () =>
                                context.push('/requests/${type.id}'),
                          );
                        },
                        childCount: state.types.length,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _TypeCard extends StatelessWidget {
  const _TypeCard({
    required this.name,
    required this.index,
    required this.onTap,
  });

  final String name;
  final int index;
  final VoidCallback onTap;

  static const _icons = [
    Icons.beach_access_rounded,
    Icons.sick_rounded,
    Icons.assignment_rounded,
    Icons.work_off_rounded,
    Icons.child_care_rounded,
    Icons.event_note_rounded,
    Icons.pending_actions_rounded,
    Icons.more_horiz_rounded,
  ];

  static const _colors = [
    Color(0xFF1E6091),
    Color(0xFF2ECC71),
    Color(0xFFE67E22),
    Color(0xFF9B59B6),
    Color(0xFFE74C3C),
    Color(0xFF1ABC9C),
    Color(0xFF3498DB),
    Color(0xFF95A5A6),
  ];

  @override
  Widget build(BuildContext context) {
    final color = _colors[index % _colors.length];
    final icon = _icons[index % _icons.length];

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, color.withAlpha(180)],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: Colors.white, size: 28),
              Flexible(
                child: Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
