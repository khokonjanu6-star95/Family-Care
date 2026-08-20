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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
              child: ListView(
                children: [
                  _buildMedicineCard('নাপা ৫০০ মিগ্রা', 'সকাল ৮:০০ টা (খাবার পর)', true),
                  _buildMedicineCard('সেকলো ২০ মিগ্রা', 'দুপুর ২:০০ টা (খাবার আগে)', false),
                  _buildMedicineCard('এটিনোলোল ৫০ মিগ্রা', 'রাত ১০:০০ টা (খাবার পর)', false),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.mic),
        label: const Text('ভয়েস বা স্ক্যান'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildMedicineCard(String name, String time, bool isTaken) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          Icons.medication,
          color: isTaken ? Colors.green : Colors.orange,
          size: 32,
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(time),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isTaken ? Colors.grey : Colors.green,
            foregroundColor: Colors.white,
          ),
          onPressed: () {},
          child: Text(isTaken ? 'খেয়েছি' : 'ওষুধ খাই'),
        ),
      ),
    );
  }
}
