import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncskills/views/login_pages/signin_screen.dart';
import 'package:syncskills/views/profile_setup/profile_setup_screen.dart';

class CheckEmailPage extends StatefulWidget {
  final String email;
  final String? firstName;
  final String? lastName;
  final String? department;

  const CheckEmailPage({
    super.key,
    required this.email,
    this.firstName,
    this.lastName,
    this.department,
  });

  @override
  _CheckEmailPageState createState() => _CheckEmailPageState();
}

class _CheckEmailPageState extends State<CheckEmailPage> {
  final supabase = Supabase.instance.client;
  final _otpController = TextEditingController();
  bool _isVerifying = false;
  bool _isResending = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> verifyOtp() async {
    final otpCode = _otpController.text.trim();

    if (otpCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the verification code')),
      );
      return;
    }

    if (otpCode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a 6-digit code')),
      );
      return;
    }

    setState(() => _isVerifying = true);

    try {
      // Verify OTP
      final response = await supabase.auth.verifyOTP(
        type: OtpType.email,
        email: widget.email,
        token: otpCode,
      );

      if (response.user != null) {
        final userId = response.user!.id;

        // Insert into users table
        await supabase.from('users').upsert({
          'id': userId,
          'email': widget.email,
          'created_at': DateTime.now().toIso8601String(),
        }, onConflict: 'id');

        // Insert into employee_details table - store department as text
        await supabase.from('employee_details').upsert({
          'id': userId,
          'first_name': widget.firstName,
          'last_name': widget.lastName,
          'department': widget.department, // Store department name directly
        }, onConflict: 'id');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email verified successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => ProfileSetupScreen()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid or expired code. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        String errorMessage = 'Verification failed';

        if (e.message.contains('Token has expired')) {
          errorMessage = 'Code has expired. Please request a new one.';
        } else if (e.message.contains('Invalid')) {
          errorMessage = 'Invalid code. Please check and try again.';
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
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  Future<void> resendOtp() async {
    setState(() => _isResending = true);

    try {
      await supabase.auth.resend(type: OtpType.signup, email: widget.email);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('A new 6-digit code was sent to your email'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending code: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5F5F5), Color(0xFFB8E6B8), Color(0xFF7DC97D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'SYNCSKILLS',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D8F3C),
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(
                        text: 'Audit.',
                        style: TextStyle(color: Colors.black),
                      ),
                      TextSpan(
                        text: ' UpSkill.',
                        style: TextStyle(color: Color(0xFFFDB913)),
                      ),
                      TextSpan(
                        text: ' Excel',
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // White Card
                Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 450),
                    padding: const EdgeInsets.all(32.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Check your e-mail.',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'We sent a 6-digit verification code to\n${widget.email}',
                          style: const TextStyle(fontSize: 14, height: 1.5),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Please enter the code below to verify your email and continue.',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),

                        // OTP input
                        TextField(
                          controller: _otpController,
                          decoration: const InputDecoration(
                            labelText: "Enter 6-digit code",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 8,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Verify button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isVerifying ? null : verifyOtp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF56AB2F),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: _isVerifying
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    "Verify",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Resend OTP
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Didn't receive the code? ",
                              style: TextStyle(fontSize: 14),
                            ),
                            GestureDetector(
                              onTap: _isResending ? null : resendOtp,
                              child: Text(
                                _isResending ? 'Sending...' : 'Resend',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _isResending
                                      ? Colors.grey
                                      : const Color(0xFF2D8F3C),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Back to sign in
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignInScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Back to Sign In",
                            style: TextStyle(
                              color: Colors.grey,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
