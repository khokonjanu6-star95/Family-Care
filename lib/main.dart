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
  // ওষুধের লিস্ট ও স্টেট ডাইনামিক করা হলো
  final List<Map<String, dynamic>> _medicines = [
    {'name': 'নাপা ৫০০ মিগ্রা', 'time': 'সকাল ৮:০০ টা (খাবার পর)', 'isTaken': true},
    {'name': 'সেকলো ২০ মিগ্রা', 'time': 'দুপুর ২:০০ টা (খাবার আগে)', 'isTaken': false},
    {'name': 'এটিনোলোল ৫০ মিগ্রা', 'time': 'রাত ১০:০০ টা (খাবার পর)', 'isTaken': false},
  ];

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
      floatingActionButton: FloatingActionButton.extended(
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
    );
  }
}
