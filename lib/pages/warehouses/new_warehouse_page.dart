import 'package:flutter/material.dart';

class NewWarehousePage extends StatelessWidget {
  const NewWarehousePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Warehouse'),
      ),
      body: const Center(
        child: Text('This is the new warehouse page'),
      ),
    );
  }
}
