import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/location_model.dart';
import '../utils/theme.dart';

class LocationCard extends StatelessWidget {
  final LocationModel location;

  const LocationCard({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (location.images.isNotEmpty)
            Container(
              height: 200,
              width: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: CachedNetworkImage(
                  imageUrl: location.images.first,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 48),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        location.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    _TypeChip(type: location.type),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  location.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _openInGoogleMaps(location),
                        icon: const Icon(Icons.map, size: 16),
                        label: const Text('View on Map'),
                      ),
                    ),
                    if (location.contactInfo != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _openContact(location.contactInfo!),
                        icon: const Icon(Icons.phone),
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openInGoogleMaps(LocationModel location) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _openContact(String contact) async {
    if (contact.contains('@')) {
      // Email
      final url = 'mailto:$contact';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      }
    } else if (contact.startsWith('http')) {
      // Website
      if (await canLaunchUrl(Uri.parse(contact))) {
        await launchUrl(Uri.parse(contact));
      }
    } else {
      // Phone
      final url = 'tel:$contact';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      }
    }
  }
}

class _TypeChip extends StatelessWidget {
  final LocationType type;

  const _TypeChip({required this.type});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String label;

    switch (type) {
      case LocationType.tourist:
        color = Colors.blue;
        icon = Icons.landscape;
        label = 'Tourist';
        break;
      case LocationType.restaurant:
        color = Colors.orange;
        icon = Icons.restaurant;
        label = 'Restaurant';
        break;
      case LocationType.teaSpot:
        color = Colors.green;
        icon = Icons.local_cafe;
        label = 'Tea Spot';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}