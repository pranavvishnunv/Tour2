import 'dart:math' as math;
import '../models/location_model.dart';
import '../models/tour_plan_model.dart';

class TourPlanGenerator {
  // Constants for time calculations
  static const int maxDailyTravelHours = 6; // Maximum travel time per day
  static const int locationVisitDuration = 60; // 1 hour visit duration in minutes
  static const int dayStartTime = 9; // 9 AM
  static const int dayEndTime = 18; // 6 PM
  static const double avgSpeedKmh = 40.0; // Average travel speed in km/h

  static List<TourPlanModel> generateTourPlansFromLocations(
    List<LocationModel> locations,
    String district,
    int duration,
  ) {
    if (locations.isEmpty) return [];

    final plans = <TourPlanModel>[];

    // Generate 2-3 different tour plans using different algorithms
    for (int i = 0; i < math.min(3, locations.length >= duration ? 3 : 1); i++) {
      late List<DayPlan> dayPlans;
      
      switch (i) {
        case 0:
          dayPlans = _generateNearestNeighborPlan(locations, district, duration);
          break;
        case 1:
          dayPlans = _generateClusteredPlan(locations, district, duration);
          break;
        case 2:
          dayPlans = _generateRandomOptimizedPlan(locations, district, duration);
          break;
        default:
          dayPlans = _generateNearestNeighborPlan(locations, district, duration);
      }

      if (dayPlans.isNotEmpty) {
        plans.add(TourPlanModel(
          id: 'plan_${district}_${i + 1}',
          district: district,
          title: '${district} Tour Plan ${i + 1}',
          description: 'A curated ${duration}-day tour of ${district} with optimized travel routes',
          duration: duration,
          dayPlans: dayPlans,
          createdAt: DateTime.now(),
        ));
      }
    }

    return plans.isNotEmpty ? plans : [_generateFallbackPlan(locations, district, duration)];
  }

  // Nearest Neighbor Algorithm - visits closest unvisited location
  static List<DayPlan> _generateNearestNeighborPlan(
    List<LocationModel> locations,
    String district,
    int duration,
  ) {
    final dayPlans = <DayPlan>[];
    final unvisitedLocations = List<LocationModel>.from(locations);
    final random = math.Random();

    for (int day = 0; day < duration; day++) {
      if (unvisitedLocations.isEmpty) break;

      final dayStops = <TourStop>[];
      LocationModel? currentLocation = unvisitedLocations.removeAt(
        random.nextInt(unvisitedLocations.length)
      ); // Start with random location

      int currentTime = dayStartTime * 60; // Convert to minutes
      int stopOrder = 1;

      // Add first location
      if (currentLocation != null) {
        dayStops.add(_createTourStop(
          currentLocation, 
          currentTime, 
          stopOrder++
        ));
        currentTime += locationVisitDuration;
      }

      // Add more locations using nearest neighbor
      while (unvisitedLocations.isNotEmpty && currentLocation != null) {
        final nearestLocation = _findNearestLocation(currentLocation, unvisitedLocations);
        if (nearestLocation == null) break;

        final travelTime = _calculateTravelTime(currentLocation, nearestLocation);
        final totalTime = travelTime + locationVisitDuration;

        // Check if we can fit this location in the day
        if (currentTime + totalTime <= dayEndTime * 60) {
          currentTime += travelTime; // Travel time
          
          dayStops.add(_createTourStop(
            nearestLocation, 
            currentTime, 
            stopOrder++,
            travelTimeFromPrevious: travelTime,
          ));
          
          currentTime += locationVisitDuration; // Visit duration
          unvisitedLocations.remove(nearestLocation);
          currentLocation = nearestLocation;
        } else {
          break; // Can't fit more locations today
        }
      }

      if (dayStops.isNotEmpty) {
        dayPlans.add(DayPlan(
          dayNumber: day + 1,
          title: 'Day ${day + 1} - ${district} Exploration',
          stops: dayStops,
          notes: 'Optimized route visiting ${dayStops.length} locations',
        ));
      }
    }

    return dayPlans;
  }

  // Clustered approach - groups nearby locations
  static List<DayPlan> _generateClusteredPlan(
    List<LocationModel> locations,
    String district,
    int duration,
  ) {
    final clusters = _createLocationClusters(locations, duration);
    final dayPlans = <DayPlan>[];

    for (int day = 0; day < math.min(duration, clusters.length); day++) {
      final cluster = clusters[day];
      final optimizedRoute = _optimizeRouteForCluster(cluster);
      
      final dayStops = <TourStop>[];
      int currentTime = dayStartTime * 60;
      
      for (int i = 0; i < optimizedRoute.length; i++) {
        final location = optimizedRoute[i];
        int travelTime = 0;
        
        if (i > 0) {
          travelTime = _calculateTravelTime(optimizedRoute[i - 1], location);
          currentTime += travelTime;
        }
        
        if (currentTime + locationVisitDuration <= dayEndTime * 60) {
          dayStops.add(_createTourStop(
            location, 
            currentTime, 
            i + 1,
            travelTimeFromPrevious: i > 0 ? travelTime : 0,
          ));
          currentTime += locationVisitDuration;
        } else {
          break;
        }
      }

      if (dayStops.isNotEmpty) {
        dayPlans.add(DayPlan(
          dayNumber: day + 1,
          title: 'Day ${day + 1} - ${district} Regional Tour',
          stops: dayStops,
          notes: 'Clustered locations in the same area for minimal travel',
        ));
      }
    }

    return dayPlans;
  }

  // Random optimized plan
  static List<DayPlan> _generateRandomOptimizedPlan(
    List<LocationModel> locations,
    String district,
    int duration,
  ) {
    final shuffled = List<LocationModel>.from(locations)..shuffle();
    return _generateNearestNeighborPlan(shuffled, district, duration);
  }

  // Fallback plan for edge cases
  static TourPlanModel _generateFallbackPlan(
    List<LocationModel> locations,
    String district,
    int duration,
  ) {
    final dayPlans = <DayPlan>[];
    final locationsPerDay = math.max(1, (locations.length / duration).ceil());
    
    for (int day = 0; day < duration; day++) {
      final startIndex = day * locationsPerDay;
      final endIndex = math.min(startIndex + locationsPerDay, locations.length);
      
      if (startIndex >= locations.length) break;
      
      final dayLocations = locations.sublist(startIndex, endIndex);
      final dayStops = dayLocations.asMap().entries.map((entry) {
        final location = entry.value;
        final startTime = dayStartTime * 60 + (entry.key * 120); // 2 hours apart
        
        return _createTourStop(location, startTime, entry.key + 1);
      }).toList();

      dayPlans.add(DayPlan(
        dayNumber: day + 1,
        title: 'Day ${day + 1} - ${district} Tour',
        stops: dayStops,
        notes: 'Basic tour plan with ${dayStops.length} locations',
      ));
    }

    return TourPlanModel(
      id: 'plan_${district}_fallback',
      district: district,
      title: '${district} Basic Tour Plan',
      description: 'A basic ${duration}-day tour of ${district}',
      duration: duration,
      dayPlans: dayPlans,
      createdAt: DateTime.now(),
    );
  }

  // Helper method to create tour stops with proper timing
  static TourStop _createTourStop(
    LocationModel location, 
    int startTimeMinutes, 
    int order, {
    int travelTimeFromPrevious = 0,
  }) {
    final startHour = startTimeMinutes ~/ 60;
    final startMin = startTimeMinutes % 60;
    final endTimeMinutes = startTimeMinutes + locationVisitDuration;
    final endHour = endTimeMinutes ~/ 60;
    final endMin = endTimeMinutes % 60;
    
    return TourStop(
      locationId: location.id,
      locationName: location.name,
      startTime: '${startHour.toString().padLeft(2, '0')}:${startMin.toString().padLeft(2, '0')}',
      endTime: '${endHour.toString().padLeft(2, '0')}:${endMin.toString().padLeft(2, '0')}',
      order: order,
      notes: '${location.description}${travelTimeFromPrevious > 0 ? ' (${travelTimeFromPrevious} min travel)' : ''}',
    );
  }

  // Calculate distance between two locations using Haversine formula
  static double _calculateDistance(LocationModel loc1, LocationModel loc2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    final lat1Rad = loc1.latitude * math.pi / 180;
    final lat2Rad = loc2.latitude * math.pi / 180;
    final deltaLat = (loc2.latitude - loc1.latitude) * math.pi / 180;
    final deltaLng = (loc2.longitude - loc1.longitude) * math.pi / 180;

    final a = math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
        math.cos(lat1Rad) * math.cos(lat2Rad) *
        math.sin(deltaLng / 2) * math.sin(deltaLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  // Calculate travel time between locations in minutes
  static int _calculateTravelTime(LocationModel from, LocationModel to) {
    final distance = _calculateDistance(from, to);
    final timeInHours = distance / avgSpeedKmh;
    return (timeInHours * 60).ceil(); // Convert to minutes and round up
  }

  // Find nearest unvisited location
  static LocationModel? _findNearestLocation(
    LocationModel current, 
    List<LocationModel> candidates
  ) {
    if (candidates.isEmpty) return null;
    
    LocationModel? nearest;
    double minDistance = double.infinity;
    
    for (final candidate in candidates) {
      final distance = _calculateDistance(current, candidate);
      if (distance < minDistance) {
        minDistance = distance;
        nearest = candidate;
      }
    }
    
    return nearest;
  }

  // Create location clusters for better route planning
  static List<List<LocationModel>> _createLocationClusters(
    List<LocationModel> locations, 
    int numClusters
  ) {
    if (locations.length <= numClusters) {
      return locations.map((loc) => [loc]).toList();
    }

    final clusters = List.generate(numClusters, (index) => <LocationModel>[]);
    final random = math.Random();
    
    // Simple clustering - can be improved with K-means
    for (final location in locations) {
      final clusterIndex = random.nextInt(numClusters);
      clusters[clusterIndex].add(location);
    }
    
    // Remove empty clusters
    return clusters.where((cluster) => cluster.isNotEmpty).toList();
  }

  // Optimize route within a cluster using simple nearest neighbor
  static List<LocationModel> _optimizeRouteForCluster(List<LocationModel> cluster) {
    if (cluster.length <= 1) return cluster;
    
    final optimized = <LocationModel>[];
    final unvisited = List<LocationModel>.from(cluster);
    
    // Start with first location
    LocationModel current = unvisited.removeAt(0);
    optimized.add(current);
    
    // Find nearest neighbor for each step
    while (unvisited.isNotEmpty) {
      final nearest = _findNearestLocation(current, unvisited);
      if (nearest != null) {
        unvisited.remove(nearest);
        optimized.add(nearest);
        current = nearest;
      } else {
        break;
      }
    }
    
    return optimized;
  }

  // Existing methods with enhancements
  static TourPlanModel regenerateTourPlan(
    TourPlanModel existingPlan,
    List<LocationModel> availableLocations,
  ) {
    final newPlans = generateTourPlansFromLocations(
      availableLocations,
      existingPlan.district,
      existingPlan.duration,
    );

    return newPlans.isNotEmpty ? newPlans.first : existingPlan;
  }

  static List<LocationModel> filterLocationsByDistrict(
    List<LocationModel> locations,
    String district,
  ) {
    return locations.where((location) => 
      location.district.toLowerCase() == district.toLowerCase()
    ).toList();
  }

  // Validate if a day plan is feasible time-wise
  static bool _isDayPlanFeasible(List<LocationModel> locations) {
    if (locations.length <= 1) return true;
    
    int totalTime = locations.length * locationVisitDuration;
    
    for (int i = 1; i < locations.length; i++) {
      totalTime += _calculateTravelTime(locations[i - 1], locations[i]);
    }
    
    return totalTime <= (dayEndTime - dayStartTime) * 60;
  }
}