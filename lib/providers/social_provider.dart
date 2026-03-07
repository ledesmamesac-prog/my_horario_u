import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/materia.dart';
import '../models/horario.dart';

class SocialProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> _amigos = [];
  List<Map<String, dynamic>> get amigos => _amigos;

  String? get _userId => _auth.currentUser?.uid;

  Future<void> loadAmigos() async {
    if (_userId == null) return;

    final snap = await _db.collection('users').doc(_userId).collection('friends').get();
    _amigos = [];
    
    for (var doc in snap.docs) {
      final friendData = await _db.collection('users').doc(doc.id).get();
      if (friendData.exists) {
        _amigos.add({
          'uid': doc.id,
          'nombre': friendData.data()?['nombre'] ?? 'Usuario',
          'email': friendData.data()?['email'] ?? '',
          'fotoUrl': friendData.data()?['fotoUrl'],
        });
      }
    }
    notifyListeners();
  }

  Future<void> addAmigo(String friendUid) async {
    if (_userId == null || friendUid == _userId) return;

    final friendDoc = await _db.collection('users').doc(friendUid).get();
    if (!friendDoc.exists) throw Exception('Usuario no encontrado');

    await _db.collection('users').doc(_userId).collection('friends').doc(friendUid).set({
      'addedAt': FieldValue.serverTimestamp(),
    });

    await loadAmigos();
  }

  Future<Map<String, dynamic>> getFriendSchedule(String friendUid) async {
    final materiasSnap = await _db.collection('users').doc(friendUid).collection('materias').get();
    final horariosSnap = await _db.collection('users').doc(friendUid).collection('horarios').get();

    final materias = materiasSnap.docs.map((d) => Materia.fromMap(d.data())).toList();
    final horarios = horariosSnap.docs.map((d) => Horario.fromMap(d.data())).toList();

    return {
      'materias': materias,
      'horarios': horarios,
    };
  }

  Future<void> removeAmigo(String friendUid) async {
    if (_userId == null) return;

    await _db
        .collection('users')
        .doc(_userId)
        .collection('friends')
        .doc(friendUid)
        .delete();

    await loadAmigos();
  }
}
