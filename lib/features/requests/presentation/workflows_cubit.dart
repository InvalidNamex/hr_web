import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_exception.dart';
import '../data/request_models.dart';
import '../data/requests_remote_datasource.dart';

part 'workflows_state.dart';

class WorkflowsCubit extends Cubit<WorkflowsState> {
  WorkflowsCubit(this._dataSource) : super(const WorkflowsInitial());

  final RequestsRemoteDataSource _dataSource;
  List<WorkflowListItem> _allItems = const [];

  Future<void> loadWorkflows() async {
    emit(const WorkflowsLoading());
    try {
      _allItems = await _dataSource.getWorkflows();
      emit(
        WorkflowsLoaded(
          items: _computeVisibleItems(_allItems, query: ''),
          query: '',
        ),
      );
    } on ApiException catch (e) {
      emit(WorkflowsError(e.message));
    } catch (_) {
      emit(const WorkflowsError('Failed to load workflows.'));
    }
  }

  void setQuery(String query) {
    final current = state;
    if (current is! WorkflowsLoaded) return;

    emit(
      current.copyWith(
        query: query,
        items: _computeVisibleItems(_allItems, query: query),
      ),
    );
  }

  List<WorkflowListItem> _computeVisibleItems(
    List<WorkflowListItem> source, {
    required String query,
  }) {
    final normalizedQuery = query.trim().toLowerCase();
    final filtered = source.where((item) {
      if (normalizedQuery.isEmpty) return true;
      return item.name.toLowerCase().contains(normalizedQuery);
    }).toList();

    filtered.sort((a, b) {
      final aDate = a.creationDate ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.creationDate ?? DateTime.fromMillisecondsSinceEpoch(0);
      final cmp = bDate.compareTo(aDate);
      if (cmp != 0) return cmp;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return filtered;
  }
}
