import 'package:flutter/material.dart';

/// Transaction Model
class TransactionItem {
  final String title;
  final String subtitle;
  final double amount;
  final IconData icon;
  final Color? iconColor;
  final String category;
  final String referenceId;
  final DateTime timestamp;
  final String paymentMethod;
  final String status;

  const TransactionItem({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.icon,
    this.iconColor,
    this.category = 'Transfer',
    this.referenceId = 'FT-99482103',
    DateTime? timestamp,
    this.paymentMethod = 'Paspor Blue GPN BCA',
    this.status = 'Completed',
  }) : timestamp = timestamp ?? const _DefaultDate();
}

class _DefaultDate implements DateTime {
  const _DefaultDate();
  @override
  dynamic noSuchMethod(Invocation invocation) => DateTime.now();
}

/// Upcoming Bill Reminder Model
class BillReminder {
  final String id;
  final String title;
  final String provider;
  final double amount;
  final DateTime dueDate;
  final IconData icon;
  final Color color;
  final bool isAutoPay;
  final String accountNumber;
  final bool isPaid;

  const BillReminder({
    required this.id,
    required this.title,
    required this.provider,
    required this.amount,
    required this.dueDate,
    required this.icon,
    required this.color,
    this.isAutoPay = false,
    required this.accountNumber,
    this.isPaid = false,
  });

  int get daysUntilDue {
    final now = DateTime.now();
    final diff =
        dueDate.difference(DateTime(now.year, now.month, now.day)).inDays;
    return diff;
  }

  String get dueLabel {
    if (isPaid) return 'Paid';
    final days = daysUntilDue;
    if (days < 0) return 'Overdue';
    if (days == 0) return 'Due today';
    if (days == 1) return 'Due tomorrow';
    return 'Due in $days days';
  }

  BillReminder copyWith({bool? isPaid, bool? isAutoPay}) {
    return BillReminder(
      id: id,
      title: title,
      provider: provider,
      amount: amount,
      dueDate: dueDate,
      icon: icon,
      color: color,
      isAutoPay: isAutoPay ?? this.isAutoPay,
      accountNumber: accountNumber,
      isPaid: isPaid ?? this.isPaid,
    );
  }
}

/// Budgeting Tip Model
class BudgetingTip {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final String detailedStrategy;
  final String estimatedSaving;
  final IconData icon;
  final Color accentColor;

  const BudgetingTip({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.detailedStrategy,
    required this.estimatedSaving,
    required this.icon,
    required this.accentColor,
  });
}

/// Personalized Financial Recommendation Model
class FinancialRecommendation {
  final String id;
  final String title;
  final String description;
  final String impactBadge;
  final String actionLabel;
  final IconData icon;
  final Color accentColor;
  final VoidCallback? onApply;

  const FinancialRecommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.impactBadge,
    required this.actionLabel,
    required this.icon,
    required this.accentColor,
    this.onApply,
  });
}

/// Default Sample Data
final List<TransactionItem> defaultTransactions = [
  const TransactionItem(
    title: 'Food City',
    subtitle: 'Today • 09:41',
    amount: -2300,
    icon: Icons.shopping_basket_outlined,
    iconColor: Color(0xFFF2A65A),
    category: 'Groceries',
    referenceId: 'FT-88390214',
  ),
  const TransactionItem(
    title: 'Recharge',
    subtitle: 'Yesterday • 18:20',
    amount: -1000,
    icon: Icons.phone_android_rounded,
    iconColor: Color(0xFF7B83EB),
    category: 'Utilities',
    referenceId: 'FT-77290123',
  ),
  const TransactionItem(
    title: 'Monthly Salary',
    subtitle: '2 May 2023 • 08:15',
    amount: 130000,
    icon: Icons.south_west_rounded,
    iconColor: Color(0xFF2E7D32),
    category: 'Income',
    referenceId: 'FT-66189012',
  ),
  const TransactionItem(
    title: 'Café Kumbuk',
    subtitle: '1 May 2023 • 16:30',
    amount: -4250,
    icon: Icons.local_cafe_outlined,
    iconColor: Color(0xFFF2A65A),
    category: 'Dining',
    referenceId: 'FT-55078901',
  ),
  const TransactionItem(
    title: 'Monthly Savings',
    subtitle: '30 Apr 2023 • 10:00',
    amount: -25000,
    icon: Icons.savings_outlined,
    iconColor: Color(0xFF7B83EB),
    category: 'Savings Vault',
    referenceId: 'FT-44967890',
  ),
];

final List<BillReminder> defaultBills = [
  BillReminder(
    id: 'bill-1',
    title: 'Ceylon Electricity Board',
    provider: 'Electricity Utility',
    amount: 14850,
    dueDate: DateTime.now().add(const Duration(days: 2)),
    icon: Icons.bolt_rounded,
    color: const Color(0xFFE65100),
    isAutoPay: false,
    accountNumber: 'CEB-99201-440',
  ),
  BillReminder(
    id: 'bill-2',
    title: 'Dialog Fiber Broadband',
    provider: 'High-Speed Home Internet',
    amount: 5420,
    dueDate: DateTime.now().add(const Duration(days: 4)),
    icon: Icons.wifi_rounded,
    color: const Color(0xFF6750A4),
    isAutoPay: true,
    accountNumber: 'DIA-FBR-00192',
  ),
  BillReminder(
    id: 'bill-3',
    title: 'National Water Drainage',
    provider: 'Municipal Water',
    amount: 1890,
    dueDate: DateTime.now().add(const Duration(days: 7)),
    icon: Icons.water_drop_rounded,
    color: const Color(0xFF0288D1),
    isAutoPay: false,
    accountNumber: 'NWSDB-448109',
  ),
  BillReminder(
    id: 'bill-4',
    title: 'BCA Platinum Mastercard',
    provider: 'Credit Card Statement',
    amount: 25000,
    dueDate: DateTime.now().add(const Duration(days: 9)),
    icon: Icons.credit_card_rounded,
    color: const Color(0xFF7B1FA2),
    isAutoPay: false,
    accountNumber: '•••• •••• •••• 2100',
  ),
  BillReminder(
    id: 'bill-5',
    title: 'Spotify Family Subscription',
    provider: 'Digital Entertainment',
    amount: 1299,
    dueDate: DateTime.now().add(const Duration(days: 12)),
    icon: Icons.music_note_rounded,
    color: const Color(0xFF2E7D32),
    isAutoPay: true,
    accountNumber: 'SUB-SPOTIFY-FAM',
  ),
];

final List<BudgetingTip> defaultBudgetingTips = [
  const BudgetingTip(
    id: 'tip-1',
    title: 'The 50/30/20 Rule',
    subtitle: 'Classic balanced budgeting framework',
    category: 'Budgeting',
    detailedStrategy:
        'Allocate 50% of take-home income to Essential Needs (rent, utilities, groceries), 30% to Lifestyle & Wants (dining, hobbies), and 20% strictly to Savings and Debt reduction.',
    estimatedSaving: '+LKR 26,000 / mo',
    icon: Icons.pie_chart_outline_rounded,
    accentColor: Color(0xFF6750A4),
  ),
  const BudgetingTip(
    id: 'tip-2',
    title: 'Subscription Spring Cleaning',
    subtitle: 'Audit silent recurring debits',
    category: 'Expenses',
    detailedStrategy:
        'FinTrust identified 3 recurring subscriptions not accessed in the last 30 days. Canceling duplicate music and streaming services saves direct cash instantly.',
    estimatedSaving: '+LKR 4,500 / mo',
    icon: Icons.replay_circle_filled_rounded,
    accentColor: Color(0xFF0288D1),
  ),
  const BudgetingTip(
    id: 'tip-3',
    title: 'Automated Micro-Savings (Round-ups)',
    subtitle: 'Save effortlessly with every purchase',
    category: 'Savings',
    detailedStrategy:
        'Every time you pay with your FinTrust debit or QR code, round up the change to the nearest 100 LKR into your High-Yield Vault. An average user collects LKR 12,500 per month without noticing.',
    estimatedSaving: '+LKR 12,500 / mo',
    icon: Icons.savings_rounded,
    accentColor: Color(0xFF2E7D32),
  ),
  const BudgetingTip(
    id: 'tip-4',
    title: '3-Month Emergency Safety Shield',
    subtitle: 'Protect against sudden market shocks',
    category: 'Security',
    detailedStrategy:
        'Build a liquid emergency reserve equal to 3 months of baseline living costs. Keep this in a zero-penalty high-interest vault rather than your daily spending account.',
    estimatedSaving: 'Risk Buffer: LKR 300,000',
    icon: Icons.shield_rounded,
    accentColor: Color(0xFFE65100),
  ),
  const BudgetingTip(
    id: 'tip-5',
    title: 'Smart Grocery Bulk Optimization',
    subtitle: 'Reduce recurring supermarket bills',
    category: 'Lifestyle',
    detailedStrategy:
        'Purchasing non-perishable staples in monthly bulk orders during weekend discount promotions reduces average supermarket spend by 14% month-over-month.',
    estimatedSaving: '+LKR 8,200 / mo',
    icon: Icons.shopping_bag_outlined,
    accentColor: Color(0xFF7B1FA2),
  ),
];

final List<FinancialRecommendation> defaultRecommendations = [
  const FinancialRecommendation(
    id: 'rec-1',
    title: 'Switch LKR 50,000 to High-Yield Vault',
    description:
        'Your main account holds surplus liquidity. Moving LKR 50,000 to the 8.5% p.a. FinTrust Vault earns +LKR 4,250 annual interest with zero lock-in.',
    impactBadge: 'Earn +LKR 4,250 / yr',
    actionLabel: 'Transfer to Vault',
    icon: Icons.trending_up_rounded,
    accentColor: Color(0xFF2E7D32),
  ),
  const FinancialRecommendation(
    id: 'rec-2',
    title: 'Dining Spend Alert: 24% Above Average',
    description:
        'You spent LKR 14,800 on dining this week. Setting a weekly dining cap of LKR 8,000 will accelerate your Bali Trip vacation goal by 2 months.',
    impactBadge: 'Save LKR 6,800 / mo',
    actionLabel: 'Set Dining Budget',
    icon: Icons.restaurant_rounded,
    accentColor: Color(0xFFE65100),
  ),
  const FinancialRecommendation(
    id: 'rec-3',
    title: 'Cashback Boost: Weekend Supermarkets',
    description:
        'Use your BCA Platinum Mastercard at Keells & Food City this weekend to earn 5% instant cashback (up to LKR 2,500).',
    impactBadge: '5% Instant Cashback',
    actionLabel: 'Activate Offer',
    icon: Icons.stars_rounded,
    accentColor: Color(0xFF6750A4),
  ),
];
