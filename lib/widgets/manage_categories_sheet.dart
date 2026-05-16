import 'package:expense_tracking_app/consts/expense_constants.dart';
import 'package:expense_tracking_app/utils/app_alerts.dart';
import 'package:expense_tracking_app/views/add_expense/cubit/expenses_cubit.dart';
import 'package:expense_tracking_app/widgets/confirm_delete_dialog.dart';
import 'package:expense_tracking_app/widgets/my_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> showManageCategoriesSheet(
  BuildContext context, {
  required ExpensesCubit cubit,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: false,
    isScrollControlled: true,
    builder: (sheetContext) {
      return BlocProvider.value(
        value: cubit,
        child: const _ManageCategoriesSheetContent(),
      );
    },
  );
}

class _ManageCategoriesSheetContent extends StatefulWidget {
  const _ManageCategoriesSheetContent();

  @override
  State<_ManageCategoriesSheetContent> createState() =>
      _ManageCategoriesSheetContentState();
}

class _ManageCategoriesSheetContentState
    extends State<_ManageCategoriesSheetContent> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpensesCubit, ExpensesCubitState>(
      builder: (context, state) {
        final cubit = context.read<ExpensesCubit>();
        final custom = cubit.customCategories;

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
                  'Manage categories',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Default categories are always available. Add your own for things like subscriptions, pets, or hobbies.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                Text(
                  'Default',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ExpenseCategories.defaults
                      .map(
                        (category) => Chip(
                          label: Text(category),
                          avatar: const Icon(Icons.lock_outline, size: 16),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your categories',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      '${custom.length}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (custom.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'No custom categories yet.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                else
                  ...custom.map(
                    (category) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(category),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            final confirmed = await showConfirmDeleteDialog(
                              context,
                              title: 'Remove category?',
                              message:
                                  'Remove "$category" from your list? Existing transactions keep this category.',
                            );
                            if (confirmed && context.mounted) {
                              await cubit.removeCustomCategory(category);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                MyInputField(
                  controller: _nameController,
                  hintText: 'New category name',
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () async {
                      final error = ExpenseCategories.validateNewCategory(
                        _nameController.text,
                        existingCategories: cubit.allCategories,
                      );
                      if (error != null) {
                        AppAlerts.showErrorMessage(context, error);
                        return;
                      }

                      final name = ExpenseCategories.normalizeName(
                        _nameController.text,
                      )!;
                      await cubit.addCustomCategory(name);
                      _nameController.clear();
                      if (context.mounted) {
                        AppAlerts.showSuccessMessage(
                          context,
                          'Category added',
                        );
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add category'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
