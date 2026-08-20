import 'package:flutter/material.dart';

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
  final List<Map<String, dynamic>> _medicines = [
    {'name': 'নাপা ৫০০ মিগ্রা', 'time': 'সকাল ৮:০০ টা (খাবার পর)', 'isTaken': true},
    {'name': 'সেকলো ২০ মিগ্রা', 'time': 'দুপুর ২:০০ টা (খাবার আগে)', 'isTaken': false},
    {'name': 'এটিনোলোল ৫০ মিগ্রা', 'time': 'রাত ১০:০০ টা (খাবার পর)', 'isTaken': false},
  ];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  void _toggleMedicineState(int index) {
    setState(() {
      _medicines[index]['isTaken'] = !_medicines[index]['isTaken'];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _medicines[index]['isTaken']
              ? '${_medicines[index]['name']} গ্রহণ করেছেন!'
              : '${_medicines[index]['name']} স্ট্যাটাস রিমুভ করা হয়েছে।',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAddMedicineDialog() {
    _nameController.clear();
    _timeController.clear();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('নতুন ওষুধ যোগ করুন', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'ওষুধের নাম ও ডোজ (যেমন: নাপা ৫০০ মিগ্রা)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _timeController,
              decoration: const InputDecoration(
                labelText: 'সময় ও নির্দেশ (যেমন: রাত ৯:০০ টা)',
                border: OutlineInputBorder(),
              ),
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
              if (_nameController.text.isNotEmpty && _timeController.text.isNotEmpty) {
                setState(() {
                  _medicines.add({
                    'name': _nameController.text,
                    'time': _timeController.text,
                    'isTaken': false,
                  });
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('নতুন ওষুধ যুক্ত করা হয়েছে!')),
                );
              }
            },
            child: const Text('যোগ করুন'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Care', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Card(
              color: Colors.tealAccent,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.favorite, color: Colors.teal, size: 36),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'আজকের ওষুধ গ্রহণের সময়সূচী',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _medicines.length,
                itemBuilder: (context, index) {
                  final med = _medicines[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Icon(
                        Icons.medication,
                        color: med['isTaken'] ? Colors.green : Colors.orange,
                        size: 32,
                      ),
                      title: Text(
                        med['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(med['time']),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: med['isTaken'] ? Colors.grey : Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => _toggleMedicineState(index),
                        child: Text(med['isTaken'] ? 'খেয়েছি' : 'ওষুধ খাই'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'add_btn',
            onPressed: _showAddMedicineDialog,
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'mic_btn',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ভয়েস বা স্ক্যান ফিচারটি শীঘ্রই আসছে!')),
              );
            },
            icon: const Icon(Icons.mic),
            label: const Text('ভয়েস বা স্ক্যান'),
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
          ),
        ],
      ),
    );
  }
}
