import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const ExpenseTrackerApp());
}

// ─── AURUM Theme ──────────────────────────────────────────────────────────────
class C {
  static const bg         = Color(0xFFF5F0E8);
  static const cardBg     = Color(0xFFFFFFFF);
  static const cardBg2    = Color(0xFFFAF7F2);
  static const gold       = Color(0xFFC9962A);
  static const goldDeep   = Color(0xFFB07D1A);
  static const goldPale   = Color(0xFFFDF3DC);
  static const goldBorder = Color(0x33C9962A);
  static const textMain   = Color(0xFF1A1612);
  static const textSub    = Color(0xFF6B6258);
  static const textHint   = Color(0xFFADA098);
  static const green      = Color(0xFF2A7D4F);
  static const greenBg    = Color(0xFFEAF5EE);
  static const red        = Color(0xFFCC3333);
  static const redBg      = Color(0xFFFFF0F0);
  static const border     = Color(0xFFEDE8DF);
  static const shadow     = Color(0x0C000000);
  static const catFood    = Color(0xFFE07B39);
  static const catHouse   = Color(0xFF5B8FD6);
  static const catShop    = Color(0xFF9B6DD6);
  static const catTravel  = Color(0xFF4BAD8A);
  static const catSub     = Color(0xFFE05C8A);
  static const catOther   = Color(0xFF8A9BB5);
}

// ─── Models ───────────────────────────────────────────────────────────────────
class TxItem {
  final String merchant, category, note;
  final double amount;
  final bool isIncome;
  final DateTime date;
  TxItem(this.merchant, this.date, this.category, this.amount, this.isIncome, {this.note = ''});
}

class AspItem {
  final String name, brand, category, reason, emoji;
  final double cost;
  bool approved;
  bool declined;
  AspItem(this.name, this.brand, this.category, this.cost, this.reason, this.emoji,
      {this.approved = false, this.declined = false});
}

class CatData {
  final String name;
  final double amount, pct;
  final Color color;
  const CatData(this.name, this.amount, this.pct, this.color);
}

class TrendPoint {
  final String label;
  final double value;
  const TrendPoint(this.label, this.value);
}

class BudgetLimit {
  final String category;
  double limit;
  BudgetLimit(this.category, this.limit);
}

class UserProfile {
  String name;
  String email;
  String initials;
  String tier;
  Color avatarColor;
  UserProfile({
    this.name = 'Alexa Reed',
    this.email = 'alexa.reed@email.com',
    this.initials = 'AR',
    this.tier = 'Gold Member',
    this.avatarColor = C.gold,
  });
}

// ─── App State ────────────────────────────────────────────────────────────────
final userProfile = UserProfile();

final List<TxItem> transactions = [
  TxItem('Dinner — Siam Garden',   DateTime(2026,6,26), 'food',    480.00, false),
  TxItem('Salary',                 DateTime(2026,6,25), 'income', 52000.00, true, note: 'Monthly salary'),
  TxItem('Central Online',         DateTime(2026,6,24), 'shopping', 1275.00, false),
  TxItem('Netflix',                DateTime(2026,6,22), 'sub',     349.00, false),
  TxItem('Tops Supermarket',       DateTime(2026,6,21), 'food',    843.00, false),
  TxItem('BTS Rabbit Card',        DateTime(2026,6,20), 'travel',   95.00, false),
  TxItem('Spotify',                DateTime(2026,6,19), 'sub',     179.00, false),
  TxItem('Freelance — Web Design', DateTime(2026,6,18), 'income',  8500.00, true, note: 'Project payment'),
  TxItem('Lazada',                 DateTime(2026,6,17), 'shopping', 1124.00, false),
  TxItem('Rent — Sukhumvit',       DateTime(2026,6,15), 'housing', 14500.00, false),
  TxItem('Pharmacy',               DateTime(2026,6,14), 'other',    320.00, false),
  TxItem('Coffee — % Arabica',     DateTime(2026,6,13), 'food',    185.00, false),
];

final List<BudgetLimit> budgetLimits = [
  BudgetLimit('food',     6000),
  BudgetLimit('shopping', 3000),
  BudgetLimit('travel',   1500),
  BudgetLimit('sub',       800),
  BudgetLimit('housing', 15000),
  BudgetLimit('other',    1000),
];

final aspirations = [
  AspItem('Sony WH-1000XM5',    'Sony Thailand',   'Electronics', 8990, '"Need for remote work focus"',   '🎧'),
  AspItem('New Balance 990v6',  'NB Thailand',     'Footwear',    7500, '"Running — old shoes worn out"',  '👟'),
  AspItem('Atomic Habits (Thai)','Se-Ed Bookstore', 'Books',        349, '"Self-improvement reading"',      '📚'),
];

const catDataStatic = [
  CatData('Food & Dining',  4830, 0.88, C.catFood),
  CatData('Housing',       14500, 1.00, C.catHouse),
  CatData('Shopping',       2399, 0.55, C.catShop),
  CatData('Travel',          950, 0.22, C.catTravel),
  CatData('Subscriptions',   528, 0.13, C.catSub),
  CatData('Other',           320, 0.08, C.catOther),
];

const trendPoints = [
  TrendPoint('Jan', 8200),
  TrendPoint('Feb', 11400),
  TrendPoint('Mar', 9800),
  TrendPoint('Apr', 14200),
  TrendPoint('May', 12600),
  TrendPoint('Jun', 16320),
];

const weeklySpend = [2100.0, 3400.0, 5200.0, 4100.0, 1800.0, 6300.0, 2900.0];
const weekLabels  = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

double get totalIncome => transactions.where((t) => t.isIncome).fold(0.0, (sum, t) => sum + t.amount);
double get totalExpense => transactions.where((t) => !t.isIncome).fold(0.0, (sum, t) => sum + t.amount);
double get netBalance => totalIncome - totalExpense;
const savingsPot   = 16320.0;

// ─── Helpers ─────────────────────────────────────────────────────────────────
String baht(double n) {
  final s = n.toStringAsFixed(0);
  final f = s.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  return '฿ $f';
}
String fmtDate(DateTime d) {
  const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  return '${months[d.month-1]} ${d.day}';
}
IconData txIcon(String cat) => switch (cat) {
  'food'    => Icons.restaurant,
  'income'  => Icons.account_balance_wallet,
  'shopping'=> Icons.shopping_bag_outlined,
  'sub'     => Icons.subscriptions_outlined,
  'travel'  => Icons.directions_transit,
  'housing' => Icons.home_outlined,
  _         => Icons.receipt_outlined,
};
Color txColor(String cat) => switch (cat) {
  'food'    => C.catFood,
  'income'  => C.green,
  'shopping'=> C.catShop,
  'sub'     => C.catSub,
  'travel'  => C.catTravel,
  'housing' => C.catHouse,
  _         => C.catOther,
};
double spentForCat(String cat) =>
    transactions.where((t) => !t.isIncome && t.category == cat).fold(0, (s, t) => s + t.amount);

// ─── App ──────────────────────────────────────────────────────────────────────
class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'AURUM',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      fontFamily: 'SF Pro Display',
      scaffoldBackgroundColor: C.bg,
      colorScheme: const ColorScheme.light(primary: C.gold, surface: C.cardBg),
    ),
    home: const AppShell(),
  );
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _tab = 0;
  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: C.bg,
    body: Center(
      child: Container(
        width: 390,
        constraints: const BoxConstraints(maxHeight: 860),
        decoration: BoxDecoration(
          color: C.bg,
          borderRadius: BorderRadius.circular(40),
          boxShadow: const [BoxShadow(color: Color(0x28000000), blurRadius: 48, offset: Offset(0, 20))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(children: [
          _StatusBar(),
          Expanded(
            child: SingleChildScrollView(
              child: _tab == 0 ? OverviewScreen(onRefresh: _refresh)
                   : _tab == 1 ? AspirationsScreen(key: const ValueKey('asp'))
                   : _tab == 2 ? const AnalyticsScreen()
                   : ProfileScreen(onRefresh: _refresh),
            ),
          ),
          _BottomNav(tab: _tab, onTab: (t) => setState(() => _tab = t)),
        ]),
      ),
    ),
  );
}

// ─── Status Bar ───────────────────────────────────────────────────────────────
class _StatusBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    color: C.bg,
    padding: const EdgeInsets.fromLTRB(24, 14, 24, 8),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
        Text('9:41', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: C.textMain)),
        Text('AURUM', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: C.gold, letterSpacing: 2)),
      ]),
      Row(children: [
        const Icon(Icons.signal_cellular_alt, size: 14, color: C.textSub),
        const SizedBox(width: 4),
        const Icon(Icons.wifi, size: 14, color: C.textSub),
        const SizedBox(width: 4),
        Container(
          width: 20, height: 10,
          decoration: BoxDecoration(border: Border.all(color: C.textSub), borderRadius: BorderRadius.circular(2)),
          padding: const EdgeInsets.all(1.5),
          child: FractionallySizedBox(
            widthFactor: 0.72, alignment: Alignment.centerLeft,
            child: Container(decoration: BoxDecoration(color: C.gold, borderRadius: BorderRadius.circular(1))),
          ),
        ),
      ]),
    ]),
  );
}

// ─── Bottom Nav ───────────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int tab;
  final ValueChanged<int> onTab;
  const _BottomNav({required this.tab, required this.onTab});

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(color: C.cardBg, border: Border(top: BorderSide(color: C.border))),
    padding: const EdgeInsets.fromLTRB(0, 10, 0, 26),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      _item(0, Icons.home_outlined,      Icons.home_rounded,        'Overview'),
      _item(1, Icons.favorite_outline,   Icons.favorite_rounded,    'Aspirations'),
      _item(2, Icons.bar_chart_outlined, Icons.bar_chart_rounded,   'Analytics'),
      _item(3, Icons.person_outline,     Icons.person_rounded,      'Profile'),
    ]),
  );

  Widget _item(int i, IconData off, IconData on, String label) {
    final active = tab == i;
    return GestureDetector(
      onTap: () => onTab(i),
      behavior: HitTestBehavior.opaque,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(active ? on : off, size: 22, color: active ? C.gold : C.textHint),
        const SizedBox(height: 3),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: active ? C.gold : C.textHint)),
        const SizedBox(height: 3),
        Container(width: 4, height: 4, decoration: BoxDecoration(shape: BoxShape.circle, color: active ? C.gold : Colors.transparent)),
      ]),
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────
class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? color;
  const _Card({required this.child, this.padding, this.color});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: padding ?? const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color ?? C.cardBg,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: C.border),
      boxShadow: const [BoxShadow(color: C.shadow, blurRadius: 8, offset: Offset(0, 2))],
    ),
    child: child,
  );
}

Widget _goldBadge(String label) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  decoration: BoxDecoration(color: C.goldPale, borderRadius: BorderRadius.circular(20), border: Border.all(color: C.goldBorder)),
  child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: C.gold)),
);

// ─── Add Transaction Modal ────────────────────────────────────────────────────
Future<void> showAddTxModal(BuildContext context, {required VoidCallback onAdded}) async {
  DateTime selectedDate = DateTime.now();
  bool isExpense = true;
  String selectedCat = 'food';
  final amtCtrl  = TextEditingController();
  final noteCtrl = TextEditingController();

  const cats = ['food','shopping','travel','sub','housing','other','income'];
  const catLabels = {'food':'Food','shopping':'Shopping','travel':'Travel',
    'sub':'Subscriptions','housing':'Housing','other':'Other','income':'Income'};
  const catEmoji = {'food':'🍽','shopping':'🛍','travel':'🚇',
    'sub':'📺','housing':'🏠','other':'📦','income':'💰'};

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => StatefulBuilder(builder: (ctx, setModal) {
      return Container(
        decoration: const BoxDecoration(
          color: C.cardBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Handle
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: C.border, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          const Text('Add Transaction', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: C.textMain)),
          const SizedBox(height: 16),

          // Type toggle
          Container(
            decoration: BoxDecoration(color: C.cardBg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: C.border)),
            padding: const EdgeInsets.all(4),
            child: Row(children: [
              _typeTab('Expense', isExpense, C.red, () => setModal(() { isExpense = true; if (selectedCat == 'income') selectedCat = 'food'; })),
              _typeTab('Income',  !isExpense, C.green, () => setModal(() { isExpense = false; selectedCat = 'income'; })),
            ]),
          ),
          const SizedBox(height: 14),

          // Date picker row
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: ctx,
                initialDate: selectedDate,
                firstDate: DateTime(2024),
                lastDate: DateTime(2027),
                builder: (ctx, child) => Theme(
                  data: Theme.of(ctx).copyWith(
                    colorScheme: const ColorScheme.light(primary: C.gold, onPrimary: Colors.white, surface: C.cardBg),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) setModal(() => selectedDate = picked);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(color: C.goldPale, borderRadius: BorderRadius.circular(12), border: Border.all(color: C.goldBorder)),
              child: Row(children: [
                const Icon(Icons.calendar_today_outlined, size: 16, color: C.gold),
                const SizedBox(width: 8),
                Text(
                  selectedDate.year == DateTime.now().year &&
                  selectedDate.month == DateTime.now().month &&
                  selectedDate.day == DateTime.now().day
                      ? 'Today, ${fmtDate(selectedDate)}'
                      : fmtDate(selectedDate),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: C.gold),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right, size: 16, color: C.gold),
              ]),
            ),
          ),
          const SizedBox(height: 12),

          // Amount
          _modalLabel('Amount'),
          Container(
            decoration: BoxDecoration(color: C.cardBg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: C.border)),
            child: TextField(
              controller: amtCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: C.textMain),
              decoration: const InputDecoration(
                prefixText: '฿  ', prefixStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: C.gold),
                hintText: '0', hintStyle: TextStyle(color: C.textHint, fontSize: 22),
                border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Note
          _modalLabel('Note (optional)'),
          Container(
            decoration: BoxDecoration(color: C.cardBg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: C.border)),
            child: TextField(
              controller: noteCtrl,
              style: const TextStyle(fontSize: 14, color: C.textMain),
              decoration: const InputDecoration(
                hintText: 'What was this for?',
                hintStyle: TextStyle(color: C.textHint, fontSize: 13),
                border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Category
          _modalLabel('Category'),
          Wrap(
            spacing: 6, runSpacing: 6,
            children: (isExpense ? cats.where((c) => c != 'income') : ['income']).map((c) {
              final active = selectedCat == c;
              final col = txColor(c);
              return GestureDetector(
                onTap: () => setModal(() => selectedCat = c),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: active ? col.withOpacity(0.15) : C.cardBg2,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: active ? col : C.border, width: active ? 1.5 : 1),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(catEmoji[c] ?? '📦', style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 4),
                    Text(catLabels[c] ?? c, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: active ? col : C.textSub)),
                  ]),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Save button
          GestureDetector(
            onTap: () {
                  final amt = double.tryParse(
                        amtCtrl.text.replaceAll(',', ''),
                      ) ??
                      0;

                  if (amt <= 0) return;

                  final tx = TxItem(
                    noteCtrl.text.trim().isEmpty
                        ? (catLabels[selectedCat] ?? "Transaction")
                        : noteCtrl.text.trim(),
                    selectedDate,
                    selectedCat,
                    amt,
                    !isExpense,
                    note: noteCtrl.text.trim(),
                  );

                  // Add to transaction list
                  transactions.insert(0, tx);

                  Navigator.pop(context);
                  onAdded();
                },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(color: C.gold, borderRadius: BorderRadius.circular(14)),
              alignment: Alignment.center,
              child: const Text('Save Transaction', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
      );
    }),
  );
}

Widget _typeTab(String label, bool active, Color color, VoidCallback onTap) => Expanded(
  child: GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        color: active ? color.withOpacity(0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: active ? color.withOpacity(0.4) : Colors.transparent),
      ),
      alignment: Alignment.center,
      child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: active ? color : C.textHint)),
    ),
  ),
);

Widget _modalLabel(String text) => Padding(
  padding: const EdgeInsets.only(bottom: 6),
  child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: C.textSub, letterSpacing: 0.5)),
);

// ─── OVERVIEW SCREEN ─────────────────────────────────────────────────────────
class OverviewScreen extends StatefulWidget {
  final VoidCallback onRefresh;
  const OverviewScreen({super.key, required this.onRefresh});
  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  double get _income  => transactions.where((t) => t.isIncome).fold(0, (s, t) => s + t.amount);
  double get _expense => transactions.where((t) => !t.isIncome).fold(0, (s, t) => s + t.amount);
  double get _net     => _income - _expense;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Header with avatar
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Overview', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: C.textMain)),
          Text('June 2026', style: const TextStyle(fontSize: 13, color: C.textSub)),
        ]),
        GestureDetector(
          onTap: () {},
          child: _AvatarWidget(size: 40),
        ),
      ]),
      const SizedBox(height: 16),

      // Balance hero
      _Card(color: C.goldPale, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('NET BALANCE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: C.gold, letterSpacing: 1.2)),
        const SizedBox(height: 6),
        Text(baht(_net), style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: _net >= 0 ? C.green : C.red, height: 1)),
        const SizedBox(height: 2),
        const Text('After all expenses this month', style: TextStyle(fontSize: 11, color: C.textSub)),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: _miniStat('INCOME',  baht(_income),  C.green)),
          const SizedBox(width: 8),
          Expanded(child: _miniStat('EXPENSE', baht(_expense), C.red)),
          const SizedBox(width: 8),
          Expanded(child: _miniStat('SAVED',
            _income > 0 ? '${((_net / _income) * 100).round()}%' : '—', C.gold)),
        ]),
      ])),
      const SizedBox(height: 14),

      // Budget alerts
      _BudgetAlertRow(),
      const SizedBox(height: 20),

      // Recent transactions
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Recent transactions', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: C.textMain)),
        GestureDetector(
          onTap: () => showAddTxModal(context, onAdded: () => setState(() {})),
          child: _goldBadge('+ Add'),
        ),
      ]),
      const SizedBox(height: 12),
      ...transactions.take(8).map((t) => _TxRow(tx: t)),
      const SizedBox(height: 8),
    ]),
  );

  Widget _miniStat(String label, String val, Color color) => Container(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
    decoration: BoxDecoration(color: C.cardBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: C.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: C.textHint, letterSpacing: 1)),
      const SizedBox(height: 4),
      Text(val, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color)),
    ]),
  );
}

class _BudgetAlertRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final alerts = budgetLimits.where((b) {
      final spent = spentForCat(b.category);
      return b.limit > 0 && spent / b.limit >= 0.7;
    }).toList();

    if (alerts.isEmpty) return const SizedBox.shrink();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Budget Alerts', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: C.textMain)),
      const SizedBox(height: 8),
      ...alerts.map((b) {
        final spent = spentForCat(b.category);
        final pct = spent / b.limit;
        final over = pct >= 1.0;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: over ? C.redBg : C.goldPale,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: over ? C.red.withOpacity(0.3) : C.goldBorder),
          ),
          child: Row(children: [
            Icon(over ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
                size: 18, color: over ? C.red : C.gold),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(b.category[0].toUpperCase() + b.category.substring(1),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: over ? C.red : C.gold)),
              Text('${baht(spent)} of ${baht(b.limit)} limit',
                  style: const TextStyle(fontSize: 11, color: C.textSub)),
            ])),
            Text('${(pct * 100).round()}%',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: over ? C.red : C.gold)),
          ]),
        );
      }),
    ]);
  }
}

class _TxRow extends StatelessWidget {
  final TxItem tx;
  const _TxRow({required this.tx});
  @override
  Widget build(BuildContext context) {
    final color = txColor(tx.category);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: C.cardBg, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: C.border),
        boxShadow: const [BoxShadow(color: C.shadow, blurRadius: 4, offset: Offset(0, 1))],
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(txIcon(tx.category), color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(tx.merchant, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: C.textMain),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          Row(children: [
            Text(fmtDate(tx.date), style: const TextStyle(fontSize: 10, color: C.textHint)),
            if (tx.note.isNotEmpty) ...[
              const Text(' · ', style: TextStyle(fontSize: 10, color: C.textHint)),
              Expanded(child: Text(tx.note, style: const TextStyle(fontSize: 10, color: C.textHint),
                  maxLines: 1, overflow: TextOverflow.ellipsis)),
            ],
          ]),
        ])),
        Text('${tx.isIncome ? '+' : '−'}${baht(tx.amount)}',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: tx.isIncome ? C.green : C.red)),
      ]),
    );
  }
}

// ─── ASPIRATIONS SCREEN ───────────────────────────────────────────────────────
class AspirationsScreen extends StatefulWidget {
  const AspirationsScreen({super.key});
  @override
  State<AspirationsScreen> createState() => _AspirationsScreenState();
}

class _AspirationsScreenState extends State<AspirationsScreen> {
  final List<AspItem> _items = List.from(aspirations);

  int _rating = 3;
  int get _pending => _items.where((a) => !a.approved && !a.declined).length;

  void _addAspiration(
    String name,
    String store,
    String category,
    double price,
    String reason,
    String emoji,
  ) {
    if (name.trim().isEmpty) return;

    setState(() {
      _items.add(
        AspItem(
          name.trim(),
          store.trim().isEmpty ? "Unknown" : store.trim(),
          category.trim().isEmpty ? "Other" : category.trim(),
          price,
          reason.trim(),
          emoji.trim().isEmpty ? "✨" : emoji.trim(),
        ),
      );
    });
  }
  void _showAddDialog() {
    final nameController = TextEditingController();
    final storeController = TextEditingController();
    final categoryController = TextEditingController();
    final priceController = TextEditingController();
    final reasonController = TextEditingController();
    final emojiController = TextEditingController(text: "✨");

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Aspiration"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Item Name"),
              ),
              TextField(
                controller: storeController,
                decoration: const InputDecoration(labelText: "Store"),
              ),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: "Category"),
              ),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Price"),
              ),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(labelText: "Reason"),
              ),
              TextField(
                controller: emojiController,
                decoration: const InputDecoration(labelText: "Emoji"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              _addAspiration(
                nameController.text,
                storeController.text,
                categoryController.text,
                double.tryParse(priceController.text) ?? 0,
                reasonController.text,
                emojiController.text,
              );

              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Aspirations', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: C.textMain)),
        _AvatarWidget(size: 36),
      ]),
      const SizedBox(height: 16),

      // Savings potential
      _Card(color: C.goldPale, child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('TOTAL SAVINGS POTENTIAL', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: C.gold, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(baht(savingsPot), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: C.gold, height: 1.1)),
          const SizedBox(height: 2),
          const Text('if all pending approved', style: TextStyle(fontSize: 10, color: C.textSub)),
        ])),
        const SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          const Text('NET BALANCE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: C.textSub, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(baht(netBalance), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: C.green)),
        ]),
      ])),
      const SizedBox(height: 10),

      Row(children: [
        Expanded(child: _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('PENDING DECISIONS', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: C.textHint, letterSpacing: 0.8)),
          const SizedBox(height: 6),
          Text('$_pending', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: C.textMain, height: 1)),
          const Text('items waiting', style: TextStyle(fontSize: 10, color: C.textHint)),
        ]))),
        const SizedBox(width: 10),
        Expanded(child: _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('SATISFACTION SCORE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: C.textHint, letterSpacing: 0.8)),
          const SizedBox(height: 6),
          RichText(text: const TextSpan(children: [
            TextSpan(text: '8.4', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: C.gold, height: 1)),
            TextSpan(text: '/10', style: TextStyle(fontSize: 13, color: C.textSub)),
          ])),
          const SizedBox(height: 6),
          ClipRRect(borderRadius: BorderRadius.circular(4),
              child: const LinearProgressIndicator(value: 0.84, backgroundColor: C.border, color: C.gold, minHeight: 5)),
        ]))),
      ]),
      const SizedBox(height: 20),

      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Pending decisions', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: C.textMain)),
        _goldBadge('$_pending items'),
      ]),
      const SizedBox(height: 12),

      ..._items.asMap().entries.map((e) {
        final a = e.value;
        return _AspCard(
          item: a,
          onApprove: () => setState(() { a.approved = true; a.declined = false; }),
          onDecline: () => setState(() { a.declined = true; a.approved = false; }),
        );
      }),

      const SizedBox(height: 8),
      const Text('Rate recent buys', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: C.textMain)),
      const SizedBox(height: 12),
      _Card(color: C.goldPale, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: C.gold.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
          child: const Text('3 DAYS AGO · AIRPODS PRO 2ND GEN',
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: C.gold, letterSpacing: 0.8)),
        ),
        const SizedBox(height: 8),
        const Text('Was it worth ฿ 9,900?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: C.textMain)),
        const SizedBox(height: 10),
        Row(children: List.generate(5, (i) => GestureDetector(
          onTap: () => setState(() => _rating = i + 1),
          child: Padding(padding: const EdgeInsets.only(right: 4),
              child: Icon(i < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 28, color: i < _rating ? C.gold : C.border)),
        ))),
      ])),
      const SizedBox(height: 16),

      Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: _showAddDialog,
              child: Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: C.gold,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x44C9962A),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
    ]),
  );
}

class _AspCard extends StatelessWidget {
  final AspItem item;
  final VoidCallback onApprove, onDecline;
  const _AspCard({required this.item, required this.onApprove, required this.onDecline});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: C.cardBg, borderRadius: BorderRadius.circular(16),
      border: Border.all(color: item.approved ? C.green.withOpacity(0.4) : item.declined ? C.red.withOpacity(0.3) : C.border),
      boxShadow: const [BoxShadow(color: C.shadow, blurRadius: 6, offset: Offset(0, 2))],
    ),
    child: Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(color: C.cardBg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: C.border)),
            child: Center(child: Text(item.emoji, style: const TextStyle(fontSize: 26))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: C.textMain)),
            Text('${item.brand} · ${item.category}', style: const TextStyle(fontSize: 11, color: C.textSub)),
            const SizedBox(height: 4),
            Text(baht(item.cost), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: C.red, height: 1.2)),
            const SizedBox(height: 4),
            Text(item.reason, style: const TextStyle(fontSize: 11, color: C.textSub, fontStyle: FontStyle.italic)),
          ])),
        ]),
      ),
      const Divider(height: 1, color: C.border),
      Padding(
        padding: const EdgeInsets.all(10),
        child: Row(children: [
          Expanded(child: GestureDetector(
            onTap: onDecline,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: item.declined ? C.redBg : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: item.declined ? C.red.withOpacity(0.4) : C.border),
              ),
              alignment: Alignment.center,
              child: Text(item.declined ? 'Declined' : 'Decline',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: item.declined ? C.red : C.textSub)),
            ),
          )),
          const SizedBox(width: 8),
          Expanded(child: GestureDetector(
            onTap: onApprove,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(color: item.approved ? C.green : C.gold, borderRadius: BorderRadius.circular(10)),
              alignment: Alignment.center,
              child: Text(item.approved ? 'Approved ✓' : 'Approve',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          )),
        ]),
      ),
    ]),
  );
}

// ─── ANALYTICS SCREEN ─────────────────────────────────────────────────────────
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
          Text('Analytics', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: C.textMain)),
          Text('June 2026 · summary', style: TextStyle(fontSize: 13, color: C.textSub)),
        ]),
        _AvatarWidget(size: 36),
      ]),
      const SizedBox(height: 16),

      // Stats grid
      Row(children: [
        Expanded(child: _statCard('TOTAL SPENT',  baht(totalExpense), '↑ 4.2% vs May',   false)),
        const SizedBox(width: 10),
        Expanded(child: _statCard('SAVED',        baht(netBalance),   '↑ 12.1% growth',  true)),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: _statCard('INCOME',       baht(totalIncome),  'This month',       true)),
        const SizedBox(width: 10),
        Expanded(child: _statCard('SAVE RATE',    '${((netBalance / totalIncome) * 100).round()}%', 'of income', true)),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: _statCard('AVG / DAY',    baht(totalExpense / 30), 'Daily spending', false)),
        const SizedBox(width: 10),
        Expanded(child: _statCard('TRANSACTIONS', '${transactions.length}', 'This month', true)),
      ]),
      const SizedBox(height: 20),

      // Weekly bar chart
      const Text('Weekly Spending', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: C.textMain)),
      const SizedBox(height: 10),
      _Card(child: Column(children: [
        SizedBox(height: 110, child: CustomPaint(painter: _BarPainter(), size: const Size(double.infinity, 110))),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: weekLabels.map((l) => Text(l, style: const TextStyle(fontSize: 10, color: C.textHint))).toList()),
      ])),
      const SizedBox(height: 20),

      // Balance trend
      const Text('Balance Trend (6 months)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: C.textMain)),
      const SizedBox(height: 10),
      _Card(child: Column(children: [
        SizedBox(height: 120, child: CustomPaint(painter: _LinePainter(), size: const Size(double.infinity, 120))),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: trendPoints.map((p) => Text(p.label, style: const TextStyle(fontSize: 10, color: C.textHint))).toList()),
      ])),
      const SizedBox(height: 20),

      // Budget vs Actual
      const Text('Budget vs Actual', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: C.textMain)),
      const SizedBox(height: 10),
      _Card(child: Column(
        children: budgetLimits.where((b) => b.limit > 0).map((b) {
          final spent = spentForCat(b.category);
          final pct = (spent / b.limit).clamp(0.0, 1.0);
          final over = spent > b.limit;
          final color = over ? C.red : (pct > 0.8 ? C.gold : C.green);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(b.category[0].toUpperCase() + b.category.substring(1),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: C.textMain)),
                Row(children: [
                  Text(baht(spent), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
                  Text(' / ${baht(b.limit)}', style: const TextStyle(fontSize: 11, color: C.textHint)),
                ]),
              ]),
              const SizedBox(height: 5),
              ClipRRect(borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(value: pct, backgroundColor: C.border, color: color, minHeight: 5)),
            ]),
          );
        }).toList(),
      )),
      const SizedBox(height: 20),

      // Donut
      const Text('Spending by Category', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: C.textMain)),
      const SizedBox(height: 10),
      _Card(child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        SizedBox(width: 100, height: 100, child: CustomPaint(painter: _DonutPainter())),
        const SizedBox(width: 16),
        Expanded(child: Column(children: catDataStatic.map((c) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: c.color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Expanded(child: Text(c.name, style: const TextStyle(fontSize: 11, color: C.textSub))),
            Text('${(c.pct * 100).round()}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: C.textMain)),
          ]),
        )).toList())),
      ])),
      const SizedBox(height: 20),

      // Top categories
      const Text('Top Expense Categories', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: C.textMain)),
      const SizedBox(height: 10),
      _Card(child: Column(children: catDataStatic.asMap().entries.map((e) {
        final c = e.value;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(children: [
            Text('#${e.key + 1}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: C.gold)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(c.name, style: const TextStyle(fontSize: 12, color: C.textMain, fontWeight: FontWeight.w600)),
                Text(baht(c.amount), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: C.red)),
              ]),
              const SizedBox(height: 5),
              ClipRRect(borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(value: c.pct, backgroundColor: C.border, color: c.color, minHeight: 5)),
            ])),
          ]),
        );
      }).toList())),
      const SizedBox(height: 16),
    ]),
  );

  Widget _statCard(String label, String val, String sub, bool pos) => _Card(
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: C.textHint, letterSpacing: 0.9)),
      const SizedBox(height: 5),
      Text(val, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: C.textMain)),
      const SizedBox(height: 2),
      Text(sub, style: TextStyle(fontSize: 10, color: pos ? C.green : C.red)),
    ]),
  );
}

// ─── PROFILE SCREEN ───────────────────────────────────────────────────────────
class ProfileScreen extends StatefulWidget {
  final VoidCallback onRefresh;
  const ProfileScreen({super.key, required this.onRefresh});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl  = TextEditingController(text: userProfile.name);
  final _emailCtrl = TextEditingController(text: userProfile.email);
  bool _editing = false;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Profile', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: C.textMain)),
      const SizedBox(height: 20),

      // Avatar + info card
      _Card(child: Column(children: [
        // Big avatar
        Center(child: Stack(children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [C.gold, Color(0xFFE8B84B)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              border: Border.all(color: C.goldPale, width: 3),
            ),
            alignment: Alignment.center,
            child: Text(userProfile.initials, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
          ),
          Positioned(bottom: 0, right: 0,
            child: Container(
              width: 24, height: 24,
              decoration: const BoxDecoration(color: C.gold, shape: BoxShape.circle),
              child: const Icon(Icons.camera_alt, size: 13, color: Colors.white),
            ),
          ),
        ])),
        const SizedBox(height: 12),
        Text(userProfile.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: C.textMain)),
        Text(userProfile.email, style: const TextStyle(fontSize: 12, color: C.textSub)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(color: C.goldPale, borderRadius: BorderRadius.circular(20), border: Border.all(color: C.goldBorder)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.workspace_premium, size: 14, color: C.gold),
            const SizedBox(width: 5),
            Text(userProfile.tier, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: C.gold)),
          ]),
        ),
        const SizedBox(height: 16),

        // Edit form
        if (_editing) ...[
          _editField('Name', _nameCtrl),
          const SizedBox(height: 10),
          _editField('Email', _emailCtrl, type: TextInputType.emailAddress),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: GestureDetector(
              onTap: () => setState(() => _editing = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(color: C.cardBg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: C.border)),
                alignment: Alignment.center,
                child: const Text('Cancel', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: C.textSub)),
              ),
            )),
            const SizedBox(width: 10),
            Expanded(child: GestureDetector(
              onTap: () => setState(() {
                userProfile.name = _nameCtrl.text;
                userProfile.email = _emailCtrl.text;
                userProfile.initials = _nameCtrl.text.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase();
                _editing = false;
                widget.onRefresh();
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(color: C.gold, borderRadius: BorderRadius.circular(12)),
                alignment: Alignment.center,
                child: const Text('Save', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            )),
          ]),
        ] else
          GestureDetector(
            onTap: () => setState(() => _editing = true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
              decoration: BoxDecoration(color: C.cardBg2, borderRadius: BorderRadius.circular(20), border: Border.all(color: C.border)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.edit_outlined, size: 14, color: C.textSub),
                SizedBox(width: 6),
                Text('Edit Profile', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: C.textSub)),
              ]),
            ),
          ),
      ])),
      const SizedBox(height: 16),

      // Stats summary
      const Text('This Month', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: C.textMain)),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: _statBox('Transactions', '${transactions.length}', Icons.receipt_outlined, C.catShop)),
        const SizedBox(width: 10),
        Expanded(child: _statBox('Total Income', baht(totalIncome), Icons.trending_up, C.green)),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: _statBox('Total Spent', baht(totalExpense), Icons.trending_down, C.red)),
        const SizedBox(width: 10),
        Expanded(child: _statBox('Save Rate', '${((netBalance / totalIncome) * 100).round()}%', Icons.savings_outlined, C.gold)),
      ]),
      const SizedBox(height: 20),

      // Budget limits section
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Monthly Budget Limits', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: C.textMain)),
        _goldBadge('Edit limits'),
      ]),
      const SizedBox(height: 10),
      _Card(child: Column(
        children: budgetLimits.map((b) => _BudgetLimitRow(budget: b, onChanged: () => setState(() {}))).toList(),
      )),
      const SizedBox(height: 20),

      // Settings rows
      const Text('Settings', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: C.textMain)),
      const SizedBox(height: 10),
      _Card(child: Column(children: [
        _settingRow(Icons.notifications_outlined, 'Notifications', 'Budget alerts & reminders'),
        const Divider(height: 1, color: C.border),
        _settingRow(Icons.security_outlined, 'Privacy', 'Data & account'),
        const Divider(height: 1, color: C.border),
        _settingRow(Icons.color_lens_outlined, 'Theme', 'AURUM Gold'),
        const Divider(height: 1, color: C.border),
        _settingRow(Icons.help_outline, 'Help & Support', 'FAQ & contact'),
      ])),
      const SizedBox(height: 16),
    ]),
  );

  Widget _editField(String label, TextEditingController ctrl, {TextInputType? type}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: C.textSub)),
      const SizedBox(height: 5),
      Container(
        decoration: BoxDecoration(color: C.cardBg2, borderRadius: BorderRadius.circular(10), border: Border.all(color: C.border)),
        child: TextField(
          controller: ctrl,
          keyboardType: type,
          style: const TextStyle(fontSize: 14, color: C.textMain),
          decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
        ),
      ),
    ],
  );

  Widget _statBox(String label, String val, IconData icon, Color color) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: C.cardBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: C.border),
        boxShadow: const [BoxShadow(color: C.shadow, blurRadius: 6, offset: Offset(0, 2))]),
    child: Row(children: [
      Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 18)),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 10, color: C.textHint)),
        Text(val, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: C.textMain)),
      ]),
    ]),
  );

  Widget _settingRow(IconData icon, String title, String sub) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
    child: Row(children: [
      Icon(icon, size: 20, color: C.gold),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: C.textMain)),
        Text(sub, style: const TextStyle(fontSize: 11, color: C.textHint)),
      ])),
      const Icon(Icons.chevron_right, size: 18, color: C.textHint),
    ]),
  );
}

class _BudgetLimitRow extends StatefulWidget {
  final BudgetLimit budget;
  final VoidCallback onChanged;
  const _BudgetLimitRow({required this.budget, required this.onChanged});
  @override
  State<_BudgetLimitRow> createState() => _BudgetLimitRowState();
}

class _BudgetLimitRowState extends State<_BudgetLimitRow> {
  bool _editing = false;
  late TextEditingController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.budget.limit.toStringAsFixed(0));
  }

  @override
  Widget build(BuildContext context) {
    final spent = spentForCat(widget.budget.category);
    final pct = widget.budget.limit > 0 ? (spent / widget.budget.limit).clamp(0.0, 1.0) : 0.0;
    final over = spent > widget.budget.limit;
    final catLabel = widget.budget.category[0].toUpperCase() + widget.budget.category.substring(1);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(children: [
        Row(children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: txColor(widget.budget.category))),
          const SizedBox(width: 8),
          Expanded(child: Text(catLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: C.textMain))),
          if (_editing)
            SizedBox(
              width: 100,
              child: TextField(
                controller: _ctrl,
                keyboardType: TextInputType.number,
                autofocus: true,
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: C.gold),
                decoration: InputDecoration(
                  prefixText: '฿ ',
                  prefixStyle: const TextStyle(color: C.gold, fontSize: 12),
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: C.gold)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                ),
                onSubmitted: (v) {
                  setState(() { widget.budget.limit = double.tryParse(v) ?? widget.budget.limit; _editing = false; });
                  widget.onChanged();
                },
              ),
            )
          else
            GestureDetector(
              onTap: () => setState(() => _editing = true),
              child: Row(children: [
                Text(baht(widget.budget.limit), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: C.gold)),
                const SizedBox(width: 4),
                const Icon(Icons.edit, size: 12, color: C.textHint),
              ]),
            ),
        ]),
        const SizedBox(height: 5),
        ClipRRect(borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: pct, backgroundColor: C.border,
              color: over ? C.red : (pct > 0.8 ? C.gold : C.green), minHeight: 4)),
        const SizedBox(height: 3),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Spent: ${baht(spent)}', style: const TextStyle(fontSize: 10, color: C.textHint)),
          Text(over ? 'Over limit!' : '${(pct * 100).round()}% used',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: over ? C.red : C.textHint)),
        ]),
      ]),
    );
  }
}

// ─── Avatar Widget ────────────────────────────────────────────────────────────
class _AvatarWidget extends StatelessWidget {
  final double size;
  const _AvatarWidget({required this.size});
  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(colors: [C.gold, Color(0xFFE8B84B)], begin: Alignment.topLeft, end: Alignment.bottomRight),
      border: Border.fromBorderSide(BorderSide(color: C.goldPale, width: 2)),
    ),
    alignment: Alignment.center,
    child: Text(userProfile.initials, style: TextStyle(color: Colors.white, fontSize: size * 0.35, fontWeight: FontWeight.w800)),
  );
}

// ─── FAB ─────────────────────────────────────────────────────────────────────
// (Integrated in OverviewScreen as floating action via Scaffold FAB alternative)

// ─── Custom Painters ─────────────────────────────────────────────────────────
class _BarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final maxV = weeklySpend.reduce(max);
    final n = weeklySpend.length;
    final slotW = size.width / n;
    final barW  = slotW * 0.5;
    for (int i = 0; i < n; i++) {
      final barH = (weeklySpend[i] / maxV) * (size.height - 16);
      final x = i * slotW + (slotW - barW) / 2;
      final isMax = weeklySpend[i] == maxV;
      final rr = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, size.height - barH, barW, barH),
        topLeft: const Radius.circular(5), topRight: const Radius.circular(5),
      );
      canvas.drawRRect(rr, Paint()..color = isMax ? C.gold : C.gold.withOpacity(0.3));
      if (isMax) {
        final tp = TextPainter(
          text: TextSpan(text: baht(weeklySpend[i]), style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: C.gold)),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x + barW / 2 - tp.width / 2, size.height - barH - 14));
      }
    }
  }
  @override bool shouldRepaint(_) => false;
}

class _LinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final vals = trendPoints.map((p) => p.value).toList();
    final maxV = vals.reduce(max), minV = vals.reduce(min);
    final n = vals.length;
    double x(int i) => i * size.width / (n - 1);
    double y(double v) => size.height * 0.85 * (1 - (v - minV) / (maxV - minV)) + size.height * 0.05;

    final gp = Paint()..color = C.border..strokeWidth = 0.5;
    for (int i = 1; i <= 3; i++) canvas.drawLine(Offset(0, size.height * i / 4), Offset(size.width, size.height * i / 4), gp);

    final fp = Path()..moveTo(x(0), y(vals[0]));
    for (int i = 1; i < n; i++) fp.lineTo(x(i), y(vals[i]));
    fp..lineTo(size.width, size.height)..lineTo(0, size.height)..close();
    canvas.drawPath(fp, Paint()..shader = LinearGradient(
      colors: [C.gold.withOpacity(0.18), C.gold.withOpacity(0)],
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)));

    final lp = Path()..moveTo(x(0), y(vals[0]));
    for (int i = 1; i < n; i++) lp.lineTo(x(i), y(vals[i]));
    canvas.drawPath(lp, Paint()..color = C.gold..strokeWidth = 2..style = PaintingStyle.stroke..strokeJoin = StrokeJoin.round..strokeCap = StrokeCap.round);

    for (int i = 0; i < n; i++) {
      final last = i == n - 1;
      canvas.drawCircle(Offset(x(i), y(vals[i])), last ? 5 : 3, Paint()..color = last ? C.gold : C.gold.withOpacity(0.6));
      if (last) canvas.drawCircle(Offset(x(i), y(vals[i])), 5, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2);
    }
  }
  @override bool shouldRepaint(_) => false;
}

class _DonutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final r = min(cx, cy) - 8;
    var start = -pi / 2;
    for (final c in catDataStatic) {
      final sweep = c.pct * 2 * pi;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        start, sweep - 0.05, false,
        Paint()..color = c.color..style = PaintingStyle.stroke..strokeWidth = 18..strokeCap = StrokeCap.butt,
      );
      start += sweep;
    }
    final tp = TextPainter(
      text: const TextSpan(text: '฿44k\ntotal', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: C.textMain, height: 1.4)),
      textDirection: TextDirection.ltr, textAlign: TextAlign.center,
    )..layout(maxWidth: 50);
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }
  @override bool shouldRepaint(_) => false;
}
