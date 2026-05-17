import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/locale_cubit.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/auth/presentation/auth_cubit.dart';
import 'features/requests/presentation/request_types_cubit.dart';
import 'features/auth/data/auth_remote_datasource.dart';
import 'features/requests/data/requests_remote_datasource.dart';
import 'core/router/app_router.dart';
import 'di.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AuthCubit _authCubit;
  late final RequestTypesCubit _requestTypesCubit;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authCubit = AuthCubit(
      dataSource: getIt<AuthRemoteDataSource>(),
      storage: getIt(),
    );
    _requestTypesCubit =
        RequestTypesCubit(getIt<RequestsRemoteDataSource>());

    // Router created once — never recreated on theme/locale change
    _router = createRouter(_authCubit);

    _authCubit.tryAutoLogin();

    // Load request types once auth is confirmed
    _authCubit.stream.listen((state) {
      if (state is AuthAuthenticated) {
        _requestTypesCubit.loadTypes();
      }
    });
  }

  @override
  void dispose() {
    _authCubit.close();
    _requestTypesCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authCubit),
        BlocProvider.value(value: _requestTypesCubit),
        BlocProvider(create: (_) => ThemeCubit(getIt())),
        BlocProvider(create: (_) => LocaleCubit(getIt())),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return BlocBuilder<LocaleCubit, LocaleState>(
            builder: (context, localeState) {
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                title: 'HR Requests',
                theme: AppTheme.light(isArabic: localeState.locale.languageCode == 'ar'),
                darkTheme: AppTheme.dark(isArabic: localeState.locale.languageCode == 'ar'),
                themeMode: themeState.mode,
                locale: localeState.locale,
                supportedLocales: const [Locale('en'), Locale('ar')],
                localizationsDelegates: const [
                  AppLocalizationsDelegate(),
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                routerConfig: _router,
              );
            },
          );
        },
      ),
    );
  }
}
