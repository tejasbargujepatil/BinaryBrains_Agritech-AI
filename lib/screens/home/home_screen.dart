import 'package:flutter/material.dart';
import 'package:krishi_mitra/l10n/app_localizations.dart';
import '../../services/weather_service.dart';
import '../../services/soil_service.dart';
import '../../models/weather_model.dart';
import '../../models/soil_model.dart';
import '../../routes/app_routes.dart';
import '../../widgets/banners/weather_banner.dart';
import '../../widgets/banners/soil_banner.dart';
import '../../widgets/action_card.dart';
import '../crops/crops_list_screen.dart';
import '../alerts/alerts_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  WeatherModel? _weather;
  SoilModel? _soil;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final weatherResult = await WeatherService.getUserWeather();
    if (weatherResult['success']) {
      setState(() => _weather = weatherResult['weather']);
    }

    final soilResult = await SoilService.getUserSoilData();
    if (soilResult['success']) {
      setState(() => _soil = soilResult['soil']);
    }

    setState(() => _isLoading = false);
  }

  List<Widget> _getPages() {
    return [
      _buildHomeDashboard(),
      const CropsListScreen(),
      const AlertsScreen(),
      const ProfileScreen(),
    ];
  }

  Widget _buildHomeDashboard() {
    final l10n = AppLocalizations.of(context)!;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.welcome,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.dashboard,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Auto-scrolling Banners using PageView
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else ...{
              if (_weather != null || _soil != null)
                SizedBox(
                  height: 200,
                  child: PageView(
                    children: [
                      if (_weather != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: WeatherBanner(weather: _weather!),
                        ),
                      if (_soil != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: SoilBanner(soil: _soil!),
                        ),
                    ],
                  ),
                ),
            },

            const SizedBox(height: 24),

            // Action Cards Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l10n.viewAll,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 12),

            // Action Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ActionCard(
                      icon: Icons.add_circle,
                      title: l10n.addNewCrop,
                      color: Theme.of(context).colorScheme.primary,
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.addCrop);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ActionCard(
                      icon: Icons.smart_toy,
                      title: l10n.agentView,
                      color: Theme.of(context).colorScheme.tertiary,
                      onTap: () {
                        setState(() => _selectedIndex = 1);
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: _getPages()[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: l10n.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.agriculture),
            label: l10n.crops,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.notifications),
            label: l10n.alerts,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: l10n.profile,
          ),
        ],
      ),
    );
  }
}
