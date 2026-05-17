import 'package:expense_tracking_app/utils/app_data.dart';
import 'package:expense_tracking_app/utils/app_navigator.dart';
import 'package:expense_tracking_app/utils/my_pref.dart';
import 'package:expense_tracking_app/views/add_expense/cubit/expenses_cubit.dart';
import 'package:expense_tracking_app/widgets/biometric_lock_tile.dart';
import 'package:expense_tracking_app/widgets/currency_setting_tile.dart';
import 'package:expense_tracking_app/widgets/delete_account_tile.dart';
import 'package:expense_tracking_app/widgets/budget_settings_sheet.dart';
import 'package:expense_tracking_app/widgets/manage_categories_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MoreTab extends StatelessWidget {
  const MoreTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = MyPref.readUserInfo();

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          MediaQuery.paddingOf(context).top + 8,
          16,
          100,
        ),
        children: [
          const SizedBox(height: 8),
          Center(
            child: CircleAvatar(
              radius: 44,
              backgroundImage: user?.profilePictureUrl != null &&
                      user!.profilePictureUrl!.isNotEmpty
                  ? NetworkImage(user.profilePictureUrl!)
                  : null,
              child: user?.profilePictureUrl == null ||
                      user!.profilePictureUrl!.isEmpty
                  ? const Icon(Icons.person, size: 44)
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              user?.name ?? 'User',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              user?.email ?? '',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Settings',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 8),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.category_outlined),
                  title: const Text('Manage categories'),
                  subtitle: const Text('Add or remove custom categories'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showManageCategoriesSheet(
                        context,
                        cubit: context.read<ExpensesCubit>(),
                      ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.savings_outlined),
                  title: const Text('Monthly budgets'),
                  subtitle: const Text('Set spending limits'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showBudgetSettingsSheet(context),
                ),
                const Divider(height: 1),
                const CurrencySettingTile(),
                const Divider(height: 1),
                const BiometricLockTile(),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Account',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 8),
          Card(
            clipBehavior: Clip.antiAlias,
            child: const DeleteAccountTile(),
          ),
          const SizedBox(height: 24),
          BlocBuilder<ExpensesCubit, ExpensesCubitState>(
            builder: (context, state) {
              final count = context.read<ExpensesCubit>().allExpenses.length;
              return Text(
                '$count transactions tracked',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              );
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                context.read<ExpensesCubit>().stopListening();
                await AppData.logOutUserMain();
                if (!context.mounted) return;
                AppNavigator.goToLogin();
              },
              icon: const Icon(Icons.logout),
              label: const Text('Log out'),
            ),
          ),
        ],
      ),
    );
  }
}
