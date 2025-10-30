import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncskills/views/login_pages/check_email_page.dart';
//import 'package:syncskills/views/login_pages/check_email_page.dart';
import 'package:syncskills/views/login_pages/otp_screen.dart';
import 'package:syncskills/views/login_pages/signin_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  bool _isButtonEnabled = false;
  bool _isLoading = false;

  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _firstNameController.addListener(_checkForm);
    _emailController.addListener(_checkForm);
    _passwordController.addListener(_checkForm);
    _confirmPasswordController.addListener(_checkForm);
    _lastNameController.addListener(_checkForm);
    _phoneNumberController.addListener(_checkForm);
  }

  void _checkForm() {
    setState(() {
      _isButtonEnabled =
          _firstNameController.text.isNotEmpty &&
          _lastNameController.text.isNotEmpty &&
          _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _phoneNumberController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> signUp() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    final phoneNumber = _phoneNumberController.text.trim();

    if (phoneNumber.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone numbers must be at least 10 characters long.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters long.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Perform sign up with Supabase auth
      final signUpResponse = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'first_name': _firstNameController.text.trim(),
          'last_name': _lastNameController.text.trim(),
        },
      );

      // Extract the auth user id
      final String? authUserId = signUpResponse.user?.id;

      if (authUserId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Signup failed. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // // Insert into your "users" table
      // await supabase.from('users').upsert({
      //   'id': authUserId,
      //   'email': email,
      //   // 'first_name': _firstNameController.text.trim(),
      //   // 'last_name': _lastNameController.text.trim(),
      //   // 'role': 'employee',
      //   'created_at': DateTime.now().toIso8601String(),
      // }, onConflict: 'id');

      // // Insert into your "employee_details" table
      // await supabase.from('employee_details').upsert({
      //   'id': authUserId,
      //   'first_name': _firstNameController.text.trim(),
      //   'last_name': _lastNameController.text.trim(),
      // }, onConflict: 'id');

      // Navigate to CheckEmailPage for OTP verification
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CheckEmailPage(
              email: email,

              firstName: _firstNameController.text,
              lastName: _lastNameController.text,
              // isSignUp: true,
              // phoneNumber: phoneNumber,
              // password: password,
            ),
          ),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        String errorMessage = 'Sign up failed';

        if (e.message.contains('User already registered')) {
          errorMessage = 'This email is already registered. Please sign in.';
        } else if (e.message.contains('Invalid email')) {
          errorMessage = 'Please enter a valid email address.';
        } else {
          errorMessage = e.message;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unexpected error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';
    if (!value.contains('@')) return 'Please enter a valid email address';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value))
      return 'Please enter a valid email address';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Logo and tagline section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Column(
                children: [
                  const Text(
                    'SYNCSKILLS',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D8F3C),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: 'Audit. ',
                          style: TextStyle(color: Colors.black),
                        ),
                        TextSpan(
                          text: 'Upskill. ',
                          style: TextStyle(color: Color(0xFFFDB913)),
                        ),
                        TextSpan(
                          text: 'Excel',
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Green rounded section
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFD4F1D4),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(60)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Header section
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            'SIGN UP',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        _buildTextField(
                          controller: _firstNameController,
                          hint: 'First Name',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your first name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        _buildTextField(
                          controller: _lastNameController,
                          hint: 'Last Name',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your last name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        _buildTextField(
                          controller: _emailController,
                          hint: 'Email',
                          validator: _validateEmail,
                        ),

                        const SizedBox(height: 18),

                        _buildTextField(
                          controller: _phoneNumberController,
                          hint: 'Phone Number',
                          obscure: false,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your phone number';
                            }
                            if (value.length < 10) {
                              return 'Phone number must be at least 10 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        _buildTextField(
                          controller: _passwordController,
                          hint: 'Password',
                          obscure: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        _buildTextField(
                          controller: _confirmPasswordController,
                          hint: 'Confirm Password',
                          obscure: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Sign Up button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: (_isButtonEnabled && !_isLoading)
                                ? signUp
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1B7A2A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'SIGN UP',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Sign in link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Already have an account? ",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SignInScreen(),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                              ),
                              child: const Text(
                                'Sign in',
                                style: TextStyle(
                                  color: Color(0xFF2D8F3C),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Divider
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                color: Colors.black26,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                'or',
                                style: TextStyle(color: Colors.black54),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 1,
                                color: Colors.black26,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Google button placeholder
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // TODO: Implement Google Sign Up
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1B7A2A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            icon: const Text(
                              'G',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            label: const Text(
                              'Sign up with Google',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color.fromARGB(248, 105, 105, 105),
            fontSize: 16,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
          errorStyle: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}
