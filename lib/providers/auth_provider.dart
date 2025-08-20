import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? _user;
  UserModel? _userModel;
  bool _isLoading = false;

  User? get user => _user;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
    _configureAuthPersistence();
  }

  void _configureAuthPersistence() async {
    try {
      // Set persistence to SESSION so auth state only persists for the current session
      await _auth.setPersistence(Persistence.SESSION);
    } catch (e) {
      debugPrint('Error configuring auth persistence: $e');
    }
  }

  void _onAuthStateChanged(User? user) async {
    _user = user;
    if (user != null) {
      await _loadUserModel();
    } else {
      _userModel = null;
    }
    notifyListeners();
  }

  Future<void> _loadUserModel() async {
    if (_user == null) return;
    
    try {
      final doc = await _firestore.collection('users').doc(_user!.uid).get();
      if (doc.exists) {
        _userModel = UserModel.fromMap(doc.data()!);
      }
    } catch (e) {
      debugPrint('Error loading user model: $e');
    }
  }

  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userModel = UserModel(
        id: credential.user!.uid,
        email: email,
        name: name,
        phone: phone,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(userModel.toMap());

      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'An error occurred during sign up';
    } catch (e) {
      return 'An unexpected error occurred';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'An error occurred during sign in';
    } catch (e) {
      return 'An unexpected error occurred';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<String?> updateUserProfile({
    required String name,
    String? phone,
    File? profileImage,
  }) async {
    try {
      if (_user == null) return 'User not authenticated';

      final userRef = _firestore.collection('users').doc(_user!.uid);
      
      final updateData = {
        'name': name,
        'phone': phone,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };

      await userRef.update(updateData);
      
      // Reload user model to reflect changes
      await _loadUserModel();
      
      // Ensure listeners are notified
      notifyListeners();
      
      return null; // Success
    } on FirebaseException catch (e) {
      return e.message ?? 'Failed to update profile';
    } catch (e) {
      return 'An unexpected error occurred';
    }
  }
}
