import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// The signed-in user's Firestore data: everything lives under
/// `users/{uid}`, so each account only ever sees its own.
class UserData {
  UserData({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirebaseFirestore get firestore => _firestore;

  /// `users/{uid}`. Throws if nobody is signed in.
  DocumentReference<Map<String, dynamic>> get doc {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('No user is signed in');
    return _firestore.collection('users').doc(uid);
  }

  /// Emits when the data picked by [select] changes, or when another user
  /// signs in (their data is different too). Follows whoever is signed in.
  Stream<void> changes(
    Stream<Object?> Function(DocumentReference<Map<String, dynamic>> user)
    select,
  ) => Stream.multi((listener) {
    StreamSubscription<Object?>? data;
    // authStateChanges starts with the current user; later values are
    // sign-ins and sign-outs.
    var initial = true;
    final auth = _auth.authStateChanges().listen((user) {
      data?.cancel();
      data = null;
      final signedInLater = !initial;
      initial = false;
      if (user == null) return;
      if (signedInLater) listener.add(null);
      final userDoc = _firestore.collection('users').doc(user.uid);
      // The first snapshot is what's already there, not a change.
      data = select(userDoc).skip(1).listen((_) => listener.add(null));
    });
    listener.onCancel = () async {
      await data?.cancel();
      await auth.cancel();
    };
  });
}
