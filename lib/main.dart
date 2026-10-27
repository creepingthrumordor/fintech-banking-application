// =============================================================================
// FinTrust Digital Banking — Material 3 Design Edition
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'models/models.dart';
import 'pages/bill_reminders_sheet.dart';
import 'pages/budgeting_tips_sheet.dart';
import 'pages/receipt_page.dart';
import 'pages/voice_search_dialog.dart';
import 'theme/app_theme.dart';
import 'widgets/m3_widgets.dart';

void main() => runApp(const FinTrustApp());

// =============================================================================
// APP ENTRY POINT — Material 3 with Dynamic Theme Support
// =============================================================================
class FinTrustApp extends StatelessWidget {
  const FinTrustApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppTheme.themeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'FinTrust',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          // Phone preview framing on desktop / wide screens
          builder: (context, child) => LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth <= 600) return child ?? const SizedBox();
              final w = math.min(430.0, constraints.maxWidth - 32);
              final h = math.min(920.0, constraints.maxHeight - 32);
              final isDark = Theme.of(context).brightness == Brightness.dark;

              return ColoredBox(
                color:
                    isDark ? const Color(0xFF0F0E13) : const Color(0xFFEADBFF),
                child: Center(
                  child: Container(
                    width: w,
                    height: h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.5)
                              : const Color(0xFF6750A4).withValues(alpha: 0.18),
                          blurRadius: 40,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: child ?? const SizedBox(),
                    ),
                  ),
                ),
              );
            },
          ),
          home: const _AppShell(),
        );
      },
    );
  }
}

// =============================================================================
// BOTTOM-NAV SHELL
// =============================================================================
class _AppShell extends StatefulWidget {
  const _AppShell();

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  int _tab = 0;
  double _balance = 231570;
  late List<TransactionItem> _transactions;
  late List<BillReminder> _bills;

  @override
  void initState() {
    super.initState();
    _transactions = List.of(defaultTransactions);
    _bills = List.of(defaultBills);
  }

  void _selectTab(int i) {
    if (i == _tab) return;
    setState(() => _tab = i);
  }

  void _push(Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  void _onTransfer(String recipient, double amount) {
    setState(() {
      _balance -= amount;
      _transactions.insert(
        0,
        TransactionItem(
          title: 'Transfer to $recipient',
          subtitle: 'Just now',
          amount: -amount,
          icon: Icons.north_east_rounded,
          iconColor: const Color(0xFFB3261E),
          category: 'Transfer',
          referenceId:
              'FT-TRF-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
        ),
      );
    });
  }

  void _onBillPaid(BillReminder bill) {
    setState(() {
      _balance -= bill.amount;
      _transactions.insert(
        0,
        TransactionItem(
          title: 'Bill: ${bill.title}',
          subtitle: 'Just now',
          amount: -bill.amount,
          icon: bill.icon,
          iconColor: bill.color,
          category: 'Bill Payment',
          referenceId: 'BILL-${bill.id.toUpperCase()}-9941',
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final pages = [
      HomePage(
        balance: _balance,
        transactions: _transactions,
        bills: _bills,
        onTab: _selectTab,
        onPush: _push,
        onTransfer: _onTransfer,
        onBillPaid: _onBillPaid,
      ),
      TransferPage(
        onTransfer: _onTransfer,
        onPush: _push,
      ),
      CardsPage(onPush: _push),
      ActivityPage(
        transactions: _transactions,
        onPush: _push,
      ),
      AccountPage(
        onPush: _push,
        onTransfer: _onTransfer,
        onBillPaid: _onBillPaid,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1B1822) : Colors.white,
          border: Border(
            top: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: _selectTab,
          elevation: 0,
          backgroundColor: Colors.transparent,
          indicatorColor: colorScheme.primaryContainer,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.swap_horiz_rounded),
              selectedIcon: Icon(Icons.swap_horiz_rounded),
              label: 'Transfer',
            ),
            NavigationDestination(
              icon: Icon(Icons.credit_card_outlined),
              selectedIcon: Icon(Icons.credit_card_rounded),
              label: 'Card',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long_rounded),
              label: 'Activity',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// PAGE: HOME / DASHBOARD
// =============================================================================
class HomePage extends StatelessWidget {
  const HomePage({
    required this.balance,
    required this.transactions,
    this.bills = const [],
    required this.onTab,
    required this.onPush,
    required this.onTransfer,
    this.onBillPaid,
    super.key,
  });

  final double balance;
  final List<TransactionItem> transactions;
  final List<BillReminder> bills;
  final ValueChanged<int> onTab;
  final ValueChanged<Widget> onPush;
  final void Function(String recipient, double amount) onTransfer;
  final Function(BillReminder bill)? onBillPaid;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          // ── Greeting Row & Action Icons ──────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome',
                      style: GoogleFonts.outfit(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Afil Musthafa',
                      style: GoogleFonts.outfit(
                        color: colorScheme.onSurface,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Voice Search Action Button
              Tooltip(
                message: 'Voice Search',
                child: InkWell(
                  borderRadius: BorderRadius.circular(100),
                  onTap: () {
                    showVoiceSearchSheet(
                      context: context,
                      onQuerySelected: (query) {
                        if (query.toLowerCase().contains('transfer')) {
                          onTab(1);
                        } else if (query.toLowerCase().contains('bill')) {
                          showBillRemindersSheet(
                            context: context,
                            onBillPaid: onBillPaid ?? (_) {},
                          );
                        } else if (query.toLowerCase().contains('tip') ||
                            query.toLowerCase().contains('budget')) {
                          showBudgetingTipsSheet(context: context);
                        } else {
                          onPush(const SmartSearchPage());
                        }
                      },
                    );
                  },
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF282334)
                          : const Color(0xFFF3EDF7),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            colorScheme.outlineVariant.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Icon(
                      Icons.mic_rounded,
                      color: colorScheme.primary,
                      size: 22,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Dark Mode Switch Button
              Tooltip(
                message:
                    isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                child: InkWell(
                  borderRadius: BorderRadius.circular(100),
                  onTap: () => AppTheme.toggleTheme(),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF352E46)
                          : const Color(0xFFEADDFF),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isDark
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                      color: isDark
                          ? const Color(0xFFFFD8E4)
                          : const Color(0xFF21005D),
                      size: 20,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Notifications bell
              Tooltip(
                message: 'Notifications',
                child: InkWell(
                  borderRadius: BorderRadius.circular(100),
                  onTap: () => onPush(const NotificationsPage()),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF282334)
                          : const Color(0xFFF3EDF7),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            colorScheme.outlineVariant.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none_rounded,
                          color: colorScheme.onSurface,
                          size: 22,
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Avatar — tap to go to account page
              GestureDetector(
                onTap: () => onTab(4),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.primaryContainer,
                    border: Border.all(color: colorScheme.primary, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      'AM',
                      style: GoogleFonts.outfit(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ── Search Bar with Voice Action ─────────────────────────────────
          M3SearchBar(
            readOnly: true,
            onTap: () => onPush(const SmartSearchPage()),
            onVoiceTap: () {
              showVoiceSearchSheet(
                context: context,
                onQuerySelected: (query) {
                  onPush(SmartSearchPage(initialQuery: query));
                },
              );
            },
          ),

          const SizedBox(height: 18),

          // ── Total Balance Card (Material 3 Purple Gradient) ───────────────
          _BalanceCard(balance: balance),

          const SizedBox(height: 18),

          // ── Personalized Financial Recommendations ───────────────────────
          M3RecommendationsCarousel(
            recommendations: defaultRecommendations,
            onPush: onPush,
          ),

          const SizedBox(height: 18),

          // ── Upcoming Bill Reminders Card ─────────────────────────────────
          M3BillRemindersCard(
            bills: bills.isNotEmpty ? bills : defaultBills,
            onBillPaid: (bill) {
              if (onBillPaid != null) {
                onBillPaid!(bill);
              }
            },
          ),

          const SizedBox(height: 18),

          // ── Budgeting Tips & Strategies Banner ───────────────────────────
          const M3BudgetTipsBanner(),

          const SizedBox(height: 18),

          // ── Recent Activity Card ─────────────────────────────────────────
          M3Card(
            child: Column(
              children: [
                M3SectionRow(
                  title: 'Recent Activity',
                  actionLabel: 'View All',
                  onAction: () => onTab(3),
                ),
                const SizedBox(height: 10),
                ...transactions.take(3).map(
                      (tx) => _TxRow(
                        tx: tx,
                        onTap: () {
                          onPush(
                            ConfirmationReceiptPage(
                              recipientName: tx.title,
                              amount: tx.amount.abs(),
                              referenceId: tx.referenceId,
                              category: tx.category,
                              paymentMethod: tx.paymentMethod,
                            ),
                          );
                        },
                      ),
                    ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ── Savings Goals Card ───────────────────────────────────────────
          M3Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                M3SectionRow(
                  title: 'Savings Goals',
                  actionLabel: '2/3 target',
                  actionColor: colorScheme.primary,
                  onAction: () => onPush(const FinancePage()),
                ),
                const SizedBox(height: 14),
                const _GoalRow(
                  label: 'Vacation',
                  target: 'LKR 6,000,000',
                  progress: 0.72,
                ),
                const SizedBox(height: 14),
                const _GoalRow(
                  label: 'Emergency Fund',
                  target: 'LKR 3,000,000',
                  progress: 0.48,
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ── Investment Summary Card ──────────────────────────────────────
          M3Card(
            onTap: () => onPush(const FinancePage()),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                M3SectionRow(
                  title: 'Investment Summary',
                  actionLabel: '+2.4%',
                  actionColor: Color(0xFF2E7D32),
                ),
                SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _MetricBox(
                        label: 'Total Value',
                        value: 'LKR 1,200,000',
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _MetricBox(
                        label: 'Yield',
                        value: 'LKR 28,500',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ── Spending & Savings Snapshot ──────────────────────────────────
          Row(
            children: [
              Expanded(
                child: M3Card(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Spending',
                        style: GoogleFonts.outfit(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'LKR 1,000,000',
                        style: GoogleFonts.outfit(
                          color: colorScheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: M3Card(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Savings',
                        style: GoogleFonts.outfit(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'LKR 3,250,000',
                        style: GoogleFonts.outfit(
                          color: colorScheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ── Fin AI Assistant Banner ──────────────────────────────────────
          GestureDetector(
            onTap: () => onPush(const AssistantPage()),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF282334)
                    : colorScheme.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.25),
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
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Meet Fin, your assistant',
                          style: GoogleFonts.outfit(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Ask me anything about your money',
                          style: GoogleFonts.outfit(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Total Balance Card Widget ────────────────────────────────────────────────
class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.balance});
  final double balance;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF6750A4), // M3 Violet
            Color(0xFF4F378B), // Deep M3 Plum/Indigo
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6750A4).withValues(alpha: 0.35),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Balance',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFEADDFF),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_rounded,
                        color: Colors.white, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      'Protected',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'LKR ${_fmt(balance)}',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 22),
          // Three account tiles
          const Row(
            children: [
              Expanded(
                child: _AccountTile(
                  label: 'Salary',
                  amount: 'LKR 130,000',
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _AccountTile(
                  label: 'Savings',
                  amount: 'LKR 100,000',
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _AccountTile(
                  label: 'Investment',
                  amount: 'LKR 200,000',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({required this.label, required this.amount});
  final String label;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              color: const Color(0xFFEADDFF),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              amount,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// PAGE: TRANSFER & PAYMENT
// =============================================================================
class TransferPage extends StatefulWidget {
  const TransferPage({
    required this.onTransfer,
    this.onPush,
    super.key,
  });

  final void Function(String recipient, double amount) onTransfer;
  final ValueChanged<Widget>? onPush;

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  int _subTab = 0;
  String? _selectedBeneficiary;
  final _amountCtrl = TextEditingController();
  (String, double)? _lastTransfer;

  static const _subTabs = ['Transfer', 'Schedule', 'QR Pay'];
  static const _beneficiaries = [
    ('kavinjan', '0123 9912 307', 'KV'),
    ('Bcas Kalmunai', '1230 9577 7000', 'BK'),
    ('Daraz', '1238 9081 2345', 'D'),
  ];

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(msg),
        ),
      );
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', ''));
    if (_selectedBeneficiary == null || amount == null || amount <= 0) {
      _toast('Please pick a beneficiary and enter a valid amount.');
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Theme.of(ctx).colorScheme.primaryContainer,
              child: Icon(
                Icons.swap_horiz_rounded,
                color: Theme.of(ctx).colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Review transfer',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Send LKR ${_fmt(amount)} to $_selectedBeneficiary?',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(ctx).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_outline_rounded, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedBeneficiary!,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(
                    'LKR ${_fmt(amount)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Theme.of(ctx).colorScheme.primary,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transfer fee',
                  style: TextStyle(
                    color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const Text(
                  'Free (0.00)',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Go back'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (ok != true || !mounted) return;

    final sentRecipient = _selectedBeneficiary!;
    final sentAmount = amount;

    widget.onTransfer(sentRecipient, sentAmount);
    _amountCtrl.clear();
    setState(() {
      _selectedBeneficiary = null;
      _lastTransfer = (sentRecipient, sentAmount);
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: const Text("Transfer sent — you're all set!"),
          action: SnackBarAction(
            label: 'Receipt',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ConfirmationReceiptPage(
                    recipientName: sentRecipient,
                    amount: sentAmount,
                    category: 'Bank & Mobile Transfer',
                    note: 'Direct Transfer to $sentRecipient',
                  ),
                ),
              );
            },
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Text(
            'Money Transfer\n& Payment',
            style: GoogleFonts.outfit(
              color: colorScheme.onSurface,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Send money locally, schedule payments, or scan QR',
            style: GoogleFonts.outfit(
              color: colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 18),

          // ── Sub-tabs Segmented Pill Bar ──────────────────────────────────
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF221F2C) : const Color(0xFFF3EDF7),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: List.generate(_subTabs.length, (i) {
                final active = i == _subTab;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (i == 2 && widget.onPush != null) {
                        widget.onPush!(const QrPaymentPage());
                      } else {
                        setState(() => _subTab = i);
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color:
                            active ? colorScheme.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Center(
                        child: Text(
                          _subTabs[i],
                          style: GoogleFonts.outfit(
                            color: active
                                ? Colors.white
                                : colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 22),

          // ── Beneficiaries Section ────────────────────────────────────────
          M3SectionRow(
            title: 'Saved Beneficiaries',
            actionLabel: 'Manage',
            onAction: () => _showManageBeneficiariesSheet(context),
          ),

          const SizedBox(height: 12),

          // Beneficiary Avatars Row
          Row(
            children: _beneficiaries.map((b) {
              final selected = _selectedBeneficiary == b.$1;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => setState(() => _selectedBeneficiary = b.$1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? colorScheme.primaryContainer
                            : (isDark ? const Color(0xFF221F2C) : Colors.white),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: selected
                              ? colorScheme.primary
                              : colorScheme.outlineVariant
                                  .withValues(alpha: 0.6),
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: selected
                                ? colorScheme.primary
                                : colorScheme.secondaryContainer,
                            child: Text(
                              b.$3,
                              style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : colorScheme.onSecondaryContainer,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            b.$1,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // ── Transfer Amount Section ──────────────────────────────────────
          Text(
            'Transfer Amount (LKR)',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
            decoration: InputDecoration(
              hintText: '0.00',
              prefixIcon: Container(
                padding: const EdgeInsets.only(left: 18, right: 10),
                alignment: Alignment.centerLeft,
                width: 65,
                child: Text(
                  'LKR',
                  style: GoogleFonts.outfit(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear_rounded),
                onPressed: () => _amountCtrl.clear(),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Quick preset amount chips
          Wrap(
            spacing: 8,
            children: ['500', '1,000', '5,000', '10,000', '25,000'].map((amt) {
              return ActionChip(
                label: Text('+$amt'),
                onPressed: () {
                  _amountCtrl.text = amt.replaceAll(',', '');
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 28),

          // ── Review Transfer Action Button ────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: const StadiumBorder(),
              ),
              onPressed: _submit,
              icon: const Icon(Icons.send_rounded, size: 18),
              label: Text(
                'Review transfer',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          if (_lastTransfer != null) ...[
            const SizedBox(height: 16),
            M3Card(
              padding: const EdgeInsets.all(16),
              backgroundColor:
                  colorScheme.primaryContainer.withValues(alpha: 0.35),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: Color(0xFF2E7D32), size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transfer Sent: LKR ${_fmt(_lastTransfer!.$2)}',
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        Text(
                          'To ${_lastTransfer!.$1}',
                          style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.tonal(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ConfirmationReceiptPage(
                            recipientName: _lastTransfer!.$1,
                            amount: _lastTransfer!.$2,
                            category: 'Bank & Mobile Transfer',
                            note: 'Direct Transfer to ${_lastTransfer!.$1}',
                          ),
                        ),
                      );
                    },
                    child: const Text('Receipt'),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // ── Quick Services Section ───────────────────────────────────────
          M3SectionRow(
            title: 'More Payment Options',
            actionLabel: 'Explore',
            onAction: () {
              if (widget.onPush != null) widget.onPush!(const ServicesPage());
            },
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _PayOptionTile(
                  icon: Icons.receipt_long_rounded,
                  title: 'Pay a Bill',
                  subtitle: 'Utilities & Gov',
                  onTap: () {
                    if (widget.onPush != null) {
                      widget.onPush!(const BillPaymentPage());
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PayOptionTile(
                  icon: Icons.phone_android_rounded,
                  title: 'Mobile Reload',
                  subtitle: 'Prepaid top-up',
                  onTap: () {
                    if (widget.onPush != null) {
                      widget.onPush!(const MobileReloadPage());
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PayOptionTile extends StatelessWidget {
  const _PayOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return M3Card(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: colorScheme.primary, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// PAGE: CARDS
// =============================================================================
class CardsPage extends StatefulWidget {
  const CardsPage({required this.onPush, super.key});
  final ValueChanged<Widget> onPush;

  @override
  State<CardsPage> createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> {
  bool _frozen = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          Text(
            'My Cards',
            style: GoogleFonts.outfit(
              color: colorScheme.onSurface,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),

          // Savings Cards
          M3SectionRow(
            title: 'Savings',
            actionLabel: 'Add account +',
            onAction: () => _showAddAccountSheet(context),
          ),
          const SizedBox(height: 12),

          // Primary Debit Card
          GestureDetector(
            onTap: () => widget.onPush(const CardDetailsPage()),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF6750A4),
                    Color(0xFF4F378B),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6750A4).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Paspor Blue GPN BCA',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '001123991008',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFEADDFF),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'LKR 3,000',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      'Primary',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          _CardRow(
            name: 'Paspor Gold Mastercard BCA',
            number: '123099912309',
            balance: 'LKR 1,238,540',
            badgeLabel: 'Balance',
            onTap: () => widget.onPush(const CardDetailsPage()),
          ),

          const SizedBox(height: 22),

          // Credit Cards
          M3SectionRow(
            title: 'Credit Card',
            actionLabel: 'Apply +',
            onAction: () =>
                _toast(context, 'New credit card application started'),
          ),
          const SizedBox(height: 12),

          _CardRow(
            name: 'BCA Platinum Mastercard',
            number: '5409001247882100',
            balance: 'LKR 5,000,000',
            badgeLabel: 'Outstanding',
            badgeColor: const Color(0xFFFFD8E4),
            badgeTextColor: const Color(0xFFB3261E),
            onTap: () => widget.onPush(const CardDetailsPage()),
          ),
          const SizedBox(height: 10),
          _CardRow(
            name: 'BCA E-Card Mastercard',
            number: '5409001247881239',
            balance: 'LKR 5,000,000',
            badgeLabel: 'Outstanding',
            badgeColor: const Color(0xFFFFD8E4),
            badgeTextColor: const Color(0xFFB3261E),
            onTap: () => widget.onPush(const CardDetailsPage()),
          ),

          const SizedBox(height: 22),

          // Flazz E-Money
          M3SectionRow(
            title: 'Flazz',
            actionLabel: 'Add card +',
            onAction: () => _toast(context, 'Add a new Flazz card'),
          ),
          const SizedBox(height: 12),

          _CardRow(
            name: 'BCA Flazz',
            number: '0145000109656583',
            balance: 'LKR 5,000,000',
            badgeLabel: 'Transit Active',
            badgeColor: const Color(0xFFD1E7DD),
            badgeTextColor: const Color(0xFF2E7D32),
            onTap: () => widget.onPush(const CardDetailsPage()),
          ),

          const SizedBox(height: 24),

          // Quick Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() => _frozen = !_frozen);
                    _toast(
                        context, _frozen ? 'Card is frozen' : 'Card is active');
                  },
                  icon: Icon(
                    _frozen ? Icons.lock_open_rounded : Icons.ac_unit_rounded,
                    size: 18,
                  ),
                  label: Text(_frozen ? 'Unfreeze card' : 'Freeze card'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => widget.onPush(const CardDetailsPage()),
                  icon: const Icon(Icons.tune_rounded, size: 18),
                  label: const Text('Card settings'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _toast(BuildContext ctx, String msg) {
    ScaffoldMessenger.of(ctx)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(msg),
      ));
  }
}

class _CardRow extends StatelessWidget {
  const _CardRow({
    required this.name,
    required this.number,
    required this.balance,
    required this.badgeLabel,
    this.badgeColor,
    this.badgeTextColor,
    required this.onTap,
  });

  final String name;
  final String number;
  final String balance;
  final String badgeLabel;
  final Color? badgeColor;
  final Color? badgeTextColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return M3Card(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.credit_card_rounded,
                color: colorScheme.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  number,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  balance,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor ?? colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              badgeLabel,
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: badgeTextColor ?? colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// PAGE: ACTIVITY / TRANSACTIONS
// =============================================================================
class ActivityPage extends StatefulWidget {
  const ActivityPage({
    required this.transactions,
    this.onPush,
    super.key,
  });

  final List<TransactionItem> transactions;
  final ValueChanged<Widget>? onPush;

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  int _filter = 0; // 0=All, 1=In (+), 2=Out (-)

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final filtered = widget.transactions.where((tx) {
      if (_filter == 1) return tx.amount > 0;
      if (_filter == 2) return tx.amount < 0;
      return true;
    }).toList();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transactions',
                style: GoogleFonts.outfit(
                  color: colorScheme.onSurface,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.filter_list_rounded),
                onPressed: () {
                  _showFilterSheet(context, _filter, (f) {
                    setState(() => _filter = f);
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'Incoming (+)', 'Outgoing (-)']
                  .asMap()
                  .entries
                  .map((e) {
                final active = e.key == _filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(e.value),
                    selected: active,
                    showCheckmark: true,
                    onSelected: (_) => setState(() => _filter = e.key),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 18),

          M3Card(
            child: Column(
              children: [
                if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'No transactions matching this filter',
                      style: GoogleFonts.outfit(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  for (var i = 0; i < filtered.length; i++) ...[
                    _TxRow(
                      tx: filtered[i],
                      onTap: () {
                        final tx = filtered[i];
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => ConfirmationReceiptPage(
                              recipientName: tx.title,
                              amount: tx.amount.abs(),
                              referenceId: tx.referenceId,
                              category: tx.category,
                              paymentMethod: tx.paymentMethod,
                            ),
                          ),
                        );
                      },
                    ),
                    if (i < filtered.length - 1)
                      Divider(
                        height: 1,
                        color:
                            colorScheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                  ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// PAGE: ACCOUNT / SETTINGS (Includes Dark Mode Switch & M3 Controls)
// =============================================================================
class AccountPage extends StatelessWidget {
  const AccountPage({
    required this.onPush,
    required this.onTransfer,
    this.onBillPaid,
    super.key,
  });

  final ValueChanged<Widget> onPush;
  final void Function(String, double) onTransfer;
  final Function(BillReminder)? onBillPaid;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          Text(
            'Account',
            style: GoogleFonts.outfit(
              color: colorScheme.onSurface,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Authentication, privacy, and security controls',
            style: GoogleFonts.outfit(
              color: colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 22),

          // ── APPEARANCE & THEME (Requested Dark Mode Switch) ──────────────
          const _GroupLabel('APPEARANCE & THEME'),
          const SizedBox(height: 10),

          M3Card(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    color: colorScheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dark Mode',
                        style: GoogleFonts.outfit(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        isDark ? 'Dark theme active' : 'Light theme active',
                        style: GoogleFonts.outfit(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Material 3 Switch with checkmark/icon
                Switch(
                  value: isDark,
                  onChanged: (val) => AppTheme.toggleTheme(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── SMART FEATURES ───────────────────────────────────────────────
          const _GroupLabel('SMART FEATURES'),
          const SizedBox(height: 10),

          _SettingsGroup(items: [
            _SettingsTile(
              icon: Icons.lightbulb_outline_rounded,
              title: 'Budgeting tips & rules',
              subtitle: '50/30/20 rule, subscription audits & micro-savings',
              onTap: () => showBudgetingTipsSheet(context: context),
            ),
            _SettingsTile(
              icon: Icons.event_note_rounded,
              title: 'Upcoming bill reminders',
              subtitle: 'Manage due dates, autopay, and quick settlements',
              onTap: () => showBillRemindersSheet(
                context: context,
                onBillPaid: onBillPaid ?? (_) {},
              ),
            ),
            _SettingsTile(
              icon: Icons.mic_rounded,
              title: 'Voice Search Assistant',
              subtitle: 'Voice-controlled banking queries and transfers',
              onTap: () => showVoiceSearchSheet(
                context: context,
                onQuerySelected: (q) =>
                    onPush(SmartSearchPage(initialQuery: q)),
              ),
            ),
          ]),

          const SizedBox(height: 20),

          // ── AUTHENTICATION ───────────────────────────────────────────────
          const _GroupLabel('AUTHENTICATION'),
          const SizedBox(height: 10),
          _SettingsGroup(items: [
            _SettingsTile(
              icon: Icons.shield_outlined,
              title: 'Account security',
              subtitle: 'Password, PIN, and biometric access',
              onTap: () => onPush(const SecurityPage()),
            ),
            _SettingsTile(
              icon: Icons.phone_android_rounded,
              title: 'Device management',
              subtitle: 'Trusted devices and active sessions',
              onTap: () => onPush(const _InfoPage(
                title: 'Device management',
                subtitle: 'Trusted devices and active sessions',
                icon: Icons.phone_android_rounded,
                body:
                    'This phone  ·  Active now\n\nNo other devices are signed in.',
              )),
            ),
            _SettingsTile(
              icon: Icons.access_time_rounded,
              title: 'Login history',
              subtitle: 'Recent sign-ins and unusual activity',
              onTap: () => onPush(const _InfoPage(
                title: 'Login history',
                subtitle: 'Recent sign-ins and unusual activity',
                icon: Icons.access_time_rounded,
                body:
                    'Today  ·  This device  ·  Colombo\nYesterday  ·  This device  ·  Colombo',
              )),
            ),
          ]),

          const SizedBox(height: 20),

          // ── PRIVACY ──────────────────────────────────────────────────────
          const _GroupLabel('PRIVACY'),
          const SizedBox(height: 10),
          _SettingsGroup(items: [
            _SettingsTile(
              icon: Icons.lock_outline_rounded,
              title: 'Privacy settings',
              subtitle: 'Data sharing, visibility, and permissions',
              onTap: () => onPush(const SecurityPage()),
            ),
            _SettingsTile(
              icon: Icons.notifications_none_rounded,
              title: 'Notification preferences',
              subtitle: 'Alerts, digests, and quiet hours',
              onTap: () => onPush(const NotificationSettingsPage()),
            ),
          ]),

          const SizedBox(height: 20),

          // ── OTHER ────────────────────────────────────────────────────────
          const _GroupLabel('OTHER'),
          const SizedBox(height: 10),
          _SettingsGroup(items: [
            _SettingsTile(
              icon: Icons.search_rounded,
              title: 'Smart Search',
              subtitle: 'Search everything in one place',
              onTap: () => onPush(const SmartSearchPage()),
            ),
            _SettingsTile(
              icon: Icons.pie_chart_outline_rounded,
              title: 'Plan',
              subtitle: 'Budget, saving and rewards',
              onTap: () => onPush(const FinancePage()),
            ),
            _SettingsTile(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Support',
              subtitle: 'AI help and secure support',
              onTap: () => onPush(const AssistantPage()),
            ),
          ]),

          const SizedBox(height: 28),

          // ── Sign Out Button ──────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => onPush(const AuthenticationPage()),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFB3261E),
                side: const BorderSide(color: Color(0xFFB3261E)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: const StadiumBorder(),
              ),
              icon: const Icon(Icons.logout_rounded),
              label: Text(
                'Sign out',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// PAGE: PERSONAL FINANCE & SAVINGS
// =============================================================================
class FinancePage extends StatelessWidget {
  const FinancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Finances'),
        actions: [
          IconButton(
            tooltip: 'Budgeting Tips',
            icon: const Icon(Icons.lightbulb_outline_rounded),
            onPressed: () => showBudgetingTipsSheet(context: context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            'Budgets, savings, and rewards',
            style: GoogleFonts.outfit(
              color: colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 16),

          // Budgeting Tips Banner
          const M3BudgetTipsBanner(),

          const SizedBox(height: 16),

          // Personalized Recommendations
          M3RecommendationsCarousel(recommendations: defaultRecommendations),

          const SizedBox(height: 16),

          // Savings Goals Card
          M3Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                M3SectionRow(
                  title: 'Savings Goals',
                  actionLabel: '2 active',
                  actionColor: colorScheme.primary,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.flight_takeoff_rounded,
                          color: colorScheme.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Bali Trip',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '233k / 800k',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: LinearProgressIndicator(
                              value: 0.29,
                              minHeight: 8,
                              color: colorScheme.primary,
                              backgroundColor: colorScheme.primaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Monthly Budget Breakdown
          M3Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const M3SectionRow(
                  title: 'Monthly Budget',
                  actionLabel: '74% used',
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: 0.74,
                    minHeight: 10,
                    color: colorScheme.primary,
                    backgroundColor: colorScheme.primaryContainer,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Spent: LKR 185,000',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Budget: LKR 250,000',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// PAGE: SMART SEARCH
// =============================================================================
class SmartSearchPage extends StatefulWidget {
  final String? initialQuery;

  const SmartSearchPage({this.initialQuery, super.key});

  @override
  State<SmartSearchPage> createState() => _SmartSearchPageState();
}

class _SmartSearchPageState extends State<SmartSearchPage> {
  late TextEditingController _searchCtrl;
  String _query = '';

  static const _items = [
    (
      'TRANSACTION',
      'Transfer to kavinjan',
      '12 May · LKR 20,000',
      Icons.swap_horiz_rounded
    ),
    (
      'BILL REMINDER',
      'Ceylon Electricity Board (CEB)',
      'Due in 2 days · LKR 14,850',
      Icons.bolt_rounded
    ),
    (
      'BILL REMINDER',
      'Dialog Fiber Broadband',
      'Due in 4 days · LKR 5,420',
      Icons.wifi_rounded
    ),
    (
      'BUDGET TIP',
      'The 50/30/20 Rule for Savings',
      'Strategy · Save +LKR 26,000/mo',
      Icons.pie_chart_outline_rounded
    ),
    (
      'SERVICE',
      'Pay a utility bill',
      'Electricity, water and more',
      Icons.receipt_outlined
    ),
    (
      'BRANCH',
      'FinTrust Central Branch',
      '0.8 km · Open until 4:00 PM',
      Icons.location_on_outlined
    ),
  ];

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery ?? '';
    _searchCtrl = TextEditingController(text: _query);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final results = _items
        .where((item) =>
            _query.isEmpty ||
            '${item.$2} ${item.$3}'
                .toLowerCase()
                .contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Smart Search')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text(
            'What can we help you find?',
            style: GoogleFonts.outfit(
              color: colorScheme.onSurface,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),

          // Pill search bar with Voice Search
          M3SearchBar(
            controller: _searchCtrl,
            hintText: 'Search people, bills, tips, services…',
            onChanged: (v) => setState(() => _query = v),
            onVoiceTap: () {
              showVoiceSearchSheet(
                context: context,
                onQuerySelected: (q) {
                  setState(() {
                    _query = q;
                    _searchCtrl.text = q;
                  });
                },
              );
            },
          ),

          const SizedBox(height: 20),

          for (final item in results) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: M3Card(
                padding: const EdgeInsets.all(14),
                onTap: () {
                  if (item.$1 == 'BUDGET TIP') {
                    showBudgetingTipsSheet(context: context);
                  } else if (item.$1 == 'BILL REMINDER') {
                    showBillRemindersSheet(
                      context: context,
                      onBillPaid: (_) {},
                    );
                  } else {
                    _showToast(context, 'Opening ${item.$2}');
                  }
                },
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child:
                          Icon(item.$4, color: colorScheme.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                item.$1,
                                style: GoogleFonts.outfit(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.primary,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.$2,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            item.$3,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// =============================================================================
// PAGE: ALL SERVICES
// =============================================================================
class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    const services = [
      ('Utility Bills', Icons.receipt_long_rounded, BillPaymentPage()),
      ('Mobile Reload', Icons.phone_android_rounded, MobileReloadPage()),
      ('QR Payments', Icons.qr_code_scanner_rounded, QrPaymentPage()),
      ('Fin AI Support', Icons.auto_awesome_rounded, AssistantPage()),
      ('Card Controls', Icons.credit_card_rounded, CardDetailsPage()),
      ('Security Center', Icons.shield_rounded, SecurityPage()),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('All Services')),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.15,
        ),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final s = services[index];
          return M3Card(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => s.$3),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(s.$2, color: colorScheme.primary, size: 24),
                ),
                const SizedBox(height: 10),
                Text(
                  s.$1,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// =============================================================================
// PAGE: QR PAYMENT
// =============================================================================
class QrPaymentPage extends StatelessWidget {
  const QrPaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('QRIS & LankaQR')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            M3Card(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  const Icon(Icons.qr_code_scanner_rounded,
                      size: 100, color: Color(0xFF6750A4)),
                  const SizedBox(height: 16),
                  Text(
                    'Scan Any QR Code to Pay',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Compatible with LankaQR, QRIS, and EMVCo merchant codes',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  // Simulate QR scan resulting in dedicated receipt
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(
                      builder: (_) => const ConfirmationReceiptPage(
                        recipientName: 'The Coffee Bean Lanka',
                        recipientAccount: 'MERCHANT-QR-8890',
                        amount: 1450,
                        category: 'QR Merchant Payment',
                        note: 'LankaQR Instant Settlement',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.camera_alt_rounded),
                label: const Text('Simulate QR Payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// PAGE: BILL PAYMENT
// =============================================================================
class BillPaymentPage extends StatefulWidget {
  const BillPaymentPage({super.key});

  @override
  State<BillPaymentPage> createState() => _BillPaymentPageState();
}

class _BillPaymentPageState extends State<BillPaymentPage> {
  String _selected = 'Electricity';
  final _account = TextEditingController(text: 'CEB-99201-440');
  final _amount = TextEditingController(text: '14850');

  @override
  void dispose() {
    _account.dispose();
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const billers = ['Electricity', 'Water', 'Internet', 'Mobile'];

    return Scaffold(
      appBar: AppBar(title: const Text('Pay a bill')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Bill payments',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text('Pay in a few simple steps',
              style: TextStyle(fontSize: 13)),
          const SizedBox(height: 20),
          const _Label('Choose a biller'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: billers.map((b) {
              final active = _selected == b;
              return ChoiceChip(
                label: Text(b),
                selected: active,
                onSelected: (_) => setState(() => _selected = b),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const _Label('Customer / account number'),
          const SizedBox(height: 8),
          TextField(
            controller: _account,
            decoration: const InputDecoration(
              hintText: 'Enter your account number',
              prefixIcon: Icon(Icons.receipt_outlined),
            ),
          ),
          const SizedBox(height: 16),
          const _Label('Amount (LKR)'),
          const SizedBox(height: 8),
          TextField(
            controller: _amount,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: '0.00',
              prefixIcon: Icon(Icons.payments_outlined),
            ),
          ),
          const SizedBox(height: 26),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                final amt = double.tryParse(_amount.text) ?? 5000;
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(
                    builder: (_) => ConfirmationReceiptPage(
                      recipientName: '$_selected Bill Payment',
                      recipientAccount: _account.text,
                      amount: amt,
                      category: 'Utility Payment',
                      note: 'Online Settlement via FinTrust',
                    ),
                  ),
                );
              },
              child: const Text('Continue to Payment'),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// PAGE: MOBILE RELOAD
// =============================================================================
class MobileReloadPage extends StatefulWidget {
  const MobileReloadPage({super.key});

  @override
  State<MobileReloadPage> createState() => _MobileReloadPageState();
}

class _MobileReloadPageState extends State<MobileReloadPage> {
  final _phoneCtrl = TextEditingController(text: '077 123 4567');
  String _amount = '1000';

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mobile Reload')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Instant Mobile Reload',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Mobile Number',
              prefixIcon: Icon(Icons.phone_iphone_rounded),
            ),
          ),
          const SizedBox(height: 20),
          const _Label('Select Preset Amount'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: ['500', '1000', '2000', '5000'].map((amt) {
              final active = _amount == amt;
              return ChoiceChip(
                label: Text('LKR $amt'),
                selected: active,
                onSelected: (_) => setState(() => _amount = amt),
              );
            }).toList(),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                final amt = double.tryParse(_amount) ?? 1000;
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(
                    builder: (_) => ConfirmationReceiptPage(
                      recipientName: 'Dialog Mobile Reload',
                      recipientAccount: _phoneCtrl.text,
                      amount: amt,
                      category: 'Mobile Reload',
                      note: 'Prepaid Account Top-Up',
                    ),
                  ),
                );
              },
              child: const Text('Reload Now'),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// PAGE: FIN ASSISTANT
// =============================================================================
class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key});

  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> {
  final _ctrl = TextEditingController();
  final List<(String, bool)> _messages = [
    (
      "Hi! I'm Fin, your Material 3 banking assistant. I can help with transfers, budgeting tips, bill reminders, and card controls. What's on your mind?",
      false
    ),
    ('What are the top budgeting tips for this month?', true),
    (
      'Our top tip is the 50/30/20 rule: allocate 50% to essential needs, 30% to wants, and 20% strictly to savings. Also check your Upcoming Bill Reminders to avoid late fees!',
      false
    ),
  ];

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add((text, true));
      _messages.add((
        'Got it! Fin is taking care of that for you. Is there anything else you need help with?',
        false
      ));
      _ctrl.clear();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fin Assistant'),
        actions: [
          IconButton(
            tooltip: 'Voice Search',
            icon: const Icon(Icons.mic_rounded),
            onPressed: () {
              showVoiceSearchSheet(
                context: context,
                onQuerySelected: (q) {
                  _ctrl.text = q;
                  _send();
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final msg in _messages)
                  Align(
                    alignment:
                        msg.$2 ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 290),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: msg.$2
                            ? colorScheme.primary
                            : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        msg.$1,
                        style: TextStyle(
                          color: msg.$2 ? Colors.white : colorScheme.onSurface,
                          fontSize: 13.5,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: 'Ask Fin anything…',
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _send,
                    icon: const Icon(Icons.arrow_upward_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// PAGE: CARD DETAILS
// =============================================================================
class CardDetailsPage extends StatefulWidget {
  const CardDetailsPage({super.key});

  @override
  State<CardDetailsPage> createState() => _CardDetailsPageState();
}

class _CardDetailsPageState extends State<CardDetailsPage> {
  bool _online = true;
  bool _international = false;
  double _limit = 250000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Card Details')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const M3Card(
            padding: EdgeInsets.all(18),
            child: Column(
              children: [
                _DetailLine(
                    label: 'Card type', value: 'FinTrust Visa Platinum'),
                _DetailLine(label: 'Card number', value: '•••• •••• •••• 4082'),
                _DetailLine(label: 'Account number', value: '•••• •••• 9031'),
                _DetailLine(label: 'Available balance', value: 'LKR 2,486,500'),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const _Label('Security controls'),
          const SizedBox(height: 10),
          SwitchListTile(
            value: _online,
            onChanged: (v) => setState(() => _online = v),
            title: const Text('Online payments'),
            subtitle: const Text('Use your card for online purchases'),
            secondary: const Icon(Icons.shopping_bag_outlined),
          ),
          SwitchListTile(
            value: _international,
            onChanged: (v) => setState(() => _international = v),
            title: const Text('International payments'),
            subtitle: const Text('Allow payments outside Sri Lanka'),
            secondary: const Icon(Icons.public_rounded),
          ),
          const SizedBox(height: 14),
          Text(
            'Daily spending limit  ·  LKR ${_fmt(_limit)}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Slider(
            value: _limit,
            min: 50000,
            max: 500000,
            divisions: 9,
            onChanged: (v) => setState(() => _limit = v),
          ),
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }
}

// =============================================================================
// PAGE: SECURITY
// =============================================================================
class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  bool _biometric = true;
  bool _alerts = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account Security')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SwitchListTile(
            value: _biometric,
            onChanged: (v) => setState(() => _biometric = v),
            title: const Text('Biometric sign in'),
            subtitle: const Text('Use Face ID or fingerprint'),
            secondary: const Icon(Icons.fingerprint_rounded),
          ),
          SwitchListTile(
            value: _alerts,
            onChanged: (v) => setState(() => _alerts = v),
            title: const Text('Transaction alerts'),
            subtitle: const Text('Get notified about every account movement'),
            secondary: const Icon(Icons.notifications_active_outlined),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// PAGE: NOTIFICATION SETTINGS & NOTIFICATIONS
// =============================================================================
class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final _prefs = <String, bool>{
    'Transactions': true,
    'Bill Reminders': true,
    'Card activity': true,
    'Budgeting Tips & Offers': true,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          for (final e in _prefs.entries)
            SwitchListTile(
              value: e.value,
              onChanged: (v) => setState(() => _prefs[e.key] = v),
              title: Text(e.key),
            ),
        ],
      ),
    );
  }
}

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _NotifTile(
            icon: Icons.bolt_rounded,
            title: 'Bill Due Soon: Ceylon Electricity Board',
            detail: 'LKR 14,850 due in 2 days',
          ),
          _NotifTile(
            icon: Icons.lightbulb_rounded,
            title: 'New Budgeting Tip: The 50/30/20 Rule',
            detail: 'Optimize your savings by up to LKR 26,000/mo',
          ),
          _NotifTile(
            icon: Icons.south_west_rounded,
            title: 'Salary received',
            detail: 'LKR 285,000  ·  Today at 9:41 AM',
          ),
        ],
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  const _NotifTile({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 2),
                Text(detail,
                    style: TextStyle(
                        color: colorScheme.onSurfaceVariant, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// PAGE: AUTHENTICATION
// =============================================================================
class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage({super.key});

  @override
  State<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  final _codeController = TextEditingController();
  bool _obscureCode = true;
  bool _isSigningIn = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _handleSignIn() async {
    final code = _codeController.text.trim();
    final colorScheme = Theme.of(context).colorScheme;

    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: colorScheme.error,
          content: Text(
            'Please enter your 6-character access code.',
            style: GoogleFonts.outfit(color: colorScheme.onError),
          ),
        ),
      );
      return;
    }

    setState(() => _isSigningIn = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _isSigningIn = false);

    _showSuccessAndPop('Signed in successfully with access code.');
  }

  void _showSuccessAndPop(String message) {
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: colorScheme.primary,
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: colorScheme.onPrimary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.outfit(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _showForgotCodeSheet(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1B24) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(Icons.key_rounded, color: colorScheme.primary, size: 22),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reset Access Code',
                            style: GoogleFonts.outfit(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'Choose where to receive your recovery code',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                _RecoveryOptionTile(
                  icon: Icons.sms_outlined,
                  title: 'SMS verification',
                  subtitle: '+1 (***) ***-8291',
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: colorScheme.primary,
                        content: Text(
                          'Recovery link sent to +1 (***) ***-8291',
                          style: GoogleFonts.outfit(color: colorScheme.onPrimary),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _RecoveryOptionTile(
                  icon: Icons.mark_email_read_outlined,
                  title: 'Email verification',
                  subtitle: 'al***@fintrust.bank',
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: colorScheme.primary,
                        content: Text(
                          'Password reset instructions sent to registered email.',
                          style: GoogleFonts.outfit(color: colorScheme.onPrimary),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFaceAuthSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _FaceScanModal(
          onSuccess: () {
            Navigator.pop(ctx);
            _showSuccessAndPop('Face ID authenticated successfully.');
          },
        );
      },
    );
  }

  void _showFingerprintAuthSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _FingerprintScanModal(
          onSuccess: () {
            Navigator.pop(ctx);
            _showSuccessAndPop('Fingerprint verified successfully.');
          },
        );
      },
    );
  }

  void _showSmsMfaSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _SmsMfaModal(
          onSuccess: () {
            Navigator.pop(ctx);
            _showSuccessAndPop('SMS two-factor authentication verified.');
          },
        );
      },
    );
  }

  void _showAuthAppMfaSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _AuthAppMfaModal(
          onSuccess: () {
            Navigator.pop(ctx);
            _showSuccessAndPop('Authenticator app token verified.');
          },
        );
      },
    );
  }

  void _showContactSupportSheet(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1B24) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'FinTrust Support',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Our security and assistance team is ready 24/7 to help you access your account.',
                  style: GoogleFonts.outfit(
                    fontSize: 13.5,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                _RecoveryOptionTile(
                  icon: Icons.auto_awesome_rounded,
                  title: 'Fin AI Banking Assistant',
                  subtitle: 'Get instant answers & reset guidance',
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const AssistantPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                _RecoveryOptionTile(
                  icon: Icons.phone_in_talk_rounded,
                  title: '24/7 Phone Banking Support',
                  subtitle: '1-800-FIN-TRUST (1-800-346-8787)',
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: colorScheme.primary,
                        content: Text(
                          'Connecting to FinTrust 24/7 Phone Support: 1-800-346-8787',
                          style: GoogleFonts.outfit(color: colorScheme.onPrimary),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                _RecoveryOptionTile(
                  icon: Icons.shield_rounded,
                  title: 'Security & Fraud Desk',
                  subtitle: 'Report suspicious activity or lock access',
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: AppTheme.error,
                        content: Text(
                          'Emergency Fraud Team notified. An agent will contact your primary phone immediately.',
                          style: GoogleFonts.outfit(color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FinTrust Digital Banking'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── CARD 1: AUTHENTICATION OVERVIEW ───────────────────────
              M3Card(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Authentication',
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to your FinTrust account using your preferred secure entry method.',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        height: 1.45,
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ── CARD 2: LOGIN ──────────────────────────────────────────
              M3Card(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Login',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: colorScheme.outlineVariant,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Default',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Access code',
                      style: GoogleFonts.outfit(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _codeController,
                      obscureText: _obscureCode,
                      maxLength: 6,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                        letterSpacing: _obscureCode ? 4 : 1,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        prefixIcon: Icon(
                          Icons.lock_outline_rounded,
                          color: colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureCode ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscureCode = !_obscureCode),
                        ),
                        hintText: 'Enter 6-digit code',
                        hintStyle: GoogleFonts.outfit(
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0,
                        ),
                        filled: true,
                        fillColor: isDark
                            ? colorScheme.surfaceContainerHigh
                            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: colorScheme.outlineVariant,
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: colorScheme.outlineVariant,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: colorScheme.primary,
                            width: 1.8,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '6 alphanumeric characters',
                          style: GoogleFonts.outfit(
                            fontSize: 12.5,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        InkWell(
                          onTap: () => _showForgotCodeSheet(context),
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                            child: Text(
                              'Forgot code?',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        onPressed: _isSigningIn ? null : _handleSignIn,
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isSigningIn
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                                ),
                              )
                            : Text(
                                'Sign in',
                                style: GoogleFonts.outfit(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ── CARD 3: BIOMETRIC SIGN IN ──────────────────────────────
              M3Card(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Biometric sign in',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _AuthOptionTile(
                            icon: Icons.account_circle_outlined,
                            label: 'Face',
                            onTap: () => _showFaceAuthSheet(context),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _AuthOptionTile(
                            icon: Icons.fingerprint_rounded,
                            label: 'Fingerprint',
                            onTap: () => _showFingerprintAuthSheet(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ── CARD 4: MFA OPTIONS ────────────────────────────────────
              M3Card(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MFA options',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _AuthOptionTile(
                            icon: Icons.phone_android_rounded,
                            label: 'SMS',
                            onTap: () => _showSmsMfaSheet(context),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _AuthOptionTile(
                            icon: Icons.shield_outlined,
                            label: 'Auth app',
                            onTap: () => _showAuthAppMfaSheet(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── BOTTOM SUPPORT SECTION ─────────────────────────────────
              Center(
                child: Text(
                  'Need help signing in?',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () => _showContactSupportSheet(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    side: BorderSide(
                      color: colorScheme.outlineVariant,
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Contact support',
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthOptionTile extends StatelessWidget {
  const _AuthOptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: isDark
                ? colorScheme.surfaceContainerHigh
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outlineVariant,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 22,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecoveryOptionTile extends StatelessWidget {
  const _RecoveryOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark
              ? colorScheme.surfaceContainerHigh
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 12.5,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _FaceScanModal extends StatefulWidget {
  const _FaceScanModal({required this.onSuccess});
  final VoidCallback onSuccess;

  @override
  State<_FaceScanModal> createState() => _FaceScanModalState();
}

class _FaceScanModalState extends State<_FaceScanModal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _verified = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    Future<void>.delayed(const Duration(milliseconds: 1300), () {
      if (mounted) {
        setState(() => _verified = true);
        Future<void>.delayed(const Duration(milliseconds: 600), () {
          if (mounted) widget.onSuccess();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1B24) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 28),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final scale = 1.0 + (_controller.value * 0.08);
                return Transform.scale(
                  scale: _verified ? 1.05 : scale,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: _verified
                          ? AppTheme.successContainer
                          : colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _verified
                            ? AppTheme.success
                            : colorScheme.primary,
                        width: 2.5,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        _verified
                            ? Icons.check_circle_rounded
                            : Icons.account_circle_outlined,
                        size: 52,
                        color: _verified
                            ? AppTheme.success
                            : colorScheme.primary,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 22),
            Text(
              _verified ? 'Face ID Verified!' : 'FinTrust Face ID',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _verified
                  ? 'Welcome back, Alex. Signing you in securely.'
                  : 'Scanning facial biometrics. Hold your device steadily.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _FingerprintScanModal extends StatefulWidget {
  const _FingerprintScanModal({required this.onSuccess});
  final VoidCallback onSuccess;

  @override
  State<_FingerprintScanModal> createState() => _FingerprintScanModalState();
}

class _FingerprintScanModalState extends State<_FingerprintScanModal> {
  bool _scanning = false;
  bool _verified = false;

  void _triggerScan() async {
    if (_scanning || _verified) return;
    setState(() => _scanning = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {
      _scanning = false;
      _verified = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    widget.onSuccess();
  }

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 400), _triggerScan);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1B24) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _triggerScan,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: _verified
                      ? AppTheme.successContainer
                      : (_scanning
                          ? colorScheme.surfaceContainerHighest
                          : colorScheme.primaryContainer),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _verified
                        ? AppTheme.success
                        : colorScheme.primary,
                    width: 2.5,
                  ),
                ),
                child: Center(
                  child: Icon(
                    _verified
                        ? Icons.check_circle_rounded
                        : Icons.fingerprint_rounded,
                    size: 54,
                    color: _verified
                        ? AppTheme.success
                        : colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _verified
                  ? 'Fingerprint Confirmed'
                  : (_scanning ? 'Reading Fingerprint...' : 'Touch Sensor to Sign In'),
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _verified
                  ? 'Identity confirmed. Access granted.'
                  : 'Place your registered finger on the sensor to authenticate.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SmsMfaModal extends StatefulWidget {
  const _SmsMfaModal({required this.onSuccess});
  final VoidCallback onSuccess;

  @override
  State<_SmsMfaModal> createState() => _SmsMfaModalState();
}

class _SmsMfaModalState extends State<_SmsMfaModal> {
  final _otp = TextEditingController(text: '748291');
  bool _verifying = false;

  void _verify() async {
    setState(() => _verifying = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _verifying = false);
    widget.onSuccess();
  }

  @override
  void dispose() {
    _otp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1B24) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(Icons.phone_android_rounded, color: colorScheme.primary, size: 22),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SMS Authentication',
                        style: GoogleFonts.outfit(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Sent to +1 (***) ***-8291',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _otp,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: 8,
                color: colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark
                    ? colorScheme.surfaceContainerHigh
                    : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: colorScheme.outlineVariant,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: colorScheme.outlineVariant,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(14)),
                  borderSide: BorderSide(color: colorScheme.primary, width: 1.8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Resend code in 45s',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: _verifying ? null : _verify,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _verifying
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                        ),
                      )
                    : Text(
                        'Verify SMS Code',
                        style: GoogleFonts.outfit(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _AuthAppMfaModal extends StatefulWidget {
  const _AuthAppMfaModal({required this.onSuccess});
  final VoidCallback onSuccess;

  @override
  State<_AuthAppMfaModal> createState() => _AuthAppMfaModalState();
}

class _AuthAppMfaModalState extends State<_AuthAppMfaModal> {
  final _token = TextEditingController(text: '492810');
  bool _verifying = false;

  void _verify() async {
    setState(() => _verifying = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _verifying = false);
    widget.onSuccess();
  }

  @override
  void dispose() {
    _token.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1B24) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(Icons.shield_outlined, color: colorScheme.primary, size: 22),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Authenticator App (TOTP)',
                        style: GoogleFonts.outfit(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Google Authenticator / 1Password',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _token,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: 8,
                color: colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark
                    ? colorScheme.surfaceContainerHigh
                    : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: colorScheme.outlineVariant,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: colorScheme.outlineVariant,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(14)),
                  borderSide: BorderSide(color: colorScheme.primary, width: 1.8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timelapse_rounded, size: 16, color: colorScheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    'Token refreshes in 24 seconds',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: _verifying ? null : _verify,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _verifying
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                        ),
                      )
                    : Text(
                        'Verify TOTP Code',
                        style: GoogleFonts.outfit(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// SHARED WIDGETS
// =============================================================================
class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.items});
  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return M3Card(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            items[i],
            if (i < items.length - 1)
              Divider(
                height: 1,
                indent: 60,
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
          ],
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: colorScheme.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.primary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _TxRow extends StatelessWidget {
  const _TxRow({required this.tx, this.onTap});
  final TransactionItem tx;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isIn = tx.amount > 0;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                tx.icon,
                size: 20,
                color: tx.iconColor ??
                    (isIn ? const Color(0xFF2E7D32) : colorScheme.primary),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.title,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tx.subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${isIn ? '+' : '−'} LKR ${_fmt(tx.amount.abs())}',
              style: GoogleFonts.outfit(
                color: isIn ? const Color(0xFF2E7D32) : colorScheme.onSurface,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalRow extends StatelessWidget {
  const _GoalRow({
    required this.label,
    required this.target,
    required this.progress,
  });

  final String label;
  final String target;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.outfit(
                    fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              target,
              style: GoogleFonts.outfit(
                  fontSize: 13, color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            color: colorScheme.primary,
            backgroundColor: colorScheme.primaryContainer,
          ),
        ),
      ],
    );
  }
}

class _MetricBox extends StatelessWidget {
  const _MetricBox({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.outfit(
                  color: colorScheme.onSurfaceVariant, fontSize: 11)),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: GoogleFonts.outfit(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      text,
      style: GoogleFonts.outfit(
        color: colorScheme.primary,
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.outfit(
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _InfoPage extends StatelessWidget {
  const _InfoPage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.body,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(subtitle,
                style: TextStyle(
                    color: colorScheme.onSurfaceVariant, fontSize: 13)),
            const SizedBox(height: 20),
            M3Card(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: colorScheme.primary, size: 28),
                  const SizedBox(height: 14),
                  Text(body, style: const TextStyle(height: 1.7)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showFilterSheet(
    BuildContext context, int currentFilter, ValueChanged<int> onSelect) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Theme.of(context).cardTheme.color,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(ctx).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Filter Transactions',
              style:
                  GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            ...['All transactions', 'Incoming (+)', 'Outgoing (-)']
                .asMap()
                .entries
                .map((e) {
              final selected = e.key == currentFilter;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  e.value,
                  style: TextStyle(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                trailing: selected
                    ? Icon(Icons.check_circle_rounded,
                        color: Theme.of(ctx).colorScheme.primary)
                    : const Icon(Icons.circle_outlined),
                onTap: () {
                  onSelect(e.key);
                  Navigator.pop(ctx);
                },
              );
            }),
          ],
        ),
      );
    },
  );
}

void _showManageBeneficiariesSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Theme.of(context).cardTheme.color,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(ctx).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Manage Beneficiaries',
              style:
                  GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(ctx).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Theme.of(ctx).colorScheme.primaryContainer,
                    child: Icon(Icons.person,
                        color: Theme.of(ctx).colorScheme.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('3 Saved Contacts',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      Text('kavinjan, Bcas Kalmunai, Daraz',
                          style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _showToast(context, 'Add contact coming soon');
                },
                icon: const Icon(Icons.person_add_rounded, size: 18),
                label: const Text('Add New Beneficiary'),
              ),
            ),
          ],
        ),
      );
    },
  );
}

void _showAddAccountSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Theme.of(context).cardTheme.color,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(ctx).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Open a New Account',
              style:
                  GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.savings_rounded),
              title: const Text('High-Yield Savings Vault'),
              subtitle: const Text('Earn 8.5% p.a. daily compounded'),
              onTap: () {
                Navigator.pop(ctx);
                _showToast(context, 'High-yield application started');
              },
            ),
          ],
        ),
      );
    },
  );
}

// =============================================================================
// UTILITIES
// =============================================================================
String _fmt(num amount) {
  final value = amount.round().abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < value.length; i++) {
    buffer.write(value[i]);
    final remaining = value.length - i - 1;
    if (remaining > 0 && remaining % 3 == 0) buffer.write(',');
  }
  return buffer.toString();
}

void _showToast(BuildContext context, String msg) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(msg),
      ),
    );
}
