import 'package:expense_tracking_app/models/monthly_budget.dart';
import 'package:expense_tracking_app/views/add_expense/cubit/expenses_cubit.dart';
import 'package:expense_tracking_app/widgets/my_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> showBudgetSettingsSheet(
  BuildContext context, {
  ExpensesCubit? cubit,
}) {
  final expensesCubit = cubit ?? context.read<ExpensesCubit>();

  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: false,
    isScrollControlled: true,
    builder: (sheetContext) {
      return BlocProvider.value(
        value: expensesCubit,
        child: _BudgetSettingsSheetBody(cubit: expensesCubit),
      );
    },
  );
}

class _BudgetSettingsSheetBody extends StatefulWidget {
  const _BudgetSettingsSheetBody({required this.cubit});

  final ExpensesCubit cubit;

  @override
  State<_BudgetSettingsSheetBody> createState() =>
      _BudgetSettingsSheetBodyState();
}

class _BudgetSettingsSheetBodyState extends State<_BudgetSettingsSheetBody> {
  late final TextEditingController _overallController;
  late final Map<String, TextEditingController> _categoryControllers;

  @override
  void initState() {
    super.initState();
    final budget = widget.cubit.monthlyBudget;
    _overallController = TextEditingController(
      text: budget.overallLimit?.toString() ?? '',
    );
    _categoryControllers = {
      for (final category in widget.cubit.allCategories)
        category: TextEditingController(
          text: budget.categoryLimits[category]?.toString() ?? '',
        ),
    };
  }

  @override
  void dispose() {
    _overallController.dispose();
    for (final controller in _categoryControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Set monthly budgets',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Track spending against limits for this month.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            MyInputField(
              controller: _overallController,
              hintText: 'Overall monthly limit (optional)',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            for (final category in widget.cubit.allCategories) ...[
              MyInputField(
                controller: _categoryControllers[category]!,
                hintText: '$category limit (optional)',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
            ],
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  final categoryLimits = <String, double>{};
                  for (final entry in _categoryControllers.entries) {
                    final value = double.tryParse(entry.value.text.trim());
                    if (value != null && value > 0) {
                      categoryLimits[entry.key] = value;
                    }
                  }

                  final overall = double.tryParse(_overallController.text.trim());

                  widget.cubit.saveBudget(
                    MonthlyBudget(
                      overallLimit:
                          overall != null && overall > 0 ? overall : null,
                      categoryLimits: categoryLimits,
                    ),
                  );
                  Navigator.of(context).pop();
                },
                child: const Text('Save budgets'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
