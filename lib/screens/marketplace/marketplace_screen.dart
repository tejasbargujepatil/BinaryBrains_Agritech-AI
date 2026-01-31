import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import 'fertilizer_comparison_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Marketplace',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryGreen,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primaryGreen,
          tabs: const [
            Tab(text: 'Fertilizers', icon: Icon(Icons.eco)),
            Tab(text: 'Products', icon: Icon(Icons.shopping_bag)),
            Tab(text: 'Equipment', icon: Icon(Icons.agriculture)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          FertilizerComparisonScreen(),
          _ComingSoonTab(title: 'Products'),
          _ComingSoonTab(title: 'Equipment'),
        ],
      ),
    );
  }
}

class _ComingSoonTab extends StatelessWidget {
  final String title;

  const _ComingSoonTab({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingXl),
              decoration: BoxDecoration(
                gradient: AppTheme.lightGradient,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.construction,
                size: 80,
                color: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            Text(
              'Coming Soon!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              '$title marketplace is under development',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
