import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/auth_service.dart';
import '../../auth/screens/login_screen.dart';
import '../../vehicle_registration/services/vehicle_service.dart';
import '../models/dashboard_models.dart';
import '../services/dashboard_service.dart';
import '../widgets/activity_list_item.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/movement_chart.dart';
import '../widgets/recent_registration_item.dart';
import '../widgets/stat_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final DashboardService _dashboardService = DashboardService();
  final VehicleService _vehicleService = VehicleService();
  final AuthService _authService = AuthService();

  bool _isLoading = true;
  String _lastUpdated = '';

  List<StatData> _stats = [];
  List<WeeklyData> _weeklyData = [];
  List<ActivityLog> _activities = [];
  List<RegisteredVehicle> _registrations = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      // 1. Fetch Stats
      final statsMap = await _dashboardService.getStats();
      _stats = [
        StatData(
          label: 'TOTAL VEHICLES',
          value: statsMap['totalVehicles']?.toString() ?? '0',
          iconPath: '',
          color: 0xFF5C6BC0,
        ),
        StatData(
          label: 'TODAY ENTRIES',
          value: statsMap['todayEntries']?.toString() ?? '0',
          iconPath: '',
          color: 0xFF43A047,
        ),
        StatData(
          label: 'TODAY EXITS',
          value: statsMap['todayExits']?.toString() ?? '0',
          iconPath: '',
          color: 0xFF00ACC1,
        ),
        StatData(
          label: 'VISITORS TODAY',
          value: statsMap['visitorsToday']?.toString() ?? '0',
          iconPath: '',
          color: 0xFFF57F17,
        ),
      ];

      // 2. Fetch Graph Data
      final graphList = await _dashboardService.getGraphData();
      _weeklyData = graphList.map((e) => WeeklyData.fromJson(e)).toList();

      // 3. Fetch Recent Activity (Reports)
      final activityList = await _dashboardService.getRecentActivity();
      _activities = activityList.map((e) => ActivityLog.fromJson(e)).toList();

      // 4. Fetch Registered Vehicles
      final vehicles = await _vehicleService.getVehicles();
      _registrations = vehicles.map((v) => RegisteredVehicle(
        vehicleNo: v.vehicleNumber,
        owner: v.ownerName,
        type: v.vehicleType,
        flat: v.flatNumber,
        status: v.status,
        date: 'N/A', // Date might not be in Vehicle model, or added later
      )).toList();
      
      // Update timestamp
      final now = DateTime.now();
      _lastUpdated = '${now.day} ${_getMonth(now.month)} ${now.year} ${now.hour}:${now.minute}:${now.second}';

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load dashboard: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await _authService.signOut();
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F7FA), // Light grey background
      appBar: AppBar(
        title: const Text(
          'Vehicle Monitoring',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.gradientStart,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.gradientStart, AppColors.gradientEnd],
            ),
          ),
        ),
        actions: [
          TextButton.icon(
             onPressed: () {},
             icon: const Icon(Icons.person, color: Colors.white),
             label: const Text('System Administrator', style: TextStyle(color: Colors.white)),
          ),
          IconButton(
            onPressed: () => _signOut(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Dashboard',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Updated $_lastUpdated',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Statistics Grid
              if (_stats.isNotEmpty)
              LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = (constraints.maxWidth - 16) / 2;
                  
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: List.generate(_stats.length, (index) {
                       return SizedBox(
                        width: itemWidth,
                        child: StatCard(
                          label: _stats[index].label,
                          value: _stats[index].value,
                          icon: _stats[index].label.contains('VEHICLES') ? Icons.directions_car :
                                _stats[index].label.contains('LOGIN') ? Icons.login :
                                _stats[index].label.contains('LOGOUT') ? Icons.logout : Icons.person_pin,
                          iconColor: Color(_stats[index].color),
                        ),
                      );
                    }),
                  );
                },
              ),
              const SizedBox(height: 30),

              // Chart and Recent Activity Section
              Column(
                children: [
                   if (_weeklyData.isNotEmpty) MovementChart(data: _weeklyData),
                   const SizedBox(height: 20),
                   Container(
                     padding: const EdgeInsets.all(24),
                     decoration: BoxDecoration(
                       color: Colors.white,
                       borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                     ),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: [
                             const Expanded(
                               child: Text(
                                 'Recent Activity',
                                 style: TextStyle(
                                   fontSize: 18,
                                   fontWeight: FontWeight.bold,
                                   color: AppColors.textPrimary,
                                 ),
                                 overflow: TextOverflow.ellipsis,
                               ),
                             ),
                             const SizedBox(width: 8),
                             Text(
                               '${_activities.length} activities',
                                style: const TextStyle(
                                 fontSize: 12,
                                 color: AppColors.textSecondary,
                               ),
                             ),
                           ],
                         ),
                         const SizedBox(height: 16),
                         if (_activities.isEmpty)
                            const Text('No recent activity'),
                         if (_activities.isNotEmpty)
                         ListView.builder(
                           shrinkWrap: true,
                           physics: const NeverScrollableScrollPhysics(),
                           itemCount: _activities.length,
                           itemBuilder: (context, index) {
                             return ActivityListItem(activity: _activities[index]);
                           },
                         ),
                       ],
                     ),
                   ),
                ],
              ),
              const SizedBox(height: 30),

              // Registrations List
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                       offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         const Expanded(
                           child: Text(
                             'Registered Vehicles',
                             style: TextStyle(
                               fontSize: 18,
                               fontWeight: FontWeight.bold,
                               color: AppColors.textPrimary,
                             ),
                             overflow: TextOverflow.ellipsis,
                           ),
                         ),
                         const SizedBox(width: 8),
                         Text(
                           '${_registrations.length} vehicles',
                            style: const TextStyle(
                             fontSize: 12,
                             color: AppColors.textSecondary,
                           ),
                         ),
                       ],
                     ),
                     const SizedBox(height: 20),
                     // Headers
                     Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                       child: rowHeader(),
                     ),
                     const Divider(),
                     if (_registrations.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('No registered vehicles'),
                        ),
                     if (_registrations.isNotEmpty)
                     ListView.builder(
                       shrinkWrap: true,
                       physics: const NeverScrollableScrollPhysics(),
                       itemCount: _registrations.length,
                       itemBuilder: (context, index) {
                         return RecentRegistrationItem(vehicle: _registrations[index]);
                       },
                     ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget rowHeader() {
     return Row(
       mainAxisAlignment: MainAxisAlignment.spaceBetween,
       children: const [
         Text('VEHICLE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
       ],
     );
  }
}
