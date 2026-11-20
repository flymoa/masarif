import 'package:firebase_auth/firebase_auth.dart';
import 'package:masarif/widgets/icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/strings.dart';
import '../utils/format.dart';
import 'models.dart';
import 'repo.dart';

enum NotifKind { savings, warning, email, goal }

class AppNotif {
  AppNotif(this.kind, this.title, this.body, this.date, {this.route});
  final NotifKind kind;
  final String title, body;
  final DateTime date;
  final String? route;
}

/// Tanbihat kaytbnaw mn data (bla collection jdida f Firestore).
final notifsProvider = Provider<List<AppNotif>>((ref) {
  final moves = ref.watch(movesProvider).value ?? const <SavingMove>[];
  final txs = ref.watch(txProvider).value ?? const <Txn>[];
  final p = ref.watch(profileProvider).value;
  final balance = ref.watch(savingsBalanceProvider);
  final user = FirebaseAuth.instance.currentUser;
  final out = <AppNotif>[];

  for (final m in moves.where((m) => m.source == 'month_left' && m.month != null)) {
    final month = monthNames[int.parse(m.month!.substring(5)) - 1];
    out.add(AppNotif(NotifKind.savings, 'Shat lik ${dh(m.amount)} f $month', 'Tkhbaw f ${S.savings}.', m.date, route: '/savings'));
  }

  final now = DateTime.now();
  final sum = summarize(txs, moves, now);
  if (sum.left < 0) {
    out.add(AppNotif(NotifKind.warning, S.negative(dh(-sum.left)), 'Chouf fin mchaw l flous had chher.', DateTime(now.year, now.month, now.day), route: '/stats'));
  }

  if (user != null && !user.emailVerified) {
    out.add(AppNotif(NotifKind.email, 'Akked l email dyalk', 'Siftna lik lien f ${user.email}.', user.metadata.creationTime ?? now));
  }

  final goal = p?.goal;
  if (goal != null && goal > 0 && moves.isNotEmpty) {
    final last = moves.first.date;
    if (balance >= goal) {
      out.add(AppNotif(NotifKind.goal, 'Wslti l hadaf dyalk!', '${dh(balance)} f ${S.savings}.', last, route: '/savings'));
    } else if (balance >= goal / 2) {
      out.add(AppNotif(NotifKind.goal, 'Wslti 50% mn l hadaf', '${dh(balance)} mn ${dh(goal)}. Kmel hakka!', last, route: '/savings'));
    }
  }

  out.sort((a, b) => b.date.compareTo(a.date));
  return out;
});

final unreadNotifsProvider = Provider<int>((ref) {
  final read = ref.watch(profileProvider).value?.notifsReadAt;
  return ref.watch(notifsProvider).where((n) => read == null || n.date.isAfter(read)).length;
});

String notifIc(NotifKind k) => switch (k) {
      NotifKind.savings => I.savings_outlined,
      NotifKind.warning => I.warning_amber_rounded,
      NotifKind.email => I.mail_outline_rounded,
      NotifKind.goal => I.track_changes_rounded,
    };
