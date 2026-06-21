import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/localization/locale_cubit.dart';
import '../data/request_models.dart';
import '../presentation/workflow_detail_cubit.dart';

class WorkflowDetailPage extends StatefulWidget {
  const WorkflowDetailPage({super.key, required this.workflowId});

  final int workflowId;

  @override
  State<WorkflowDetailPage> createState() => _WorkflowDetailPageState();
}

class _WorkflowDetailPageState extends State<WorkflowDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<WorkflowDetailCubit>().loadWorkflow(widget.workflowId);
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
    final langCode = context.watch<LocaleCubit>().state.locale.languageCode;

    return BlocBuilder<WorkflowDetailCubit, WorkflowDetailState>(
      builder: (context, state) {
        if (state is WorkflowDetailInitial || state is WorkflowDetailLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is WorkflowDetailError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(state.message),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => context
                      .read<WorkflowDetailCubit>()
                      .loadWorkflow(widget.workflowId),
                  icon: const Icon(Icons.refresh),
                  label: Text(l.retry),
                ),
              ],
            ),
          );
        }

        final workflow = (state as WorkflowDetailLoaded).workflow;
        final grouped = <int, List<WorkflowGroupDetail>>{};
        for (final group in workflow.groupDetails) {
          grouped
              .putIfAbsent(group.groupId, () => <WorkflowGroupDetail>[])
              .add(group);
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l.workflowDetails,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: l.editWorkflow,
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () async {
                    final updated = await context.push<bool>(
                        '/workflows/${widget.workflowId}/edit',
                      extra: workflow,
                    );
                    if (updated == true && context.mounted) {
                      context.read<WorkflowDetailCubit>().loadWorkflow(
                        widget.workflowId,
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workflow.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('${l.workflowId}: ${workflow.workflowId}'),
                    Text(
                      '${l.creationDate}: ${_formatDate(workflow.creationDate)}',
                    ),
                    Text(
                      '${l.createdBy}: ${workflow.empCreatedId?.toString() ?? '-'}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l.workflowSteps,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (workflow.steps.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(l.noData),
                ),
              )
            else
              ...workflow.steps.map(
                (step) => Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text(step.stepNo.toString())),
                    title: Text(step.localizedUsername(langCode)),
                    subtitle: Text('${l.employee}: ${step.empId}'),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              l.groupDetails,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (grouped.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(l.noData),
                ),
              )
            else
              ...grouped.entries.map(
                (entry) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${l.group}: ${entry.value.first.groupName}',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        ...entry.value.map(
                          (item) => ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.label_outline),
                            title: Text(
                              item.localizedRequestTypeName(langCode),
                            ),
                            subtitle: Text(
                              '${l.requestType}: ${item.requestTypeId}',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
