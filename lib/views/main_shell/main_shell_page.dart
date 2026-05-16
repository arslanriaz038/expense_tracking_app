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
    AppNavigator.push(
      context,
      BlocProvider.value(
        value: cubit,
        child: AddExpensePage(cubit: cubit),
      ),
    );
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
              extendBody: true,
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
              floatingActionButton: FloatingActionButton(
                onPressed: () => _openAddExpense(shellContext),
                tooltip: 'Add transaction',
                shape: const CircleBorder(),
                child: const Icon(Icons.add),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              bottomNavigationBar: BottomAppBar(
                shape: const CircularNotchedRectangle(),
                notchMargin: 8,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: SafeArea(
                  child: SizedBox(
                    height: 56,
                    child: Row(
                      children: [
                        Expanded(
                          child: _BottomNavItem(
                            icon: Icons.home_outlined,
                            selectedIcon: Icons.home,
                            label: 'Home',
                            selected: _currentIndex == 0,
                            onTap: () => setState(() => _currentIndex = 0),
                          ),
                        ),
                        Expanded(
                          child: _BottomNavItem(
                            icon: Icons.receipt_long_outlined,
                            selectedIcon: Icons.receipt_long,
                            label: 'Activity',
                            selected: _currentIndex == 1,
                            onTap: () => setState(() => _currentIndex = 1),
                          ),
                        ),
                        const SizedBox(width: 56),
                        Expanded(
                          child: _BottomNavItem(
                            icon: Icons.insights_outlined,
                            selectedIcon: Icons.insights,
                            label: 'Insights',
                            selected: _currentIndex == 2,
                            onTap: () => setState(() => _currentIndex = 2),
                          ),
                        ),
                        Expanded(
                          child: _BottomNavItem(
                            icon: Icons.more_horiz,
                            selectedIcon: Icons.more_horiz,
                            label: 'More',
                            selected: _currentIndex == 3,
                            onTap: () => setState(() => _currentIndex = 3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = selected ? colorScheme.primary : colorScheme.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(selected ? selectedIcon : icon, color: color, size: 22),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: color,
                      fontSize: 11,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
