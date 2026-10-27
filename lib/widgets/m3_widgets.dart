import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../pages/budgeting_tips_sheet.dart';
import '../pages/bill_reminders_sheet.dart';
import '../pages/voice_search_dialog.dart';
import '../pages/receipt_page.dart';

/// Material 3 Card wrapper with authentic rounded corners and dynamic surface tint
class M3Card extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final BorderSide? border;

  const M3Card({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.backgroundColor,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final cardBg =
        backgroundColor ?? (isDark ? const Color(0xFF1E1B24) : Colors.white);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: border?.color ??
              (isDark ? const Color(0xFF383542) : const Color(0xFFEADBFF)),
          width: border?.width ?? 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : colorScheme.primary.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(18),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Material 3 Section Header with title and optional action chip
class M3SectionRow extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final Color? actionColor;
  final VoidCallback? onAction;

  const M3SectionRow({
    super.key,
    required this.title,
    this.actionLabel,
    this.actionColor,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.outfit(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w800,
              fontSize: 17,
              letterSpacing: -0.2,
            ),
          ),
        ),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: (actionColor ?? colorScheme.primary)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                actionLabel!,
                style: GoogleFonts.outfit(
                  color: actionColor ?? colorScheme.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Material 3 Rounded Chip matching the Design Kit (e.g. "✓ Enabled", "✓ Focused")
class M3CheckChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool>? onSelected;

  const M3CheckChip({
    super.key,
    required this.label,
    this.isSelected = true,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FilterChip(
      selected: isSelected,
      showCheckmark: true,
      label: Text(
        label,
        style: GoogleFonts.outfit(
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
      onSelected: onSelected ?? (_) {},
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
        side: BorderSide(
          color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
        ),
      ),
    );
  }
}

/// Material 3 Pill Search Bar with prominent Voice Search Icon
class M3SearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onVoiceTap;
  final String hintText;
  final bool readOnly;
  final VoidCallback? onTap;

  const M3SearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onVoiceTap,
    this.hintText = 'Search payments, cards, tips, bills…',
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF23202B) : const Color(0xFFF3EDF7),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        onChanged: onChanged,
        style: GoogleFonts.outfit(
          fontSize: 14,
          color: colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.outfit(
            color: colorScheme.onSurfaceVariant,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: colorScheme.primary,
            size: 22,
          ),
          suffixIcon: IconButton(
            tooltip: 'Voice Search',
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mic_rounded,
                color: colorScheme.primary,
                size: 20,
              ),
            ),
            onPressed: onVoiceTap ??
                () {
                  showVoiceSearchSheet(
                    context: context,
                    onQuerySelected: (query) {
                      if (controller != null) {
                        controller!.text = query;
                      }
                      if (onChanged != null) {
                        onChanged!(query);
                      }
                    },
                  );
                },
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
    );
  }
}

/// Material 3 Personalized Financial Recommendations Widget
class M3RecommendationsCarousel extends StatelessWidget {
  final List<FinancialRecommendation> recommendations;
  final ValueChanged<Widget>? onPush;

  const M3RecommendationsCarousel({
    super.key,
    required this.recommendations,
    this.onPush,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    if (recommendations.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        M3SectionRow(
          title: 'Smart AI Recommendations',
          actionLabel: '${recommendations.length} insights',
          actionColor: colorScheme.primary,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 195,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: recommendations.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final rec = recommendations[index];
              return Container(
                width: 290,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            const Color(0xFF2A2338),
                            const Color(0xFF1E1A29),
                          ]
                        : [
                            const Color(0xFFFBF8FF),
                            const Color(0xFFF3EDF7),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: rec.accentColor.withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: rec.accentColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child:
                              Icon(rec.icon, color: rec.accentColor, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: rec.accentColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              rec.impactBadge,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: rec.accentColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      rec.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rec.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () {
                          if (rec.onApply != null) {
                            rec.onApply!();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                behavior: SnackBarBehavior.floating,
                                content: Text('Applied "${rec.title}"'),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                        label: Text(
                          rec.actionLabel,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Material 3 Upcoming Bill Reminders Quick Card
class M3BillRemindersCard extends StatelessWidget {
  final List<BillReminder> bills;
  final Function(BillReminder bill) onBillPaid;

  const M3BillRemindersCard({
    super.key,
    required this.bills,
    required this.onBillPaid,
  });

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

    final upcoming = bills.take(2).toList();

    return M3Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          M3SectionRow(
            title: 'Upcoming Bill Reminders',
            actionLabel: 'View all (${bills.length})',
            onAction: () {
              showBillRemindersSheet(
                context: context,
                onBillPaid: onBillPaid,
              );
            },
          ),
          const SizedBox(height: 14),
          for (final bill in upcoming) ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF282534) : const Color(0xFFF7F2FA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: bill.daysUntilDue <= 2
                      ? const Color(0xFFE65100).withValues(alpha: 0.4)
                      : colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: bill.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(bill.icon, color: bill.color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bill.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          '${bill.dueLabel} • LKR ${_formatAmount(bill.amount)}',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      visualDensity: VisualDensity.compact,
                      shape: const StadiumBorder(),
                    ),
                    onPressed: () {
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
                      onBillPaid(bill);
                    },
                    child: const Text('Pay', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Material 3 Budgeting Tips Quick Banner
class M3BudgetTipsBanner extends StatelessWidget {
  const M3BudgetTipsBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => showBudgetingTipsSheet(context: context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2438) : const Color(0xFFEADDFF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.3),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.lightbulb_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Budgeting Tips & Strategies',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: isDark ? Colors.white : const Color(0xFF21005D),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '50/30/20 rule, subscription audits & micro-savings',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: isDark
                          ? const Color(0xFFE6E0E9)
                          : const Color(0xFF49454F),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: isDark ? Colors.white70 : colorScheme.primary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

/// Material 3 Squircle Floating Action Button matching the Design Kit
class M3FloatingActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  const M3FloatingActionButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(18),
        elevation: 3,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: colorScheme.onPrimaryContainer,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}
