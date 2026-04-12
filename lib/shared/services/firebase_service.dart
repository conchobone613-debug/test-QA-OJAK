import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirebaseServiceException implements Exception {
  final String code;
  final String message;
  const FirebaseServiceException({required this.code, required this.message});

  @override
  String toString() => 'FirebaseServiceException($code): $message';
}

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(region: 'asia-northeast3');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ─── Firestore ───

  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument(String path) async {
    try {
      return await _firestore.doc(path).get();
    } on FirebaseException catch (e) {
      throw FirebaseServiceException(code: e.code, message: e.message ?? 'Firestore get error');
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getCollection(
    String path, {
    List<List<dynamic>> where = const [],
    String? orderBy,
    bool descending = false,
    int? limit,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection(path);
      for (final w in where) {
        query = query.where(w[0] as String, isEqualTo: w.length > 1 ? w[1] : null);
      }
      if (orderBy != null) query = query.orderBy(orderBy, descending: descending);
      if (startAfter != null) query = query.startAfterDocument(startAfter);
      if (limit != null) query = query.limit(limit);
      return await query.get();
    } on FirebaseException catch (e) {
      throw FirebaseServiceException(code: e.code, message: e.message ?? 'Firestore query error');
    }
  }

  Future<void> setDocument(String path, Map<String, dynamic> data, {bool merge = true}) async {
    try {
      await _firestore.doc(path).set(data, SetOptions(merge: merge));
    } on FirebaseException catch (e) {
      throw FirebaseServiceException(code: e.code, message: e.message ?? 'Firestore set error');
    }
  }

  Future<void> updateDocument(String path, Map<String, dynamic> data) async {
    try {
      await _firestore.doc(path).update(data);
    } on FirebaseException catch (e) {
      throw FirebaseServiceException(code: e.code, message: e.message ?? 'Firestore update error');
    }
  }

  Future<void> deleteDocument(String path) async {
    try {
      await _firestore.doc(path).delete();
    } on FirebaseException catch (e) {
      throw FirebaseServiceException(code: e.code, message: e.message ?? 'Firestore delete error');
    }
  }

  Future<DocumentReference<Map<String, dynamic>>> addDocument(
      String collectionPath, Map<String, dynamic> data) async {
    try {
      return await _firestore.collection(collectionPath).add(data);
    } on FirebaseException catch (e) {
      throw FirebaseServiceException(code: e.code, message: e.message ?? 'Firestore add error');
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> documentStream(String path) {
    return _firestore.doc(path).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> collectionStream(
    String path, {
    String? orderBy,
    bool descending = false,
    int? limit,
  }) {
    Query<Map<String, dynamic>> query = _firestore.collection(path);
    if (orderBy != null) query = query.orderBy(orderBy, descending: descending);
    if (limit != null) query = query.limit(limit);
    return query.snapshots();
  }

  Future<void> runTransaction(Future<void> Function(Transaction tx) handler) async {
    try {
      await _firestore.runTransaction(handler);
    } on FirebaseException catch (e) {
      throw FirebaseServiceException(code: e.code, message: e.message ?? 'Transaction error');
    }
  }

  WriteBatch batch() => _firestore.batch();

  Future<void> commitBatch(WriteBatch batch) async {
    try {
      await batch.commit();
    } on FirebaseException catch (e) {
      throw FirebaseServiceException(code: e.code, message: e.message ?? 'Batch commit error');
    }
  }

  // ─── Storage ───

  Future<String> uploadFile(String storagePath, File file, {String? contentType}) async {
    try {
      final metadata = contentType != null ? SettableMetadata(contentType: contentType) : null;
      final task = _storage.ref(storagePath).putFile(file, metadata);
      final snapshot = await task;
      return await snapshot.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw FirebaseServiceException(code: e.code, message: e.message ?? 'Storage upload error');
    }
  }

  Future<String> uploadBytes(String storagePath, Uint8List bytes, {String? contentType}) async {
    try {
      final metadata = contentType != null ? SettableMetadata(contentType: contentType) : null;
      final task = _storage.ref(storagePath).putData(bytes, metadata);
      final snapshot = await task;
      return await snapshot.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw FirebaseServiceException(code: e.code, message: e.message ?? 'Storage uploadBytes error');
    }
  }

  Future<void> deleteFile(String storagePath) async {
    try {
      await _storage.ref(storagePath).delete();
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') return;
      throw FirebaseServiceException(code: e.code, message: e.message ?? 'Storage delete error');
    }
  }

  // ─── Cloud Functions ───

  Future<Map<String, dynamic>> callFunction(String name, Map<String, dynamic> data) async {
    try {
      final callable = _functions.httpsCallable(name);
      final result = await callable.call(data);
      return Map<String, dynamic>.from(result.data as Map);
    } on FirebaseFunctionsException catch (e) {
      throw FirebaseServiceException(code: e.code, message: e.message ?? 'Functions call error');
    }
  }

  // ─── Auth helpers ───

  String? get currentUserId => _auth.currentUser?.uid;

  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw FirebaseServiceException(code: e.code, message: e.message ?? 'Auth delete error');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw FirebaseServiceException(code: e.code, message: e.message ?? 'Sign out error');
    }
  }
}