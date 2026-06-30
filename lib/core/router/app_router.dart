import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/auth_cubit.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/requests/pages/request_list_page.dart';
import '../../features/requests/pages/request_detail_page.dart';
import '../../features/requests/pages/dashboard_page.dart';
import '../../features/requests/pages/workflows_page.dart';
import '../../features/requests/pages/workflow_detail_page.dart';
import '../../features/requests/pages/create_workflow_page.dart';
import '../../features/requests/data/request_models.dart';
import '../../features/requests/presentation/request_info_cubit.dart';
import '../../features/requests/presentation/execute_vacation_cubit.dart';
import '../../features/requests/presentation/request_list_cubit.dart';
import '../../features/requests/presentation/workflows_cubit.dart';
import '../../features/requests/presentation/workflow_detail_cubit.dart';
import '../../features/requests/presentation/create_workflow_cubit.dart';
import '../../features/requests/data/requests_remote_datasource.dart';
import '../../features/groups/data/group_models.dart';
import '../../features/groups/data/groups_remote_datasource.dart';
import '../../features/groups/pages/groups_screen.dart';
import '../../features/groups/pages/group_form_page.dart';
import '../../features/groups/pages/group_members_page.dart';
import '../../features/groups/presentation/groups_cubit.dart';
import '../../features/groups/presentation/group_form_cubit.dart';
import '../../features/groups/presentation/group_members_cubit.dart';
import '../../core/storage/storage_service.dart';
import '../../di.dart';
import '../../app_shell.dart';

GoRouter createRouter(AuthCubit authCubit) {
  return GoRouter(
    refreshListenable: _AuthNotifier(authCubit),
    redirect: (context, state) {
      final authState = authCubit.state;
      final isLoginRoute = state.matchedLocation == '/login';

      if (authState is AuthInitial) return null;
      if (authState is AuthUnauthenticated || authState is AuthError) {
        return isLoginRoute ? null : '/login';
      }
      if (authState is AuthAuthenticated) {
        return isLoginRoute ? '/' : null;
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: '/requests/:typeId',
            builder: (context, state) {
              final typeId = int.parse(state.pathParameters['typeId']!);
              return BlocProvider(
                create: (_) =>
                    RequestListCubit(getIt<RequestsRemoteDataSource>()),
                child: RequestListPage(typeId: typeId),
              );
            },
            routes: [
              GoRoute(
                path: ':masterId',
                builder: (context, state) {
                  final masterId = int.parse(state.pathParameters['masterId']!);
                  final requestId = (state.extra as int?) ?? 0;
                  return MultiBlocProvider(
                    providers: [
                      BlocProvider(
                        create: (_) => RequestInfoCubit(
                          getIt<RequestsRemoteDataSource>(),
                          getIt<StorageService>(),
                        ),
                      ),
                      BlocProvider(
                        create: (_) => ExecuteVacationCubit(
                          getIt<RequestsRemoteDataSource>(),
                          getIt<StorageService>(),
                        ),
                      ),
                    ],
                    child: RequestDetailPage(
                      empReqMasterId: masterId,
                      requestId: requestId,
                    ),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/workflows',
            builder: (context, state) => BlocProvider(
              create: (_) => WorkflowsCubit(getIt<RequestsRemoteDataSource>()),
              child: const WorkflowsPage(),
            ),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => BlocProvider(
                  create: (_) => CreateWorkflowCubit(
                    getIt<RequestsRemoteDataSource>(),
                    getIt<StorageService>(),
                  ),
                  child: const CreateWorkflowPage(),
                ),
              ),
              GoRoute(
                path: ':workflowId',
                builder: (context, state) {
                  final workflowId = int.parse(
                    state.pathParameters['workflowId']!,
                  );
                  return BlocProvider(
                    create: (_) =>
                        WorkflowDetailCubit(getIt<RequestsRemoteDataSource>()),
                    child: WorkflowDetailPage(workflowId: workflowId),
                  );
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) {
                      final workflowId = int.parse(
                        state.pathParameters['workflowId']!,
                      );
                      final initialWorkflow = state.extra as WorkflowDetails?;
                      return BlocProvider(
                        create: (_) => CreateWorkflowCubit(
                          getIt<RequestsRemoteDataSource>(),
                          getIt<StorageService>(),
                        ),
                        child: CreateWorkflowPage(
                          initialWorkflow: initialWorkflow,
                          editWorkflowId: workflowId,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/groups',
            builder: (context, state) => BlocProvider(
              create: (_) => GroupsCubit(getIt<GroupsRemoteDataSource>()),
              child: const GroupsScreen(),
            ),
          ),
          GoRoute(
            path: '/groups/new',
            builder: (context, state) => BlocProvider(
              create: (_) => GroupFormCubit(
                getIt<GroupsRemoteDataSource>(),
                getIt<StorageService>(),
              ),
              child: const GroupFormPage(),
            ),
          ),
          GoRoute(
            path: '/groups/:groupId/edit',
            builder: (context, state) {
              final group = state.extra as Group?;
              return BlocProvider(
                create: (_) => GroupFormCubit(
                  getIt<GroupsRemoteDataSource>(),
                  getIt<StorageService>(),
                ),
                child: GroupFormPage(initialGroup: group),
              );
            },
          ),
          GoRoute(
            path: '/groups/:groupId/members',
            builder: (context, state) {
              final groupId = int.parse(state.pathParameters['groupId']!);
              final groupName = (state.extra as String?) ?? '';
              return BlocProvider(
                create: (_) =>
                    GroupMembersCubit(getIt<GroupsRemoteDataSource>()),
                child: GroupMembersPage(
                  groupId: groupId,
                  groupName: groupName,
                ),
              );
            },
          ),
        ],
      ),
    ],
  );
}

class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier(this._cubit) {
    _cubit.stream.listen((_) => notifyListeners());
  }
  final AuthCubit _cubit;
}
