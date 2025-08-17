class TourPlanModel {
  final String id;
  final String district;
  final String title;
  final String description;
  final int duration; // in days
  final List<DayPlan> dayPlans;
  final DateTime createdAt;
  final bool isActive;

  TourPlanModel({
    required this.id,
    required this.district,
    required this.title,
    required this.description,
    required this.duration,
    required this.dayPlans,
    required this.createdAt,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'district': district,
      'title': title,
      'description': description,
      'duration': duration,
      'dayPlans': dayPlans.map((e) => e.toMap()).toList(),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isActive': isActive,
    };
  }

  factory TourPlanModel.fromMap(Map<String, dynamic> map) {
    return TourPlanModel(
      id: map['id'] ?? '',
      district: map['district'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      duration: map['duration'] ?? 1,
      dayPlans: List<DayPlan>.from(
        map['dayPlans']?.map((x) => DayPlan.fromMap(x)) ?? [],
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      isActive: map['isActive'] ?? true,
    );
  }
}

class DayPlan {
  final int dayNumber;
  final String title;
  final List<TourStop> stops;
  final String? notes;

  DayPlan({
    required this.dayNumber,
    required this.title,
    required this.stops,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'dayNumber': dayNumber,
      'title': title,
      'stops': stops.map((e) => e.toMap()).toList(),
      'notes': notes,
    };
  }

  factory DayPlan.fromMap(Map<String, dynamic> map) {
    return DayPlan(
      dayNumber: map['dayNumber'] ?? 1,
      title: map['title'] ?? '',
      stops: List<TourStop>.from(
        map['stops']?.map((x) => TourStop.fromMap(x)) ?? [],
      ),
      notes: map['notes'],
    );
  }
}

class TourStop {
  final String locationId;
  final String locationName;
  final String startTime;
  final String endTime;
  final int order;
  final String? notes;

  TourStop({
    required this.locationId,
    required this.locationName,
    required this.startTime,
    required this.endTime,
    required this.order,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'locationId': locationId,
      'locationName': locationName,
      'startTime': startTime,
      'endTime': endTime,
      'order': order,
      'notes': notes,
    };
  }

  factory TourStop.fromMap(Map<String, dynamic> map) {
    return TourStop(
      locationId: map['locationId'] ?? '',
      locationName: map['locationName'] ?? '',
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      order: map['order'] ?? 0,
      notes: map['notes'],
    );
  }
}
