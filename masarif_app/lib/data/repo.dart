import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/format.dart';
import 'models.dart';

class Repo {
  Repo(this.uid);
  final String uid;

  final _db = FirebaseFirestore.instance;
  DocumentReference<Map<String, dynamic>> get userDoc => _db.collection('users').doc(uid);
  CollectionReference<Map<String, dynamic>> get txCol => userDoc.collection('transactions');
  CollectionReference<Map<String, dynamic>> get catCol => userDoc.collection('categories');
  CollectionReference<Map<String, dynamic>> get moveCol => userDoc.collection('epargne');

  // Mo3amalat
  Future<String> addTx(Txn t) async {
    final ref = txCol.doc();
    await ref.set({...t.toMap(), 'createdAt': FieldValue.serverTimestamp()});
    return ref.id;
  }

  Future<void> updateTx(Txn t) => txCol.doc(t.id).update(t.toMap());
  Future<void> setDeleted(String id, bool v) =>
      txCol.doc(id).update({'deleted': v, 'updatedAt': FieldValue.serverTimestamp()});

  // Categories
  Future<void> saveCat(Cat c) => (c.id.isEmpty ? catCol.doc() : catCol.doc(c.id)).set(c.toMap());

  /// Msse7 categorie dyal l user: l mo3amalat dyalha kaymchiw l "Okhra".
  Future<void> deleteCat(Cat c) async {
    final fallback = c.type == TxType.income ? 'other_inc' : 'other_exp';
    final txs = await txCol.where('categoryId', isEqualTo: c.id).get();
    final batch = _db.batch();
    for (final d in txs.docs) {
      batch.update(d.reference, {'categoryId': fallback, 'updatedAt': FieldValue.serverTimestamp()});
    }
    batch.delete(catCol.doc(c.id));
    await batch.commit();
  }

  Future<void> setCatHidden(String id, bool hidden) => userDoc.set({
        'hiddenCats': hidden ? FieldValue.arrayUnion([id]) : FieldValue.arrayRemove([id]),
      }, SetOptions(merge: true));

  // Profil
  Future<void> setProfile(Map<String, dynamic> data) => userDoc.set(data, SetOptions(merge: true));

  // Dwayr zman
  Future<void> addMove(SavingMove m) => moveCol.doc().set(m.toMap());

  /// Kaymse7 ga3 data dyal l user f Firestore (9bel ma ytmsa7 l compte).
  Future<void> deleteAllData() async {
    for (final col in [txCol, catCol, moveCol]) {
      final docs = await col.get();
      for (var i = 0; i < docs.docs.length; i += 400) {
        final batch = _db.batch();
        for (final d in docs.docs.skip(i).take(400)) {
          batch.delete(d.reference);
        }
        await batch.commit();
      }
    }
    await userDoc.delete();
  }
}

final authProvider = StreamProvider<User?>((ref) => FirebaseAuth.instance.authStateChanges());

final repoProvider = Provider<Repo?>((ref) {
  final u = ref.watch(authProvider).value;
  return u == null ? null : Repo(u.uid);
});

final profileProvider = StreamProvider<UserProfile>((ref) {
  final r = ref.watch(repoProvider);
  if (r == null) return Stream.value(UserProfile());
  return r.userDoc.snapshots().map((s) => UserProfile.fromMap(s.data()));
});

final txProvider = StreamProvider<List<Txn>>((ref) {
  final r = ref.watch(repoProvider);
  if (r == null) return Stream.value(const []);
  return r.txCol
      .orderBy('date', descending: true)
      .snapshots()
      .map((s) => s.docs.map(Txn.fromDoc).where((t) => !t.deleted).toList());
});

/// true = kayn chi 7aja mazal ma tsynchronizatch (offline wla f triq).
final pendingSyncProvider = StreamProvider<bool>((ref) {
  final r = ref.watch(repoProvider);
  if (r == null) return Stream.value(false);
  return r.txCol
      .limit(1)
      .snapshots(includeMetadataChanges: true)
      .map((s) => s.metadata.hasPendingWrites || s.metadata.isFromCache);
});

final userCatsProvider = StreamProvider<List<Cat>>((ref) {
  final r = ref.watch(repoProvider);
  if (r == null) return Stream.value(const []);
  return r.catCol.snapshots().map((s) => s.docs.map(Cat.fromDoc).toList());
});

/// Ga3 l categories (jahza + dyal l user).
final allCatsProvider = Provider<List<Cat>>((ref) {
  final mine = ref.watch(userCatsProvider).value ?? const [];
  return [...defaultCats, ...mine];
});

/// Categories li kayban f grille dyal P6 (bla li mkhbyin).
final visibleCatsProvider = Provider<List<Cat>>((ref) {
  final hidden = ref.watch(profileProvider).value?.hiddenCats ?? const [];
  return ref.watch(allCatsProvider).where((c) => !hidden.contains(c.id)).toList();
});

Cat catById(List<Cat> all, String id) =>
    all.firstWhere((c) => c.id == id, orElse: () => defaultCats.firstWhere((c) => c.id == 'other_exp'));

final movesProvider = StreamProvider<List<SavingMove>>((ref) {
  final r = ref.watch(repoProvider);
  if (r == null) return Stream.value(const []);
  return r.moveCol.orderBy('date', descending: true).snapshots().map((s) => s.docs.map(SavingMove.fromDoc).toList());
});

final savingsBalanceProvider = Provider<double>((ref) {
  final moves = ref.watch(movesProvider).value ?? const [];
  return moves.fold(0.0, (a, m) => a + m.signed);
});

class MonthSummary {
  MonthSummary(this.income, this.expense, this.put, this.take);
  final double income, expense, put, take;

  /// PDR F7: Li b9a = dakhl − masarif − li tkhba + li tjbed.
  /// (L flous li tkhbaw mn "li shat" dyal chher l fat ma kayt7sbouch hna.)
  double get left => income - expense - put + take;
}

MonthSummary summarize(List<Txn> txs, List<SavingMove> moves, DateTime month) {
  final key = monthKey(month);
  double inc = 0, exp = 0, put = 0, take = 0;
  for (final t in txs) {
    if (monthKey(t.date) != key) continue;
    t.type == TxType.income ? inc += t.amount : exp += t.amount;
  }
  for (final m in moves) {
    if (m.source == 'month_left' || monthKey(m.date) != key) continue;
    m.type == MoveType.put ? put += m.amount : take += m.amount;
  }
  return MonthSummary(inc, exp, put, take);
}
