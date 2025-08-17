import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/tour_provider.dart';
import '../../providers/location_provider.dart';
import '../../constants/districts.dart';
import '../../models/location_model.dart';
import '../../utils/theme.dart';
import '../../widgets/tour_plan_card.dart';
import '../../widgets/location_card.dart';

class DistrictScreen extends StatefulWidget {
  final String districtId;

  const DistrictScreen({Key? key, required this.districtId}) : super(key: key);

  @override
  State<DistrictScreen> createState() => _DistrictScreenState();
}

class _DistrictScreenState extends State<DistrictScreen> 
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  void _loadData() async {
    final tourProvider = Provider.of<TourProvider>(context, listen: false);
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    
    await Future.wait([
      tourProvider.loadTourPlansByDistrict(widget.districtId),
      locationProvider.loadLocationsByDistrict(widget.districtId),
    ]);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final districtName = KeralaDistricts.getDistrictName(widget.districtId);

    return Scaffold(
      appBar: AppBar(
        title: Text(districtName),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tour Plans'),
            Tab(text: 'Tourist Places'),
            Tab(text: 'Restaurants'),
            Tab(text: 'Tea Spots'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TourPlansTab(),
          _LocationsTab(type: LocationType.tourist),
          _LocationsTab(type: LocationType.restaurant),
          _LocationsTab(type: LocationType.teaSpot),
        ],
      ),
    );
  }
}

class _TourPlansTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TourProvider>(
      builder: (context, tourProvider, _) {
        if (tourProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (tourProvider.tourPlans.isEmpty) {
          return const Center(
            child: Text('No tour plans available for this district'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tourProvider.tourPlans.length,
          itemBuilder: (context, index) {
            final tourPlan = tourProvider.tourPlans[index];
            return TourPlanCard(
              tourPlan: tourPlan,
              onTap: () {
                context.push('/tour/${tourPlan.id}');
              },
            );
          },
        );
      },
    );
  }
}

class _LocationsTab extends StatelessWidget {
  final LocationType type;

  const _LocationsTab({required this.type});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, _) {
        if (locationProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final locations = locationProvider.getLocationsByType(type);

        if (locations.isEmpty) {
          return Center(
            child: Text('No ${_getTypeText(type)} available for this district'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: locations.length,
          itemBuilder: (context, index) {
            final location = locations[index];
            return LocationCard(location: location);
          },
        );
      },
    );
  }

  String _getTypeText(LocationType type) {
    switch (type) {
      case LocationType.tourist:
        return 'tourist places';
      case LocationType.restaurant:
        return 'restaurants';
      case LocationType.teaSpot:
        return 'tea spots';
    }
  }
}