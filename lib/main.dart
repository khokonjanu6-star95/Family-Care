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
              : '${_medicines[index]['name']} স্ট্যাটাস পরিবর্তন করা হয়েছে।',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ওষুধটি কি মুছে ফেলতে চান?'),
        content: Text('আপনার তালিকা থেকে "${_medicines[index]['name']}" মুছে ফেলা হবে।'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('না'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              final deletedName = _medicines[index]['name'];
              setState(() {
                _medicines.removeAt(index);
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$deletedName মুছে ফেলা হয়েছে')),
              );
            },
            child: const Text('হ্যাঁ, মুছে ফেলুন'),
          ),
        ],
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
                labelText: 'ওষুধের নাম ও ডোজ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _timeController,
              decoration: const InputDecoration(
                labelText: 'সময় ও নির্দেশ',
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
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
                padding: const EdgeInsets.only(bottom: 120),
                itemCount: _medicines.length,
                itemBuilder: (context, index) {
                  final med = _medicines[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      child: Row(
                        children: [
                          // বামপাশে 'ওষুধ খাই' বাটন
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: med['isTaken'] ? Colors.grey : Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                            ),
                            onPressed: () => _toggleMedicineState(index),
                            child: Text(med['isTaken'] ? 'খেয়েছি' : 'ওষুধ খাই'),
                          ),
                          const SizedBox(width: 12),
                          // মাঝখানে নাম ও সময়
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  med['name'],
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  med['time'],
                                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          // ডানপাশে ডিলিট বাটন (সুরক্ষার জন্য পপ-আপসহ)
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => _confirmDelete(index),
                          ),
                        ],
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
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
