import 'package:expense_tracking_app/consts/expense_constants.dart';
import 'package:expense_tracking_app/models/expense.dart';
import 'package:expense_tracking_app/utils/app_navigator.dart';
import 'package:expense_tracking_app/utils/money_format.dart';
import 'package:expense_tracking_app/views/add_expense/cubit/expenses_cubit.dart';
import 'package:expense_tracking_app/views/add_expense/view/add_expense_screen.dart';
import 'package:expense_tracking_app/widgets/confirm_delete_dialog.dart';
import 'package:expense_tracking_app/widgets/receipt_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ExpenseItemCard extends StatelessWidget {
  const ExpenseItemCard({
    super.key,
    required this.expense,
  });

  final Expense expense;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExpensesCubit>();
    final formattedDate = DateFormat('MMM d, yyyy').format(expense.date);
    final amount = expense.amountValue;
    final isIncome = expense.type == ExpenseType.income;
    final amountText = amount != null
        ? MoneyFormat.formatSigned(amount, isIncome: isIncome)
        : expense.amount;
    final amountColor = isIncome ? Colors.green.shade700 : Colors.red.shade700;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: expense.receiptImageUrl != null
            ? GestureDetector(
                onTap: () => showReceiptImageViewer(
                  context,
                  expense.receiptImageUrl!,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    expense.receiptImageUrl!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _TypeIcon(isIncome: isIncome),
                  ),
                ),
              )
            : _TypeIcon(isIncome: isIncome),
        title: Text(expense.description),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              amountText,
              style: TextStyle(
                color: amountColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$formattedDate · ${expense.category}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        isThreeLine: true,
        trailing: SizedBox(
          width: 96,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () {
                  AppNavigator.push(
                    context,
                    BlocProvider.value(
                      value: cubit,
                      child: AddExpensePage(
                        expense: expense,
                        cubit: cubit,
                      ),
                    ),
                  );
                },
              ),
              expense.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                    )
                  : IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        if (expense.id == null) return;
                        final confirmed = await showConfirmDeleteDialog(
                          context,
                          title: 'Delete ${isIncome ? 'income' : 'expense'}?',
                          message:
                              'Remove "${expense.description}" from your history?',
                        );
                        if (confirmed && context.mounted) {
                          await cubit.deleteExpense(expense.id!);
                        }
                      },
                    ),
            ],
          ),
        ),
        onTap: () {
          AppNavigator.push(
            context,
            BlocProvider.value(
              value: cubit,
              child: AddExpensePage(
                cubit: cubit,
                expense: expense,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TypeIcon extends StatelessWidget {
  const _TypeIcon({required this.isIncome});

  final bool isIncome;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: (isIncome ? Colors.green : Colors.red)
          .withValues(alpha: 0.12),
      child: Icon(
        isIncome ? Icons.arrow_downward : Icons.arrow_upward,
        color: isIncome ? Colors.green.shade700 : Colors.red.shade700,
        size: 20,
      ),
    );
  }
}
