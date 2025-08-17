import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/tour_plan_model.dart';

class TourProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<TourPlanModel> _tourPlans = [];
  bool _isLoading = false;

  List<TourPlanModel> get tourPlans => _tourPlans;
  bool get isLoading => _isLoading;

  Future<void> loadTourPlansByDistrict(String district) async {
    _isLoading = true;
    notifyListeners();

    try {
      final query = await _firestore
          .collection('tourPlans')
          .where('district', isEqualTo: district)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      _tourPlans = query.docs
          .map((doc) => TourPlanModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error loading tour plans: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  TourPlanModel? getTourPlanById(String tourId) {
    try {
      return _tourPlans.firstWhere((plan) => plan.id == tourId);
    } catch (e) {
      return null;
    }
  }
}
