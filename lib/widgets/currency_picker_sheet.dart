import 'package:expense_tracking_app/models/app_currency.dart';
import 'package:expense_tracking_app/utils/my_pref.dart';
import 'package:flutter/material.dart';

Future<String?> showCurrencyPickerSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    useRootNavigator: false,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => const _CurrencyPickerSheet(),
  );
}

class _CurrencyPickerSheet extends StatefulWidget {
  const _CurrencyPickerSheet();

  @override
  State<_CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<_CurrencyPickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AppCurrency> get _filteredCurrencies {
    return AppCurrencyRegistry.all
        .where((currency) => currency.matchesQuery(_query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCode = MyPref.getCurrencyCode();
    final filtered = _filteredCurrencies;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: Text(
                'Choose currency',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SearchBar(
                controller: _searchController,
                hintText: 'Search by name or code (e.g. PKR)',
                leading: const Icon(Icons.search),
                trailing: _query.isEmpty
                    ? null
                    : [
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        ),
                      ],
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'No currencies match "$_query"',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final currency = filtered[index];
                        final selected = currency.code == selectedCode;

                        return ListTile(
                          title: Text(currency.displayLabel),
                          subtitle: Text(currency.listSubtitle),
                          trailing: selected
                              ? Icon(
                                  Icons.check_circle,
                                  color:
                                      Theme.of(context).colorScheme.primary,
                                )
                              : null,
                          selected: selected,
                          onTap: () =>
                              Navigator.of(context).pop(currency.code),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
