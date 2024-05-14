// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Mahasu/pages/auth/forgot_page.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _passwordObscureText = true;

  // controllers
  final TextEditingController emailCtl = TextEditingController();
  final TextEditingController passwordCtl = TextEditingController();
  bool _isLoading = false;

  forgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return const ForgotPasswordPage();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Welcome back!
              SizedBox(height: 50),
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Welcome back!',
                    style: GoogleFonts.getFont(
                      'Nunito Sans',
                      fontWeight: FontWeight.w700,
                      fontSize: 30,
                      height: 1.3,
                      letterSpacing: -0.3,
                      color: Color(0xFF1E232C),
                    ),
                  ),
                ),
              ),

              // Email text field
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, 0, 8),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Email',
                    style: GoogleFonts.getFont(
                      'Nunito Sans',
                      fontWeight: FontWeight.w200,
                      fontSize: 14,
                      height: 1.3,
                      color: Color(0xFF1E232C),
                    ),
                  ),
                ),
              ),
              TextField(
                enabled: true,
                controller: emailCtl,
                obscureText: false,
                decoration: const InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  hintText: 'Email address',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                style: const TextStyle(color: Colors.black),
              ),
              SizedBox(height: 20),
              // Password text field
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, 0, 8),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Password',
                    style: GoogleFonts.getFont(
                      'Nunito Sans',
                      fontWeight: FontWeight.w200,
                      fontSize: 14,
                      height: 1.3,
                      color: Color(0xFF1E232C),
                    ),
                  ),
                ),
              ),
              TextField(
                enabled: true,
                controller: passwordCtl,
                obscureText: _passwordObscureText,
                decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  hintText: 'Password',
                  hintStyle: const TextStyle(color: Colors.grey),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _passwordObscureText = !_passwordObscureText;
                      });
                    },
                    icon: Icon(
                      _passwordObscureText
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                  ),
                ),
                style: const TextStyle(color: Colors.black),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        forgotPassword();
                      },
                      child: Text(
                        'Forgot password?',
                        style: GoogleFonts.getFont(
                          'Nunito Sans',
                          fontWeight: FontWeight.w200,
                          fontSize: 14,
                          height: 1.3,
                          color: Color(0xFF1E232C),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Login button
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  setState(() {
                    _isLoading = true;
                  });
                  try {
                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                        email: emailCtl.text, password: passwordCtl.text);

                    // set _isloading to false
                    setState(() {
                      _isLoading = false;
                    });
                  } on FirebaseAuthException catch (e) {
                    if (e.code == 'invalid-credential') {
                      // show snackbar
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Center(
                            child: Text('Credentials are invalid.'),
                          ),
                        ),
                      );
                      setState(() {
                        _isLoading = false;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Center(
                            child: Text(e.code),
                          ),
                        ),
                      );
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  }
                },
                child: Container(
                  height: 50,
                  width: 200,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade400, Colors.green.shade600],
                      begin: AlignmentDirectional.topStart,
                      end: AlignmentDirectional.bottomEnd,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: _isLoading
                            ? CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : Text(
                                'Login',
                                style: TextStyle(color: Colors.white),
                              )),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
