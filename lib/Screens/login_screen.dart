import 'package:crud/Screens/forgot_password.dart';
import 'package:crud/Screens/home_screen.dart';
// import 'package:crud/Screens/loginwithphone.dart';
import 'package:crud/Screens/signup_screen.dart';
import 'package:crud/Utils/utility.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  bool loading = false;
  final _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    super.dispose();
    userNameController.dispose();
    passwordController.dispose();
  }

  void login() {
    setState(() {
      loading = true;
    });
    _auth
        .signInWithEmailAndPassword(
            email: userNameController.text,
            password: passwordController.text.toString())
        .then((value) {
      Utils().toastMessage(value.user!.email.toString());
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const Home()));
      setState(() {
        loading = false;
      });
    }).onError((error, stackTrace) {
      debugPrint(error.toString());
      Utils().toastMessage(error.toString());
      setState(() {
        loading = false;
      });
    });
  }

  googleLogin() async {
    debugPrint("googleLogin Method Called");
    GoogleSignIn googleSignin = GoogleSignIn();
    try {
      var result = await googleSignin.signIn();
      if (result == null) {
        return;
      } else {
        final userData = await result.authentication;
        final credential = GoogleAuthProvider.credential(
            accessToken: userData.accessToken, idToken: userData.idToken);
        await FirebaseAuth.instance.signInWithCredential(credential);
        debugPrint("Result, $result");
        debugPrint(result.displayName);
        debugPrint(result.displayName);
        debugPrint(result.email);
        debugPrint(result.photoUrl);
        // ignore: use_build_context_synchronously
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const Home()));
      }
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text("Short Notes"),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Login Here",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 30,
                ),
                Form(
                    key: _formkey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: userNameController,
                          decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.email),
                              hintText: "Enter Email OR UserName",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              )),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "UserName Cannot Be Empty";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(Icons.lock),
                            hintText: "Enter Password",
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Password Cannot Be Empty";
                            }
                            return null;
                          },
                        ),
                      ],
                    )),

                //const Text("Forgot password"),
                const SizedBox(height: 30),
                SizedBox(
                  width: 400,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: (() {
                      if (_formkey.currentState!.validate()) {
                        login();
                      }
                    }),
                    child: Center(
                      child: loading
                          ? const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            )
                          : const Text(
                              "Login",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ),
                Align(
                  //alignment: Alignment.bottomRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ForgotPassword()));
                    },
                    child: const Text("Forgot Password"),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignupPage()));
                      },
                      child: const Text("Sign up"),
                    )
                  ],
                ),
                // const SizedBox(height: 20),
                // InkWell(
                //   onTap: () {
                //     Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //             builder: (context) => const LoginWithPhone()));
                //   },
                //   child: Container(
                //     height: 50,
                //     decoration: BoxDecoration(
                //       borderRadius: BorderRadius.circular(30),
                //       border: Border.all(color: Colors.black, width: 2),
                //     ),
                //     child: const Center(
                //       child: Text(
                //         "Login With Phone",
                //         style: TextStyle(
                //             fontSize: 17, fontWeight: FontWeight.bold),
                //       ),
                //     ),
                //   ),
                // ),
                const SizedBox(height: 20),
                InkWell(
                  onTap: () {
                    googleLogin();
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      //color: const Color.fromARGB(255, 25, 83, 243),
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: const Center(
                      child: Text(
                        "Login With Google",
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )),
    );
  }
}
