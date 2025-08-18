import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../constants/districts.dart';
import '../../utils/theme.dart';
import '../../widgets/district_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kerala Tourism'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'profile') {
                context.push('/profile');
              } else if (value == 'add_location') {
                context.push('/add-location');
              } else if (value == 'logout') {
                Provider.of<AuthProvider>(context, listen: false).signOut();
                context.go('/login');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Profile'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'add_location',
                child: ListTile(
                  leading: Icon(Icons.add_location),
                  title: Text('Add Location'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.userModel;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryGreen, AppTheme.lightGreen],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome ${user?.name ?? 'Explorer'}!',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Discover the beauty of God\'s Own Country',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Explore Districts',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
               GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width < 320
                      ? 1: MediaQuery.of(context).size.width < 600
                        ? 2 // 📱 Mobile
                        : MediaQuery.of(context).size.width < 950
                            ? 4 // 📱📱 Tablet / small web
                            : 5,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: KeralaDistricts.districts.length,
                  itemBuilder: (context, index) {
                    final district = KeralaDistricts.districts[index];
                    return DistrictCard(
                      district: district,
                      onTap: () {
                        context.push('/district/${district['id']}');
                      },
                    );
                  },
                )
              ],
            ),
          );
        },
      ),
    );
  }
}