import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GetOperatorEmailPage extends StatelessWidget {
  const GetOperatorEmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Get Operator Email'),
      ),
      body: Center(
        child: ElevatedButton(
            onPressed: () async {
              // return the logged in user's email
              final email = await FirebaseAuth.instance.currentUser!.email;
              print(email);
            },
            child: const Text('Get Operator Email')),
      ),
    );
  }
}
