import 'package:expense_tracking_app/models/expense.dart';
import 'package:expense_tracking_app/utils/app_navigator.dart';
import 'package:expense_tracking_app/utils/my_pref.dart';
import 'package:expense_tracking_app/views/login_page.dart';
import 'package:expense_tracking_app/widgets/pie_chart_widget.dart';
import 'package:expense_tracking_app/widgets/user_avatar.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.expensesList});

  final List<Expense> expensesList;

  @override
  Widget build(BuildContext context) {
    // final List<Expense> expenses = [
    //   Expense("Grocery", 50.0),
    //   // Add more expenses here
    // ];
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
                UserProfileAvatar(
                  imageRadius: 60,
                  showOnlineIndicator: false,
                  expensesList: expensesList,
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
            PieChartWidget(expensesList),
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

// class Expense {
//   final String category;
//   final double amount;

//   Expense(this.category, this.amount);
// }
