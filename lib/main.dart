import 'package:beadneko/core/network/http.dart';
import 'package:beadneko/i18n/i18n.dart';
import 'package:beadneko/models/bead_project.dart';
import 'package:beadneko/pages/home.dart';
import 'package:beadneko/store.dart';
import 'package:beadneko/theme.dart';
import 'package:beadneko/utils/sp_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_ytlog/flutter_ytlog.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SPUtil.init().then((value) async {
    await Hive.initFlutter();
    Hive.registerAdapter(BeadProjectAdapter());
    await Hive.openBox<BeadProject>('projects');
    XHttp.init();
    runApp(Store.init(const MyApp()));
  });
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
}

class MyApp extends StatefulWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        // 程序的字体大小不受系统字体大小影响
        textScaler: TextScaler.noScaling,
      ),
      child: Consumer<ConfigStore>(
        builder: (context, config, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            navigatorKey: MyApp.navigatorKey,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: config.themeMode,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              // 项目本地化资源代理
              S.delegate,
            ],
            // 支持的语言
            supportedLocales: S.supportedLocales,
            locale: config.locale,
            home: const HomePage(),
            navigatorObservers: [MyRouteObserver()],
            builder: FlutterSmartDialog.init(
              builder: (context, child) => GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                child: child ?? const SizedBox(),
              ),
              loadingBuilder: (String msg) => CustomLoadingWidget(msg: msg),
            ),
          );
        },
      ),
    );
  }
}

class CustomLoadingWidget extends StatelessWidget {
  final String msg;
  const CustomLoadingWidget({super.key, required this.msg});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const SpinKitFadingCircle(color: Colors.white, size: 40.0),
    );
  }
}

class MyRouteObserver<R extends Route<dynamic>> extends RouteObserver<R> {
  final String _tag = 'MyRouteObserver';
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    Log.i(_tag, '⤴️ push to route: ${route.settings.name}');
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    String curPageName = newRoute?.settings.name ?? '';
    Log.i(_tag, '🔂 replace to route: $curPageName');
  }

  @override
  void didPop(Route route, Route? previousRoute) async {
    super.didPop(route, previousRoute);
    String curPageName = previousRoute?.settings.name ?? '';
    Log.i(_tag, '⤵️ pop to route: $curPageName');
  }
}
