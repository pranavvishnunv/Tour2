import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/tour_plan_model.dart';
import '../../models/location_model.dart';

class TourMapScreen extends StatefulWidget {
  final TourPlanModel tourPlan;
  final List<LocationModel> locations;

  const TourMapScreen({
    super.key,
    required this.tourPlan,
    required this.locations,
  });

  @override
  State<TourMapScreen> createState() => _TourMapScreenState();
}

class _TourMapScreenState extends State<TourMapScreen> {
  late MapController _mapController;
  int _currentStopIndex = 0;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  List<LatLng> get _routeCoordinates {
    return widget.locations.map((location) {
      return LatLng(location.latitude, location.longitude);
    }).toList();
  }

  List<Marker> get _markers {
    return widget.locations.asMap().entries.map((entry) {
      final index = entry.key;
      final location = entry.value;
      
      return Marker(
        point: LatLng(location.latitude, location.longitude),
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () => _showLocationDetails(location, index),
          child: Container(
            decoration: BoxDecoration(
              color: index == _currentStopIndex ? Colors.red : Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(
              child: Text(
                (index + 1).toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  void _showLocationDetails(LocationModel location, int index) {
    setState(() {
      _currentStopIndex = index;
    });

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              location.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(location.description),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _openInGoogleMaps(location),
                  icon: const Icon(Icons.navigation),
                  label: const Text('Navigate'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _openInGoogleMaps(location, directions: true),
                  icon: const Icon(Icons.directions),
                  label: const Text('Directions'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openInGoogleMaps(LocationModel location, {bool directions = false}) async {
    final url = directions
        ? 'https://www.google.com/maps/dir/?api=1&destination=${location.latitude},${location.longitude}'
        : 'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}';
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _launchGoogleMapsWithRoute() async {
    // Create waypoints for Google Maps
    final waypoints = _routeCoordinates.skip(1).take(_routeCoordinates.length - 2).map((latLng) {
      return '${latLng.latitude},${latLng.longitude}';
    }).join('|');

    final destination = _routeCoordinates.last;
    final url = 'https://www.google.com/maps/dir/?api=1&origin=${_routeCoordinates.first.latitude},${_routeCoordinates.first.longitude}&destination=${destination.latitude},${destination.longitude}&waypoints=$waypoints';
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.tourPlan.title} - Tour Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.navigation),
            onPressed: _launchGoogleMapsWithRoute,
            tooltip: 'Open in Google Maps',
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _routeCoordinates.isNotEmpty 
                  ? _routeCoordinates.first 
                  : const LatLng(10.8505, 76.2711), // Kerala center
              initialZoom: 12,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(markers: _markers),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _routeCoordinates,
                    color: Colors.blue,
                    strokeWidth: 3,
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Stop ${_currentStopIndex + 1} of ${widget.locations.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.locations[_currentStopIndex].name,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: _currentStopIndex > 0
                              ? () => setState(() => _currentStopIndex--)
                              : null,
                        ),
                        Text('${_currentStopIndex + 1}/${widget.locations.length}'),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: _currentStopIndex < widget.locations.length - 1
                              ? () => setState(() => _currentStopIndex++)
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
