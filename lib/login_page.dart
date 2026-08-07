import 'package:ecommerce_app/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'register_page.dart';
import 'home_page.dart';
import 'admin_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() =>
      _LoginPageState();
}

class _LoginPageState
    extends State<LoginPage> {

  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  bool isLoading = false;

  bool obscurePassword = true;

  // =====================================
  // LOGIN USER
  // =====================================
  Future<void> loginUser() async {

    String email =
        emailController.text.trim();

    String password =
        passwordController.text.trim();

    // VALIDASI
    if (
        email.isEmpty ||
        password.isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            "Email dan password wajib diisi",
          ),
        ),
      );

      return;
    }

    setState(() => isLoading = true);

    try {

      // ================================
      // LOGIN FIREBASE
      // ================================
      UserCredential userCredential =
          await FirebaseAuth.instance
              .signInWithEmailAndPassword(

        email: email,
        password: password,
      );

      // ================================
      // UID
      // ================================
      String uid =
          userCredential.user!.uid;

      // ================================
      // AMBIL DATA USER
      // ================================
      DocumentSnapshot userData =
          await FirebaseFirestore.instance
              .collection("users")
              .doc(uid)
              .get();

      // ================================
      // DEFAULT ROLE
      // ================================
      String role = "user";

      // ================================
      // JIKA ADA ROLE
      // ================================
      if (userData.exists) {

        final data =
            userData.data()
                as Map<String, dynamic>;

        role =
            data.containsKey("role")
                ? data["role"]
                : "user";
      }

      // ================================
      // NAVIGATE
      // ================================
      if (!mounted) return;
      if (role == "admin") {

        Navigator.pushReplacement(
          context,

          MaterialPageRoute(
            builder: (_) =>
                const AdminPage(),
          ),
        );

      } else {

        Navigator.pushReplacement(
          context,

          MaterialPageRoute(
            builder: (_) =>
                const HomePage(),
          ),
        );
      }

    } on FirebaseAuthException catch (e) {

      String message = "Login gagal";

      if (e.code ==
          'user-not-found') {

        message =
            "Email tidak ditemukan";

      } else if (
          e.code ==
              'wrong-password') {

        message = "Password salah";

      } else if (
          e.code ==
              'invalid-email') {

        message =
            "Format email tidak valid";
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(message),
        ),
      );

    } catch (e) {

      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  void dispose() {

    emailController.dispose();
    passwordController.dispose();

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

                const SizedBox(height: 60),

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

                  "Welcome Back",

                  style: TextStyle(

                    fontSize: 28,

                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(

                  "Login untuk melanjutkan",

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

                const SizedBox(height: 35),

                // =========================
                // BUTTON LOGIN
                // =========================
                SizedBox(

                  width: double.infinity,

                  height: 55,

                  child: ElevatedButton(

                    onPressed:
                        isLoading
                            ? null
                            : loginUser,

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

                                "Sign In",

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
                // REGISTER
                // =========================
                Row(

                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  children: [

                    const Text(
                      "Belum punya akun?",
                    ),

                    GestureDetector(

                      onTap: () {

                        Navigator.push(

                          context,

                          MaterialPageRoute(
                            builder: (_) =>
                                RegisterPage(),
                          ),
                        );
                      },

                      child: const Text(

                        " Sign Up",

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