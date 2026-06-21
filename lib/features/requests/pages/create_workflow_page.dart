import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/localization/locale_cubit.dart';
import '../data/request_models.dart';
import '../presentation/create_workflow_cubit.dart';

class CreateWorkflowPage extends StatefulWidget {
  const CreateWorkflowPage({
    super.key,
    this.initialWorkflow,
    this.editWorkflowId,
  });

  /// When provided the page operates in edit mode and pre-populates all fields.
  final WorkflowDetails? initialWorkflow;
  final int? editWorkflowId;

  bool get isEditMode => editWorkflowId != null;

  @override
  State<CreateWorkflowPage> createState() => _CreateWorkflowPageState();
}

class _CreateWorkflowPageState extends State<CreateWorkflowPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  // null entry = empty / unfilled slot; always at least one null at the end
  final List<WorkflowDropdownUser?> _steps = [null];

  // Each _GroupBinding holds a chosen group + requestType (both may be null)
  final List<_GroupBinding> _groupBindings = [];

  @override
  void initState() {
    super.initState();
    final initial = widget.initialWorkflow;
    if (initial != null) {
      _nameController.text = initial.name;
      _steps.clear();
      for (final step in initial.steps) {
        _steps.add(
          WorkflowDropdownUser(
            id: step.empId,
            name: step.username,
            nameAr: step.usernameAr,
          ),
        );
      }
      _steps.add(null); // trailing empty slot
      for (final gd in initial.groupDetails) {
        _groupBindings.add(
          _GroupBinding()
            ..group = WorkflowDropdownGroup(id: gd.groupId, name: gd.groupName)
            ..requestType = WorkflowDropdownRequestType(
              id: gd.requestTypeId,
              name: gd.requestTypeName,
              nameAr: gd.requestTypeNameAr,
            ),
        );
      }
    }
    context.read<CreateWorkflowCubit>().loadDropdowns();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // ── Steps management ────────────────────────────────────────────────────────

  void _onUserSelected(int index, WorkflowDropdownUser user) {
    setState(() {
      _steps[index] = user;
      if (index == _steps.length - 1) _steps.add(null);
    });
  }

  void _onUserRemoved(int index) {
    setState(() {
      _steps.removeAt(index);
      if (_steps.isEmpty || _steps.last != null) _steps.add(null);
    });
  }

  // ── Group-binding management ─────────────────────────────────────────────

  void _addGroupBinding() =>
      setState(() => _groupBindings.add(_GroupBinding()));

  void _removeGroupBinding(int index) =>
      setState(() => _groupBindings.removeAt(index));

  // ── Generic picker bottom-sheet ──────────────────────────────────────────

  Future<void> _pickItem<T>({
    required List<T> items,
    required String Function(T) display,
    required ValueChanged<T> onSelected,
    required String searchHint,
  }) async {
    final result = await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _SearchPickerSheet<T>(
        items: items,
        display: display,
        searchHint: searchHint,
      ),
    );
    if (result != null) onSelected(result);
  }

  // ── Save ─────────────────────────────────────────────────────────────────

  void _save(WorkflowDropdowns dropdowns, AppLocalizations l) {
    if (!_formKey.currentState!.validate()) return;

    final filledSteps = _steps.whereType<WorkflowDropdownUser>().toList();
    if (filledSteps.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.noStepsError)));
      return;
    }

    for (final b in _groupBindings) {
      if (b.group == null || b.requestType == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.incompleteBindingError)));
        return;
      }
    }

    final steps = filledSteps
        .asMap()
        .entries
        .map((e) => SaveWorkflowStep(stepNo: e.key + 1, empId: e.value.id))
        .toList();

    final groupDetails = _groupBindings
        .map(
          (b) => SaveWorkflowGroupDetail(
            groupId: b.group!.id,
            requestTypeId: b.requestType!.id,
          ),
        )
        .toList();

    final cubit = context.read<CreateWorkflowCubit>();
    final editId = widget.editWorkflowId;
    if (editId != null) {
      cubit.update(
        UpdateWorkflowRequest(
          workflowId: editId,
          name: _nameController.text.trim(),
          loggedInUserId: cubit.loggedInUserId,
          groupDetails: groupDetails,
          steps: steps,
        ),
      );
    } else {
      cubit.save(
        SaveWorkflowRequest(
          name: _nameController.text.trim(),
          loggedInUserId: cubit.loggedInUserId,
          groupDetails: groupDetails,
          steps: steps,
        ),
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final langCode = context.watch<LocaleCubit>().state.locale.languageCode;
    final colorScheme = Theme.of(context).colorScheme;

    return BlocConsumer<CreateWorkflowCubit, CreateWorkflowState>(
      listener: (context, state) {
        if (state is CreateWorkflowSaved) {
          final msg = widget.isEditMode
              ? l.workflowUpdateSuccess
              : l.workflowSaveSuccess;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(msg)));
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop(true);
          } else {
            context.go('/workflows');
          }
        } else if (state is CreateWorkflowError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: colorScheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        // Loading dropdowns
        if (state is CreateWorkflowInitial ||
            state is CreateWorkflowLoadingDropdowns) {
          return const Center(child: CircularProgressIndicator());
        }

        // Failed to load dropdowns (no dropdowns in state)
        if (state is CreateWorkflowError && state.dropdowns == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(state.message),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () =>
                      context.read<CreateWorkflowCubit>().loadDropdowns(),
                  icon: const Icon(Icons.refresh),
                  label: Text(l.retry),
                ),
              ],
            ),
          );
        }

        final dropdowns = switch (state) {
          CreateWorkflowDropdownsLoaded(:final dropdowns) => dropdowns,
          CreateWorkflowSaving(:final dropdowns) => dropdowns,
          CreateWorkflowError(:final dropdowns) => dropdowns,
          _ => null,
        };

        if (dropdowns == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final isSaving = state is CreateWorkflowSaving;

        return Column(
          children: [
            // ── Back breadcrumb ─────────────────────────────────────────
            InkWell(
              onTap: isSaving
                  ? null
                  : () => context.canPop()
                        ? context.pop()
                        : context.go('/workflows'),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_back, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      l.workflows,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),

            // ── Form ────────────────────────────────────────────────────
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isEditMode ? l.editWorkflow : l.newWorkflow,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),

                      // ── Workflow name ─────────────────────────────────
                      TextFormField(
                        controller: _nameController,
                        enabled: !isSaving,
                        decoration: InputDecoration(
                          labelText: l.workflowName,
                          hintText: l.workflowNameHint,
                          border: const OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return l.workflowNameRequired;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),

                      // ── Steps ─────────────────────────────────────────
                      _buildStepsSection(dropdowns, l, langCode, isSaving),
                      const SizedBox(height: 28),

                      // ── Group bindings ────────────────────────────────
                      _buildGroupBindingsSection(
                        dropdowns,
                        l,
                        langCode,
                        isSaving,
                      ),
                      const SizedBox(height: 32),

                      // ── Save ──────────────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: isSaving
                              ? null
                              : () => _save(dropdowns, l),
                          child: isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(l.save),
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

  // ── Steps section ────────────────────────────────────────────────────────

  Widget _buildStepsSection(
    WorkflowDropdowns dropdowns,
    AppLocalizations l,
    String langCode,
    bool isSaving,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.workflowSteps,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ...List.generate(_steps.length, (index) {
          final user = _steps[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Index badge
                SizedBox(
                  width: 32,
                  child: user != null
                      ? CircleAvatar(
                          radius: 14,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 8),

                // User picker
                Expanded(
                  child: _PickerField(
                    displayText: user?.localizedName(langCode),
                    hint: l.selectEmployee,
                    enabled: !isSaving,
                    onTap: () => _pickItem<WorkflowDropdownUser>(
                      items: dropdowns.users,
                      display: (u) => u.localizedName(langCode),
                      onSelected: (u) => _onUserSelected(index, u),
                      searchHint: l.searchEmployee,
                    ),
                  ),
                ),

                // Delete button (only for filled rows)
                if (user != null) ...[
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: isSaving ? null : () => _onUserRemoved(index),
                    icon: const Icon(Icons.clear),
                    color: Theme.of(context).colorScheme.error,
                    tooltip: l.remove,
                  ),
                ] else
                  const SizedBox(width: 48),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ── Group bindings section ───────────────────────────────────────────────

  Widget _buildGroupBindingsSection(
    WorkflowDropdowns dropdowns,
    AppLocalizations l,
    String langCode,
    bool isSaving,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l.groupDetails,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            TextButton.icon(
              onPressed: isSaving ? null : _addGroupBinding,
              icon: const Icon(Icons.add),
              label: Text(l.addGroupBinding),
            ),
          ],
        ),
        if (_groupBindings.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              l.noGroupBindings,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          )
        else
          ...List.generate(_groupBindings.length, (index) {
            final binding = _groupBindings[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          _PickerField(
                            displayText: binding.group?.name,
                            hint: l.selectGroup,
                            enabled: !isSaving,
                            onTap: () => _pickItem<WorkflowDropdownGroup>(
                              items: dropdowns.groups,
                              display: (g) => g.name,
                              onSelected: (g) =>
                                  setState(() => binding.group = g),
                              searchHint: l.searchGroup,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _PickerField(
                            displayText: binding.requestType?.localizedName(
                              langCode,
                            ),
                            hint: l.selectRequestType,
                            enabled: !isSaving,
                            onTap: () => _pickItem<WorkflowDropdownRequestType>(
                              items: dropdowns.requestTypes,
                              display: (rt) => rt.localizedName(langCode),
                              onSelected: (rt) =>
                                  setState(() => binding.requestType = rt),
                              searchHint: l.searchRequestType,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: isSaving
                          ? null
                          : () => _removeGroupBinding(index),
                      icon: const Icon(Icons.delete_outline),
                      color: colorScheme.error,
                      tooltip: l.remove,
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}

// ── Local helper classes ─────────────────────────────────────────────────────

class _GroupBinding {
  WorkflowDropdownGroup? group;
  WorkflowDropdownRequestType? requestType;
}

// ── Picker trigger field ─────────────────────────────────────────────────────

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.displayText,
    required this.hint,
    required this.onTap,
    this.enabled = true,
  });

  final String? displayText;
  final String hint;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasValue = displayText != null;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(
            color: enabled
                ? colorScheme.outline
                : colorScheme.outline.withValues(alpha: 0.4),
          ),
          borderRadius: BorderRadius.circular(4),
          color: enabled
              ? null
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                displayText ?? hint,
                style: TextStyle(
                  color: hasValue
                      ? colorScheme.onSurface
                      : colorScheme.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: enabled
                  ? colorScheme.onSurfaceVariant
                  : colorScheme.outline.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Searchable picker bottom-sheet ───────────────────────────────────────────

class _SearchPickerSheet<T> extends StatefulWidget {
  const _SearchPickerSheet({
    required this.items,
    required this.display,
    required this.searchHint,
  });

  final List<T> items;
  final String Function(T) display;
  final String searchHint;

  @override
  State<_SearchPickerSheet<T>> createState() => _SearchPickerSheetState<T>();
}

class _SearchPickerSheetState<T> extends State<_SearchPickerSheet<T>> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);

    final filtered = _query.isEmpty
        ? widget.items
        : widget.items
              .where(
                (item) => widget
                    .display(item)
                    .toLowerCase()
                    .contains(_query.toLowerCase()),
              )
              .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scrollController) => Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: widget.searchHint,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(child: Text(l.noData))
                : ListView.builder(
                    controller: scrollController,
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final item = filtered[i];
                      return ListTile(
                        title: Text(widget.display(item)),
                        onTap: () => Navigator.of(context).pop(item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
