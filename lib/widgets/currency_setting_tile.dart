import 'package:expense_tracking_app/models/app_currency.dart';
import 'package:expense_tracking_app/utils/app_alerts.dart';
import 'package:expense_tracking_app/utils/currency_notifier.dart';
import 'package:expense_tracking_app/utils/my_pref.dart';
import 'package:expense_tracking_app/widgets/currency_picker_sheet.dart';
import 'package:flutter/material.dart';

class CurrencySettingTile extends StatefulWidget {
  const CurrencySettingTile({super.key});

  @override
  State<CurrencySettingTile> createState() => _CurrencySettingTileState();
}

class _CurrencySettingTileState extends State<CurrencySettingTile> {
  late AppCurrency _currency =
      AppCurrencyRegistry.forCode(MyPref.getCurrencyCode());

  Future<void> _openPicker() async {
    final code = await showCurrencyPickerSheet(context);
    if (code == null || code == _currency.code || !mounted) return;

    await CurrencyNotifier.instance.setCurrencyCode(code);
    if (!mounted) return;

    setState(() => _currency = AppCurrencyRegistry.forCode(code));
    AppAlerts.showSuccessMessage(
      context,
      'Currency set to ${_currency.displayLabel}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.payments_outlined),
      title: const Text('Currency'),
      subtitle: Text('${_currency.name} (${_currency.code})'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _currency.symbol,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: _openPicker,
    );
  }
}
