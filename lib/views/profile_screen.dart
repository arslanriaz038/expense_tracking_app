import 'package:expense_tracking_app/gen/colors.gen.dart';
import 'package:expense_tracking_app/utils/app_navigator.dart';
import 'package:expense_tracking_app/utils/my_pref.dart';
import 'package:expense_tracking_app/views/login_page.dart';
import 'package:expense_tracking_app/widgets/user_avatar.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Column(
              children: [
                const UserProfileAvatar(
                  imageRadius: 60,
                  showOnlineIndicator: false,
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  MyPref.readUserInfo()?.name ?? '',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  MyPref.readUserInfo()?.email ?? '',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  MyPref.logOutUser();
                  AppNavigator.popUntilFirst(context);
                  AppNavigator.pushReplacement(context, const LoginPage());
                },
                child: const Text("Log out"),
                // icon: Assets.appIcons.logOut.svg(),
              ),
            ),
            const SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }
}
