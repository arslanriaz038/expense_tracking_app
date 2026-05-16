import 'package:expense_tracking_app/consts/expense_constants.dart';
import 'package:expense_tracking_app/models/monthly_budget.dart';
import 'package:expense_tracking_app/views/add_expense/cubit/expenses_cubit.dart';
import 'package:expense_tracking_app/widgets/my_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> showBudgetSettingsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      final cubit = context.read<ExpensesCubit>();
      final overallController = TextEditingController(
        text: cubit.monthlyBudget.overallLimit?.toString() ?? '',
      );
      final categoryControllers = {
        for (final category in ExpenseCategories.all)
          category: TextEditingController(
            text: cubit.monthlyBudget.categoryLimits[category]?.toString() ?? '',
          ),
      };

      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Set monthly budgets',
                style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Track spending against limits for this month.',
                style: Theme.of(sheetContext).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              MyInputField(
                controller: overallController,
                hintText: 'Overall monthly limit (optional)',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              for (final category in ExpenseCategories.all) ...[
                MyInputField(
                  controller: categoryControllers[category]!,
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
                    for (final entry in categoryControllers.entries) {
                      final value = double.tryParse(entry.value.text.trim());
                      if (value != null && value > 0) {
                        categoryLimits[entry.key] = value;
                      }
                    }

                    final overall =
                        double.tryParse(overallController.text.trim());

                    cubit.saveBudget(
                      MonthlyBudget(
                        overallLimit:
                            overall != null && overall > 0 ? overall : null,
                        categoryLimits: categoryLimits,
                      ),
                    );
                    Navigator.of(sheetContext).pop();
                  },
                  child: const Text('Save budgets'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
