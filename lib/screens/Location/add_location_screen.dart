import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';

import '../../providers/auth_provider.dart';
import '../../providers/location_provider.dart';
import '../../models/location_model.dart';
import '../../constants/districts.dart';
import '../../widgets/loading_overlay.dart';
import 'package:latlong2/latlong.dart';
import '../../widgets/location_picker.dart';
import 'package:geolocator/geolocator.dart';

class AddLocationScreen extends StatefulWidget {
  const AddLocationScreen({super.key});

  @override
  State<AddLocationScreen> createState() => _AddLocationScreenState();
}

class _AddLocationScreenState extends State<AddLocationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _contactController = TextEditingController();

  String? _selectedDistrict;
  LocationType _selectedType = LocationType.tourist;
  List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _contactController.dispose();
    super.dispose();
  }
  // ignore: unused_element
  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services are disabled.");
    }

    // Check permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permissions are denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permissions are permanently denied.");
    }

  // Fetch location
  return await Geolocator.getCurrentPosition();
}
  Future<void> _pickImages() async {
    final images = await _picker.pickMultiImage();
    setState(() {
      _selectedImages = images.map((image) => File(image.path)).toList();
    });
  }

  Future<void> _openMapPicker() async {
    final pickedLocation = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (context) => LocationPicker(
          onLocationPicked: (LatLng pickedLocation) {
            Navigator.of(context).pop(pickedLocation);
          },
          autoGoToCurrentLocation: true,
        ),
      ),
    );

    if (!mounted) return;

    if (pickedLocation != null) {
      setState(() {
        _latitudeController.text = pickedLocation.latitude.toString();
        _longitudeController.text = pickedLocation.longitude.toString();
      });
    }
  }


  Future<void> _submitLocation() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);

    if (authProvider.user == null) {
      Fluttertoast.showToast(msg: 'You must be logged in to add locations');
      return;
    }

    final location = LocationModel(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      district: _selectedDistrict!,
      latitude: double.parse(_latitudeController.text),
      longitude: double.parse(_longitudeController.text),
      type: _selectedType,
      addedBy: authProvider.user!.uid,
      createdAt: DateTime.now(),
      contactInfo: _contactController.text.trim().isEmpty 
          ? null 
          : _contactController.text.trim(),
    );

    final error = await locationProvider.addLocation(
      location: location,
      imageFiles: _selectedImages.isEmpty ? null : _selectedImages,
    );

    if (error != null) {
      Fluttertoast.showToast(msg: error);
    } else {
      Fluttertoast.showToast(
        msg: 'Location added successfully! It will be visible after verification.',
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Location'),
      ),
      body: Consumer<LocationProvider>(
        builder: (context, locationProvider, _) {
          return LoadingOverlay(
            isLoading: locationProvider.isLoading,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Basic Information',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Location Name',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter location name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedDistrict,
                              decoration: const InputDecoration(
                                labelText: 'District',
                                border: OutlineInputBorder(),
                              ),
                              items: KeralaDistricts.districts.map((district) {
                                return DropdownMenuItem(
                                  value: district['id'],
                                  child: Text(district['name']!),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedDistrict = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select a district';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<LocationType>(
                              initialValue: _selectedType,
                              decoration: const InputDecoration(
                                labelText: 'Location Type',
                                border: OutlineInputBorder(),
                              ),
                              items: LocationType.values.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(_getTypeDisplayName(type)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedType = value!;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _descriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Description',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a description';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Location Coordinates',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: _openMapPicker,
                              icon: const Icon(Icons.map),
                              label: const Text("Pick from Map"),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _latitudeController,
                                    decoration: const InputDecoration(
                                      labelText: 'Latitude',
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _longitudeController,
                                    decoration: const InputDecoration(
                                      labelText: 'Longitude',
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Additional Information',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _contactController,
                              decoration: const InputDecoration(
                                labelText: 'Contact Information (Optional)',
                                border: OutlineInputBorder(),
                                hintText: 'Phone, email, or website',
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Images',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            if (_selectedImages.isNotEmpty) ...[
                              SizedBox(
                                height: 100,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _selectedImages.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                          image: FileImage(_selectedImages[index]),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                            OutlinedButton.icon(
                              onPressed: _pickImages,
                              icon: const Icon(Icons.add_photo_alternate),
                              label: Text(_selectedImages.isEmpty 
                                  ? 'Add Images' 
                                  : 'Change Images'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _submitLocation,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Submit for Verification'),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info, color: Colors.blue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Your location will be reviewed by our team before being made visible to other users.',
                              style: TextStyle(color: Colors.blue[800]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getTypeDisplayName(LocationType type) {
    switch (type) {
      case LocationType.tourist:
        return 'Tourist Place';
      case LocationType.restaurant:
        return 'Restaurant';
      case LocationType.teaSpot:
        return 'Tea Spot';
    }
  }
}
