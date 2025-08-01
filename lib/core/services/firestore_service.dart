import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../error/exceptions.dart';

/// Service để quản lý các operations với Firestore
class FirestoreService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirestoreService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Lấy user ID hiện tại
  String get currentUserId {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthException('User not authenticated');
    }
    return user.uid;
  }

  /// Lấy collection reference cho user hiện tại
  CollectionReference getUserCollection(String collectionName) {
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection(collectionName);
  }

  /// Tạo document mới với auto-generated ID
  Future<String> createDocument(
    String collectionName,
    Map<String, dynamic> data,
  ) async {
    try {
      final docRef = getUserCollection(collectionName).doc();
      final documentData = {
        ...data,
        'id': docRef.id,
        'userId': currentUserId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      await docRef.set(documentData);
      return docRef.id;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to create document');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  /// Cập nhật document
  Future<void> updateDocument(
    String collectionName,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    try {
      final updateData = {
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      await getUserCollection(collectionName)
          .doc(documentId)
          .update(updateData);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to update document');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  /// Xóa document
  Future<void> deleteDocument(
    String collectionName,
    String documentId,
  ) async {
    try {
      await getUserCollection(collectionName).doc(documentId).delete();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to delete document');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  /// Lấy document theo ID
  Future<DocumentSnapshot> getDocument(
    String collectionName,
    String documentId,
  ) async {
    try {
      return await getUserCollection(collectionName).doc(documentId).get();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get document');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  /// Lấy tất cả documents trong collection
  Future<QuerySnapshot> getCollection(String collectionName) async {
    try {
      return await getUserCollection(collectionName).get();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get collection');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  /// Lấy documents với query
  Future<QuerySnapshot> getDocumentsWhere(
    String collectionName, {
    String? field,
    dynamic isEqualTo,
    dynamic isNotEqualTo,
    dynamic isLessThan,
    dynamic isLessThanOrEqualTo,
    dynamic isGreaterThan,
    dynamic isGreaterThanOrEqualTo,
    dynamic arrayContains,
    List<dynamic>? arrayContainsAny,
    List<dynamic>? whereIn,
    List<dynamic>? whereNotIn,
    bool? isNull,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    try {
      Query query = getUserCollection(collectionName);

      if (field != null) {
        if (isEqualTo != null) {
          query = query.where(field, isEqualTo: isEqualTo);
        }
        if (isNotEqualTo != null) {
          query = query.where(field, isNotEqualTo: isNotEqualTo);
        }
        if (isLessThan != null) {
          query = query.where(field, isLessThan: isLessThan);
        }
        if (isLessThanOrEqualTo != null) {
          query = query.where(field, isLessThanOrEqualTo: isLessThanOrEqualTo);
        }
        if (isGreaterThan != null) {
          query = query.where(field, isGreaterThan: isGreaterThan);
        }
        if (isGreaterThanOrEqualTo != null) {
          query = query.where(field, isGreaterThanOrEqualTo: isGreaterThanOrEqualTo);
        }
        if (arrayContains != null) {
          query = query.where(field, arrayContains: arrayContains);
        }
        if (arrayContainsAny != null) {
          query = query.where(field, arrayContainsAny: arrayContainsAny);
        }
        if (whereIn != null) {
          query = query.where(field, whereIn: whereIn);
        }
        if (whereNotIn != null) {
          query = query.where(field, whereNotIn: whereNotIn);
        }
        if (isNull != null) {
          query = query.where(field, isNull: isNull);
        }
      }

      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      return await query.get();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to query documents');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  /// Stream để lắng nghe thay đổi của collection
  Stream<QuerySnapshot> getCollectionStream(String collectionName) {
    try {
      return getUserCollection(collectionName).snapshots();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get collection stream');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  /// Stream để lắng nghe thay đổi của document
  Stream<DocumentSnapshot> getDocumentStream(
    String collectionName,
    String documentId,
  ) {
    try {
      return getUserCollection(collectionName).doc(documentId).snapshots();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get document stream');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  /// Batch write operations
  Future<void> batchWrite(List<BatchOperation> operations) async {
    try {
      final batch = _firestore.batch();

      for (final operation in operations) {
        final docRef = getUserCollection(operation.collectionName)
            .doc(operation.documentId);

        switch (operation.type) {
          case BatchOperationType.create:
            final data = {
              ...operation.data!,
              'id': operation.documentId,
              'userId': currentUserId,
              'createdAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            };
            batch.set(docRef, data);
            break;
          case BatchOperationType.update:
            final data = {
              ...operation.data!,
              'updatedAt': FieldValue.serverTimestamp(),
            };
            batch.update(docRef, data);
            break;
          case BatchOperationType.delete:
            batch.delete(docRef);
            break;
        }
      }

      await batch.commit();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to execute batch operation');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  /// Setup offline persistence
  static Future<void> enableOfflinePersistence() async {
    try {
      await FirebaseFirestore.instance.enablePersistence();
    } on FirebaseException catch (e) {
      // Persistence có thể đã được enable hoặc không support
      print('Firestore persistence error: ${e.message}');
    }
  }
}

/// Class để định nghĩa batch operations
class BatchOperation {
  final String collectionName;
  final String documentId;
  final BatchOperationType type;
  final Map<String, dynamic>? data;

  const BatchOperation({
    required this.collectionName,
    required this.documentId,
    required this.type,
    this.data,
  });
}

enum BatchOperationType {
  create,
  update,
  delete,
}