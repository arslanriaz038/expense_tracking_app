import 'package:expense_tracking_app/models/expense.dart';
import 'package:expense_tracking_app/utils/app_data.dart';
import 'package:expense_tracking_app/utils/app_navigator.dart';
import 'package:expense_tracking_app/utils/expense_list_filters.dart';
import 'package:expense_tracking_app/utils/my_pref.dart';
import 'package:expense_tracking_app/views/login_screen.dart';
import 'package:expense_tracking_app/widgets/category_breakdown_chart.dart';
import 'package:expense_tracking_app/widgets/expense_summary_banner.dart';
import 'package:expense_tracking_app/widgets/user_avatar.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.expensesList});

  final List<Expense> expensesList;

  @override
  Widget build(BuildContext context) {
    final totals = calculateTotals(expensesList);

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            UserProfileAvatar(
              imageRadius: 60,
              showOnlineIndicator: false,
              expensesList: expensesList,
            ),
            const SizedBox(height: 8),
            Text(
              MyPref.readUserInfo()?.name ?? '',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              MyPref.readUserInfo()?.email ?? '',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            ExpenseSummaryBanner(totals: totals),
            const SizedBox(height: 12),
            CategoryBreakdownChart(
              categoryTotals: categorySpending(expensesList),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  AppData.logOutUserMain();
                  AppNavigator.popUntilFirst(context);
                  AppNavigator.pushReplacement(context, const LoginScreen());
                },
                child: const Text('Log out'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
