import 'package:expense_tracking_app/utils/app_alerts.dart';
import 'package:expense_tracking_app/utils/app_navigator.dart';
import 'package:expense_tracking_app/utils/expense_list_filters.dart';
import 'package:expense_tracking_app/views/add_expense/cubit/expenses_cubit.dart';
import 'package:expense_tracking_app/views/add_expense/view/add_expense_screen.dart';
import 'package:expense_tracking_app/views/main_shell/tabs/activity_tab.dart';
import 'package:expense_tracking_app/views/main_shell/tabs/home_tab.dart';
import 'package:expense_tracking_app/views/main_shell/tabs/insights_tab.dart';
import 'package:expense_tracking_app/views/main_shell/tabs/more_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => MainShellPageState();
}

class MainShellPageState extends State<MainShellPage> {
  int _currentIndex = 0;
  final _activityTabKey = GlobalKey<ActivityTabState>();

  void openActivityTab({ExpenseListFilters? filters}) {
    if (filters != null) {
      _activityTabKey.currentState?.applyFilters(filters);
    }
    setState(() => _currentIndex = 1);
  }

  void openInsightsTab() {
    setState(() => _currentIndex = 2);
  }

  void _openAddExpense(BuildContext context) {
    final cubit = context.read<ExpensesCubit>();
    cubit.resetForm();
    AppNavigator.push(context, AddExpensePage(cubit: cubit));
  }

  Future<void> _onRefresh(BuildContext context) async {
    final cubit = context.read<ExpensesCubit>();
    await cubit.refreshExpenses();
    await cubit.loadBudget();
    await cubit.loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExpensesCubit()
        ..startListening()
        ..loadBudget(),
      child: BlocListener<ExpensesCubit, ExpensesCubitState>(
        listener: (context, state) {
          if (state is FailedState) {
            AppAlerts.showErrorMessage(
              context,
              state.errorMessage ?? 'Something went wrong',
            );
          } else if (state is ExpenseDeletedState) {
            AppAlerts.showSuccessMessage(context, 'Deleted successfully');
          } else if (state is ExpenseAddedState) {
            AppAlerts.showSuccessMessage(context, 'Saved successfully');
          } else if (state is ExpenseUpdatedState) {
            AppAlerts.showSuccessMessage(context, 'Updated successfully');
          } else if (state is BudgetSavedState) {
            AppAlerts.showSuccessMessage(context, 'Budgets updated');
          }
        },
        child: Builder(
          builder: (shellContext) {
            return Scaffold(
              body: IndexedStack(
                index: _currentIndex,
                children: [
                  HomeTab(
                    onViewAllActivity: openActivityTab,
                    onAddTransaction: () => _openAddExpense(shellContext),
                    onOpenInsights: openInsightsTab,
                  ),
                  ActivityTab(
                    key: _activityTabKey,
                    onAddTransaction: () => _openAddExpense(shellContext),
                    onRefresh: () => _onRefresh(shellContext),
                  ),
                  InsightsTab(onRefresh: () => _onRefresh(shellContext)),
                  const MoreTab(),
                ],
              ),
              bottomNavigationBar: NavigationBar(
                selectedIndex: _currentIndex,
                onDestinationSelected: (index) {
                  setState(() => _currentIndex = index);
                },
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.receipt_long_outlined),
                    selectedIcon: Icon(Icons.receipt_long),
                    label: 'Activity',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.insights_outlined),
                    selectedIcon: Icon(Icons.insights),
                    label: 'Insights',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.more_horiz),
                    selectedIcon: Icon(Icons.more_horiz),
                    label: 'More',
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () => _openAddExpense(shellContext),
                tooltip: 'Add transaction',
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            );
          },
        ),
      ),
    );
  }
}
