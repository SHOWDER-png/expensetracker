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

// ─── Theme ────────────────────────────────────────────────────────────────────

class C {
  // Purple/Gold palette (from HTML)
  static const bgPage       = Color(0xFFF3EEFF);
  static const purpleMid    = Color(0xFFF5F0FF);
  static const purpleDeep   = Color(0xFFEDE5FF);
  static const purpleCard   = Color(0xFFE8DEFF);
  static const purpleAccent = Color(0xFF7C3AED);
  static const purpleLight  = Color(0xFFA78BFA);
  static const purpleBorder = Color(0x267C3AED);
  static const gold         = Color(0xFFB45309);
  static const goldMid      = Color(0xFFD97706);
  static const goldLight    = Color(0xFFF59E0B);
  static const goldPale     = Color(0xFFFEF3C7);
  static const goldBorder   = Color(0x40B45309);
  static const green        = Color(0xFF16A34A);
  static const greenBg      = Color(0x1A16A34A);
  static const red          = Color(0xFFDC2626);
  static const redBg        = Color(0x1ADC2626);
  static const textMain     = Color(0xFF1E1033);
  static const textMuted    = Color(0xFF6D5F8A);
  static const textHint     = Color(0xFFA393C0);
  // Additional category colors
  static const blue         = Color(0xFF2563EB);
  static const orange       = Color(0xFFEA580C);
}

// ─── Models ───────────────────────────────────────────────────────────────────

class TxItem {
  final String name, date, category;
  final double amount;
  final bool isIncome;
  const TxItem(this.name, this.date, this.category, this.amount, this.isIncome);
}

class CatSpend {
  final String name;
  final double amount, pct;
  final Color color;
  const CatSpend(this.name, this.amount, this.pct, this.color);
}

class AspItem {
  final String name, reason, icon;
  final double cost;
  const AspItem(this.name, this.reason, this.icon, this.cost);
}

class MonthBal {
  final String label;
  final double balance;
  const MonthBal(this.label, this.balance);
}

// ─── Static Data ──────────────────────────────────────────────────────────────

const transactions = [
  TxItem('Dinner — Siam Garden',    'Jun 26', 'food',     48.00,   false),
  TxItem('Salary deposit',          'Jun 25', 'income',   5200.00, true),
  TxItem('Online shopping',         'Jun 24', 'shopping', 127.50,  false),
  TxItem('Streaming subscriptions', 'Jun 22', 'sub',      34.99,   false),
  TxItem('Grocery — Whole Foods',   'Jun 21', 'food',     84.32,   false),
  TxItem('BART Transit',            'Jun 20', 'transport', 9.50,   false),
  TxItem('Netflix',                 'Jun 19', 'sub',      17.99,   false),
  TxItem('Freelance — Acme Corp',   'Jun 18', 'income',   850.00,  true),
  TxItem('Amazon',                  'Jun 17', 'shopping', 112.40,  false),
  TxItem('Rent — Apt 4B',           'Jun 15', 'housing',  1450.00, false),
];

const catSpends = [
  CatSpend('Food',      2854, 0.92, C.red),
  CatSpend('Housing',   2498, 0.75, C.purpleAccent),
  CatSpend('Shopping',  1784, 0.52, C.goldMid),
  CatSpend('Transport',  420, 0.28, C.blue),
  CatSpend('Other',      364, 0.18, C.green),
];

const donutData = [
  CatSpend('Food',      0, 0.32, C.red),
  CatSpend('Housing',   0, 0.28, C.purpleAccent),
  CatSpend('Shopping',  0, 0.20, C.goldMid),
  CatSpend('Transport', 0, 0.12, C.blue),
  CatSpend('Other',     0, 0.08, C.green),
];

const aspirations = [
  AspItem('MacBook Pro M4',    'For work upgrade',          '💻', 2499),
  AspItem('Sony WH-1000XM6',  'Noise cancelling for travel','🎧',  349),
  AspItem('Standing Desk',    'Home office upgrade',        '🖥',  599),
];

const balanceTrend = [
  MonthBal('Jan', 1200),
  MonthBal('Feb', 1680),
  MonthBal('Mar', 2100),
  MonthBal('Apr', 2750),
  MonthBal('May', 3120),
  MonthBal('Jun', 3530),
];

const totalIncome  = 12450.0;
const totalExpense =  8920.0;
const netBalance   =  3530.0;

// ─── Helpers ─────────────────────────────────────────────────────────────────

String fmt(double n) {
  final s = n.toStringAsFixed(2);
  final parts = s.split('.');
  final intPart = parts[0].replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  return '\$$intPart.${parts[1]}';
}

IconData _txIcon(String cat) {
  switch (cat) {
    case 'food':      return Icons.restaurant;
    case 'income':    return Icons.payments;
    case 'shopping':  return Icons.shopping_bag;
    case 'sub':       return Icons.tv;
    case 'transport': return Icons.directions_transit;
    case 'housing':   return Icons.home;
    default:          return Icons.receipt;
  }
}

Color _txColor(String cat) {
  switch (cat) {
    case 'food':      return C.orange;
    case 'income':    return C.green;
    case 'shopping':  return C.purpleAccent;
    case 'sub':       return C.blue;
    case 'transport': return C.green;
    case 'housing':   return C.purpleAccent;
    default:          return C.textMuted;
  }
}

// ─── App ──────────────────────────────────────────────────────────────────────

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Expense Tracker',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      fontFamily: 'Inter',
      scaffoldBackgroundColor: C.purpleDeep,
      colorScheme: const ColorScheme.light(
        primary: C.purpleAccent,
        surface: Colors.white,
      ),
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.purpleDeep,
      body: Center(
        child: Container(
          width: 390,
          constraints: const BoxConstraints(maxHeight: 860),
          decoration: BoxDecoration(
            color: C.bgPage,
            borderRadius: BorderRadius.circular(36),
            boxShadow: const [
              BoxShadow(color: Color(0x407C3AED), blurRadius: 40, offset: Offset(0, 16)),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              _StatusBar(),
              Expanded(
                child: SingleChildScrollView(
                  child: _tab == 0
                      ? OverviewScreen(onTabChange: (t) => setState(() => _tab = t))
                      : _tab == 1
                          ? const AspirationsScreen()
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
}

// ─── Status Bar ───────────────────────────────────────────────────────────────

class _StatusBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 8),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [C.purpleMid, C.goldPale],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('9:41',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: C.textMain)),
              Row(children: [
                const Icon(Icons.signal_cellular_alt, size: 16, color: C.textMain),
                const SizedBox(width: 4),
                const Icon(Icons.wifi, size: 16, color: C.textMain),
                const SizedBox(width: 4),
                Container(
                  width: 22, height: 11,
                  decoration: BoxDecoration(
                    border: Border.all(color: C.textMain.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  padding: const EdgeInsets.all(1.5),
                  child: FractionallySizedBox(
                    widthFactor: 0.75,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(color: C.textMain, borderRadius: BorderRadius.circular(1)),
                    ),
                  ),
                ),
              ]),
            ],
          ),
          Container(
            width: 90, height: 22,
            decoration: BoxDecoration(color: C.textMain, borderRadius: BorderRadius.circular(11)),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom Nav ───────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int tab;
  final ValueChanged<int> onTab;
  const _BottomNav({required this.tab, required this.onTab});

  static const _items = [
    {'label': 'Overview',     'icon': Icons.home_outlined,      'active': Icons.home},
    {'label': 'Aspirations',  'icon': Icons.favorite_outline,   'active': Icons.favorite},
    {'label': 'Analytics',    'icon': Icons.bar_chart_outlined, 'active': Icons.bar_chart},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: C.purpleBorder)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(3, (i) {
          final active = tab == i;
          return GestureDetector(
            onTap: () => onTab(i),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  active ? _items[i]['active'] as IconData : _items[i]['icon'] as IconData,
                  size: 22,
                  color: active ? C.goldMid : C.textHint,
                ),
                const SizedBox(height: 3),
                Text(
                  _items[i]['label'] as String,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: active ? C.goldMid : C.textHint,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _GradHeader extends StatelessWidget {
  final Widget child;
  const _GradHeader({required this.child});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [C.purpleMid, C.goldPale],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      border: Border(bottom: BorderSide(color: C.purpleBorder)),
    ),
    child: child,
  );
}

class _Avatar extends StatelessWidget {
  final String initials;
  const _Avatar(this.initials);
  @override
  Widget build(BuildContext context) => Container(
    width: 36, height: 36,
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        colors: [C.purpleAccent, C.goldLight],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      border: Border.fromBorderSide(BorderSide(color: C.goldLight, width: 2)),
    ),
    alignment: Alignment.center,
    child: Text(initials,
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
  );
}

class _PurpleCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  const _PurpleCard({required this.child, this.padding});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: C.purpleMid,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: C.purpleBorder),
    ),
    padding: padding ?? const EdgeInsets.all(14),
    child: child,
  );
}

class _GoldCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  const _GoldCard({required this.child, this.padding});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: C.goldPale,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: C.goldBorder),
    ),
    padding: padding ?? const EdgeInsets.all(14),
    child: child,
  );
}

// ─── Overview Screen ──────────────────────────────────────────────────────────

class OverviewScreen extends StatefulWidget {
  final ValueChanged<int> onTabChange;
  const OverviewScreen({super.key, required this.onTabChange});
  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  bool _isExpense = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        _GradHeader(child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Good morning, Alexa',
                  style: TextStyle(fontSize: 11, color: C.textMuted)),
              const SizedBox(height: 2),
              Row(children: [
                const Text('June 2026',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: C.gold)),
                const SizedBox(width: 4),
                const Icon(Icons.expand_more, size: 14, color: C.gold),
              ]),
            ]),
            const _Avatar('AR'),
          ],
        )),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Column(children: [
            // Flow bar
            _FlowBar(),
            const SizedBox(height: 14),
            // Quick track
            _QuickTrack(isExpense: _isExpense, onToggle: (v) => setState(() => _isExpense = v)),
            const SizedBox(height: 14),
            // Transactions
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Transaction history',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: C.textMain)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: C.goldPale,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: C.goldBorder),
                ),
                child: const Row(children: [
                  Text('June 2026', style: TextStyle(fontSize: 10, color: C.gold, fontWeight: FontWeight.w600)),
                  SizedBox(width: 3),
                  Icon(Icons.expand_more, size: 10, color: C.gold),
                ]),
              ),
            ]),
            const SizedBox(height: 10),
            ...transactions.take(6).map((t) => _TxCard(tx: t)),
          ]),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _FlowBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          const Icon(Icons.trending_up, size: 12, color: C.green),
          const SizedBox(width: 4),
          const Text('Income',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: C.green)),
        ]),
        Row(children: [
          const Text('Expenses',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: C.red)),
          const SizedBox(width: 4),
          const Icon(Icons.trending_down, size: 12, color: C.red),
        ]),
      ]),
      const SizedBox(height: 6),
      Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: C.goldBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(children: [
          Expanded(
            flex: 58,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFFDCFCE7), Color(0xFFBBF7D0)]),
              ),
              padding: const EdgeInsets.only(left: 12),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(fmt(totalIncome),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: C.green)),
                const Text('58% of flow', style: TextStyle(fontSize: 9, color: C.textHint)),
              ]),
            ),
          ),
          Container(width: 3,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [C.goldLight, C.gold], begin: Alignment.topCenter, end: Alignment.bottomCenter),
              )),
          Expanded(
            flex: 42,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFFFEE2E2), Color(0xFFFECACA)]),
              ),
              padding: const EdgeInsets.only(right: 12),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(fmt(totalExpense),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: C.red)),
                const Text('42% of flow', style: TextStyle(fontSize: 9, color: C.textHint)),
              ]),
            ),
          ),
        ]),
      ),
      const SizedBox(height: 7),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: C.goldPale,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: C.goldBorder),
        ),
        child: RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(children: [
            TextSpan(text: 'Net balance · ',
                style: TextStyle(fontSize: 9, color: C.gold, fontWeight: FontWeight.w600)),
            TextSpan(text: '+\$3,530.00',
                style: TextStyle(fontSize: 14, color: C.gold, fontWeight: FontWeight.w800)),
          ]),
        ),
      ),
    ]);
  }
}

class _QuickTrack extends StatelessWidget {
  final bool isExpense;
  final ValueChanged<bool> onToggle;
  const _QuickTrack({required this.isExpense, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return _PurpleCard(child: Column(children: [
      // Toggle
      Container(
        decoration: BoxDecoration(color: C.purpleCard, borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.all(3),
        child: Row(children: [
          _toggleTab('Expense', isExpense, C.red, () => onToggle(true)),
          _toggleTab('Income',  !isExpense, C.green, () => onToggle(false)),
        ]),
      ),
      const SizedBox(height: 12),
      _inputRow('Amount', '\$0.00', TextInputType.number),
      const SizedBox(height: 8),
      _inputRow('Note', 'What was this for?', TextInputType.text),
      const SizedBox(height: 8),
      _inputRow('Category', 'e.g. Food, Travel, Bills…', TextInputType.text),
      const SizedBox(height: 10),
      GestureDetector(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [C.gold, C.goldLight]),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: const Text('SAVE',
              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2)),
        ),
      ),
    ]));
  }

  Widget _toggleTab(String label, bool active, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: active ? color.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: active ? color.withOpacity(0.3) : Colors.transparent),
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                  color: active ? color : C.textHint)),
        ),
      ),
    );
  }

  Widget _inputRow(String label, String hint, TextInputType type) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 10, color: C.textMuted)),
      const SizedBox(height: 4),
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: C.purpleBorder),
        ),
        child: TextField(
          keyboardType: type,
          style: const TextStyle(fontSize: 12, color: C.textMain),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: C.textHint, fontSize: 12),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
        ),
      ),
    ]);
  }
}

class _TxCard extends StatelessWidget {
  final TxItem tx;
  const _TxCard({required this.tx});

  @override
  Widget build(BuildContext context) {
    final color = _txColor(tx.category);
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: C.purpleMid,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: C.purpleBorder),
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(_txIcon(tx.category), size: 18, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(tx.name,
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: C.textMain)),
          const SizedBox(height: 2),
          Text(tx.date, style: const TextStyle(fontSize: 10, color: C.textHint)),
        ])),
        Text(
          '${tx.isIncome ? '+' : '−'}${fmt(tx.amount)}',
          style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w800,
            color: tx.isIncome ? C.green : C.red,
          ),
        ),
      ]),
    );
  }
}

// ─── Aspirations Screen ───────────────────────────────────────────────────────

class AspirationsScreen extends StatefulWidget {
  const AspirationsScreen({super.key});
  @override
  State<AspirationsScreen> createState() => _AspirationsScreenState();
}

class _AspirationsScreenState extends State<AspirationsScreen> {
  final Set<int> _bought = {};
  final Set<int> _skipped = {};
  int _rating = 3;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Header
      _GradHeader(child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Aspirations',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: C.textMain)),
            const SizedBox(height: 2),
            const Text('Buy or skip? You decide.',
                style: TextStyle(fontSize: 10, color: C.textMuted)),
          ]),
          const _Avatar('AR'),
        ],
      )),

      Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Dashboard
          _GoldCard(child: Column(children: [
            Row(children: [
              Expanded(child: _metricBox('Total savings potential', '\$1,240', C.green)),
              const SizedBox(width: 8),
              Expanded(child: _metricBox('Incoming decisions', '5 items', C.gold)),
            ]),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: C.goldBorder),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('SATISFACTION SCORE',
                      style: TextStyle(fontSize: 9, color: C.gold, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                  const SizedBox(height: 4),
                  Row(children: List.generate(5, (i) => Icon(
                    i < 4 ? Icons.star : Icons.star_border,
                    size: 14, color: C.goldLight,
                  ))),
                ]),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  const Text('8.5',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: C.gold)),
                  const Text('/ 10', style: TextStyle(fontSize: 10, color: C.textHint)),
                ]),
              ]),
            ),
          ])),

          const SizedBox(height: 14),
          const Text('Decision pool',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: C.textMain, letterSpacing: 0.5)),
          const SizedBox(height: 8),

          ...aspirations.asMap().entries.map((e) {
            final i = e.key;
            final a = e.value;
            final bought = _bought.contains(i);
            final skipped = _skipped.contains(i);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: _PurpleCard(child: Row(children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: C.purpleDeep,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: C.purpleBorder),
                  ),
                  child: Center(child: Text(a.icon, style: const TextStyle(fontSize: 24))),
                ),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(a.name,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: C.textMain)),
                  const SizedBox(height: 2),
                  Text(a.reason, style: const TextStyle(fontSize: 10, color: C.textMuted)),
                  Text(fmt(a.cost),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: C.gold)),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() { _bought.add(i); _skipped.remove(i); }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: bought ? [C.green, const Color(0xFF22C55E)] : [C.green.withOpacity(0.7), const Color(0xFF22C55E)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            const Icon(Icons.check, size: 12, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(bought ? 'Bought!' : 'Buy it',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.3)),
                          ]),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() { _skipped.add(i); _bought.remove(i); }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          decoration: BoxDecoration(
                            color: skipped ? C.red.withOpacity(0.15) : C.redBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: C.red.withOpacity(0.3)),
                          ),
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            const Icon(Icons.close, size: 12, color: C.red),
                            const SizedBox(width: 4),
                            Text(skipped ? 'Skipped' : "Don't buy",
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: C.red, letterSpacing: 0.3)),
                          ]),
                        ),
                      ),
                    ),
                  ]),
                ])),
              ])),
            );
          }),

          const SizedBox(height: 4),
          const Text('Post-purchase review',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: C.textMain)),
          const SizedBox(height: 8),

          _GoldCard(child: Row(children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: C.gold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: C.goldBorder),
              ),
              child: const Icon(Icons.star_outline, color: C.gold, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Rate your recent AirPods Pro',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: C.textMain)),
              const Text('Bought 3 days ago · Worth it?',
                  style: TextStyle(fontSize: 10, color: C.textHint)),
              const SizedBox(height: 6),
              StatefulBuilder(builder: (_, set) => Row(
                children: List.generate(5, (i) => GestureDetector(
                  onTap: () => setState(() => _rating = i + 1),
                  child: Icon(
                    i < _rating ? Icons.star : Icons.star_border,
                    size: 18, color: C.goldLight,
                  ),
                )),
              )),
            ])),
          ])),

          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: C.goldPale,
                border: Border.all(color: C.goldMid, width: 2),
                boxShadow: const [BoxShadow(color: Color(0x33B45309), blurRadius: 10, offset: Offset(0, 2))],
              ),
              child: const Icon(Icons.add, color: C.gold, size: 22),
            ),
          ),
        ]),
      ),
      const SizedBox(height: 16),
    ]);
  }

  Widget _metricBox(String label, String value, Color color) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: C.goldBorder),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label.toUpperCase(),
          style: const TextStyle(fontSize: 9, color: C.gold, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
      const SizedBox(height: 4),
      Text(value,
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: color)),
    ]),
  );
}

// ─── Analytics Screen ─────────────────────────────────────────────────────────

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Profile header
      _GradHeader(child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: C.goldBorder),
        ),
        child: Row(children: [
          Stack(children: [
            Container(
              width: 54, height: 54,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [C.purpleAccent, C.goldLight]),
                border: Border.fromBorderSide(BorderSide(color: C.goldLight, width: 2)),
              ),
              alignment: Alignment.center,
              child: const Text('AR',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
            ),
            Positioned(
              bottom: 0, right: 0,
              child: Container(
                width: 20, height: 20,
                decoration: const BoxDecoration(color: C.goldMid, shape: BoxShape.circle),
                child: const Icon(Icons.camera_alt, size: 11, color: Colors.white),
              ),
            ),
          ]),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('ALEXA REED',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: C.textMain, letterSpacing: 1)),
            const SizedBox(height: 3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: C.goldPale,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: C.goldBorder),
              ),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.workspace_premium, size: 10, color: C.gold),
                SizedBox(width: 3),
                Text('ELITE PLAN',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: C.gold, letterSpacing: 0.8)),
              ]),
            ),
            const SizedBox(height: 3),
            const Text('Gold tier · Member since 2024',
                style: TextStyle(fontSize: 10, color: C.textMuted)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: C.goldBorder),
            ),
            child: const Text('Edit',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: C.gold)),
          ),
        ]),
      )),

      Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Stats row
          Row(children: [
            Expanded(child: _statCard('Monthly spend', '\$8,920', '↑ 4.2% vs last month', false)),
            const SizedBox(width: 8),
            Expanded(child: _statCard('Saved this month', '\$3,530', '↑ 12.1% growth', true)),
          ]),
          const SizedBox(height: 12),

          // Donut chart
          _chartTitle(Icons.donut_large, 'Spending by category'),
          const SizedBox(height: 8),
          _PurpleCard(child: Row(children: [
            SizedBox(
              width: 90, height: 90,
              child: CustomPaint(painter: _DonutPainter(donutData)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(children: donutData.map((d) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: d.color, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Expanded(child: Text(d.name, style: const TextStyle(fontSize: 10, color: C.textMuted))),
                  Text('${(d.pct * 100).round()}%',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: C.textMain)),
                ]),
              )).toList()),
            ),
          ])),
          const SizedBox(height: 12),

          // Line chart
          _chartTitle(Icons.show_chart, 'Balance trend'),
          const SizedBox(height: 8),
          _PurpleCard(child: Column(children: [
            SizedBox(
              height: 80,
              child: CustomPaint(
                painter: _LinePainter(balanceTrend),
                size: const Size(double.infinity, 80),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: balanceTrend.map((b) => Text(b.label,
                  style: const TextStyle(fontSize: 9, color: C.textHint))).toList(),
            ),
          ])),
          const SizedBox(height: 12),

          // Top categories
          _chartTitle(Icons.emoji_events, 'Top expense categories'),
          const SizedBox(height: 8),
          _PurpleCard(
            child: Column(
              children: catSpends.asMap().entries.map((e) {
                final i = e.key;
                final c = e.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(children: [
                    Text('#${i + 1}',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: C.gold, letterSpacing: 0)),
                    const SizedBox(width: 8),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(c.name, style: const TextStyle(fontSize: 10, color: C.textMain)),
                      const SizedBox(height: 3),
                      LayoutBuilder(builder: (_, box) => Container(
                        width: box.maxWidth * c.pct,
                        height: 4,
                        decoration: BoxDecoration(
                          color: c.color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      )),
                    ])),
                    const SizedBox(width: 8),
                    Text(fmt(c.amount),
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: C.red)),
                  ]),
                );
              }).toList(),
            ),
          ),
        ]),
      ),
      const SizedBox(height: 16),
    ]);
  }

  Widget _statCard(String label, String value, String delta, bool isPositive) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: C.purpleMid,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: C.purpleBorder),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label.toUpperCase(),
          style: const TextStyle(fontSize: 9, color: C.textHint, letterSpacing: 0.8)),
      const SizedBox(height: 4),
      Text(value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: C.textMain)),
      const SizedBox(height: 2),
      Text(delta,
          style: TextStyle(fontSize: 9, color: isPositive ? C.green : C.red)),
    ]),
  );

  Widget _chartTitle(IconData icon, String label) => Row(children: [
    Icon(icon, size: 14, color: C.gold),
    const SizedBox(width: 5),
    Text(label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: C.gold, letterSpacing: 0.5)),
  ]);
}

// ─── Custom Painters ─────────────────────────────────────────────────────────

class _DonutPainter extends CustomPainter {
  final List<CatSpend> data;
  _DonutPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final r = min(cx, cy) - 10;
    const strokeW = 16.0;
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = strokeW..strokeCap = StrokeCap.butt;
    const full = 2 * pi;
    var start = -pi / 2;

    for (final d in data) {
      final sweep = d.pct * full;
      paint.color = d.color;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        start, sweep - 0.04, false, paint,
      );
      start += sweep;
    }

    // Center text
    final tp = TextPainter(
      text: const TextSpan(
        text: '\$8,920',
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: C.textMain),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  @override
  bool shouldRepaint(_) => false;
}

class _LinePainter extends CustomPainter {
  final List<MonthBal> data;
  _LinePainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final maxVal = data.map((d) => d.balance).reduce(max);
    final minVal = data.map((d) => d.balance).reduce(min);
    final range = maxVal - minVal;
    final n = data.length;

    double x(int i) => i * size.width / (n - 1);
    double y(double v) => size.height * (1 - (v - minVal) / range) * 0.85 + size.height * 0.05;

    // Grid lines
    final gridPaint = Paint()..color = C.gold.withOpacity(0.1)..strokeWidth = 0.5;
    for (int i = 1; i <= 3; i++) {
      final gy = size.height * i / 4;
      canvas.drawLine(Offset(0, gy), Offset(size.width, gy), gridPaint);
    }

    // Fill
    final path = Path()..moveTo(x(0), y(data[0].balance));
    for (int i = 1; i < n; i++) path.lineTo(x(i), y(data[i].balance));
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(
      path,
      Paint()..shader = LinearGradient(
        colors: [C.gold.withOpacity(0.2), C.gold.withOpacity(0)],
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Line
    final linePaint = Paint()
      ..color = C.goldMid
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final linePath = Path()..moveTo(x(0), y(data[0].balance));
    for (int i = 1; i < n; i++) linePath.lineTo(x(i), y(data[i].balance));
    canvas.drawPath(linePath, linePaint);

    // Dots
    for (int i = 0; i < n; i++) {
      final isLast = i == n - 1;
      canvas.drawCircle(
        Offset(x(i), y(data[i].balance)),
        isLast ? 4 : 3,
        Paint()..color = isLast ? C.goldLight : C.goldMid,
      );
      if (isLast) {
        canvas.drawCircle(
          Offset(x(i), y(data[i].balance)),
          4,
          Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 1.5,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
