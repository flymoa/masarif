import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:masarif/widgets/icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/models.dart';
import '../data/repo.dart';
import '../l10n/strings.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import '../widgets/zellige.dart';

// ───────────────────────── Popup "Shat lik" (bottom sheet)
Future<void> showMonthLeftDialog(BuildContext context, WidgetRef ref, SavingMove move, String monthName) async {
  var auto = false;
  final balance = ref.read(savingsBalanceProvider);
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: false,
    builder: (ctx) => StatefulBuilder(builder: (ctx, setLocal) {
      final c = ctx.c;
      return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SizedBox(
          height: 110,
          child: Stack(fit: StackFit.expand, children: [
            Container(color: AppColors.deepGreen),
            ZelligeBackground(color: AppColors.deepGreen, fadeFrom: Alignment.bottomCenter, fadeTo: Alignment.topCenter, opacity: 0.5, tile: 38, stops: const [0.0, 0.8]),
            Center(child: Text('${monthName.toUpperCase()} TSALA', style: capsLabel(AppColors.gold).copyWith(fontSize: 13, letterSpacing: 2))),
          ]),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text(S.popupTitle(dh(move.amount), monthName), textAlign: TextAlign.center, style: display(24)),
              const SizedBox(height: 8),
              Text(S.popupBody, textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: c.muted)),
              const SizedBox(height: 14),
              Card2(
                padding: const EdgeInsets.all(14),
                child: Row(children: [
                  Expanded(child: Column(children: [Text('Daba', style: TextStyle(fontSize: 11, color: c.muted)), Text(dh(balance), style: const TextStyle(fontWeight: FontWeight.w600))])),
                  Ic(I.arrow_forward_rounded, color: c.navMuted),
                  Expanded(child: Column(children: [Text('Mn ba3d', style: TextStyle(fontSize: 11, color: c.muted)), Text(dh(balance + move.amount), style: TextStyle(fontWeight: FontWeight.w600, color: c.positive))])),
                ]),
              ),
              const SizedBox(height: 16),
              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text(S.yesPut)),
              TextButton(onPressed: () => Navigator.pop(ctx, false), style: TextButton.styleFrom(foregroundColor: c.text), child: const Text(S.later)),
              CheckboxListTile(
                value: auto,
                onChanged: (v) => setLocal(() => auto = v ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                title: const Text(S.doAuto, style: TextStyle(fontSize: 13)),
              ),
            ]),
          ),
        ),
      ]);
    }),
  );
  final repo = ref.read(repoProvider);
  if (repo == null) return;
  if (auto) repo.setProfile({'autoSavings': true});
  if (result == true) {
    repo.addMove(move);
    if (context.mounted) {
      toast(context, 'Tkhbaw ${dh(move.amount)} f ${S.savings} ✓');
      context.push('/savings');
    }
  }
}

// ───────────────────────── Dwayr zman
class SavingsScreen extends ConsumerWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final balance = ref.watch(savingsBalanceProvider);
    final moves = ref.watch(movesProvider).value ?? const <SavingMove>[];
    final goal = ref.watch(profileProvider).value?.goal;
    final hasGoal = goal != null && goal > 0;
    final ratio = hasGoal ? balance / goal : 0.0;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            const TopBar(S.savings),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Container(
                  height: 220,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(color: c.brand, borderRadius: BorderRadius.circular(28)),
                  child: Stack(children: [
                    const Positioned(right: 14, bottom: 0, child: ArchZellige(width: 124, height: 168)),
                    Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(S.savingsBalance.toUpperCase(), style: capsLabel(AppColors.onBrandMuted)),
                        const SizedBox(height: 6),
                        Text.rich(TextSpan(children: [
                          TextSpan(text: dh(balance).replaceAll(' DH', ''), style: display(36, color: Colors.white).copyWith(letterSpacing: -1.2)),
                          TextSpan(text: ' DH', style: display(18, color: AppColors.onBrandMuted)),
                        ])),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 170,
                          child: Text(S.savingsMessage(balance, goal),
                              style: GoogleFonts.fraunces(fontStyle: FontStyle.italic, fontSize: 16, color: AppColors.gold, height: 1.3)),
                        ),
                      ]),
                    ),
                  ]),
                ),
                const SizedBox(height: 14),
                Card2(
                  radius: 24,
                  padding: const EdgeInsets.all(16),
                  child: Row(children: [
                    SizedBox(
                      width: 72,
                      height: 72,
                      child: Stack(alignment: Alignment.center, children: [
                        CustomPaint(size: const Size.square(72), painter: _RingPainter(ratio, c.divider)),
                        Text(hasGoal ? '${(ratio * 100).clamp(0, 999).round()}%' : '—', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      ]),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(hasGoal ? 'Lhadaf: ${dh(goal)}' : S.noGoal, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        if (hasGoal) ...[
                          const SizedBox(height: 3),
                          Text(balance >= goal ? 'Wslti l hadaf dyalk ✓' : 'B9a lik ${dh(goal - balance)}', style: TextStyle(fontSize: 12, color: c.muted)),
                        ],
                        TextButton(onPressed: () => context.push('/savings/move?mode=goal'), child: const Text('${S.changeGoal} →')),
                      ]),
                    ),
                  ]),
                ),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(child: FilledButton.icon(onPressed: () => context.push('/savings/move?mode=put'), icon: const Ic(I.add_rounded), label: const Text(S.put))),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: c.surface, foregroundColor: c.text, disabledBackgroundColor: c.surface),
                      onPressed: balance > 0 ? () => context.push('/savings/move?mode=take') : null,
                      icon: const Ic(I.remove_rounded),
                      label: const Text(S.take),
                    ),
                  ),
                ]),
                const SizedBox(height: 18),
                CapsTitle(S.moves.toUpperCase()),
                if (moves.isEmpty)
                  Card2(padding: const EdgeInsets.all(20), child: Text(S.savingsEmpty, style: TextStyle(color: c.muted)))
                else
                  for (final m in moves)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Card2(
                        radius: 18,
                        padding: const EdgeInsets.all(12),
                        child: Row(children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: m.source == 'month_left' ? AppColors.deepGreen : (m.type == MoveType.put ? c.chipActive : c.divider),
                              shape: BoxShape.circle,
                            ),
                            child: Ic(
                              m.source == 'month_left' ? I.auto_awesome_rounded : (m.type == MoveType.put ? I.add_rounded : I.remove_rounded),
                              color: m.source == 'month_left' ? AppColors.gold : (m.type == MoveType.put ? c.positive : c.muted),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(
                                m.source == 'month_left' && m.month != null
                                    ? 'Li shat f ${monthNames[int.parse(m.month!.substring(5)) - 1]}'
                                    : (m.type == MoveType.put ? 'Khbiti b yeddek' : 'Jbedti'),
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                              Text(dayLabel(m.date), style: TextStyle(fontSize: 12, color: c.muted)),
                            ]),
                          ),
                          Text(dh(m.signed, sign: true), style: TextStyle(fontWeight: FontWeight.w600, color: m.type == MoveType.put ? c.positive : c.text)),
                        ]),
                      ),
                    ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.ratio, this.track);
  final double ratio;
  final Color track;
  @override
  void paint(Canvas canvas, Size size) {
    const w = 8.0;
    final rect = Rect.fromLTWH(w / 2, w / 2, size.width - w, size.height - w);
    canvas.drawArc(rect, 0, math.pi * 2, false, Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = w);
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * ratio.clamp(0, 1), false, Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = w);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.ratio != ratio || old.track != track;
}

// ───────────────────────── Khbi / Jbed / Lhadaf
class SavingsMoveScreen extends ConsumerStatefulWidget {
  const SavingsMoveScreen({super.key, required this.mode});
  final String mode;
  @override
  ConsumerState<SavingsMoveScreen> createState() => _SavingsMoveScreenState();
}

class _SavingsMoveScreenState extends ConsumerState<SavingsMoveScreen> {
  late String _mode = widget.mode;
  String _amount = '';

  void _save() {
    final amount = parseAmount(_amount);
    if (amount == null) return toast(context, S.badAmount);
    final repo = ref.read(repoProvider)!;
    if (_mode == 'goal') {
      repo.setProfile({'savingsGoal': amount});
      context.pop();
      return;
    }
    if (_mode == 'take' && amount > ref.read(savingsBalanceProvider) + 0.001) {
      return toast(context, S.notEnough);
    }
    repo.addMove(SavingMove(id: '', type: _mode == 'take' ? MoveType.take : MoveType.put, amount: amount, date: DateTime.now()));
    toast(context, _mode == 'take' ? S.toastTake(dh(amount)) : S.toastPut(dh(amount)));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final balance = ref.watch(savingsBalanceProvider);
    final amount = parseAmount(_amount);
    final caps = switch (_mode) { 'take' => S.howMuchTake, 'goal' => S.goalCaps, _ => S.howMuchPut };
    final chips = _mode == 'goal' ? const [5000, 10000, 20000, 50000] : const [100, 200, 500, 1000];
    final btn = switch (_mode) {
      'goal' => S.save,
      'take' => amount == null ? S.take : S.takeBtn(dh(amount)),
      _ => amount == null ? S.put : S.saveBtn(dh(amount)),
    };

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              const BackBox(),
              Expanded(child: Text(S.savings, textAlign: TextAlign.center, style: display(18))),
              const SizedBox(width: 46),
            ]),
            const SizedBox(height: 16),
            Segmented<String>(
              items: const {'put': S.put, 'take': S.take, 'goal': S.goal},
              value: _mode,
              onChanged: (v) => setState(() => (_mode = v, _amount = '')),
            ),
            const SizedBox(height: 14),
            Card2(
              radius: 24,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              child: Column(children: [
                Text(caps, style: capsLabel(c.muted)),
                AmountDisplay(_amount),
                const SizedBox(height: 10),
                QuickChips(values: chips, selected: _amount, onPick: (v) => setState(() => _amount = '$v')),
                const SizedBox(height: 10),
                Text('Sold daba: ${dh(balance)}', style: TextStyle(fontSize: 12, color: c.muted)),
              ]),
            ),
            if (_mode != 'goal') ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: c.goldSoft, borderRadius: BorderRadius.circular(16)),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Ic(I.info_outline_rounded, size: 18, color: c.goldInk),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _mode == 'put' ? '"Li b9a lik" ghadi ynqs b had l mablagh. Had l flous ma kayt7sbouch masarif.' : '"Li b9a lik" ghadi yzid b had l mablagh.',
                      style: TextStyle(fontSize: 13, height: 1.45, color: c.text),
                    ),
                  ),
                ]),
              ),
            ],
            Expanded(child: Center(child: NumPad(onKey: (k) => setState(() => _amount = applyKey(_amount, k))))),
            FilledButton(onPressed: _save, child: Text(btn)),
          ]),
        ),
      ),
    );
  }
}
