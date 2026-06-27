import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const ExpenseTrackerApp());
}

// ─── Theme Colors ─────────────────────────────────────────────────────────────

class AppColors {
  static const background = Color(0xFFF5F4F0);
  static const foreground = Color(0xFF141414);
  static const card = Color(0xFFFFFFFF);
  static const primary = Color(0xFF1C1C28);
  static const primaryForeground = Color(0xFFFFFFFF);
  static const muted = Color(0xFFECEAE6);
  static const mutedForeground = Color(0xFF8A8880);
  static const border = Color(0x14000000);
  static const accent = Color(0xFF1E6B4A);
  static const scaffoldBg = Color(0xFFD8D7D0);

  static const catColors = {
    'housing': Color(0xFF3B6CB7),
    'food': Color(0xFFE07B39),
    'transport': Color(0xFF2D9D78),
    'shopping': Color(0xFF8B5CF6),
    'entertainment': Color(0xFFD4556A),
    'health': Color(0xFF20A5A0),
    'utilities': Color(0xFFA08C5B),
    'income': Color(0xFF1E6B4A),
  };
}

// ─── Data Models ──────────────────────────────────────────────────────────────

class Category {
  final String id;
  final String label;
  final Color color;
  final String icon;
  const Category(this.id, this.label, this.color, this.icon);
}

class Transaction {
  final int id;
  final String date;
  final String merchant;
  final String category;
  final double amount;
  final bool isIncome;
  final String? note;
  const Transaction({
    required this.id,
    required this.date,
    required this.merchant,
    required this.category,
    required this.amount,
    required this.isIncome,
    this.note,
  });
}

class SpendingData {
  final String categoryId;
  final double amount;
  const SpendingData(this.categoryId, this.amount);
}

class MonthlyData {
  final String month;
  final double spending;
  const MonthlyData(this.month, this.spending);
}

// ─── Static Data ──────────────────────────────────────────────────────────────

const categories = [
  Category('housing', 'Housing', Color(0xFF3B6CB7), '🏠'),
  Category('food', 'Food & Dining', Color(0xFFE07B39), '🍽'),
  Category('transport', 'Transport', Color(0xFF2D9D78), '🚇'),
  Category('shopping', 'Shopping', Color(0xFF8B5CF6), '🛍'),
  Category('entertainment', 'Entertainment', Color(0xFFD4556A), '🎬'),
  Category('health', 'Health', Color(0xFF20A5A0), '🩺'),
  Category('utilities', 'Utilities', Color(0xFFA08C5B), '⚡'),
  Category('income', 'Income', Color(0xFF1E6B4A), '💳'),
];

const monthlyData = [
  MonthlyData('J', 2740),
  MonthlyData('F', 2310),
  MonthlyData('M', 3120),
  MonthlyData('A', 2890),
  MonthlyData('M', 2650),
  MonthlyData('J', 3110),
];

const transactions = [
  Transaction(id: 1, date: '2026-06-25', merchant: 'Whole Foods Market', category: 'food', amount: -84.32, isIncome: false),
  Transaction(id: 2, date: '2026-06-25', merchant: 'Stripe Inc.', category: 'income', amount: 6100.00, isIncome: true, note: 'Salary'),
  Transaction(id: 3, date: '2026-06-24', merchant: 'BART Transit', category: 'transport', amount: -9.50, isIncome: false),
  Transaction(id: 4, date: '2026-06-24', merchant: 'Aesop Fillmore', category: 'shopping', amount: -48.00, isIncome: false),
  Transaction(id: 5, date: '2026-06-23', merchant: 'Pacific Gas & Electric', category: 'utilities', amount: -145.20, isIncome: false),
  Transaction(id: 6, date: '2026-06-22', merchant: 'Tartine Bakery', category: 'food', amount: -22.80, isIncome: false),
  Transaction(id: 7, date: '2026-06-22', merchant: 'Netflix', category: 'entertainment', amount: -17.99, isIncome: false),
  Transaction(id: 8, date: '2026-06-21', merchant: 'Lyft', category: 'transport', amount: -14.25, isIncome: false),
  Transaction(id: 9, date: '2026-06-20', merchant: 'UCSF Health', category: 'health', amount: -95.00, isIncome: false),
  Transaction(id: 10, date: '2026-06-19', merchant: 'Rent — 425 Fell St', category: 'housing', amount: -1450.00, isIncome: false),
  Transaction(id: 11, date: '2026-06-18', merchant: "Trader Joe's", category: 'food', amount: -63.44, isIncome: false),
  Transaction(id: 12, date: '2026-06-18', merchant: 'Freelance — Acme Corp', category: 'income', amount: 850.00, isIncome: true),
  Transaction(id: 13, date: '2026-06-17', merchant: 'Amazon', category: 'shopping', amount: -112.40, isIncome: false),
  Transaction(id: 14, date: '2026-06-16', merchant: 'Muni Monthly Pass', category: 'transport', amount: -103.00, isIncome: false),
  Transaction(id: 15, date: '2026-06-15', merchant: 'Anchor Brewing', category: 'entertainment', amount: -38.00, isIncome: false),
];

const spendingByCategory = [
  SpendingData('housing', 1450.00),
  SpendingData('food', 369.21),
  SpendingData('shopping', 325.40),
  SpendingData('health', 260.00),
  SpendingData('utilities', 235.19),
  SpendingData('transport', 126.75),
  SpendingData('entertainment', 55.99),
];

const totalIncome = 6950.00;
final totalSpent = spendingByCategory.fold(0.0, (s, c) => s + c.amount);
final balance = totalIncome - totalSpent;
final savingsRate = ((balance / totalIncome) * 100).round();

// ─── Helpers ─────────────────────────────────────────────────────────────────

Category getCat(String id) => categories.firstWhere((c) => c.id == id);

String fmt(double n) {
  final abs = n.abs();
  return '\$${abs.toStringAsFixed(2).replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  )}';
}

String fmtShort(double n) {
  if (n >= 1000) return '\$${(n / 1000).toStringAsFixed(1)}k';
  return '\$$n';
}

String fmtDate(String d) {
  final parts = d.split('-');
  final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${months[int.parse(parts[1]) - 1]} ${int.parse(parts[2])}';
}

// ─── App ──────────────────────────────────────────────────────────────────────

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'SF Pro Display',
        scaffoldBackgroundColor: AppColors.scaffoldBg,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          surface: AppColors.card,
        ),
      ),
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _tab = 0;
  bool _showModal = false;

  final _titles = ['Overview', 'Activity', 'Budget'];
  final _navItems = [
    {'label': 'Home', 'icon': Icons.home_outlined, 'activeIcon': Icons.home},
    {'label': 'Activity', 'icon': Icons.list_outlined, 'activeIcon': Icons.list},
    {'label': 'Budget', 'icon': Icons.pie_chart_outline, 'activeIcon': Icons.pie_chart},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Center(
        child: Container(
          width: 390,
          height: 844,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(44),
            boxShadow: const [
              BoxShadow(
                color: Color(0x59000000),
                blurRadius: 80,
                offset: Offset(0, 40),
              ),
              BoxShadow(
                color: Color(0xFF1C1C28),
                blurRadius: 0,
                spreadRadius: 10,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Column(
                children: [
                  // Status bar
                  _buildStatusBar(),
                  // Page header
                  _buildPageHeader(),
                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: _tab == 0
                            ? const HomeScreen()
                            : _tab == 1
                                ? const TransactionsScreen()
                                : const BudgetScreen(),
                      ),
                    ),
                  ),
                  // Bottom nav
                  _buildBottomNav(),
                ],
              ),
              if (_showModal)
                AddModal(onClose: () => setState(() => _showModal = false)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '9:41',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Courier',
                  color: AppColors.foreground,
                ),
              ),
              Row(
                children: [
                  // Signal bars
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [2, 3, 4, 5]
                        .map((h) => Container(
                              width: 4,
                              height: h * 2.5,
                              margin: const EdgeInsets.only(left: 2),
                              decoration: BoxDecoration(
                                color: AppColors.foreground,
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.wifi, size: 16, color: AppColors.foreground),
                  const SizedBox(width: 4),
                  Container(
                    width: 22,
                    height: 11,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.foreground.withOpacity(0.6)),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    padding: const EdgeInsets.all(1.5),
                    child: FractionallySizedBox(
                      widthFactor: 0.75,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.foreground,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Dynamic island
          Container(
            width: 96,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.chevron_left, size: 18, color: AppColors.mutedForeground),
              const SizedBox(width: 8),
              Text(
                _titles[_tab],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.foreground,
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Text(
                'Jun 2026',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Courier',
                  color: AppColors.mutedForeground,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, size: 14, color: AppColors.mutedForeground),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (int i = 0; i < 3; i++) ...[
                if (i == 1) const SizedBox(width: 56), // spacer for FAB
                GestureDetector(
                  onTap: () => setState(() => _tab = i),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _tab == i
                            ? _navItems[i]['activeIcon'] as IconData
                            : _navItems[i]['icon'] as IconData,
                        size: 20,
                        color: _tab == i ? AppColors.primary : AppColors.mutedForeground,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _navItems[i]['label'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: _tab == i ? AppColors.primary : AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          // FAB
          Positioned(
            top: -28,
            child: GestureDetector(
              onTap: () => setState(() => _showModal = true),
              child: Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: AppColors.primaryForeground, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Home Screen ──────────────────────────────────────────────────────────────

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Balance card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(20),
            child: Stack(
              children: [
                Positioned(
                  top: -32, right: -32,
                  child: Container(
                    width: 144, height: 144,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.05),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -48, left: -16,
                  child: Container(
                    width: 176, height: 176,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.05),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'JUNE 2026',
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: 'Courier',
                        letterSpacing: 2,
                        color: Colors.white60,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      fmt(balance),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryForeground,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Available balance',
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: 'Courier',
                        color: Colors.white60,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: Colors.white12, height: 1),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _statItem('Income', fmt(totalIncome), const Color(0xFF6EE7B7)),
                        const SizedBox(width: 24),
                        _statItem('Spent', fmt(totalSpent), Colors.white),
                        const SizedBox(width: 24),
                        _statItem('Saved', '$savingsRate%', const Color(0xFF6EE7B7)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Spending chart
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Spending',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Jan – Jun',
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'Courier',
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 100,
                  child: CustomPaint(
                    painter: BarChartPainter(monthlyData),
                    size: const Size(double.infinity, 100),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Recent transactions
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recent',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: transactions.take(5).toList().asMap().entries.map((e) {
                    final i = e.key;
                    final t = e.value;
                    return TransactionRow(
                      transaction: t,
                      showDivider: i < 4,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _statItem(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontFamily: 'Courier', color: Colors.white50)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: valueColor),
        ),
      ],
    );
  }
}

// ─── Bar Chart ────────────────────────────────────────────────────────────────

class BarChartPainter extends CustomPainter {
  final List<MonthlyData> data;
  BarChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final maxVal = data.map((d) => d.spending).reduce(max);
    final barWidth = (size.width / data.length) * 0.5;
    final gap = (size.width / data.length) * 0.5;
    const labelHeight = 18.0;
    final chartHeight = size.height - labelHeight;

    for (int i = 0; i < data.length; i++) {
      final x = i * (size.width / data.length) + gap / 2;
      final barH = (data[i].spending / maxVal) * (chartHeight - 8);
      final isLast = i == data.length - 1;

      final paint = Paint()
        ..color = isLast ? AppColors.primary : AppColors.muted
        ..style = PaintingStyle.fill;

      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, chartHeight - barH, barWidth, barH),
        topLeft: const Radius.circular(4),
        topRight: const Radius.circular(4),
      );
      canvas.drawRRect(rect, paint);

      // Label
      final tp = TextPainter(
        text: TextSpan(
          text: data[i].month,
          style: TextStyle(
            fontSize: 10,
            fontFamily: 'Courier',
            color: AppColors.mutedForeground,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(x + barWidth / 2 - tp.width / 2, chartHeight + 4),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Transaction Row ──────────────────────────────────────────────────────────

class TransactionRow extends StatelessWidget {
  final Transaction transaction;
  final bool showDivider;
  final bool showCategory;

  const TransactionRow({
    super.key,
    required this.transaction,
    this.showDivider = true,
    this.showCategory = false,
  });

  @override
  Widget build(BuildContext context) {
    final cat = getCat(transaction.category);
    final isIncome = transaction.isIncome;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: cat.color.withOpacity(0.13),
                  shape: BoxShape.circle,
                ),
                child: Center(child: Text(cat.icon, style: const TextStyle(fontSize: 16))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.merchant,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          fmtDate(transaction.date),
                          style: const TextStyle(
                            fontSize: 11,
                            fontFamily: 'Courier',
                            color: AppColors.mutedForeground,
                          ),
                        ),
                        if (showCategory) ...[
                          const Text(
                            ' · ',
                            style: TextStyle(color: AppColors.mutedForeground, fontSize: 11),
                          ),
                          Text(
                            cat.label,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.mutedForeground,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Icon(
                    isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                    size: 12,
                    color: isIncome ? AppColors.accent : AppColors.mutedForeground,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${isIncome ? '+' : ''}${fmt(transaction.amount.abs())}',
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Courier',
                      fontWeight: FontWeight.w600,
                      color: isIncome ? AppColors.accent : AppColors.foreground,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1, indent: 16, color: AppColors.border),
      ],
    );
  }
}

// ─── Transactions Screen ──────────────────────────────────────────────────────

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});
  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _search = '';
  String _filter = 'all';
  final _controller = TextEditingController();

  List<Transaction> get filtered => transactions.where((t) {
        final matchSearch =
            _search.isEmpty || t.merchant.toLowerCase().contains(_search.toLowerCase());
        final matchFilter = _filter == 'all' ||
            (_filter == 'income' && t.isIncome) ||
            (_filter == 'expense' && !t.isIncome);
        return matchSearch && matchFilter;
      }).toList();

  @override
  Widget build(BuildContext context) {
    final items = filtered;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // Search
              Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: _controller,
                  onChanged: (v) => setState(() => _search = v),
                  style: const TextStyle(fontSize: 14, color: AppColors.foreground),
                  decoration: InputDecoration(
                    hintText: 'Search transactions…',
                    hintStyle: const TextStyle(color: AppColors.mutedForeground, fontSize: 14),
                    prefixIcon: const Icon(Icons.search, size: 16, color: AppColors.mutedForeground),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Filter pills
              Row(
                children: ['all', 'expense', 'income'].map((f) {
                  final active = _filter == f;
                  return GestureDetector(
                    onTap: () => setState(() => _filter = f),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: active ? AppColors.primary : AppColors.card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: active ? AppColors.primary : AppColors.border),
                      ),
                      child: Text(
                        f[0].toUpperCase() + f.substring(1),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: active ? AppColors.primaryForeground : AppColors.mutedForeground,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: items.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(48),
                    child: Center(
                      child: Text(
                        'No transactions',
                        style: TextStyle(color: AppColors.mutedForeground, fontSize: 14),
                      ),
                    ),
                  )
                : Column(
                    children: items.asMap().entries.map((e) {
                      return TransactionRow(
                        transaction: e.value,
                        showDivider: e.key < items.length - 1,
                        showCategory: true,
                      );
                    }).toList(),
                  ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ─── Budget Screen ────────────────────────────────────────────────────────────

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final maxCatAmount = spendingByCategory.map((c) => c.amount).reduce(max);
    final budgetUsedPct = totalSpent / totalIncome;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Summary row
          Row(
            children: [
              Expanded(
                child: _summaryCard(
                  'SPENT',
                  fmt(totalSpent),
                  'of ${fmt(totalIncome)}',
                  Colors.black,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _summaryCard(
                  'SAVED',
                  fmt(balance),
                  '$savingsRate% rate',
                  AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress bar
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Budget used',
                      style: TextStyle(fontSize: 11, fontFamily: 'Courier', color: AppColors.mutedForeground),
                    ),
                    Text(
                      '${(budgetUsedPct * 100).round()}%',
                      style: const TextStyle(fontSize: 11, fontFamily: 'Courier', color: AppColors.mutedForeground),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: budgetUsedPct,
                    backgroundColor: AppColors.muted,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Categories
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'By category',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const Divider(height: 1, color: AppColors.border),
                ...spendingByCategory.asMap().entries.map((e) {
                  final c = e.value;
                  final cat = getCat(c.categoryId);
                  final pct = c.amount / maxCatAmount;
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(cat.icon, style: const TextStyle(fontSize: 16)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    cat.label,
                                    style: const TextStyle(fontSize: 14, color: AppColors.foreground),
                                  ),
                                ),
                                Text(
                                  fmt(c.amount),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontFamily: 'Courier',
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.foreground,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: pct,
                                backgroundColor: AppColors.muted,
                                valueColor: AlwaysStoppedAnimation<Color>(cat.color),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (e.key < spendingByCategory.length - 1)
                        const Divider(height: 1, color: AppColors.border),
                    ],
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _summaryCard(String label, String value, String sub, Color valueColor) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontFamily: 'Courier',
              letterSpacing: 1.5,
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: valueColor),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: const TextStyle(fontSize: 11, fontFamily: 'Courier', color: AppColors.mutedForeground),
          ),
        ],
      ),
    );
  }
}

// ─── Add Modal ────────────────────────────────────────────────────────────────

class AddModal extends StatelessWidget {
  final VoidCallback onClose;
  const AddModal({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: onClose,
          child: Container(
            color: Colors.black.withOpacity(0.4),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add transaction',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    GestureDetector(
                      onTap: onClose,
                      child: const Icon(Icons.close, size: 18, color: AppColors.mutedForeground),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _inputField('AMOUNT', '0.00', isNumber: true),
                const SizedBox(height: 16),
                _inputField('MERCHANT', 'Where did you spend?'),
                const SizedBox(height: 16),
                // Category dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CATEGORY',
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: 'Courier',
                        letterSpacing: 1.5,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.muted,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '🏠 Housing',
                            style: TextStyle(fontSize: 14, color: AppColors.foreground),
                          ),
                          const Icon(Icons.keyboard_arrow_down,
                              size: 16, color: AppColors.mutedForeground),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: onClose,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Add expense',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryForeground,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _inputField(String label, String hint, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontFamily: 'Courier',
            letterSpacing: 1.5,
            color: AppColors.mutedForeground,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.muted,
            borderRadius: BorderRadius.circular(14),
          ),
          child: TextField(
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            style: TextStyle(
              fontSize: isNumber ? 22 : 14,
              fontFamily: isNumber ? 'Courier' : null,
              color: AppColors.foreground,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.mutedForeground),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
