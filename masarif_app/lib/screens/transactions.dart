import 'package:flutter/material.dart';
import 'package:masarif/widgets/icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models.dart';
import '../data/repo.dart';
import '../l10n/strings.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';

enum _Filter { all, expense, income }

/// Msse7 b confirmation + Rje3 (5 tawani).
Future<bool> deleteWithUndo(BuildContext context, WidgetRef ref, Txn t, {bool confirm = true}) async {
  if (confirm) {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(S.confirmDelete),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text(S.no)),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(S.yes, style: TextStyle(color: context.c.danger))),
        ],
      ),
    );
    if (ok != true) return false;
  }
  final repo = ref.read(repoProvider)!;
  repo.setDeleted(t.id, true);
  if (context.mounted) {
    toast(context, S.deleted, action: S.undo, seconds: 5, onAction: () => repo.setDeleted(t.id, false));
  }
  return true;
}

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key, this.initialCat, this.initialMonth});
  final String? initialCat;
  final String? initialMonth;
  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  _Filter _filter = _Filter.all;
  String _query = '';
  bool _searching = false;
  late String? _cat = widget.initialCat;
  // null = kolchi; sinon "2026-11"
  late String? _month = widget.initialMonth ?? monthKey(DateTime.now());

  @override
  void didUpdateWidget(covariant TransactionsScreen old) {
    super.didUpdateWidget(old);
    if (old.initialCat != widget.initialCat || old.initialMonth != widget.initialMonth) {
      _cat = widget.initialCat;
      _month = widget.initialMonth ?? _month;
    }
  }

  Future<void> _openFilter(List<Cat> cats) async {
    final now = DateTime.now();
    final thisKey = monthKey(now);
    final lastKey = monthKey(DateTime(now.year, now.month - 1));
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setLocal) {
        final c = ctx.c;
        Widget chip(String label, bool sel, VoidCallback onTap) => InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () {
                onTap();
                setLocal(() {});
                setState(() {});
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                decoration: BoxDecoration(
                  color: sel ? c.segActive : c.surface,
                  border: sel ? null : Border.all(color: c.border),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: sel ? Colors.white : c.text)),
              ),
            );
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(S.filter, style: display(18)),
              const SizedBox(height: 16),
              CapsTitle('FATRA'),
              Wrap(spacing: 8, runSpacing: 8, children: [
                chip(S.periodThis, _month == thisKey, () => _month = thisKey),
                chip(S.periodLast, _month == lastKey, () => _month = lastKey),
                chip(S.periodAll, _month == null, () => _month = null),
              ]),
              const SizedBox(height: 18),
              CapsTitle(S.category.toUpperCase()),
              Wrap(spacing: 8, runSpacing: 8, children: [
                chip(S.all, _cat == null, () => _cat = null),
                for (final cat in cats) chip(cat.name, _cat == cat.id, () => _cat = cat.id),
              ]),
              const SizedBox(height: 20),
              FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('Chouf')),
            ]),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final all = ref.watch(txProvider).value ?? const <Txn>[];
    final cats = ref.watch(allCatsProvider);
    final q = _query.trim().toLowerCase();
    final inPeriod = all.where((t) => _month == null || monthKey(t.date) == _month).toList();
    final list = inPeriod.where((t) {
      if (_filter == _Filter.expense && t.type != TxType.expense) return false;
      if (_filter == _Filter.income && t.type != TxType.income) return false;
      if (_cat != null && t.categoryId != _cat) return false;
      if (q.isNotEmpty && !t.note.toLowerCase().contains(q) && !catById(cats, t.categoryId).name.toLowerCase().contains(q)) return false;
      return true;
    }).toList();
    final income = inPeriod.where((t) => t.type == TxType.income).fold<double>(0, (a, t) => a + t.amount);
    final expense = inPeriod.where((t) => t.type == TxType.expense).fold<double>(0, (a, t) => a + t.amount);

    final groups = <DateTime, List<Txn>>{};
    for (final t in list) {
      groups.putIfAbsent(dayOnly(t.date), () => []).add(t);
    }
    final filtered = _cat != null || _month != monthKey(DateTime.now());

    Widget tile(String label, String value, Color? color) => Expanded(
          child: Card2(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            radius: 16,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: capsLabel(c.muted).copyWith(fontSize: 10)),
              const SizedBox(height: 4),
              FittedBox(child: Text(value, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: color))),
            ]),
          ),
        );

    return SafeArea(
      bottom: false,
      child: CustomScrollView(slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
          sliver: SliverList.list(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(children: [
                Expanded(child: Text(S.tabTx, style: display(24))),
                CircleBtn(icon: _searching ? I.close_rounded : I.search_rounded, label: S.search, onTap: () => setState(() {
                      _searching = !_searching;
                      if (!_searching) _query = '';
                    })),
                const SizedBox(width: 10),
                CircleBtn(icon: I.tune_rounded, label: S.filter, badge: filtered, onTap: () => _openFilter(cats)),
              ]),
            ),
            if (_searching) ...[
              const SizedBox(height: 12),
              TextField(
                autofocus: true,
                onChanged: (v) => setState(() => _query = v),
                decoration: const InputDecoration(hintText: S.search, prefixIcon: Ic(I.search_rounded), contentPadding: EdgeInsets.symmetric(vertical: 12)),
              ),
            ],
            const SizedBox(height: 16),
            Segmented<_Filter>(
              items: const {_Filter.all: S.all, _Filter.expense: S.expenses, _Filter.income: S.income},
              value: _filter,
              onChanged: (v) => setState(() => _filter = v),
            ),
            const SizedBox(height: 12),
            Row(children: [
              tile(S.income2.toUpperCase(), dh(income, sign: true), c.positive),
              const SizedBox(width: 10),
              tile(S.expense2.toUpperCase(), dh(-expense), null),
            ]),
            const SizedBox(height: 18),
            if (list.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Text(S.empty, textAlign: TextAlign.center, style: TextStyle(color: c.muted)),
              ),
          ]),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
          sliver: SliverList.builder(
            itemCount: groups.length,
            itemBuilder: (context, i) {
              final day = groups.keys.elementAt(i);
              final items = groups[day]!;
              final total = items.fold<double>(0, (a, t) => a + t.signed);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  CapsTitle(dayLabel(day).toUpperCase(), trailing: dh(total, sign: true)),
                  for (final t in items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Dismissible(
                        key: ValueKey(t.id),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (_) => deleteWithUndo(context, ref, t),
                        background: Container(
                          decoration: BoxDecoration(color: const Color(0xFFC4392D), borderRadius: BorderRadius.circular(18)),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          child: const Column(mainAxisSize: MainAxisSize.min, children: [
                            Ic(I.delete_outline_rounded, color: Colors.white),
                            Text(S.delete, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                          ]),
                        ),
                        child: TxRow(t, showDay: false),
                      ),
                    ),
                ]),
              );
            },
          ),
        ),
      ]),
    );
  }
}
