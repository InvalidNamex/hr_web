import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../presentation/request_info_cubit.dart';
import '../presentation/execute_vacation_cubit.dart';
import '../data/request_models.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/localization/locale_cubit.dart';

class RequestDetailPage extends StatefulWidget {
  const RequestDetailPage({
    super.key,
    required this.empReqMasterId,
    required this.requestId,
  });

  final int empReqMasterId;
  final int requestId;

  @override
  State<RequestDetailPage> createState() => _RequestDetailPageState();
}

class _RequestDetailPageState extends State<RequestDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<RequestInfoCubit>().loadInfo(
          empReqMasterId: widget.empReqMasterId,
          requestId: widget.requestId,
        );
  }

  Future<bool?> _confirmDialog(
      BuildContext context, String title, String message) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        final l = AppLocalizations.of(ctx);
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l.confirm),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final langCode = context.watch<LocaleCubit>().state.locale.languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(l.requestDetails)),
      body: BlocListener<ExecuteVacationCubit, ExecuteVacationState>(
        listener: (context, state) {
          if (state is ExecuteVacationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.isUndo ? l.undoSuccess : l.executeSuccess),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
            // Reload info to reflect the new status.
            // Do NOT reset ExecuteVacationCubit here — resetting before
            // RequestInfoLoaded arrives causes a state gap where the button
            // logic can't determine canExecute/canUndo correctly.
            context.read<RequestInfoCubit>().loadInfo(
                  empReqMasterId: widget.empReqMasterId,
                  requestId: widget.requestId,
                );
          } else if (state is ExecuteVacationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        child: BlocBuilder<RequestInfoCubit, RequestInfoState>(
          builder: (context, state) {
            if (state is RequestInfoLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is RequestInfoError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.message),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () =>
                          context.read<RequestInfoCubit>().loadInfo(
                                empReqMasterId: widget.empReqMasterId,
                                requestId: widget.requestId,
                              ),
                      child: Text(l.retry),
                    ),
                  ],
                ),
              );
            }

            if (state is RequestInfoLoaded) {
              return _DetailBody(
                info: state.info,
                langCode: langCode,
                onExecute: () async {
                  final confirmed = await _confirmDialog(
                    context,
                    l.confirmExecute,
                    l.confirmExecuteMsg,
                  );
                  if (confirmed == true && context.mounted) {
                    final req = ExecuteVacationRequest(
                      empReqMasterId: state.info.empReqMasterId,
                      vacReqDetailId: state.info.vacReqDetailId,
                      empId: state.info.employeeId,
                    );
                    context.read<ExecuteVacationCubit>().execute(req);
                  }
                },
                onUndo: () async {
                  final confirmed = await _confirmDialog(
                    context,
                    l.confirmUndo,
                    l.confirmUndoMsg,
                  );
                  if (confirmed == true && context.mounted) {
                    final req = ExecuteVacationRequest(
                      empReqMasterId: state.info.empReqMasterId,
                      vacReqDetailId: state.info.vacReqDetailId,
                      empId: state.info.employeeId,
                    );
                    context.read<ExecuteVacationCubit>().undo(req);
                  }
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.info,
    required this.langCode,
    required this.onExecute,
    required this.onUndo,
  });

  final RequestInfo info;
  final String langCode;
  final VoidCallback onExecute;
  final VoidCallback onUndo;

  String _loc(String? en, String? ar) =>
      langCode == 'ar' && ar != null ? ar : (en ?? '');

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final executeState = context.watch<ExecuteVacationCubit>().state;
    final isActing = executeState is ExecuteVacationLoading;

    // 0 = pending (can execute), 1 = approved (can undo), 2 = rejected
    final canExecute = info.requestStatus == 0 && !info.isCancelled;
    final canUndo    = info.requestStatus == 1 && !info.isCancelled;

    // Chips for boolean options that are true
    final chips = <String>[
      if (info.advSal)    l.advanceSalary,
      if (info.ticket)    l.ticket,
      if (info.exitRentry) l.exitReentry,
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header card ──────────────────────────────────────────
              Card(
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (info.requestNumber != null)
                        _InfoRow(
                          label: l.requestNumber,
                          value: '#${info.requestNumber}',
                        ),
                      _InfoRow(
                        label: l.employee,
                        value: _loc(info.employeeName, info.employeeNameAr),
                      ),
                      if (info.requestTypeName != null)
                        _InfoRow(
                          label: l.requestType,
                          value: _loc(info.requestTypeName, info.requestTypeNameAr),
                        ),
                      if (info.vacTypeName != null)
                        _InfoRow(
                          label: l.vacationType,
                          value: _loc(info.vacTypeName, info.vacTypeNameAr),
                        ),
                      if (info.alterEmpName != null)
                        _InfoRow(
                          label: l.alternateEmployee,
                          value: _loc(info.alterEmpName, info.alterEmpNameAr),
                        ),
                      if (info.exitRentry && info.exitRentryTypeName != null)
                        _InfoRow(
                          label: l.exitReentryType,
                          value: _loc(info.exitRentryTypeName, info.exitRentryTypeNameAr),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Dates card ───────────────────────────────────────────
              Card(
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.fromDate,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.outline)),
                            Text(info.fromDate ?? '-',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.toDate,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.outline)),
                            Text(info.toDate ?? '-',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      if (info.daysNum != null)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l.days,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.outline)),
                              Text('${info.daysNum}',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Status card ──────────────────────────────────────────
              Card(
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoRow(
                        label: l.status,
                        value: info.localizedStatus(langCode),
                        valueColor: Theme.of(context).colorScheme.primary,
                      ),
                      if (info.declineReason != null)
                        _InfoRow(
                          label: l.declineReason,
                          value: info.declineReason!,
                          valueColor: Theme.of(context).colorScheme.error,
                        ),
                      if (info.vacReason != null)
                        _InfoRow(label: l.reason, value: info.vacReason!),
                    ],
                  ),
                ),
              ),

              // ── Option chips ─────────────────────────────────────────
              if (chips.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: chips
                      .map((c) => Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(
                              c,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ],
              // ── Approval flow ────────────────────────────────────────
              if (info.requestUserDetails != null) ...[
                const SizedBox(height: 12),
                _ApprovalFlowCard(
                  details: info.requestUserDetails!,
                  langCode: langCode,
                ),
              ],
              const SizedBox(height: 24),

              // ── Action buttons ───────────────────────────────────────
              if (isActing)
                const Center(child: CircularProgressIndicator())
              else if (canExecute || canUndo)
                Row(
                  children: [
                    if (canExecute)
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: onExecute,
                          icon: const Icon(Icons.check_circle_outline),
                          label: Text(l.execute),
                        ),
                      ),
                    if (canExecute && canUndo) const SizedBox(width: 12),
                    if (canUndo)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onUndo,
                          icon: const Icon(Icons.undo),
                          label: Text(l.undo),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.outline),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: valueColor,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Approval flow card ────────────────────────────────────────────────────────

class _ApprovalFlowCard extends StatelessWidget {
  const _ApprovalFlowCard({
    required this.details,
    required this.langCode,
  });

  final RequestUserDetails details;
  final String langCode;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final steps = <_FlowStep>[
      if (details.initiatorDetails != null)
        _FlowStep(
          label: l.initiator,
          detail: details.initiatorDetails!,
          approveState: null,
        ),
      ...details.requestWorkFlowDetails.map(
        (d) => _FlowStep(label: l.approver, detail: d, approveState: d.approveState),
      ),
      if (details.resumeWorkDetails != null)
        _FlowStep(
          label: l.resumeWork,
          detail: details.resumeWorkDetails!,
          approveState: null,
        ),
    ];

    steps.sort((a, b) {
      final dateA = a.detail.reqDate;
      final dateB = b.detail.reqDate;
      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return -1;
      if (dateB == null) return 1;
      return dateA.compareTo(dateB);
    });

    if (steps.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.approvalFlow,
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: colorScheme.outline, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ...steps.map((s) => _FlowStepTile(
                  step: s,
                  langCode: langCode,
                  colorScheme: colorScheme,
                )),
          ],
        ),
      ),
    );
  }
}

class _FlowStep {
  const _FlowStep({
    required this.label,
    required this.detail,
    required this.approveState,
  });

  final String label;
  final WorkflowUserDetail detail;
  /// null = initiator/resume (no approve icon), 1 = approved, 0 = pending, else rejected
  final int? approveState;
}

class _FlowStepTile extends StatelessWidget {
  const _FlowStepTile({
    required this.step,
    required this.langCode,
    required this.colorScheme,
  });

  final _FlowStep step;
  final String langCode;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final (icon, color, stateLabel) = switch (step.approveState) {
      1     => (Icons.check_circle, colorScheme.primary, l.stepApproved),
      0     => (Icons.hourglass_empty, colorScheme.outline, l.stepPending),
      null  => (Icons.person, colorScheme.outline, ''),
      _     => (Icons.cancel, colorScheme.error, l.stepRejected),
    };

    // Format ISO date to readable string, fallback to raw value
    final rawDate = step.detail.reqDate ?? '';
    String displayDate = rawDate;
    if (rawDate.isNotEmpty) {
      try {
        final dt = DateTime.parse(rawDate);
        displayDate =
            '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
            '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      } catch (_) {}
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      step.label,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: colorScheme.outline),
                    ),
                    if (stateLabel.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Text(
                        '· $stateLabel',
                        style: theme.textTheme.bodySmall?.copyWith(color: color),
                      ),
                    ],
                  ],
                ),
                Text(
                  step.detail.localizedUserName(langCode),
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (displayDate.isNotEmpty)
                  Text(
                    displayDate,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: colorScheme.outline),
                  ),
                if (step.detail.declineReason != null)
                  Text(
                    step.detail.declineReason!,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: colorScheme.error),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
