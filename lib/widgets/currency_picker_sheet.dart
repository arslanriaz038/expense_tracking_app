import 'package:expense_tracking_app/models/app_currency.dart';
import 'package:expense_tracking_app/utils/my_pref.dart';
import 'package:flutter/material.dart';

Future<String?> showCurrencyPickerSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    useRootNavigator: false,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      final selectedCode = MyPref.getCurrencyCode();
      final currencies = AppCurrencyRegistry.all;

      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        builder: (context, scrollController) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: Text(
                  'Choose currency',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: currencies.length,
                  itemBuilder: (context, index) {
                    final currency = currencies[index];
                    final selected = currency.code == selectedCode;

                    return ListTile(
                      title: Text(currency.displayLabel),
                      subtitle: Text(currency.listSubtitle),
                      trailing: selected
                          ? Icon(
                              Icons.check_circle,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                      selected: selected,
                      onTap: () => Navigator.of(context).pop(currency.code),
                    );
                  },
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
