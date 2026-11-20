import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:masarif/widgets/icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/models.dart';
import '../data/repo.dart';
import '../l10n/strings.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';

class _CatTotal {
  _CatTotal(this.cat, this.total, this.count);
  final Cat cat;
  final double total;
  final int count;
}

List<_CatTotal> _byCat(Iterable<Txn> txs, List<Cat> cats, TxType type) {
  final map = <String, _CatTotal>{};
  for (final t in txs) {
    if (t.type != type) continue;
    final cur = map[t.categoryId];
    map[t.categoryId] = _CatTotal(catById(cats, t.categoryId), (cur?.total ?? 0) + t.amount, (cur?.count ?? 0) + 1);
  }
  return map.values.toList()..sort((a, b) => b.total.compareTo(a.total));
}

/// Alwan dyal donut (b tartib), mtwa7din m3a l theme.
List<Color> seriesColors(bool dark) => [
      dark ? const Color(0xFF7FD3A4) : AppColors.deepGreen,
      AppColors.gold,
      dark ? const Color(0xFFF0A070) : const Color(0xFFA0471F),
      const Color(0xFF7FA58E),
      dark ? const Color(0xFF8A836F) : const Color(0xFFCFC7B6),
      dark ? const Color(0xFFC3A0F0) : const Color(0xFF5B4A7A),
    ];

String _pct(double v) => '${(v * 100).round()}%';

enum _Period { week, month, year }

const _dayShort = ['Tn', 'Tl', 'Lr', 'Kh', 'Jm', 'Sb', '7d'];
const _dayFull = ['Tnin', 'Tlat', 'Larb3', 'Lkhmis', 'Jem3a', 'Sebt', '7ed'];

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});
  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  _Period _period = _Period.week;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final txs = (ref.watch(txProvider).value ?? const <Txn>[]).where((t) => t.type == TxType.expense).toList();
    final cats = ref.watch(allCatsProvider);
    final now = DateTime.now();
    final today = dayOnly(now);

    // Barres + fatra 7aliya + fatra li fatt (bach n9arno)
    late List<String> labels;
    late List<double> values;
    late List<VoidCallback?> taps;
    late bool Function(Txn) inCur;
    late bool Function(Txn) inPrev;
    late String caps;
    int currentIndex;
    switch (_period) {
      case _Period.week:
        final monday = today.subtract(Duration(days: today.weekday - 1));
        labels = _dayShort;
        values = [for (var i = 0; i < 7; i++) txs.where((t) => dayOnly(t.date) == monday.add(Duration(days: i))).fold(0.0, (a, t) => a + t.amount)];
        taps = List.filled(7, null);
        inCur = (t) => !t.date.isBefore(monday) && t.date.isBefore(monday.add(const Duration(days: 7)));
        inPrev = (t) => !t.date.isBefore(monday.subtract(const Duration(days: 7))) && t.date.isBefore(monday);
        caps = S.thisWeekSpent;
        currentIndex = today.weekday - 1;
      case _Period.month:
        final months = [for (var i = 5; i >= 0; i--) DateTime(now.year, now.month - i)];
        labels = [for (final m in months) monthShort[m.month - 1]];
        values = [for (final m in months) txs.where((t) => monthKey(t.date) == monthKey(m)).fold(0.0, (a, t) => a + t.amount)];
        taps = [for (final m in months) () => context.push('/month/${monthKey(m)}')];
        inCur = (t) => monthKey(t.date) == monthKey(now);
        inPrev = (t) => monthKey(t.date) == monthKey(DateTime(now.year, now.month - 1));
        caps = S.thisMonthSpent;
        currentIndex = 5;
      case _Period.year:
        labels = [for (var m = 1; m <= 12; m++) monthShort[m - 1].substring(0, 1)];
        values = [for (var m = 1; m <= 12; m++) txs.where((t) => t.date.year == now.year && t.date.month == m).fold(0.0, (a, t) => a + t.amount)];
        taps = [for (var m = 1; m <= 12; m++) () => context.push('/month/${monthKey(DateTime(now.year, m))}')];
        inCur = (t) => t.date.year == now.year;
        inPrev = (t) => t.date.year == now.year - 1;
        caps = S.thisYearSpent;
        currentIndex = now.month - 1;
    }
    final cur = txs.where(inCur).toList();
    final total = cur.fold<double>(0, (a, t) => a + t.amount);
    final prevTotal = txs.where(inPrev).fold<double>(0, (a, t) => a + t.amount);
    final change = prevTotal > 0 ? ((total - prevTotal) / prevTotal * 100).round() : null;
    final maxV = values.fold<double>(1, math.max);
    final maxI = values.indexOf(values.reduce(math.max));
    final top = _byCat(cur, cats, TxType.expense);
    final colors = seriesColors(context.isDark);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 110),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 46),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(S.tabStats, style: display(24).copyWith(height: 1.2)),
                Text('Fin kaymchiw flousek', style: TextStyle(fontSize: 12, color: c.muted)),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          Segmented<_Period>(
            items: const {_Period.week: S.week, _Period.month: S.month, _Period.year: S.year},
            value: _period,
            onChanged: (v) => setState(() => _period = v),
          ),
          const SizedBox(height: 14),
          Card2(
            radius: 24,
            padding: const EdgeInsets.all(18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(caps, style: capsLabel(c.muted).copyWith(fontSize: 10)),
                    const SizedBox(height: 4),
                    FittedBox(child: Text(dh(total), style: display(28).copyWith(letterSpacing: -0.8))),
                  ]),
                ),
                if (change != null && change != 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: change < 0 ? c.chipActive : c.goldSoft, borderRadius: BorderRadius.circular(999)),
                    child: Text(change < 0 ? S.lessThan(-change) : S.moreThan(change),
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: change < 0 ? c.brandFg : c.goldInk)),
                  ),
              ]),
              const SizedBox(height: 18),
              SizedBox(
                height: 110,
                child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  for (var i = 0; i < values.length; i++)
                    Expanded(
                      child: Semantics(
                        label: '${labels[i]}: ${dh(values[i])}',
                        button: taps[i] != null,
                        child: GestureDetector(
                          onTap: taps[i],
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: values.length > 7 ? 3 : 6),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: math.max(6, 100 * values[i] / maxV),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(9),
                                color: (i == maxI && values[i] > 0)
                                    ? AppColors.gold
                                    : (i == currentIndex ? c.brandFg : (context.isDark ? const Color(0xFF24382F) : const Color(0xFFCFE0D5))),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ]),
              ),
              const SizedBox(height: 8),
              Row(children: [
                for (var i = 0; i < labels.length; i++)
                  Expanded(
                    child: Text(labels[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: (i == maxI || i == currentIndex) ? FontWeight.w600 : FontWeight.w400,
                          color: i == maxI && values[i] > 0 ? c.goldInk : (i == currentIndex ? c.brandFg : c.muted),
                        )),
                  ),
              ]),
              if (_period == _Period.week && values[maxI] > 0) ...[
                Divider(height: 24, color: c.divider),
                Text(S.biggestDay(_dayFull[maxI], dh(values[maxI])), style: TextStyle(fontSize: 12, color: c.muted)),
              ],
            ]),
          ),
          const SizedBox(height: 12),
          Card2(
            radius: 24,
            padding: const EdgeInsets.all(18),
            child: top.isEmpty
                ? Text(S.empty, style: TextStyle(color: c.muted))
                : Row(children: [
                    SizedBox(
                      width: 112,
                      height: 112,
                      child: Stack(alignment: Alignment.center, children: [
                        CustomPaint(
                          size: const Size.square(112),
                          painter: _DonutPainter([for (final t in top) t.total], colors, c.divider),
                        ),
                        Column(mainAxisSize: MainAxisSize.min, children: [
                          Text(total.round().toString(), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                          Text('DH', style: TextStyle(fontSize: 10, color: c.muted)),
                        ]),
                      ]),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(children: [
                        for (var i = 0; i < math.min(top.length, 6); i++)
                          InkWell(
                            onTap: () => context.go('/tx?cat=${top[i].cat.id}${_period == _Period.month ? '&month=${monthKey(now)}' : ''}'),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(children: [
                                Container(width: 8, height: 8, decoration: BoxDecoration(color: colors[i % colors.length], shape: BoxShape.circle)),
                                const SizedBox(width: 8),
                                Expanded(child: Text(top[i].cat.name, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis)),
                                Text(_pct(top[i].total / total), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              ]),
                            ),
                          ),
                      ]),
                    ),
                  ]),
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter(this.values, this.colors, this.track);
  final List<double> values;
  final List<Color> colors;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<double>(0, (a, v) => a + v);
    const stroke = 14.0;
    final rect = Rect.fromLTWH(stroke / 2, stroke / 2, size.width - stroke, size.height - stroke);
    canvas.drawArc(rect, 0, math.pi * 2, false, Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke);
    if (total <= 0) return;
    var start = -math.pi / 2;
    for (var i = 0; i < values.length; i++) {
      final sweep = values[i] / total * math.pi * 2;
      canvas.drawArc(rect, start, math.max(0, sweep - 0.02), false, Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) => true;
}

// ───────────────────────── Tafasil chher
class MonthDetailScreen extends ConsumerStatefulWidget {
  const MonthDetailScreen({super.key, required this.monthKey});
  final String monthKey;
  @override
  ConsumerState<MonthDetailScreen> createState() => _MonthDetailScreenState();
}

class _MonthDetailScreenState extends ConsumerState<MonthDetailScreen> {
  late DateTime _month = DateTime(int.parse(widget.monthKey.substring(0, 4)), int.parse(widget.monthKey.substring(5)));

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final txs = ref.watch(txProvider).value ?? const <Txn>[];
    final moves = ref.watch(movesProvider).value ?? const <SavingMove>[];
    final cats = ref.watch(allCatsProvider);
    final sum = summarize(txs, moves, _month);
    final inMonth = txs.where((t) => monthKey(t.date) == monthKey(_month)).toList();
    final exp = _byCat(inMonth, cats, TxType.expense);
    final now = DateTime.now();
    final isCurrent = _month.year == now.year && _month.month == now.month;
    final colors = seriesColors(context.isDark);

    Widget tile(String label, String value, {bool gold = false}) => Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: gold ? AppColors.gold.withValues(alpha: 0.18) : Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: TextStyle(fontSize: 10, color: gold ? AppColors.gold : AppColors.onBrandMuted)),
              const SizedBox(height: 2),
              FittedBox(child: Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: gold ? AppColors.gold : Colors.white))),
            ]),
          ),
        );

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(children: [
                const BackBox(),
                Expanded(
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    IconButton(
                      tooltip: 'Chher li fat',
                      onPressed: () => setState(() => _month = DateTime(_month.year, _month.month - 1)),
                      icon: Ic(I.chevron_left_rounded, color: c.muted),
                    ),
                    Flexible(child: Text(monthLabel(_month), style: display(17), overflow: TextOverflow.ellipsis)),
                    IconButton(
                      tooltip: 'Chher jay',
                      onPressed: isCurrent ? null : () => setState(() => _month = DateTime(_month.year, _month.month + 1)),
                      icon: Ic(I.chevron_right_rounded, color: c.muted),
                    ),
                  ]),
                ),
                const SizedBox(width: 46),
              ]),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: c.brand, borderRadius: BorderRadius.circular(24)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(S.leftInMonth, style: capsLabel(AppColors.onBrandMuted)),
                const SizedBox(height: 6),
                Text(dh(sum.left), style: display(32, color: sum.left < 0 ? const Color(0xFFF4A38C) : Colors.white)),
                const SizedBox(height: 14),
                Row(children: [
                  tile(S.income2, dh(sum.income).replaceAll(' DH', '')),
                  const SizedBox(width: 8),
                  tile(S.expense2, dh(sum.expense).replaceAll(' DH', '')),
                  const SizedBox(width: 8),
                  tile(S.saved2, dh(sum.put - sum.take).replaceAll(' DH', ''), gold: true),
                ]),
              ]),
            ),
            const SizedBox(height: 18),
            CapsTitle(S.byCategory, trailing: '${inMonth.length} MO3AMALA'),
            if (exp.isEmpty) Padding(padding: const EdgeInsets.all(8), child: Text(S.empty, style: TextStyle(color: c.muted))),
            for (var i = 0; i < exp.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(18),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => context.go('/tx?cat=${exp[i].cat.id}&month=${monthKey(_month)}'),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(children: [
                        CatIcon(exp[i].cat, size: 42),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(children: [
                            Row(children: [
                              Expanded(child: Text(exp[i].cat.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                              Text(dh(exp[i].total).replaceAll(' DH', ''), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            ]),
                            const SizedBox(height: 6),
                            ProgressBar(exp[i].total / sum.expense, height: 5, color: colors[i % colors.length]),
                          ]),
                        ),
                      ]),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
