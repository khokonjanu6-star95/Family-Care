import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(const FamilyCareApp());
}

class FamilyCareApp extends StatelessWidget {
  const FamilyCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Family Care',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _medicines = [];
  bool _isLoading = true;

  final TextEditingController _nameController = TextEditingController();
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _requestNotificationPermission();
    _loadMedicines();
  }

  void _requestNotificationPermission() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> _loadMedicines() async {
    final prefs = await SharedPreferences.getInstance();
    final String? medicinesData = prefs.getString('medicines_data');

    if (medicinesData != null) {
      final List<dynamic> decoded = jsonDecode(medicinesData);
      setState(() {
        _medicines =
            decoded.map((item) => Map<String, dynamic>.from(item)).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _medicines = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _saveMedicines() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_medicines);
    await prefs.setString('medicines_data', encoded);
  }

  Future<void> _scheduleNotification(
      int id, String title, TimeOfDay time) async {
    final now = DateTime.now();
    var scheduledDate =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'ওষুধ খাওয়ার সময় হয়েছে!',
      'অনুগ্রহ করে আপনার "$title" ওষুধটি গ্রহণ করুন।',
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medicine_reminder_channel',
          'Medicine Reminders',
          channelDescription: 'Notification channel for medicine reminders',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  void _toggleMedicineState(int index) {
    setState(() {
      _medicines[index]['isTaken'] = !(_medicines[index]['isTaken'] ?? false);
    });
    _saveMedicines();
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ওষুধটি মুছে ফেলতে চান?'),
        content: Text('"${_medicines[index]['name']}" মুছে ফেলা হবে।'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('না'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              final id = _medicines[index]['id'] ?? index;
              _cancelNotification(id);
              setState(() {
                _medicines.removeAt(index);
              });
              _saveMedicines();
              Navigator.pop(ctx);
            },
            child: const Text('মুছে ফেলুন'),
          ),
        ],
      ),
    );
  }

  void _showAddMedicineDialog() {
    _nameController.clear();
    _selectedTime = null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('নতুন ওষুধ যোগ করুন'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'ওষুধের নাম ও ডোজ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                tileColor: Colors.grey.shade100,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                title: Text(
                  _selectedTime == null
                      ? 'সময় সিলেক্ট করুন'
                      : 'সময়: ${_selectedTime!.format(context)}',
                ),
                trailing: const Icon(Icons.access_time, color: Colors.teal),
                onTap: () async {
                  final TimeOfDay? time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    setDialogState(() {
                      _selectedTime = time;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('বাতিল'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal, foregroundColor: Colors.white),
              onPressed: () {
                if (_nameController.text.isNotEmpty && _selectedTime != null) {
                  final name = _nameController.text;
                  final timeStr = _selectedTime!.format(context);
                  final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

                  final newMed = {
                    'id': notificationId,
                    'name': name,
                    'time': timeStr,
                    'hour': _selectedTime!.hour,
                    'minute': _selectedTime!.minute,
                    'isTaken': false,
                  };

                  setState(() {
                    _medicines.add(newMed);
                  });

                  _saveMedicines();
                  _scheduleNotification(notificationId, name, _selectedTime!);

                  Navigator.pop(ctx);
                }
              },
              child: const Text('যোগ করুন'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Care'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _medicines.length,
              itemBuilder: (context, index) {
                final med = _medicines[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (med['isTaken'] ?? false)
                            ? Colors.grey
                            : Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => _toggleMedicineState(index),
                      child: Text(
                          (med['isTaken'] ?? false) ? 'খেয়েছি' : 'ওষুধ খাই'),
                    ),
                    title: Text(med['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(med['time']),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _confirmDelete(index),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMedicineDialog,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
