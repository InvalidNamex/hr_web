import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/auth_cubit.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/requests/pages/request_list_page.dart';
import '../../features/requests/pages/request_detail_page.dart';
import '../../features/requests/pages/dashboard_page.dart';
import '../../features/requests/presentation/request_info_cubit.dart';
import '../../features/requests/presentation/execute_vacation_cubit.dart';
import '../../features/requests/presentation/request_list_cubit.dart';
import '../../features/requests/data/requests_remote_datasource.dart';
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
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
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
                create: (_) => RequestListCubit(getIt<RequestsRemoteDataSource>()),
                child: RequestListPage(typeId: typeId),
              );
            },
            routes: [
              GoRoute(
                path: ':masterId',
                builder: (context, state) {
                  final masterId =
                      int.parse(state.pathParameters['masterId']!);
                  final requestId = (state.extra as int?) ?? 0;
                  return MultiBlocProvider(
                    providers: [
                      BlocProvider(
                        create: (_) => RequestInfoCubit(
                            getIt<RequestsRemoteDataSource>(),
                            getIt<StorageService>()),
                      ),
                      BlocProvider(
                        create: (_) => ExecuteVacationCubit(
                            getIt<RequestsRemoteDataSource>()),
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
