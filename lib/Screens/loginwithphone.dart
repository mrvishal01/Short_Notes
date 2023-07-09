import 'package:crud/Screens/verify_code.dart';
import 'package:crud/Utils/utility.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginWithPhone extends StatefulWidget {
  const LoginWithPhone({super.key});

  @override
  State<LoginWithPhone> createState() => _LoginWithPhoneState();
}

class _LoginWithPhoneState extends State<LoginWithPhone> {
  final phoneNoController = TextEditingController();
  bool loading = false;
  final auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login With Phone')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 80),
            TextFormField(
              controller: phoneNoController,
              decoration: const InputDecoration(hintText: '+91 234 4561 123'),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: 400,
              height: 50,
              child: ElevatedButton(
                onPressed: (() {
                  setState(() {
                    loading = true;
                  });
                  auth.verifyPhoneNumber(
                      phoneNumber: phoneNoController.text,
                      verificationCompleted: (_) {
                        setState(() {
                          loading = false;
                        });
                      },
                      verificationFailed: (error) {
                        setState(() {
                          loading = false;
                        });
                        //debugPrint(error.toString());
                        Utils().toastMessage(error.toString());
                      },
                      codeSent: (String verificationId, int? token) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: ((context) => VerifyCodeScreen(
                                      verificationId: verificationId,
                                    ))));
                        setState(() {//
                          loading = false;
                        });
                      },
                      codeAutoRetrievalTimeout: (error) {
                        //debugPrint(error.toString());
                        Utils().toastMessage(error.toString());
                         setState(() {
                    loading = false;
                  });
                      });
                }),
                child: const Center(
                  child: Text(
                    "Login",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
