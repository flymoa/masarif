import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:masarif/widgets/icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/notifs.dart';
import '../data/repo.dart';
import '../l10n/strings.dart';
import '../theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';

class NotifsScreen extends ConsumerWidget {
  const NotifsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.c;
    final all = ref.watch(notifsProvider);
    final read = ref.watch(profileProvider).value?.notifsReadAt;
    bool isNew(AppNotif n) => read == null || n.date.isAfter(read);
    final fresh = all.where(isNew).toList();
    final old = all.where((n) => !isNew(n)).toList();

    Widget item(AppNotif n, bool unread) {
      final (bg, fg) = switch (n.kind) {
        NotifKind.savings => (AppColors.deepGreen, AppColors.gold),
        NotifKind.warning => (context.isDark ? const Color(0xFF3A2518) : const Color(0xFFF5E6DE), context.isDark ? const Color(0xFFF0A070) : const Color(0xFFA0471F)),
        NotifKind.email => (c.chipActive, c.brandFg),
        NotifKind.goal => (c.goldSoft, c.goldInk),
      };
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Opacity(
          opacity: unread ? 1 : 0.8,
          child: Material(
            color: c.surface,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: n.route == null ? null : () => context.push(n.route!),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(width: 44, height: 44, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)), child: Ic(notifIc(n.kind), color: fg, size: 21)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(n.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 3),
                      Text(n.body, style: TextStyle(fontSize: 13, color: c.muted, height: 1.4)),
                      const SizedBox(height: 3),
                      Text('${dayLabel(n.date)} · ${hhmm(n.date)}', style: TextStyle(fontSize: 11, color: c.navMuted)),
                    ]),
                  ),
                  if (unread) Container(margin: const EdgeInsets.only(top: 6), width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle)),
                ]),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Row(children: [
                const BackBox(),
                const SizedBox(width: 12),
                Expanded(child: Text(S.notifications, style: display(18))),
                if (fresh.isNotEmpty)
                  TextButton(
                    onPressed: () => ref.read(repoProvider)?.setProfile({'notifsReadAt': Timestamp.now()}),
                    child: const Text(S.markAllRead),
                  ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                if (all.isEmpty) Padding(padding: const EdgeInsets.all(24), child: Text(S.noNotifs, textAlign: TextAlign.center, style: TextStyle(color: c.muted))),
                if (fresh.isNotEmpty) ...[const CapsTitle(S.newNotifs), for (final n in fresh) item(n, true)],
                if (old.isNotEmpty) ...[const SizedBox(height: 10), const CapsTitle(S.oldNotifs), for (final n in old) item(n, false)],
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
