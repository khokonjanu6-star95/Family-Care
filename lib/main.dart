import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
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
    _loadMedicines();
  }

  Future<void> _loadMedicines() async {
    final prefs = await SharedPreferences.getInstance();
    final String? medicinesData = prefs.getString('medicines_data');

    if (medicinesData != null) {
      final List<dynamic> decoded = jsonDecode(medicinesData);
      setState(() {
        _medicines = decoded.map((item) => Map<String, dynamic>.from(item)).toList();
        _isLoading = false;
      });
      _scheduleInAppAlarms();
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

  void _scheduleInAppAlarms() {
    final now = DateTime.now();
    for (var med in _medicines) {
      if (med['hour'] != null && med['minute'] != null && !(med['isTaken'] ?? false)) {
        var scheduled = DateTime(now.year, now.month, now.day, med['hour'], med['minute']);
        if (scheduled.isBefore(now)) {
          scheduled = scheduled.add(const Duration(days: 1));
        }
        final difference = scheduled.difference(now);
        Timer(difference, () {
          _triggerAlarmDialog(med['name']);
        });
      }
    }
  }

  void _triggerAlarmDialog(String medName) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.teal.shade50,
        title: const Row(
          children: [
            Icon(Icons.alarm_on, color: Colors.teal, size: 30),
            SizedBox(width: 8),
            Text('ওষুধের সময় হয়েছে!'),
          ],
        ),
        content: Text(
          'আপনার "$medName" ওষুধটি খাওয়ার সময় হয়ে গেছে। দয়া করে এখনই গ্রহণ করুন।',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ঠিক আছে'),
          ),
        ],
      ),
    );
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                title: Text(
                  _selectedTime == null
                      ? 'সময় সিলেক্ট করুন'
                      : 'সময়: ${_selectedTime!.format(context)}',
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
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
              onPressed: () {
                if (_nameController.text.isNotEmpty && _selectedTime != null) {
                  final name = _nameController.text;
                  final timeStr = _selectedTime!.format(context);

                  final newMed = {
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

                  final now = DateTime.now();
                  var scheduled = DateTime(now.year, now.month, now.day, _selectedTime!.hour, _selectedTime!.minute);
                  if (scheduled.isBefore(now)) {
                    scheduled = scheduled.add(const Duration(days: 1));
                  }
                  final diff = scheduled.difference(now);
                  Timer(diff, () {
                    _triggerAlarmDialog(name);
                  });

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
                  child: ListTile(
                    leading: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (med['isTaken'] ?? false) ? Colors.grey : Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => _toggleMedicineState(index),
                      child: Text((med['isTaken'] ?? false) ? 'খেয়েছি' : 'ওষুধ খাই'),
                    ),
                    title: Text(med['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
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
