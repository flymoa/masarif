import 'package:flutter/material.dart';
import 'package:masarif/widgets/icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/models.dart';
import '../data/repo.dart';
import '../l10n/strings.dart';
import '../theme.dart';
import '../widgets/common.dart';

// ───────────────────────── Categories (grille)
class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});
  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  TxType _type = TxType.expense;

  Future<void> _defaultActions(Cat cat, bool hidden) async {
    if (cat.id.startsWith('other')) {
      toast(context, '"Okhra" dima kayna');
      return;
    }
    final repo = ref.read(repoProvider);
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            CatIcon(cat, size: 56),
            const SizedBox(height: 10),
            Text(cat.name, style: display(18)),
            const SizedBox(height: 6),
            Text(S.catDeleteNote, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: ctx.c.muted, height: 1.5)),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () {
                repo?.setCatHidden(cat.id, !hidden);
                Navigator.pop(ctx);
              },
              child: Text(hidden ? 'Werriha' : S.hide),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final all = ref.watch(allCatsProvider);
    final hidden = ref.watch(profileProvider).value?.hiddenCats ?? const [];
    final mine = all.where((x) => !x.isDefault && x.type == _type).toList();
    final defaults = all.where((x) => x.isDefault && x.type == _type).toList();
    int count(TxType t) => all.where((x) => x.type == t).length;

    Widget tile(Cat cat, {bool isHidden = false, required VoidCallback onTap}) => Opacity(
          opacity: isHidden ? 0.45 : 1,
          child: Material(
            color: c.surface,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: onTap,
              child: Stack(children: [
                Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    CatIcon(cat),
                    const SizedBox(height: 8),
                    Text(cat.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  ]),
                ),
                if (isHidden) Positioned(top: 8, right: 10, child: Text('Mkhbya', style: TextStyle(fontSize: 10, color: c.muted))),
              ]),
            ),
          ),
        );

    Widget grid(List<Widget> children) => GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.05,
          children: children,
        );

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            TopBar(
              S.categories,
              trailing: CircleBtn(icon: I.add_rounded, label: S.addCat, filled: true, onTap: () => context.push('/categories/edit?type=${_type.name}')),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Segmented<TxType>(
                  items: {TxType.expense: '${S.expenses} · ${count(TxType.expense)}', TxType.income: '${S.income} · ${count(TxType.income)}'},
                  value: _type,
                  onChanged: (v) => setState(() => _type = v),
                ),
                const SizedBox(height: 18),
                if (mine.isNotEmpty) ...[
                  CapsTitle(S.mine.toUpperCase()),
                  grid([for (final cat in mine) tile(cat, onTap: () => context.push('/categories/edit?id=${cat.id}'))]),
                  const SizedBox(height: 18),
                ],
                CapsTitle(S.defaultCat.toUpperCase()),
                grid([
                  for (final cat in defaults)
                    tile(cat, isHidden: hidden.contains(cat.id), onTap: () => _defaultActions(cat, hidden.contains(cat.id))),
                ]),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text('Brek 3la chi categorie bach t3dlha wla tkhbiha.', style: TextStyle(fontSize: 12, color: c.muted)),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── Zid / 3dl categorie
class CategoryEditScreen extends ConsumerStatefulWidget {
  const CategoryEditScreen({super.key, this.catId});
  final String? catId;
  @override
  ConsumerState<CategoryEditScreen> createState() => _CategoryEditScreenState();
}

class _CategoryEditScreenState extends ConsumerState<CategoryEditScreen> {
  final _name = TextEditingController();
  TxType _type = TxType.expense;
  String _icon = 'coffee';
  String _color = 'brown';
  bool _loaded = false;
  Cat? _original;

  static const _iconChoices = ['coffee', 'resto', 'cart', 'car', 'bolt', 'pharma', 'play', 'netflix', 'spotify', 'sport', 'gift', 'phone', 'book', 'work', 'box'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final t = GoRouterState.of(context).uri.queryParameters['type'];
    if (!_loaded && t == 'income') _type = TxType.income;
  }

  void _load(List<Cat> all) {
    if (_loaded || widget.catId == null) return;
    final cat = all.where((x) => x.id == widget.catId).firstOrNull;
    if (cat == null) return;
    _loaded = true;
    _original = cat;
    _name.text = cat.name;
    _type = cat.type;
    _icon = cat.iconKey;
    _color = cat.colorKey;
  }

  void _save() {
    if (_name.text.trim().isEmpty) return toast(context, S.required);
    ref.read(repoProvider)!.saveCat(Cat(id: widget.catId ?? '', name: _name.text.trim(), icon: _icon, color: _color, type: _type));
    context.pop();
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Bghiti tmse7 "${_original!.name}"?'),
        content: const Text('L mo3amalat dyalha ghadi ymchiw l "Okhra".'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text(S.no)),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(S.yes, style: TextStyle(color: context.c.danger))),
        ],
      ),
    );
    if (ok != true) return;
    ref.read(repoProvider)!.deleteCat(_original!);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    _load(ref.watch(allCatsProvider));
    final b = Theme.of(context).brightness;
    final preview = Cat(id: '', name: _name.text, icon: _icon, color: _color, type: _type);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            TopBar(widget.catId == null ? S.addCat : S.editCat),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Card2(
                  padding: const EdgeInsets.all(14),
                  child: Row(children: [
                    CatIcon(preview, size: 56),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(S.name.toUpperCase(), style: capsLabel(c.muted).copyWith(fontSize: 10)),
                        TextField(
                          controller: _name,
                          onChanged: (_) => setState(() {}),
                          style: display(18),
                          decoration: const InputDecoration(
                            hintText: '9hwa, Netflix…',
                            filled: false,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 6),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                        ),
                      ]),
                    ),
                  ]),
                ),
                const SizedBox(height: 14),
                Segmented<TxType>(items: const {TxType.expense: S.expense, TxType.income: S.income}, value: _type, onChanged: (v) => setState(() => _type = v)),
                const SizedBox(height: 18),
                CapsTitle(S.icon.toUpperCase()),
                GridView.count(
                  crossAxisCount: 5,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children: [
                    for (final k in _iconChoices)
                      Semantics(
                        selected: k == _icon,
                        button: true,
                        label: k,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => setState(() => _icon = k),
                          child: Container(
                            decoration: BoxDecoration(
                              color: c.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: k == _icon ? c.brandFg : c.border, width: k == _icon ? 2 : 1),
                            ),
                            alignment: Alignment.center,
                            child: CatIcon(Cat(id: '', name: '', icon: k, color: _color, type: _type), size: 38),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                CapsTitle(S.color.toUpperCase()),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  for (final k in catPalette.keys)
                    Semantics(
                      selected: k == _color,
                      button: true,
                      label: k,
                      child: GestureDetector(
                        onTap: () => setState(() => _color = k),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(catPalette[k]![b == Brightness.light ? 0 : 2]),
                            border: k == _color ? Border.all(color: c.bg, width: 3) : null,
                            boxShadow: k == _color ? [BoxShadow(color: c.text, spreadRadius: 2)] : null,
                          ),
                        ),
                      ),
                    ),
                ]),
                const SizedBox(height: 28),
                Row(children: [
                  if (_original != null) ...[
                    Expanded(child: OutlinedButton(onPressed: _delete, child: const Text(S.delete))),
                    const SizedBox(width: 10),
                  ],
                  Expanded(flex: 2, child: FilledButton(onPressed: _save, child: const Text(S.save))),
                ]),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
