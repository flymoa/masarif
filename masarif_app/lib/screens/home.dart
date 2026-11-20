import 'package:flutter/material.dart';
import 'package:masarif/widgets/icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/models.dart';
import '../data/notifs.dart';
import '../data/repo.dart';
import '../l10n/strings.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import '../widgets/zellige.dart';
import 'savings.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _checkedPrompt = false;
  bool _hidden = false;

  /// M1: f awwel ftou7 f chher jdid, nsowlo 3la li shat f chher l fat.
  void _maybePrompt() {
    if (_checkedPrompt) return;
    final txs = ref.read(txProvider);
    final moves = ref.read(movesProvider);
    final profile = ref.read(profileProvider);
    final repo = ref.read(repoProvider);
    if (!txs.hasValue || !moves.hasValue || !profile.hasValue || repo == null) return;
    _checkedPrompt = true;

    final now = DateTime.now();
    final key = monthKey(now);
    final p = profile.value!;
    if (p.lastPromptMonth == key) return;

    final prev = DateTime(now.year, now.month - 1);
    final prevKey = monthKey(prev);
    final left = summarize(txs.value!, moves.value!, prev).left;
    final already = moves.value!.any((m) => m.source == 'month_left' && m.month == prevKey);
    repo.setProfile({'lastPromptMonth': key});
    if (left <= 0 || already) return;

    final move = SavingMove(id: '', type: MoveType.put, amount: left, date: now, source: 'month_left', month: prevKey);
    if (p.autoSavings) {
      repo.addMove(move);
      toast(context, 'Tkhbaw ${dh(left)} f ${S.savings} ✓');
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) showMonthLeftDialog(context, ref, move, monthNames[prev.month - 1]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    ref.listen(txProvider, (_, __) => _maybePrompt());
    ref.listen(movesProvider, (_, __) => _maybePrompt());
    ref.listen(profileProvider, (_, __) => _maybePrompt());

    final txs = ref.watch(txProvider).value ?? const <Txn>[];
    final moves = ref.watch(movesProvider).value ?? const <SavingMove>[];
    final p = ref.watch(profileProvider).value;
    final left = summarize(txs, moves, DateTime.now()).left;
    final unread = ref.watch(unreadNotifsProvider);

    Widget action(String icon, String label, VoidCallback onTap, {bool gold = false}) => Expanded(
          child: Semantics(
            button: true,
            label: label,
            child: GestureDetector(
              onTap: onTap,
              child: Column(children: [
                Container(
                  height: 58,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: gold ? AppColors.gold : c.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: gold ? null : Border.all(color: c.border),
                  ),
                  child: Ic(icon, color: gold ? AppColors.onGold : c.brandFg, size: 22),
                ),
                const SizedBox(height: 7),
                // Dima f str wa7ed: ila ma kafatch l blasa, l kelma katsghar chwiya.
                SizedBox(
                  height: 16,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(label,
                        maxLines: 1,
                        softWrap: false,
                        style: TextStyle(fontSize: 12, fontWeight: gold ? FontWeight.w600 : FontWeight.w400, color: gold ? c.text : c.muted)),
                  ),
                ),
              ]),
            ),
          ),
        );

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 110),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(children: [
              GestureDetector(onTap: () => context.go('/profile'), child: const Avatar()),
              const SizedBox(width: 12),
              Expanded(child: Text(p?.name ?? '', style: display(19), overflow: TextOverflow.ellipsis)),
              CircleBtn(icon: I.notifications_none_rounded, label: S.notifications, badge: unread > 0, onTap: () => context.push('/notifs')),
            ]),
          ),
          const SizedBox(height: 18),

          // Carte "Li b9a lik" — minimaliste, b zellige o 3in.
          Container(
            height: 124,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(color: c.brand, borderRadius: BorderRadius.circular(24)),
            child: Stack(children: [
              Positioned.fill(left: 150, child: ZelligeBackground(color: c.brand, opacity: 0.5, tile: 48, stops: const [0.1, 0.75])),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(S.leftCaps, style: capsLabel(AppColors.onBrandMuted)),
                  const SizedBox(height: 4),
                  Transform.translate(
                    offset: const Offset(-11, 0),
                    child: Row(children: [
                      IconButton(
                        tooltip: _hidden ? S.showAmount : S.hideAmount,
                        onPressed: () => setState(() => _hidden = !_hidden),
                        icon: Ic(_hidden ? I.visibility_off_outlined : I.visibility_outlined, color: AppColors.onBrandMuted, size: 22),
                      ),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text.rich(TextSpan(children: [
                            TextSpan(
                              text: _hidden ? '##### ' : '${dh(left).replaceAll(' DH', '')} ',
                              style: display(38, color: left < 0 && !_hidden ? const Color(0xFFF4A38C) : Colors.white).copyWith(letterSpacing: _hidden ? 2 : -1.4),
                            ),
                            TextSpan(text: 'DH', style: display(19, color: AppColors.onBrandMuted, weight: FontWeight.w500)),
                          ])),
                        ),
                      ),
                    ]),
                  ),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 16),

          Row(children: [
            action(I.north_east_rounded, S.expense, () => context.push('/add')),
            const SizedBox(width: 10),
            action(I.south_west_rounded, S.income, () => context.push('/add?type=income')),
            const SizedBox(width: 10),
            action(I.savings_outlined, S.savings, () => context.push('/savings'), gold: true),
            const SizedBox(width: 10),
            action(I.bar_chart_rounded, S.tabStats, () => context.go('/stats')),
          ]),
          const SizedBox(height: 22),

          SectionTitle(S.recent, trailing: TextButton(onPressed: () => context.go('/tx'), child: const Text('${S.seeAll} ›'))),
          if (txs.isEmpty)
            Card2(
              padding: const EdgeInsets.all(24),
              child: Column(children: [
                Ic(I.receipt_long_outlined, size: 40, color: c.muted),
                const SizedBox(height: 10),
                Text(S.empty, textAlign: TextAlign.center, style: TextStyle(color: c.muted, height: 1.5)),
              ]),
            )
          else
            for (final t in txs.take(5)) Padding(padding: const EdgeInsets.only(bottom: 8), child: TxRow(t)),
        ],
      ),
    );
  }
}
