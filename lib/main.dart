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
  static const bg         = Color(0xFFF5F0E8); // warm beige
  static const cardBg     = Color(0xFFFFFFFF);
  static const cardBg2    = Color(0xFFFAF7F2); // soft cream card
  static const gold       = Color(0xFFC9962A); // AURUM gold
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
  // category
  static const catFood    = Color(0xFFE07B39);
  static const catHouse   = Color(0xFF5B8FD6);
  static const catShop    = Color(0xFF9B6DD6);
  static const catTravel  = Color(0xFF4BAD8A);
  static const catSub     = Color(0xFFE05C8A);
  static const catOther   = Color(0xFF8A9BB5);
}

// ─── Models ───────────────────────────────────────────────────────────────────
class TxItem {
  final String merchant, date, category, note;
  final double amount;
  final bool isIncome;
  const TxItem(this.merchant, this.date, this.category, this.amount, this.isIncome, {this.note = ''});
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

// ─── Static Data ──────────────────────────────────────────────────────────────
final transactions = [
  const TxItem('Dinner — Siam Garden',    'Jun 26', 'food',    480.00, false),
  const TxItem('Salary',                  'Jun 25', 'income', 52000.00, true, note: 'Monthly salary'),
  const TxItem('Central Online',          'Jun 24', 'shopping', 1275.00, false),
  const TxItem('Netflix',                 'Jun 22', 'sub',     349.00, false),
  const TxItem('Tops Supermarket',        'Jun 21', 'food',    843.00, false),
  const TxItem('BTS Rabbit Card',         'Jun 20', 'travel',   95.00, false),
  const TxItem('Spotify',                 'Jun 19', 'sub',     179.00, false),
  const TxItem('Freelance — Web Design',  'Jun 18', 'income',  8500.00, true, note: 'Project payment'),
  const TxItem('Lazada',                  'Jun 17', 'shopping', 1124.00, false),
  const TxItem('Rent — Sukhumvit',        'Jun 15', 'housing', 14500.00, false),
];

final aspirations = [
  AspItem('Sony WH-1000XM5',    'Sony Thailand',   'Electronics', 8990, '"Need for remote work focus"',   '🎧'),
  AspItem('New Balance 990v6',   'NB Thailand',     'Footwear',    7500, '"Running — old shoes worn out"',  '👟'),
  AspItem('Atomic Habits (Thai)','Se-Ed Bookstore', 'Books',        349, '"Self-improvement reading"',      '📚'),
];

const catData = [
  CatData('Food & Dining',  4830, 0.88, C.catFood),
  CatData('Housing',       14500, 1.00, C.catHouse),
  CatData('Shopping',       2399, 0.55, C.catShop),
  CatData('Travel',          950, 0.22, C.catTravel),
  CatData('Subscriptions',   528, 0.13, C.catSub),
];

const trendPoints = [
  TrendPoint('Jan', 8200),
  TrendPoint('Feb', 11400),
  TrendPoint('Mar', 9800),
  TrendPoint('Apr', 14200),
  TrendPoint('May', 12600),
  TrendPoint('Jun', 16320),
];

const totalIncome   = 60500.0;
const totalExpense  = 44207.0;
const netBalance    = 16293.0;
const savingsPot    = 16320.0;

// ─── Helpers ─────────────────────────────────────────────────────────────────
String baht(double n) {
  final s = n.toStringAsFixed(0);
  final formatted = s.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  return '฿ $formatted';
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
        child: Column(
          children: [
            _StatusBar(tab: _tab),
            Expanded(
              child: SingleChildScrollView(
                child: _tab == 0 ? const OverviewScreen()
                     : _tab == 1 ? AspirationsScreen(key: const ValueKey('asp'))
                     : const AnalyticsScreen(),
              ),
            ),
            _BottomNav(tab: _tab, onTab: (t) => setState(() => _tab = t)),
          ],
        ),
      ),
    ),
  );
}

// ─── Status Bar ───────────────────────────────────────────────────────────────
class _StatusBar extends StatelessWidget {
  final int tab;
  const _StatusBar({required this.tab});
  @override
  Widget build(BuildContext context) => Container(
    color: C.bg,
    padding: const EdgeInsets.fromLTRB(24, 14, 24, 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('9:41', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: C.textMain)),
          const Text('AURUM', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: C.gold, letterSpacing: 2)),
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
      ],
    ),
  );
}

// ─── Bottom Nav ───────────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int tab;
  final ValueChanged<int> onTab;
  const _BottomNav({required this.tab, required this.onTab});

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: C.cardBg,
      border: Border(top: BorderSide(color: C.border)),
    ),
    padding: const EdgeInsets.fromLTRB(0, 10, 0, 26),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _navItem(0, Icons.home_outlined, Icons.home_rounded, 'Overview'),
        _navItem(1, Icons.favorite_outline, Icons.favorite_rounded, 'Aspirations'),
        _navItem(2, Icons.bar_chart_outlined, Icons.bar_chart_rounded, 'Analytics'),
      ],
    ),
  );

  Widget _navItem(int i, IconData off, IconData on, String label) {
    final active = tab == i;
    return GestureDetector(
      onTap: () => onTab(i),
      behavior: HitTestBehavior.opaque,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(active ? on : off, size: 22, color: active ? C.gold : C.textHint),
        const SizedBox(height: 3),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
            color: active ? C.gold : C.textHint)),
        const SizedBox(height: 3),
        Container(width: 4, height: 4, decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? C.gold : Colors.transparent,
        )),
      ]),
    );
  }
}

// ─── Shared ───────────────────────────────────────────────────────────────────
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

class _SectionTitle extends StatelessWidget {
  final String text;
  final Widget? trailing;
  const _SectionTitle(this.text, {this.trailing});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: C.textMain)),
      if (trailing != null) trailing!,
    ],
  );
}

Widget _goldBadge(String label) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  decoration: BoxDecoration(
    color: C.goldPale,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: C.goldBorder),
  ),
  child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: C.gold)),
);

// ─── OVERVIEW SCREEN ─────────────────────────────────────────────────────────
class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Header
      const Text('Overview', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: C.textMain)),
      const SizedBox(height: 4),
      Text('June 2026', style: const TextStyle(fontSize: 13, color: C.textSub)),
      const SizedBox(height: 16),

      // Balance hero
      _Card(
        color: C.goldPale,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('NET BALANCE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: C.gold, letterSpacing: 1.2)),
          const SizedBox(height: 6),
          Text(baht(netBalance), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: C.green, height: 1)),
          const SizedBox(height: 2),
          const Text('After all expenses this month', style: TextStyle(fontSize: 11, color: C.textSub)),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: _miniStat('INCOME',  baht(totalIncome),  C.green)),
            const SizedBox(width: 8),
            Expanded(child: _miniStat('EXPENSE', baht(totalExpense), C.red)),
            const SizedBox(width: 8),
            Expanded(child: _miniStat('SAVED',   '${((netBalance / totalIncome) * 100).round()}%', C.gold)),
          ]),
        ]),
      ),
      const SizedBox(height: 14),

      // Quick Add
      _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Quick Add', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: C.textMain)),
        const SizedBox(height: 12),
        _quickInput('Amount', '฿ 0', TextInputType.number),
        const SizedBox(height: 8),
        _quickInput('What for?', 'e.g. Dinner, BTS, Coffee…', TextInputType.text),
        const SizedBox(height: 8),
        _catPills(),
        const SizedBox(height: 12),
        GestureDetector(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(color: C.gold, borderRadius: BorderRadius.circular(12)),
            alignment: Alignment.center,
            child: const Text('Save Expense', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
          ),
        ),
      ])),
      const SizedBox(height: 20),

      // Recent transactions
      _SectionTitle('Recent transactions',
        trailing: _goldBadge('See all')),
      const SizedBox(height: 12),
      ...transactions.take(6).map((t) => _TxRow(tx: t)),
    ]),
  );

  Widget _miniStat(String label, String val, Color color) => Container(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
    decoration: BoxDecoration(color: C.cardBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: C.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: C.textHint, letterSpacing: 1)),
      const SizedBox(height: 4),
      Text(val, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
    ]),
  );

  Widget _quickInput(String label, String hint, TextInputType type) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 10, color: C.textSub, fontWeight: FontWeight.w600)),
      const SizedBox(height: 4),
      Container(
        decoration: BoxDecoration(color: C.cardBg2, borderRadius: BorderRadius.circular(10), border: Border.all(color: C.border)),
        child: TextField(
          keyboardType: type,
          style: const TextStyle(fontSize: 14, color: C.textMain),
          decoration: InputDecoration(
            hintText: hint, hintStyle: const TextStyle(color: C.textHint, fontSize: 13),
            border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          ),
        ),
      ),
    ],
  );

  Widget _catPills() => Wrap(
    spacing: 6, runSpacing: 6,
    children: ['Food', 'Travel', 'Shopping', 'Housing', 'Sub', 'Other'].map((c) {
      final colors = {'Food': C.catFood, 'Travel': C.catTravel, 'Shopping': C.catShop,
                      'Housing': C.catHouse, 'Sub': C.catSub, 'Other': C.catOther};
      final col = colors[c] ?? C.catOther;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: col.withOpacity(0.1), borderRadius: BorderRadius.circular(20),
          border: Border.all(color: col.withOpacity(0.25))),
        child: Text(c, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: col)),
      );
    }).toList(),
  );
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
          if (tx.note.isNotEmpty)
            Text(tx.note, style: const TextStyle(fontSize: 10, color: C.textHint)),
          Text(tx.date, style: const TextStyle(fontSize: 10, color: C.textHint)),
        ])),
        Text(
          '${tx.isIncome ? '+' : '−'}${baht(tx.amount)}',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: tx.isIncome ? C.green : C.red),
        ),
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
  final List<AspItem> _items = aspirations;
  int _rating = 3;

  int get _pending => _items.where((a) => !a.approved && !a.declined).length;
  double get _approvedTotal => _items.where((a) => a.approved).fold(0, (s, a) => s + a.cost);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Header
      const Text('Aspirations', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: C.textMain)),
      const SizedBox(height: 16),

      // Savings potential card (gold)
      _Card(
        color: C.goldPale,
        child: Row(children: [
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
        ]),
      ),
      const SizedBox(height: 10),

      // Stats row
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
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: 0.84, backgroundColor: C.border, color: C.gold, minHeight: 5),
          ),
        ]))),
      ]),
      const SizedBox(height: 20),

      // Pending decisions
      _SectionTitle('Pending decisions', trailing: _goldBadge('${_pending} items')),
      const SizedBox(height: 12),

      ..._items.asMap().entries.map((e) {
        final i = e.key;
        final a = e.value;
        return _AspCard(
          item: a,
          onApprove: () => setState(() { a.approved = true; a.declined = false; }),
          onDecline: () => setState(() { a.declined = true; a.approved = false; }),
        );
      }),

      const SizedBox(height: 8),

      // Rate recent buy
      const Text('Rate recent buys', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: C.textMain)),
      const SizedBox(height: 12),
      _Card(
        color: C.goldPale,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: C.gold.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
            child: const Text('3 DAYS AGO · AIRPODS PRO 2ND GEN',
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: C.gold, letterSpacing: 0.8)),
          ),
          const SizedBox(height: 8),
          const Text('Was it worth ฿ 9,900?',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: C.textMain)),
          const SizedBox(height: 10),
          Row(children: List.generate(5, (i) => GestureDetector(
            onTap: () => setState(() => _rating = i + 1),
            child: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(i < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 28, color: i < _rating ? C.gold : C.border),
            ),
          ))),
        ]),
      ),
      const SizedBox(height: 16),

      // FAB
      Align(alignment: Alignment.centerRight,
        child: Container(
          width: 52, height: 52,
          decoration: const BoxDecoration(shape: BoxShape.circle, color: C.gold,
            boxShadow: [BoxShadow(color: Color(0x44C9962A), blurRadius: 12, offset: Offset(0, 4))]),
          child: const Icon(Icons.add, color: Colors.white, size: 24),
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
      border: Border.all(color: item.approved ? C.green.withOpacity(0.4)
          : item.declined ? C.red.withOpacity(0.3) : C.border),
      boxShadow: const [BoxShadow(color: C.shadow, blurRadius: 6, offset: Offset(0, 2))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Emoji icon box
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(color: C.cardBg2, borderRadius: BorderRadius.circular(12),
              border: Border.all(color: C.border)),
            child: Center(child: Text(item.emoji, style: const TextStyle(fontSize: 26))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: C.textMain)),
            Text('${item.brand} · ${item.category}',
                style: const TextStyle(fontSize: 11, color: C.textSub)),
            const SizedBox(height: 4),
            Text(baht(item.cost),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: C.red, height: 1.2)),
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
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                      color: item.declined ? C.red : C.textSub)),
            ),
          )),
          const SizedBox(width: 8),
          Expanded(child: GestureDetector(
            onTap: onApprove,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: item.approved ? C.green : C.gold,
                borderRadius: BorderRadius.circular(10),
              ),
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
      const Text('Analytics', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: C.textMain)),
      const SizedBox(height: 4),
      const Text('June 2026 · summary', style: TextStyle(fontSize: 13, color: C.textSub)),
      const SizedBox(height: 16),

      // Stats grid
      Row(children: [
        Expanded(child: _statCard('TOTAL SPENT', baht(totalExpense), '↑ 4.2% vs May', false)),
        const SizedBox(width: 10),
        Expanded(child: _statCard('SAVED', baht(netBalance), '↑ 12.1% growth', true)),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: _statCard('INCOME', baht(totalIncome), 'This month', true)),
        const SizedBox(width: 10),
        Expanded(child: _statCard('SAVE RATE', '${((netBalance / totalIncome) * 100).round()}%', 'of income', true)),
      ]),
      const SizedBox(height: 20),

      // Balance trend
      const _SectionTitle('Balance trend'),
      const SizedBox(height: 10),
      _Card(child: Column(children: [
        SizedBox(height: 120, child: CustomPaint(painter: _LinePainter(), size: const Size(double.infinity, 120))),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: trendPoints.map((p) => Text(p.label,
              style: const TextStyle(fontSize: 10, color: C.textHint))).toList(),
        ),
      ])),
      const SizedBox(height: 20),

      // Spending by category
      const _SectionTitle('Spending by category'),
      const SizedBox(height: 10),
      _Card(child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        SizedBox(width: 100, height: 100,
            child: CustomPaint(painter: _DonutPainter())),
        const SizedBox(width: 16),
        Expanded(child: Column(children: catData.map((c) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: c.color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Expanded(child: Text(c.name, style: const TextStyle(fontSize: 11, color: C.textSub))),
            Text('${(c.pct * 100).round()}%',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: C.textMain)),
          ]),
        )).toList())),
      ])),
      const SizedBox(height: 20),

      // Top categories
      const _SectionTitle('Top expense categories'),
      const SizedBox(height: 10),
      _Card(child: Column(children: catData.asMap().entries.map((e) {
        final i = e.key;
        final c = e.value;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(children: [
            Text('#${i + 1}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: C.gold)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(c.name, style: const TextStyle(fontSize: 12, color: C.textMain, fontWeight: FontWeight.w600)),
                Text(baht(c.amount), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: C.red)),
              ]),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(value: c.pct, backgroundColor: C.border, color: c.color, minHeight: 5),
              ),
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

// ─── Custom Painters ─────────────────────────────────────────────────────────
class _LinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final vals = trendPoints.map((p) => p.value).toList();
    final maxV = vals.reduce(max), minV = vals.reduce(min);
    final n = vals.length;
    double x(int i) => i * size.width / (n - 1);
    double y(double v) => size.height * 0.85 * (1 - (v - minV) / (maxV - minV)) + size.height * 0.05;

    // Grid
    final gp = Paint()..color = C.border..strokeWidth = 0.5;
    for (int i = 1; i <= 3; i++) {
      canvas.drawLine(Offset(0, size.height * i / 4), Offset(size.width, size.height * i / 4), gp);
    }
    // Fill
    final fp = Path()..moveTo(x(0), y(vals[0]));
    for (int i = 1; i < n; i++) fp.lineTo(x(i), y(vals[i]));
    fp..lineTo(size.width, size.height)..lineTo(0, size.height)..close();
    canvas.drawPath(fp, Paint()..shader = LinearGradient(
      colors: [C.gold.withOpacity(0.18), C.gold.withOpacity(0)],
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)));
    // Line
    final lp = Path()..moveTo(x(0), y(vals[0]));
    for (int i = 1; i < n; i++) lp.lineTo(x(i), y(vals[i]));
    canvas.drawPath(lp, Paint()..color = C.gold..strokeWidth = 2..style = PaintingStyle.stroke..strokeJoin = StrokeJoin.round..strokeCap = StrokeCap.round);
    // Dots
    for (int i = 0; i < n; i++) {
      final last = i == n - 1;
      canvas.drawCircle(Offset(x(i), y(vals[i])), last ? 5 : 3, Paint()..color = last ? C.gold : C.gold.withOpacity(0.7));
      if (last) canvas.drawCircle(Offset(x(i), y(vals[i])), 5, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2);
    }
  }
  @override
  bool shouldRepaint(_) => false;
}

class _DonutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final r = min(cx, cy) - 8;
    const sw = 18.0;
    var start = -pi / 2;
    for (final c in catData) {
      final sweep = c.pct * 2 * pi;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        start, sweep - 0.05, false,
        Paint()..color = c.color..style = PaintingStyle.stroke..strokeWidth = sw..strokeCap = StrokeCap.butt,
      );
      start += sweep;
    }
    final tp = TextPainter(
      text: TextSpan(text: baht(totalExpense).replaceAll('฿ ', '฿\n'),
          style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: C.textMain, height: 1.3)),
      textDirection: TextDirection.ltr, textAlign: TextAlign.center,
    )..layout(maxWidth: r * 1.2);
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }
  @override
  bool shouldRepaint(_) => false;
}
