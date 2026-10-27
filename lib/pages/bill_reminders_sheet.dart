import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import 'receipt_page.dart';

/// Shows an interactive Material 3 Upcoming Bill Reminders Sheet
void showBillRemindersSheet({
  required BuildContext context,
  required Function(BillReminder bill) onBillPaid,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor:
        Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) => _BillRemindersSheet(onBillPaid: onBillPaid),
  );
}

class _BillRemindersSheet extends StatefulWidget {
  final Function(BillReminder bill) onBillPaid;

  const _BillRemindersSheet({required this.onBillPaid});

  @override
  State<_BillRemindersSheet> createState() => _BillRemindersSheetState();
}

class _BillRemindersSheetState extends State<_BillRemindersSheet> {
  late List<BillReminder> _bills;

  @override
  void initState() {
    super.initState();
    _bills = List.of(defaultBills);
  }

  void _payBill(BillReminder bill) {
    Navigator.pop(context);
    // Push the dedicated confirmation & receipt screen directly!
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ConfirmationReceiptPage(
          recipientName: bill.title,
          recipientAccount: bill.accountNumber,
          amount: bill.amount,
          referenceId: 'BILL-${bill.id.toUpperCase()}-9941',
          category: 'Utility & Bill Payment',
          note: 'Settlement for ${bill.provider}',
        ),
      ),
    );
    widget.onBillPaid(bill);
  }

  void _showAddReminderDialog() {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final accountCtrl = TextEditingController();
    DateTime pickedDate = DateTime.now().add(const Duration(days: 7));

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Text('Add Bill Reminder'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Biller / Service Name',
                      hintText: 'e.g. CleanCo Water',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Amount (LKR)',
                      hintText: 'e.g. 3500',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: accountCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Account / Reference Number',
                      hintText: 'e.g. ACC-19042',
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_month_rounded),
                    title: const Text('Due Date'),
                    subtitle: Text(
                      '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    trailing: TextButton(
                      child: const Text('Change'),
                      onPressed: () async {
                        final res = await showDatePicker(
                          context: context,
                          initialDate: pickedDate,
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (res != null) {
                          setDialogState(() => pickedDate = res);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  final amount = double.tryParse(amountCtrl.text) ?? 2500;
                  final newBill = BillReminder(
                    id: 'bill-${DateTime.now().millisecondsSinceEpoch}',
                    title: titleCtrl.text.isNotEmpty
                        ? titleCtrl.text
                        : 'Custom Bill',
                    provider: 'Direct Reminder',
                    amount: amount,
                    dueDate: pickedDate,
                    icon: Icons.receipt_long_rounded,
                    color: const Color(0xFF6750A4),
                    accountNumber: accountCtrl.text.isNotEmpty
                        ? accountCtrl.text
                        : 'REF-00129',
                  );
                  setState(() => _bills.insert(0, newBill));
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: Text('Reminder added for ${newBill.title}'),
                    ),
                  );
                },
                child: const Text('Save Reminder'),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatAmount(double amt) {
    final value = amt.round().abs().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < value.length; i++) {
      buffer.write(value[i]);
      final remaining = value.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) buffer.write(',');
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Title Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.event_note_rounded,
                      color: colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Upcoming Bill Reminders',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Never miss a due date or penalty fee',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Add Reminder button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _showAddReminderDialog,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('+ Add New Bill Reminder'),
                  style: OutlinedButton.styleFrom(
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Bills list
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: _bills.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final bill = _bills[index];
                    final isDueSoon = bill.daysUntilDue <= 3;
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF221F2C) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDueSoon
                              ? const Color(0xFFE65100).withValues(alpha: 0.5)
                              : colorScheme.outlineVariant
                                  .withValues(alpha: 0.7),
                          width: isDueSoon ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: bill.color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(bill.icon,
                                    color: bill.color, size: 24),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      bill.title,
                                      style: GoogleFonts.outfit(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    Text(
                                      '${bill.provider} • ${bill.accountNumber}',
                                      style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'LKR ${_formatAmount(bill.amount)}',
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isDueSoon
                                          ? const Color(0xFFE65100)
                                              .withValues(alpha: 0.15)
                                          : colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      bill.dueLabel,
                                      style: GoogleFonts.outfit(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: isDueSoon
                                            ? const Color(0xFFE65100)
                                            : colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Divider(
                            height: 1,
                            color: colorScheme.outlineVariant
                                .withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    bill.isAutoPay
                                        ? Icons.autorenew_rounded
                                        : Icons.schedule_rounded,
                                    size: 16,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    bill.isAutoPay
                                        ? 'Auto-Debit Active'
                                        : 'Manual Payment',
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 8),
                                  shape: const StadiumBorder(),
                                ),
                                onPressed: () => _payBill(bill),
                                child: const Text('Pay Bill Now'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
