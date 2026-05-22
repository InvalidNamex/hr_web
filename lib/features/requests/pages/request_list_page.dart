import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../data/request_models.dart';
import '../presentation/request_list_cubit.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/localization/locale_cubit.dart';

class RequestListPage extends StatefulWidget {
  const RequestListPage({super.key, required this.typeId});

  final int typeId;

  @override
  State<RequestListPage> createState() => _RequestListPageState();
}

class _RequestListPageState extends State<RequestListPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  int? _statusFilter; // null = all
  String _nameQuery = '';
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    context.read<RequestListCubit>().loadRequests(widget.typeId);
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(RequestListPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.typeId != widget.typeId) {
      _clearFilters();
      context.read<RequestListCubit>().loadRequests(widget.typeId);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<RequestListCubit>().loadMore();
    }
  }

  void _clearFilters() {
    setState(() {
      _statusFilter = null;
      _nameQuery = '';
      _fromDate = null;
      _toDate = null;
      _searchController.clear();
    });
  }

  bool get _hasActiveFilter =>
      _statusFilter != null ||
      _nameQuery.isNotEmpty ||
      _fromDate != null ||
      _toDate != null;

  List<RequestListItem> _applyFilters(
      List<RequestListItem> items, String langCode) {
    return items.where((item) {
      // Status
      if (_statusFilter != null) {
        final raw = item.raw['RequestStatus'];
        final s = raw is int ? raw : int.tryParse('$raw') ?? -1;
        if (s != _statusFilter) return false;
      }
      // Name (searches both EN and AR)
      if (_nameQuery.isNotEmpty) {
        final q = _nameQuery.toLowerCase();
        final en = (item.employeeName ?? '').toLowerCase();
        final ar = (item.employeeNameAr ?? '').toLowerCase();
        if (!en.contains(q) && !ar.contains(q)) return false;
      }
      // Date range
      if (_fromDate != null || _toDate != null) {
        final dateStr = item.requestDate;
        if (dateStr == null) return false;
        final parsed = DateTime.tryParse(
            dateStr.length >= 10 ? dateStr.substring(0, 10) : dateStr);
        if (parsed == null) return false;
        final d = DateTime(parsed.year, parsed.month, parsed.day);
        if (_fromDate != null && d.isBefore(_fromDate!)) return false;
        if (_toDate != null && d.isAfter(_toDate!)) return false;
      }
      return true;
    }).toList();
  }

  Future<void> _pickDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _fromDate != null && _toDate != null
          ? DateTimeRange(start: _fromDate!, end: _toDate!)
          : null,
    );
    if (range != null) {
      setState(() {
        _fromDate = range.start;
        _toDate = range.end;
      });
    }
  }

  int _rawStatus(RequestListItem item) {
    final raw = item.raw['RequestStatus'];
    return raw is int ? raw : int.tryParse('$raw') ?? -1;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final langCode = context.watch<LocaleCubit>().state.locale.languageCode;

    return Column(
      children: [
        // ── Back button ────────────────────────────────────────────
        InkWell(
          onTap: () => context.canPop() ? context.pop() : context.go('/'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.arrow_back, size: 20),
                const SizedBox(width: 8),
                Text(l.requests,
                    style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: BlocBuilder<RequestListCubit, RequestListState>(
            builder: (context, state) {
              if (state is RequestListLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is RequestListError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(state.message),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => context
                            .read<RequestListCubit>()
                            .loadRequests(widget.typeId),
                        child: Text(l.retry),
                      ),
                    ],
                  ),
                );
              }

              if (state is RequestListLoaded) {
                final allItems = state.items;
                final filtered = _applyFilters(allItems, langCode);

                // Use API summary if available, otherwise fall back to client-computed counts
                final summary = state.summary;
                final pendingCount = summary?.pendingCount ??
                    allItems.where((i) => _rawStatus(i) == 0).length;
                final approvedCount = summary?.approvedCount ??
                    allItems.where((i) => _rawStatus(i) == 1).length;
                final rejectedCount = summary?.rejectedCount ??
                    allItems.where((i) => _rawStatus(i) == 2).length;

                return Column(
                  children: [
                    // ── Filter bar ─────────────────────────────────────────
                    _FilterBar(
                      l: l,
                      langCode: langCode,
                      statusFilter: _statusFilter,
                      searchController: _searchController,
                      fromDate: _fromDate,
                      toDate: _toDate,
                      hasActiveFilter: _hasActiveFilter,
                      onStatusChanged: (v) => setState(() => _statusFilter = v),
                      onNameChanged: (v) => setState(() => _nameQuery = v),
                      onDatePick: _pickDateRange,
                      onClearDates: () => setState(() {
                        _fromDate = null;
                        _toDate = null;
                      }),
                      onClearAll: _clearFilters,
                    ),
                    const Divider(height: 1),

                    // ── List ───────────────────────────────────────────────
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(child: Text(l.noData))
                          : RefreshIndicator(
                              onRefresh: () =>
                                  context.read<RequestListCubit>().refresh(),
                              child: ListView.builder(
                                controller: _scrollController,
                                padding:
                                    const EdgeInsets.fromLTRB(16, 12, 16, 8),
                                itemCount:
                                    filtered.length + (state.hasMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == filtered.length) {
                                    return const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 24),
                                      child: Center(
                                          child: CircularProgressIndicator()),
                                    );
                                  }
                                  final item = filtered[index];
                                  return _RequestTile(
                                    item: item,
                                    langCode: langCode,
                                    onTap: () async {
                                      await context.push(
                                        '/requests/${widget.typeId}/${item.empReqMasterId}',
                                        extra: item.requestId,
                                      );
                                      if (context.mounted) {
                                        context
                                            .read<RequestListCubit>()
                                            .refresh();
                                      }
                                    },
                                  );
                                },
                              ),
                            ),
                    ),

                    // ── Summary bar ────────────────────────────────────────
                    _SummaryBar(
                      totalCount: state.totalCount,
                      loadedCount: allItems.length,
                      pendingCount: pendingCount,
                      approvedCount: approvedCount,
                      rejectedCount: rejectedCount,
                      l: l,
                    ),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter Bar
// ─────────────────────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.l,
    required this.langCode,
    required this.statusFilter,
    required this.searchController,
    required this.fromDate,
    required this.toDate,
    required this.hasActiveFilter,
    required this.onStatusChanged,
    required this.onNameChanged,
    required this.onDatePick,
    required this.onClearDates,
    required this.onClearAll,
  });

  final AppLocalizations l;
  final String langCode;
  final int? statusFilter;
  final TextEditingController searchController;
  final DateTime? fromDate;
  final DateTime? toDate;
  final bool hasActiveFilter;
  final ValueChanged<int?> onStatusChanged;
  final ValueChanged<String> onNameChanged;
  final VoidCallback onDatePick;
  final VoidCallback onClearDates;
  final VoidCallback onClearAll;

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final dateLabel = fromDate != null && toDate != null
        ? '${_fmtDate(fromDate!)} → ${_fmtDate(toDate!)}'
        : fromDate != null
            ? '≥ ${_fmtDate(fromDate!)}'
            : toDate != null
                ? '≤ ${_fmtDate(toDate!)}'
                : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search field
          TextField(
            controller: searchController,
            onChanged: onNameChanged,
            decoration: InputDecoration(
              isDense: true,
              hintText: l.searchEmployee,
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        searchController.clear();
                        onNameChanged('');
                      },
                    )
                  : null,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          const SizedBox(height: 8),
          // Status chips + date button + clear
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _StatusChip(
                label: l.all,
                selected: statusFilter == null,
                onTap: () => onStatusChanged(null),
              ),
              _StatusChip(
                label: l.statusPending,
                color: Theme.of(context).colorScheme.primary,
                selected: statusFilter == 0,
                onTap: () =>
                    onStatusChanged(statusFilter == 0 ? null : 0),
              ),
              _StatusChip(
                label: l.statusApproved,
                color: Colors.green,
                selected: statusFilter == 1,
                onTap: () =>
                    onStatusChanged(statusFilter == 1 ? null : 1),
              ),
              _StatusChip(
                label: l.statusRejected,
                color: Colors.red,
                selected: statusFilter == 2,
                onTap: () =>
                    onStatusChanged(statusFilter == 2 ? null : 2),
              ),
              // Date range button
              InputChip(
                avatar: Icon(
                  Icons.date_range,
                  size: 16,
                  color: dateLabel != null
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                label: Text(
                  dateLabel ?? l.dateFilter,
                  style: TextStyle(
                    color: dateLabel != null
                        ? Theme.of(context).colorScheme.primary
                        : null,
                    fontSize: 12,
                  ),
                ),
                onPressed: onDatePick,
                deleteIcon: dateLabel != null
                    ? const Icon(Icons.close, size: 14)
                    : null,
                onDeleted: dateLabel != null ? onClearDates : null,
                selected: dateLabel != null,
                showCheckmark: false,
              ),
              // Clear all
              if (hasActiveFilter)
                ActionChip(
                  avatar: const Icon(Icons.filter_alt_off, size: 16),
                  label: Text(l.clearFilters, style: const TextStyle(fontSize: 12)),
                  onPressed: onClearAll,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      selected: selected,
      selectedColor: effectiveColor.withValues(alpha: 0.15),
      checkmarkColor: effectiveColor,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide.none),
      labelStyle: selected ? TextStyle(color: effectiveColor) : null,
      onSelected: (_) => onTap(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Request Tile
// ─────────────────────────────────────────────────────────────────────────────

class _RequestTile extends StatelessWidget {
  const _RequestTile({
    required this.item,
    required this.langCode,
    required this.onTap,
  });

  final RequestListItem item;
  final String langCode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final date = item.requestDate != null && item.requestDate!.length > 10
        ? item.requestDate!.substring(0, 10)
        : item.requestDate;

    return Card(
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _statusColor(context, item.status ?? ''),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.localizedEmployeeName(langCode),
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      if (item.localizedTypeName(langCode).isNotEmpty)
                        Text(
                          item.localizedTypeName(langCode),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (date != null) ...[  
                            Icon(Icons.calendar_today_outlined,
                                size: 14,
                                color: Theme.of(context).colorScheme.outline),
                            const SizedBox(width: 6),
                            Text(date,
                                style: Theme.of(context).textTheme.bodySmall),
                            const SizedBox(width: 16),
                          ],
                          if (item.status != null && item.status!.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _statusColor(context, item.status ?? '').withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item.localizedStatus(langCode),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color:
                                          _statusColor(context, item.status ?? ''),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                    ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Summary Bar
// ─────────────────────────────────────────────────────────────────────────────

class _SummaryBar extends StatelessWidget {
  const _SummaryBar({
    required this.totalCount,
    required this.loadedCount,
    required this.pendingCount,
    required this.approvedCount,
    required this.rejectedCount,
    required this.l,
  });

  final int totalCount;
  final int loadedCount;
  final int pendingCount;
  final int approvedCount;
  final int rejectedCount;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface;
    return Container(
      decoration: BoxDecoration(
        color: surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _SummaryItem(
              label: l.summaryTotal,
              count: totalCount,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            _SummaryItem(
              label: l.statusPending,
              count: pendingCount,
              color: Theme.of(context).colorScheme.primary,
            ),
            _SummaryItem(
              label: l.statusApproved,
              count: approvedCount,
              color: Colors.green,
            ),
            _SummaryItem(
              label: l.statusRejected,
              count: rejectedCount,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$count',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold, color: color),
        ),
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: Theme.of(context).colorScheme.outline),
        ),
      ],
    );
  }
}

Color _statusColor(BuildContext context, String status) {
  switch (status.toLowerCase()) {
    case 'approved':
    case 'موافق عليه':
      return Colors.green;
    case 'rejected':
    case 'مرفوض':
      return Colors.red;
    case 'cancelled':
    case 'ملغي':
      return Colors.grey;
    case 'pending':
    case 'قيد الانتظار':
    default:
      return Theme.of(context).colorScheme.primary;
  }
}
