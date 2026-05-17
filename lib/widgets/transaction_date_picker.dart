import 'package:expense_tracking_app/gen/colors.gen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

DateTime dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

String formatTransactionDateLabel(DateTime date, DateTime now) {
  final selected = dateOnly(date);
  final today = dateOnly(now);

  if (selected == today) return 'Today';
  if (selected == today.subtract(const Duration(days: 1))) return 'Yesterday';
  return DateFormat('EEE, MMM d, yyyy').format(date);
}

class TransactionDatePicker extends StatelessWidget {
  const TransactionDatePicker({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
    this.firstDate,
    this.lastDate,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;

  Future<void> _openCalendar(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.isAfter(now) ? now : selectedDate,
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? now,
      helpText: 'Select transaction date',
      cancelText: 'Cancel',
      confirmText: 'Done',
    );
    if (picked != null && dateOnly(picked) != dateOnly(selectedDate)) {
      onDateChanged(dateOnly(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = dateOnly(now);
    final yesterday = today.subtract(const Duration(days: 1));
    final selected = dateOnly(selectedDate);
    final isToday = selected == today;
    final isYesterday = selected == yesterday;
    final primaryLabel = formatTransactionDateLabel(selectedDate, now);
    final showSubtitle = isToday || isYesterday;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: ColorName.gray,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              label: const Text('Today'),
              selected: isToday,
              showCheckmark: false,
              onSelected: (_) => onDateChanged(today),
            ),
            FilterChip(
              label: const Text('Yesterday'),
              selected: isYesterday,
              showCheckmark: false,
              onSelected: (_) => onDateChanged(yesterday),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Material(
          color: ColorName.snow,
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            onTap: () => _openCalendar(context),
            borderRadius: BorderRadius.circular(6),
            child: InputDecorator(
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                prefixIcon: Icon(
                  Icons.calendar_today_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 22,
                ),
                suffixIcon: Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: ColorName.textFieldBorder),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: ColorName.textFieldBorder),
                ),
                filled: true,
                fillColor: ColorName.snow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    primaryLabel,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  if (showSubtitle) ...[
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('MMMM d, yyyy').format(selectedDate),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: ColorName.osloGray,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
