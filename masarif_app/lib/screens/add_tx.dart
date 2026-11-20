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

/// Zid / 3dl mo3amala (design V2: categories lfo9, mablagh, clavier).
class AddTxScreen extends ConsumerStatefulWidget {
  const AddTxScreen({super.key, this.txId, this.initialType});
  final String? txId;
  final TxType? initialType;
  @override
  ConsumerState<AddTxScreen> createState() => _AddTxScreenState();
}

class _AddTxScreenState extends ConsumerState<AddTxScreen> {
  String _amount = '';
  String _note = '';
  late TxType _type = widget.initialType ?? TxType.expense;
  String? _catId;
  DateTime _date = DateTime.now();
  bool _loaded = false;

  bool get _isEdit => widget.txId != null;

  void _load(List<Txn> txs) {
    if (_loaded || !_isEdit) return;
    final t = txs.where((t) => t.id == widget.txId).firstOrNull;
    if (t == null) return;
    _loaded = true;
    _type = t.type;
    _catId = t.categoryId;
    _date = t.date;
    _note = t.note;
    final cents = (t.amount * 100).round();
    _amount = cents % 100 == 0 ? '${cents ~/ 100}' : '${cents ~/ 100},${(cents % 100).toString().padLeft(2, '0')}';
  }

  Future<void> _editDetails() async {
    final noteCtrl = TextEditingController(text: _note);
    var date = _date;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setLocal) {
        final c = ctx.c;
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(S.note, style: display(16)),
            const SizedBox(height: 8),
            TextField(controller: noteCtrl, autofocus: true, decoration: const InputDecoration(hintText: S.noteHint)),
            const SizedBox(height: 14),
            Card2(
              padding: EdgeInsets.zero,
              child: ListTile(
                leading: Ic(I.calendar_today_outlined, color: c.muted),
                title: const Text(S.date),
                trailing: Text(fullDate(date), style: const TextStyle(fontWeight: FontWeight.w600)),
                onTap: () async {
                  final d = await showDatePicker(context: ctx, initialDate: date, firstDate: DateTime(2020), lastDate: DateTime.now().add(const Duration(days: 365)));
                  if (d != null) setLocal(() => date = DateTime(d.year, d.month, d.day, date.hour, date.minute));
                },
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('Mzyan')),
          ]),
        );
      }),
    );
    setState(() {
      _note = noteCtrl.text.trim();
      _date = date;
    });
  }

  Future<void> _pickOther(List<Cat> cats) async {
    final id = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(padding: const EdgeInsets.only(left: 4, bottom: 12), child: Text(S.categories, style: display(18))),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              mainAxisSpacing: 12,
              crossAxisSpacing: 8,
              childAspectRatio: 0.85,
              children: [
                for (final cat in cats)
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.pop(ctx, cat.id),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      CatIcon(cat, size: 52),
                      const SizedBox(height: 6),
                      Text(cat.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                    ]),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton.icon(onPressed: () {
              Navigator.pop(ctx);
              context.push('/categories/edit?type=${_type.name}');
            }, icon: const Ic(I.add_rounded), label: const Text(S.addCat)),
          ]),
        ),
      ),
    );
    if (id != null) setState(() => _catId = id);
  }

  void _save() {
    final amount = parseAmount(_amount);
    if (amount == null) return toast(context, S.badAmount);
    if (_catId == null) return toast(context, S.pickCat);
    final repo = ref.read(repoProvider)!;
    final cats = ref.read(allCatsProvider);
    final t = Txn(id: widget.txId ?? '', type: _type, amount: amount, categoryId: _catId!, date: _date, note: _note);
    if (_isEdit) {
      repo.updateTx(t);
      toast(context, S.updated);
    } else {
      repo.addTx(t);
      toast(context, _type == TxType.income ? S.toastIncome(dh(amount)) : S.toastExpense(dh(amount), catById(cats, _catId!).name));
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    _load(ref.watch(txProvider).value ?? const []);
    final hidden = ref.watch(profileProvider).value?.hiddenCats ?? const [];
    final cats = ref.watch(allCatsProvider).where((x) => x.type == _type && (!hidden.contains(x.id) || x.id == _catId)).toList();
    // Lkhrin f lfo9: li m5tar + 4 lwlin
    final quick = <Cat>[
      if (_catId != null && cats.any((x) => x.id == _catId)) cats.firstWhere((x) => x.id == _catId),
      ...cats.where((x) => x.id != _catId),
    ].take(4).toList();
    final selected = _catId == null ? null : catById(ref.watch(allCatsProvider), _catId!);
    final amount = parseAmount(_amount);

    Widget typePill(TxType t, String label) => GestureDetector(
          onTap: () => setState(() {
            _type = t;
            if (_catId != null && catById(ref.read(allCatsProvider), _catId!).type != t) _catId = null;
          }),
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(color: _type == t ? c.segActive : Colors.transparent, borderRadius: BorderRadius.circular(999)),
            child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _type == t ? Colors.white : c.muted)),
          ),
        );

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              const BackBox(),
              Expanded(child: Text(_isEdit ? S.editTx : S.addTx, textAlign: TextAlign.center, style: display(17))),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(999)),
                child: Row(children: [typePill(TxType.expense, S.expense), typePill(TxType.income, S.income)]),
              ),
            ]),
            const SizedBox(height: 16),
            Text(_type == TxType.expense ? S.whereSpent : S.whereFrom, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.muted)),
            const SizedBox(height: 10),
            Row(children: [
              for (final cat in quick)
                Expanded(
                  child: Semantics(
                    selected: cat.id == _catId,
                    button: true,
                    child: GestureDetector(
                      onTap: () => setState(() => _catId = cat.id),
                      child: Column(children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: cat.id == _catId ? AppColors.gold : Colors.transparent, width: 2),
                          ),
                          child: CatIcon(cat, size: 52),
                        ),
                        const SizedBox(height: 4),
                        Text(cat.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 11, fontWeight: cat.id == _catId ? FontWeight.w600 : FontWeight.w400, color: cat.id == _catId ? c.brandFg : c.muted)),
                      ]),
                    ),
                  ),
                ),
              Expanded(
                child: GestureDetector(
                  onTap: () => _pickOther(cats),
                  child: Column(children: [
                    Container(
                      margin: const EdgeInsets.all(5),
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: c.navMuted, width: 1.2)),
                      child: Ic(I.add_rounded, color: c.muted),
                    ),
                    Text(S.otherCat, maxLines: 1, style: TextStyle(fontSize: 11, color: c.muted)),
                  ]),
                ),
              ),
            ]),
            const SizedBox(height: 14),
            Card2(
              radius: 24,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              child: Column(children: [
                Text(_type == TxType.expense ? S.spentCaps : S.gotCaps, style: capsLabel(c.muted)),
                AmountDisplay(_amount),
                const SizedBox(height: 10),
                QuickChips(values: const [20, 50, 100, 200], selected: _amount, onPick: (v) => setState(() => _amount = '$v')),
                const SizedBox(height: 10),
                InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: _editDetails,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: c.bg, borderRadius: BorderRadius.circular(999)),
                    child: Text('✎ ${_note.isEmpty ? S.note : _note} · ${fullDate(_date)}', style: TextStyle(fontSize: 13, color: c.muted)),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 6),
            Expanded(child: Center(child: NumPad(onKey: (k) => setState(() => _amount = applyKey(_amount, k))))),
            FilledButton(
              onPressed: _save,
              child: Text(_isEdit
                  ? S.saveEdit
                  : (amount != null && selected != null ? S.addBtn(dh(amount), selected.name) : S.save)),
            ),
          ]),
        ),
      ),
    );
  }
}
