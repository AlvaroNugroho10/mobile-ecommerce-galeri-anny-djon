import 'package:ecommerce_app/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() =>
      _RegisterPageState();
}

class _RegisterPageState
    extends State<RegisterPage> {

  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  final confirmController =
      TextEditingController();

  bool isLoading = false;

  bool obscurePassword = true;

  bool obscureConfirm = true;

  // =====================================
  // REGISTER USER
  // =====================================
  Future<void> registerUser() async {

    String email =
        emailController.text.trim();

    String password =
        passwordController.text.trim();

    String confirm =
        confirmController.text.trim();

    // =====================================
    // VALIDASI
    // =====================================
    if (
        email.isEmpty ||
        password.isEmpty ||
        confirm.isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            "Semua field harus diisi",
          ),
        ),
      );

      return;
    }

    if (password != confirm) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            "Password tidak sama",
          ),
        ),
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {

      // =====================================
      // REGISTER FIREBASE AUTH
      // =====================================
      UserCredential userCredential =
          await FirebaseAuth.instance
              .createUserWithEmailAndPassword(

        email: email,
        password: password,
      );

      // =====================================
      // SIMPAN USER KE FIRESTORE
      // =====================================
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({

        'uid':
            userCredential.user!.uid,

        'email':
            email,

        'role':
            'user',

        'createdAt':
            FieldValue.serverTimestamp(),
      });

      // =====================================
      // PINDAH KE HOME
      // =====================================
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(

        context,

        MaterialPageRoute(
          builder: (_) =>
              const HomePage(),
        ),

        (route) => false,
      );

    } on FirebaseAuthException catch (e) {

      String message =
          "Register gagal";

      if (e.code ==
          'email-already-in-use') {

        message =
            "Email sudah digunakan";

      } else if (
          e.code ==
              'weak-password') {

        message =
            "Password terlalu lemah";
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(message),
        ),
      );

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {

    emailController.dispose();

    passwordController.dispose();

    confirmController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: SafeArea(

        child: SingleChildScrollView(

          child: Padding(

            padding:
                const EdgeInsets.symmetric(
              horizontal: 28,
            ),

            child: Column(

              children: [

                const SizedBox(height: 50),

                // =========================
                // LOGO
                // =========================
                Center(

                  child: Image.asset(
                    'assets/logo.png',
                    height: 170,
                  ),
                ),

                const SizedBox(height: 35),

                // =========================
                // TITLE
                // =========================
                const Text(

                  "Create Account",

                  style: TextStyle(

                    fontSize: 28,

                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(

                  "Daftar untuk melanjutkan",

                  style: TextStyle(

                    color: Colors.grey[700],

                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 35),

                // =========================
                // EMAIL
                // =========================
                TextField(

                  controller:
                      emailController,

                  keyboardType:
                      TextInputType
                          .emailAddress,

                  decoration: InputDecoration(

                    hintText: "Email",

                    prefixIcon:
                        const Icon(
                      Icons.email_outlined,
                    ),

                    filled: true,

                    fillColor:
                        AppColors.card,

                    contentPadding:
                        const EdgeInsets.symmetric(
                      vertical: 18,
                    ),

                    border:
                        OutlineInputBorder(

                      borderRadius:
                          BorderRadius.circular(
                        16,
                      ),

                      borderSide:
                          BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // =========================
                // PASSWORD
                // =========================
                TextField(

                  controller:
                      passwordController,

                  obscureText:
                      obscurePassword,

                  decoration: InputDecoration(

                    hintText: "Password",

                    prefixIcon:
                        const Icon(
                      Icons.lock_outline,
                    ),

                    suffixIcon:
                        IconButton(

                      onPressed: () {

                        setState(() {

                          obscurePassword =
                              !obscurePassword;
                        });
                      },

                      icon: Icon(

                        obscurePassword

                            ? Icons.visibility_off

                            : Icons.visibility,
                      ),
                    ),

                    filled: true,

                    fillColor:
                        AppColors.card,

                    contentPadding:
                        const EdgeInsets.symmetric(
                      vertical: 18,
                    ),

                    border:
                        OutlineInputBorder(

                      borderRadius:
                          BorderRadius.circular(
                        16,
                      ),

                      borderSide:
                          BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // =========================
                // CONFIRM PASSWORD
                // =========================
                TextField(

                  controller:
                      confirmController,

                  obscureText:
                      obscureConfirm,

                  decoration: InputDecoration(

                    hintText:
                        "Confirm Password",

                    prefixIcon:
                        const Icon(
                      Icons.lock_outline,
                    ),

                    suffixIcon:
                        IconButton(

                      onPressed: () {

                        setState(() {

                          obscureConfirm =
                              !obscureConfirm;
                        });
                      },

                      icon: Icon(

                        obscureConfirm

                            ? Icons.visibility_off

                            : Icons.visibility,
                      ),
                    ),

                    filled: true,

                    fillColor:
                        AppColors.card,

                    contentPadding:
                        const EdgeInsets.symmetric(
                      vertical: 18,
                    ),

                    border:
                        OutlineInputBorder(

                      borderRadius:
                          BorderRadius.circular(
                        16,
                      ),

                      borderSide:
                          BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 35),

                // =========================
                // BUTTON REGISTER
                // =========================
                SizedBox(

                  width: double.infinity,

                  height: 55,

                  child: ElevatedButton(

                    onPressed:
                        isLoading
                            ? null
                            : registerUser,

                    style:
                        ElevatedButton.styleFrom(

                      backgroundColor:
                          Colors.brown,

                      elevation: 0,

                      shape:
                          RoundedRectangleBorder(

                        borderRadius:
                            BorderRadius.circular(
                          16,
                        ),
                      ),
                    ),

                    child:
                        isLoading

                            ? const SizedBox(

                                height: 22,
                                width: 22,

                                child:
                                    CircularProgressIndicator(

                                  color:
                                      AppColors.card,

                                  strokeWidth: 2,
                                ),
                              )

                            : const Text(

                                "Sign Up",

                                style: TextStyle(

                                  color:
                                      AppColors.card,

                                  fontSize: 16,

                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                  ),
                ),

                const SizedBox(height: 35),

                // =========================
                // LOGIN
                // =========================
                Row(

                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  children: [

                    const Text(
                      "Sudah punya akun?",
                    ),

                    GestureDetector(

                      onTap: () {

                        Navigator.pop(context);
                      },

                      child: const Text(

                        " Sign In",

                        style: TextStyle(

                          color: Colors.brown,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}