import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:e_learning/interface/signup.dart';
import 'package:e_learning/interface/dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:e_learning/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool hidePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loginUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    // Validation belongs in the page
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email and password.')),
      );
      return;
    }

    try {
      await _authService.login(email, password);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Logged in successfully!')));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message ?? 'Login failed.')));
    }
  }

  Future<void> sendResetEmail() async {
    final email = emailController.text.trim();

    // Empty field validation
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address.')),
      );
      return;
    }

    // Basic email validation
    if (!email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address.')),
      );
      return;
    }

    try {
      await _authService.resetPassword(email);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset link sent. Please check your email.'),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message = 'Unable to send password reset email.';

      if (e.code == 'invalid-email') {
        message = 'Please enter a valid email address.';
      } else if (e.code == 'too-many-requests') {
        message = 'Too many attempts. Please try again later.';
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),

          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 70),

                      // Character Image
                      Center(
                        child: Image.asset(
                          'assets/images/login.png',
                          height: 130,
                          fit: BoxFit.contain,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Welcome Back
                      Center(
                        child: Text(
                          'Welcome Back!',
                          style: GoogleFonts.nunito(
                            fontSize: 27,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                      ),

                      const SizedBox(height: 3),

                      // Subtitle
                      Center(
                        child: Text(
                          'Good to see you again',
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Colors.grey,
                          ),
                        ),
                      ),

                      const SizedBox(height: 50),

                      // ================= EMAIL =================
                      Text(
                        'Email',
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 6),

                      _buildTextField(
                        controller: emailController,
                        hintText: 'Email address',
                        icon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 26),

                      // ================= PASSWORD =================
                      Text(
                        'Password',
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 6),

                      _buildTextField(
                        controller: passwordController,
                        hintText: 'Password',
                        icon: Icons.lock_outline,
                        obscureText: hidePassword,

                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              hidePassword = !hidePassword;
                            });
                          },
                          icon: Icon(
                            hidePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.grey,
                            size: 22,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ================= FORGOT PASSWORD =================
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: sendResetEmail,
                          child: Text(
                            'Forgot password?',
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFFF5555),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // ================= LOGIN BUTTON =================
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            loginUser();
                          },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),

                          child: Text(
                            'LOG IN',
                            style: GoogleFonts.nunito(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ================= SIGN UP =================
              Padding(
                padding: const EdgeInsets.only(bottom: 28, top: 20),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF333333),
                      ),
                    ),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpPage(),
                          ),
                        );
                      },

                      child: Text(
                        'SIGN UP',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF58C900),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // REUSABLE TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return SizedBox(
      height: 55,

      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,

        // Text entered by user
        style: GoogleFonts.nunito(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),

        decoration: InputDecoration(
          hintText: hintText,

          // Placeholder
          hintStyle: GoogleFonts.nunito(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF777777),
          ),

          prefixIcon: Icon(icon, color: const Color(0xFF909090), size: 25),

          suffixIcon: suffixIcon,

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD9D9D9), width: 1.5),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF6064F4), width: 2),
          ),
        ),
      ),
    );
  }
}
