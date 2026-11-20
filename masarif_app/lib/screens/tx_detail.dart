import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/models.dart';
import '../data/repo.dart';
import '../l10n/strings.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import 'transactions.dart';

class TxDetailScreen extends ConsumerWidget {
  const TxDetailScreen({super.key, required this.txId});
  final String txId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final t = (ref.watch(txProvider).value ?? const <Txn>[]).where((x) => x.id == txId).firstOrNull;
    if (t == null) {
      return const Scaffold(body: SafeArea(child: TopBar(S.details)));
    }
    final cat = catById(ref.watch(allCatsProvider), t.categoryId);
    final title = t.note.isNotEmpty ? t.note : cat.name;

    Widget row(String k, String v, {bool last = false}) => Container(
          constraints: const BoxConstraints(minHeight: 52),
          decoration: BoxDecoration(border: last ? null : Border(bottom: BorderSide(color: c.divider))),
          child: Row(children: [
            Text(k, style: TextStyle(fontSize: 14, color: c.muted)),
            const SizedBox(width: 16),
            Expanded(child: Text(v, textAlign: TextAlign.right, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
          ]),
        );

    return Scaffold(
      backgroundColor: c.brand,
      body: Column(children: [
        SafeArea(
          bottom: false,
          child: Column(children: [
            const TopBar(S.details, onDark: true),
            const SizedBox(height: 24),
            CatIcon(cat, size: 72),
            const SizedBox(height: 12),
            Text(title, style: display(18, color: Colors.white)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
              child: Text(cat.name, style: const TextStyle(fontSize: 12, color: Color(0xFFDCEBE1))),
            ),
            const SizedBox(height: 14),
            Text.rich(TextSpan(children: [
              TextSpan(
                text: '${t.type == TxType.income ? '+' : '−'}${dh(t.amount).replaceAll(' DH', '')} ',
                style: display(40, color: Colors.white).copyWith(letterSpacing: -1.4),
              ),
              TextSpan(text: 'DH', style: display(20, color: AppColors.onBrandMuted)),
            ])),
            const SizedBox(height: 6),
            Text('${fullDate(t.date)} · ${hhmm(t.date)}', style: const TextStyle(fontSize: 13, color: AppColors.onBrandMuted)),
            const SizedBox(height: 28),
          ]),
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            decoration: BoxDecoration(color: c.bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(30))),
            child: SafeArea(
              top: false,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Card2(
                  child: Column(children: [
                    row(S.type, t.type == TxType.income ? S.income : S.expense),
                    row(S.category, cat.name),
                    row(S.date, fullDate(t.date)),
                    row(S.note, t.note.isEmpty ? '—' : t.note, last: true),
                  ]),
                ),
                const SizedBox(height: 12),
                const Padding(padding: EdgeInsets.only(left: 4), child: SyncPill()),
                const Spacer(),
                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final ok = await deleteWithUndo(context, ref, t);
                        if (ok && context.mounted) context.pop();
                      },
                      child: const Text(S.delete),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(flex: 2, child: FilledButton(onPressed: () => context.push('/tx/${t.id}/edit'), child: const Text(S.edit))),
                ]),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}
