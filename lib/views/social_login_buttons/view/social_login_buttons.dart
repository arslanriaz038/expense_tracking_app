import 'dart:io';
import 'package:expense_tracking_app/gen/assets.gen.dart';
import 'package:expense_tracking_app/utils/app_alerts.dart';
import 'package:expense_tracking_app/utils/app_navigator.dart';
import 'package:expense_tracking_app/views/app_lock/authenticated_home.dart';
import 'package:expense_tracking_app/views/social_login_buttons/cubit/social_login_cubit.dart';
import 'package:expense_tracking_app/widgets/link_account_dialog.dart';
import 'package:expense_tracking_app/widgets/loading_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SocialLoginButtons extends StatelessWidget {
  const SocialLoginButtons({
    super.key,
    this.nameHint,
    this.providerIdHint,
  });

  final String? nameHint;
  final String? providerIdHint;

  void _openMainScreen(BuildContext context) =>
      AppNavigator.pushReplacement(context, const AuthenticatedHome());

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SocialLoginCubit(),
      child: BlocConsumer<SocialLoginCubit, SocialLoginCubitState>(
        listener: (context, state) async {
          if (state is FailedState) {
            AppAlerts.showErrorMessage(
              context,
              state.errorMessage ?? 'Sign-in failed. Please try again.',
            );
          } else if (state is LoginSuccess) {
            _openMainScreen(context);
          } else if (state is AccountLinkNeededState) {
            final cubit = context.read<SocialLoginCubit>();
            final password = await showLinkAccountPasswordDialog(
              context,
              email: state.email,
              pendingProviderLabel: state.pendingProviderLabel,
            );

            if (!context.mounted) return;

            if (password == null) {
              cubit.reset();
              return;
            }

            await cubit.linkWithPassword(
              email: state.email,
              password: password,
              pendingCredential: state.pendingCredential,
              name: nameHint,
              providerId: providerIdHint,
            );
          }
        },
        builder: (context, state) {
          final SocialLoginCubit cubit = context.read<SocialLoginCubit>();
          return state is LoadingState
              ? const Center(child: LoadingAnimation())
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: _SocialLoginButton(
                        icon: Transform.scale(
                          scale: 1.35,
                          child: Assets.appIcons.google.image(),
                        ),
                        onPressed: cubit.signInWithGoogle,
                      ),
                    ),
                    if (Platform.isIOS) ...[
                      const SizedBox(width: 20),
                      Expanded(
                        child: _SocialLoginButton(
                          icon: Transform.scale(
                            scale: 1.35,
                            child: Assets.appIcons.apple.image(),
                          ),
                          onPressed: cubit.signInWithApple,
                        ),
                      ),
                    ]
                  ],
                );
        },
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  const _SocialLoginButton({
    required this.icon,
    this.onPressed,
  });

  final void Function()? onPressed;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: MediaQuery.sizeOf(context).width,
      child: OutlinedButton(
        onPressed: onPressed,
        child: icon,
      ),
    );
  }
}
