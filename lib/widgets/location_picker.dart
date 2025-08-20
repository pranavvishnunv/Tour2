
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationPicker extends StatefulWidget {
  final Function(LatLng) onLocationPicked;
  final bool autoGoToCurrentLocation;

  const LocationPicker({
    super.key, 
    required this.onLocationPicked,
    this.autoGoToCurrentLocation = false,
  });

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  late MapController _mapController;
  LatLng? _pickedLocation;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    if (widget.autoGoToCurrentLocation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _goToCurrentLocation();
      });
    }
  }

  /// ✅ Get current location (works on Android/iOS/Web)
  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services are disabled.");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permissions are denied.");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permissions are permanently denied.");
    }

    return await Geolocator.getCurrentPosition();
  }

  /// ✅ Move map to current location
  Future<void> _goToCurrentLocation() async {
    try {
      final pos = await _getCurrentLocation();
      final latLng = LatLng(pos.latitude, pos.longitude);

      setState(() {
        _pickedLocation = latLng;
      });

      _mapController.move(latLng, 17.0); // Proper zoom level for street-level detail
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not fetch location: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pick a Location"),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _goToCurrentLocation,
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              if (_pickedLocation != null) {
                Navigator.pop(context, _pickedLocation);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Pick a location first")),
                );
              }
            },
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          // initialCenter: const LatLng(10.0, 76.0), // Default Kerala position
          initialZoom: 8.0,
          onTap: (tapPosition, latLng) {
            setState(() {
              _pickedLocation = latLng;
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: _pickedLocation != null
                ? [
                    Marker(
                      point: _pickedLocation!,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ]
                : [],
          ),
        ],
      ),
    );
  }
}
