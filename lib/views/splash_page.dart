import 'package:expense_tracking_app/consts/app_constants.dart';
import 'package:expense_tracking_app/gen/assets.gen.dart';
import 'package:expense_tracking_app/gen/colors.gen.dart';
import 'package:expense_tracking_app/services/auth_session_service.dart';
import 'package:expense_tracking_app/utils/app_navigator.dart';
import 'package:expense_tracking_app/views/app_lock/authenticated_home.dart';
import 'package:expense_tracking_app/views/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  AnimationController? animationController;
  Animation<double>? fadeAnimation;
  bool _hasRouted = false;

  void openLoginScreen(BuildContext context) {
    AppNavigator.pushReplacement(
      context,
      const LoginScreen(),
    );
  }

  void openMainScreen(BuildContext context) {
    AppNavigator.pushReplacement(
      context,
      const AuthenticatedHome(),
    );
  }

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [
        SystemUiOverlay.bottom,
        SystemUiOverlay.top,
      ],
    );
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController!,
        curve: Curves.easeInOutCirc,
      ),
    );
    animationController?.forward();
    animationController?.addListener(() async {
      if (animationController?.status != AnimationStatus.completed ||
          _hasRouted) {
        return;
      }
      _hasRouted = true;

      final user = await AuthSessionService.restoreSession();
      if (!mounted) return;

      user != null ? openMainScreen(context) : openLoginScreen(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ColorName.primaryColor.withOpacity(0.5),
            ColorName.primaryColor,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: FadeTransition(
              opacity: fadeAnimation!,
              // curve: Curves.easeInOutBack,
              child: Hero(
                tag: AppConstants.heroAnimationTagForN,
                child: Assets.appIcons.expenses.image(width: 250, height: 250),
              )),
        ),
      ),
    );
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }
}
