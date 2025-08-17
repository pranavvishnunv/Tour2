import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import '../models/location_model.dart';

class LocationProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  List<LocationModel> _locations = [];
  bool _isLoading = false;

  List<LocationModel> get locations => _locations;
  bool get isLoading => _isLoading;

  Future<void> loadLocationsByDistrict(String district) async {
    _isLoading = true;
    notifyListeners();

    try {
      final query = await _firestore
          .collection('locations')
          .where('district', isEqualTo: district)
          .where('isApproved', isEqualTo: true)
          .get();

      _locations = query.docs
          .map((doc) => LocationModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error loading locations: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> addLocation({
    required LocationModel location,
    List<File>? imageFiles,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      List<String> imageUrls = [];

      // Upload images if provided
      if (imageFiles != null && imageFiles.isNotEmpty) {
        for (int i = 0; i < imageFiles.length; i++) {
          final ref = _storage
              .ref()
              .child('locations')
              .child(location.id)
              .child('image_$i.jpg');
          
          await ref.putFile(imageFiles[i]);
          final url = await ref.getDownloadURL();
          imageUrls.add(url);
        }
      }

      final locationWithImages = LocationModel(
        id: location.id,
        name: location.name,
        description: location.description,
        district: location.district,
        latitude: location.latitude,
        longitude: location.longitude,
        type: location.type,
        addedBy: location.addedBy,
        createdAt: location.createdAt,
        images: imageUrls,
        contactInfo: location.contactInfo,
        additionalInfo: location.additionalInfo,
      );

      await _firestore
          .collection('locations')
          .doc(location.id)
          .set(locationWithImages.toMap());

      return null; // Success
    } catch (e) {
      debugPrint('Error adding location: $e');
      return 'Failed to add location';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<LocationModel> getLocationsByType(LocationType type) {
    return _locations.where((location) => location.type == type).toList();
  }
}