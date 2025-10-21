import 'package:flutter/material.dart';

void main() {
  runApp(const invoicely_desktopApp());
}

class invoicely_desktopApp extends StatelessWidget {
  const invoicely_desktopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Invoicely',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
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
      appBar: AppBar(title: const Text('Invoicely')),
      body: const Center(
        child: Text(
          '🚀 Bem-vindo ao Invoicely!',
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}
