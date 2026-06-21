import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../presentation/workflows_cubit.dart';

class WorkflowsPage extends StatefulWidget {
  const WorkflowsPage({super.key});

  @override
  State<WorkflowsPage> createState() => _WorkflowsPageState();
}

class _WorkflowsPageState extends State<WorkflowsPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<WorkflowsCubit>().loadWorkflows();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? value) {
    if (value == null) return '-';
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l.workflows,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: l.newWorkflow,
                    onPressed: () async {
                      final saved = await context.push<bool>('/workflows/new');
                      if (saved == true && context.mounted) {
                        context.read<WorkflowsCubit>().loadWorkflows();
                      }
                    },
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: l.searchWorkflows,
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (value) =>
                    context.read<WorkflowsCubit>().setQuery(value),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: BlocBuilder<WorkflowsCubit, WorkflowsState>(
            builder: (context, state) {
              if (state is WorkflowsInitial || state is WorkflowsLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is WorkflowsError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(state.message),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: () =>
                            context.read<WorkflowsCubit>().loadWorkflows(),
                        icon: const Icon(Icons.refresh),
                        label: Text(l.retry),
                      ),
                    ],
                  ),
                );
              }

              final loaded = state as WorkflowsLoaded;
              if (loaded.items.isEmpty) {
                return Center(child: Text(l.noData));
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final item = loaded.items[index];
                  return Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      leading: CircleAvatar(
                        child: Text(item.stepsCount.toString()),
                      ),
                      title: Text(
                        item.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${l.stepsCount}: ${item.stepsCount} • ${l.creationDate}: ${_formatDate(item.creationDate)}',
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/workflows/${item.id}'),
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemCount: loaded.items.length,
              );
            },
          ),
        ),
      ],
    );
  }
}
