import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/tour_provider.dart';
import '../../models/tour_plan_model.dart';
import '../../utils/theme.dart';

class TourDetailsScreen extends StatelessWidget {
  final String tourId;

  const TourDetailsScreen({Key? key, required this.tourId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TourProvider>(
      builder: (context, tourProvider, _) {
        final tourPlan = tourProvider.getTourPlanById(tourId);

        if (tourPlan == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Tour Details')),
            body: const Center(child: Text('Tour plan not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(tourPlan.title),
            actions: [
              IconButton(
                icon: const Icon(Icons.map),
                onPressed: () => _openInGoogleMaps(tourPlan),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  color: AppTheme.primaryGreen,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tourPlan.title,
                        style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${tourPlan.duration} ${tourPlan.duration == 1 ? 'Day' : 'Days'}',
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tourPlan.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Daily Itinerary',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      ...tourPlan.dayPlans.map((dayPlan) => _DayPlanCard(dayPlan: dayPlan)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openInGoogleMaps(TourPlanModel tourPlan) async {
    // Create a route with all stops
    final stops = <String>[];
    for (final dayPlan in tourPlan.dayPlans) {
      for (final stop in dayPlan.stops) {
        stops.add(stop.locationName);
      }
    }
    
    if (stops.isNotEmpty) {
      final query = stops.join(' to ');
      final url = 'https://www.google.com/maps/dir/$query';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      }
    }
  }
}

class _DayPlanCard extends StatelessWidget {
  final DayPlan dayPlan;

  const _DayPlanCard({required this.dayPlan});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${dayPlan.dayNumber}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    dayPlan.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...dayPlan.stops.map((stop) => _StopItem(stop: stop)),
            if (dayPlan.notes != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notes:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(dayPlan.notes!),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StopItem extends StatelessWidget {
  final TourStop stop;

  const _StopItem({required this.stop});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const SizedBox(width: 44),
          Expanded(
            child: Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    stop.locationName,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                Text(
                  '${stop.startTime} - ${stop.endTime}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}