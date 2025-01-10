import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';
import '../Services/socket_service.dart';
import './on_duty_form.dart';
import './leave_form.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  
  Map<String, dynamic>? userData;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;


  Map<String, String> calendarStatus = {}; // Key: date, Value: status
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    
    // Listen for calendar updates
    SocketService().on('refresh_calendar', (_) {
      _fetchCalendarSettings();
    });
    // Listen for user-specific calendar refresh
    SocketService().on('refresh_calendar_user', (_) {
      //print("User-specific calendar refresh triggered");
      _fetchCalendarSettings();
      // Implement calendar refresh logic here
    });

    _loadUserDetails();
    _tabController = TabController(length: 2, vsync: this); // Two tabs: On-Duty and Leave
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _loadUserDetails() async {
    final userToken = await storage.read(key: 'jwt_token');
    if (userToken != null) {
      try {
        final userMap = JwtDecoder.decode(userToken);
        setState(() {
          userData = userMap['userData'];
        });
        //debugPrint('$userData');
        SocketService().emit('register_user', (userData?['employeeId']));
        _fetchCalendarSettings();
      } catch (e) {
        debugPrint('Error decoding userJson: $e');
      }
    }
  }

  Future<void> _fetchCalendarSettings() async {
    try {

      final response = await ApiService.get(
        '/attendance/getFullCalendar',
      );
      //debugPrint('calendar data :$response');

      if (response['success'] == true && response['calendar'] != null) {
        final data = response['calendar'] as List;
        setState(() {
          calendarStatus = {
            for (var entry in data) entry['date']: entry['status']
          };
          _selectedDay = null;
          _rangeStart = null;
          _rangeEnd = null;
          //debugPrint('$calendarStatus');
        });
      }
    } catch (e) {
      debugPrint('Error fetching calendar settings: $e');
    }
  }

  Future<void> _logout(BuildContext context) async {
    await storage.deleteAll();
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  void _openNotificationSettings() {
    Navigator.of(context).pushNamed('/notification-settings');
  }

  // Get color based on status
  Color _getColorForStatus(String? status) {
    switch (status) {
      case 'holiday':
        return Colors.yellow.shade400;
      case 'weeklyOff':
        return Colors.grey;
      case 'holiday&weeklyOff':
        return Colors.orange;
      case 'leave':
        return Colors.redAccent;
      case 'onDuty':
        return Colors.green;
      case 'onDuty&holiday' || 'onDuty&weeklyOff':
        return Colors.purple;
      case 'onDuty&holiday&weeklyOff':
        return Colors.deepPurple;
      // No color for working days
      default:
        return Colors.transparent;
    }
  }

  @override
Widget build(BuildContext context) {
  return PopScope(
    canPop: true,
    child: Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
        ),
        leading: PopupMenuButton<int>(
          icon: const Icon(Icons.person),
          onSelected: (value) {
            if (value == 1) {
              _logout(context);
            } else if (value == 2) {
              Navigator.of(context).pushNamed('/admin-settings');
            }
          },
          itemBuilder: (context) {
            final List<PopupMenuEntry<int>> menuItems = [];
            if (userData?['role'] == 'admin') {
              menuItems.add(
                const PopupMenuItem(
                  value: 2,
                  child: Row(
                    children: [
                      Icon(Icons.settings, color: Colors.blue),
                      SizedBox(width: 10),
                      Text('Admin Settings'),
                    ],
                  ),
                ),
              );
            }
            menuItems.add(
              const PopupMenuItem(
                value: 1,
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 10),
                    Text('Logout'),
                  ],
                ),
              ),
            );
            return menuItems;
          },
        ),
        title: Text(' ${userData?['name'] ?? "User"} '),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: _openNotificationSettings,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              children: [
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: TableCalendar(
                      firstDay: DateTime(2000),
                      lastDay: DateTime(2100),
                      focusedDay: _focusedDay,
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      rangeStartDay: _rangeStart,
                      rangeEndDay: _rangeEnd,
                      onRangeSelected: (start, end, focusedDay) {
                        setState(() {
                          _selectedDay = null;
                          _rangeStart = start;
                          _rangeEnd = end;
                          _focusedDay = focusedDay;
                        });
                      },
                      rangeSelectionMode: _rangeSelectionMode,
                      calendarFormat: CalendarFormat.month,
                      headerStyle: const HeaderStyle(formatButtonVisible: false),
                      daysOfWeekStyle: const DaysOfWeekStyle(
                        weekdayStyle: TextStyle(fontSize: 12, color: Color(0xFF333333)),
                        weekendStyle: TextStyle(fontSize: 12, color: Color(0xFFE21B5A)),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.grey, width: 1)),
                        ),
                      ),
                      calendarBuilders: CalendarBuilders(
                        defaultBuilder: (context, day, focusedDay) {
                          final status = calendarStatus[day.toIso8601String().split('T')[0]];
                          final color = _getColorForStatus(status);
                          if (color != Colors.transparent) {
                            return Container(
                              margin: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${day.day}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          }
                          return null;
                        },
                        todayBuilder: (context, day, focusedDay) {
                          final status = calendarStatus[day.toIso8601String().split('T')[0]];
                          final borderColor = _getColorForStatus(status);
                          return Container(
                            margin: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: borderColor == Colors.transparent
                                      ? Colors.blue
                                      : borderColor,
                                  width: 3),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${day.day}',
                                style: TextStyle(
                                    color: borderColor == Colors.transparent
                                        ? Colors.blue
                                        : borderColor),
                              ),
                            ),
                          );
                        },
                        selectedBuilder: (context, day, focusedDay) {
                          return Container(
                            margin: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.blueAccent,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${day.day}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'On-Duty'),
                    Tab(text: 'Leave'),
                  ],
                ),
                SizedBox(
                  height: 500, // Ensure some height for TabBarView
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      OnDutyForm(
                        selectedDay: _selectedDay,
                        rangeStart: _rangeStart,
                        rangeEnd: _rangeEnd,
                        isRangeEnabled: true,
                        onToggleMode: (RangeSelectionMode mode) {
                          setState(() {
                            _rangeSelectionMode = mode;
                            if (_rangeSelectionMode == RangeSelectionMode.toggledOff) {
                              _rangeStart = null;
                              _rangeEnd = null;
                            } else {
                              _selectedDay = null;
                            }
                          });
                        },
                        onAttendanceApplied: _fetchCalendarSettings,
                      ),
                      LeaveForm(
                        selectedDay: _selectedDay,
                        rangeStart: _rangeStart,
                        rangeEnd: _rangeEnd,
                        isRangeEnabled: true,
                        onToggleMode: (RangeSelectionMode mode) {
                          setState(() {
                            _rangeSelectionMode = mode;
                            if (_rangeSelectionMode == RangeSelectionMode.toggledOff) {
                              _rangeStart = null;
                              _rangeEnd = null;
                            } else {
                              _selectedDay = null;
                            }
                          });
                        },
                        onAttendanceApplied: _fetchCalendarSettings,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}