import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/tour_plan_model.dart';
import '../../models/location_model.dart';
import '../../providers/tour_provider.dart';
import '../../providers/location_provider.dart';
import 'tour_map_screen.dart';

class TourDetailsScreen extends StatefulWidget {
  final String tourId;

  const TourDetailsScreen({super.key, required this.tourId});

  @override
  State<TourDetailsScreen> createState() => _TourDetailsScreenState();
}

class _TourDetailsScreenState extends State<TourDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Load tour plan if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tourProvider = Provider.of<TourProvider>(context, listen: false);
      if (tourProvider.getTourPlanById(widget.tourId) == null) {
        // Load tour plans for the district
        final tourPlan = tourProvider.getTourPlanById(widget.tourId);
        if (tourPlan != null) {
          tourProvider.loadTourPlansByDistrict(tourPlan.district);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tourProvider = Provider.of<TourProvider>(context);
    final tourPlan = tourProvider.getTourPlanById(widget.tourId);

    if (tourPlan == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Tour Details'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Tour plan not found'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(tourPlan.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share functionality coming soon!')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(tourPlan),
            
            // Description
            _buildDescription(tourPlan),
            
            // Itinerary
            _buildItinerary(tourPlan),
            
            // Action buttons
            _buildActionButtons(context, tourPlan),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(TourPlanModel tourPlan) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tourPlan.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tourPlan.description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                '${tourPlan.duration} days',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(TourPlanModel tourPlan) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About this tour',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tourPlan.description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItinerary(TourPlanModel tourPlan) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Itinerary',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...tourPlan.dayPlans.map((dayPlan) => _buildDayCard(dayPlan)).toList(),
        ],
      ),
    );
  }

  Widget _buildDayCard(DayPlan dayPlan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dayPlan.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (dayPlan.notes != null) ...[
              const SizedBox(height: 8),
              Text(
                dayPlan.notes!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
            const SizedBox(height: 16),
            ...dayPlan.stops.map((stop) => _buildStopCard(stop)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStopCard(TourStop stop) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue,
            child: Text(
              stop.order.toString(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stop.locationName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${stop.startTime} - ${stop.endTime}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                if (stop.notes != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    stop.notes!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, TourPlanModel tourPlan) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // Start tour functionality
                _startTour(context, tourPlan);
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Tour'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                // Save tour functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tour saved!')),
                );
              },
              icon: const Icon(Icons.bookmark_border),
              label: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }

  void _startTour(BuildContext context, TourPlanModel tourPlan) async {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Collect all location IDs from tour stops
      final locationIds = tourPlan.dayPlans
          .expand((dayPlan) => dayPlan.stops.map((stop) => stop.locationId))
          .toList();

      // Fetch location details
      final locations = await locationProvider.getLocationsByIds(locationIds);

      if (locations.isEmpty) {
        if (context.mounted) {
          Navigator.pop(context); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No locations found for this tour')),
          );
        }
        return;
      }

      if (context.mounted) {
        Navigator.pop(context); // Close loading
        
        // Navigate to tour map screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TourMapScreen(
              tourPlan: tourPlan,
              locations: locations,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting tour: ${e.toString()}')),
        );
      }
    }
  }
}
