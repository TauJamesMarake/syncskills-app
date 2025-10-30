import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncskills/views/login_pages/signin_screen.dart';
import 'package:syncskills/views/profile_setup/profile_setup_screen.dart';
import 'package:syncskills/user_dashboard_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String email;
  final String password;
  final String? firstName;
  final String? lastName;
  final bool isSignUp;

  const OtpVerificationScreen({
    Key? key,
    required this.phoneNumber,
    required this.email,
    required this.password,
    this.firstName,
    this.lastName,
    required this.isSignUp,
  }) : super(key: key);

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final supabase = Supabase.instance.client;
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isVerifying = false;
  bool _isResending = false;

  String get _enteredCode =>
      _controllers.map((controller) => controller.text).join();

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  Future<void> _verifyOtp() async {
    if (_enteredCode.length != 6) return;

    setState(() => _isVerifying = true);

    try {
      // Verify the OTP code
      final response = await supabase.auth.verifyOTP(
        phone: widget.phoneNumber,
        token: _enteredCode,
        type: OtpType.sms,
      );

      final user = response.user;

      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Invalid code. Please try again."),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (widget.isSignUp) {
        // Sign up flow: Check if profile exists
        final existingProfile = await supabase
            .from('employee_details')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (existingProfile == null) {
          // Create initial profile entry
          await supabase.from('employee_details').insert({
            'id': user.id,
            'first_name': widget.firstName,
            'last_name': widget.lastName,
            'phone_number': widget.phoneNumber,
          });
        }

        if (mounted) {
          // Navigate to profile setup
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => ProfileSetupScreen()),
            (route) => false,
          );
        }
      } else {
        // Sign in flow: Check if profile is complete
        final profile = await supabase
            .from('employee_details')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (mounted) {
          if (profile == null || profile['first_name'] == null) {
            // Profile not complete, go to setup
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => ProfileSetupScreen()),
              (route) => false,
            );
          } else {
            // Profile complete, go to dashboard
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Welcome back!"),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => DashboardScreen()),
              (route) => false,
            );
          }
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        String errorMessage = "Verification failed";

        if (e.message.contains('invalid') || e.message.contains('expired')) {
          errorMessage = "Invalid or expired code. Please try again.";
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
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  Future<void> _resendCode() async {
    setState(() => _isResending = true);

    try {
      await supabase.auth.signInWithOtp(phone: widget.phoneNumber);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Code resent successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error resending code: $e"),
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
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5F5F5), Color(0xFFB8E6B8), Color(0xFF7DC97D)],
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
                        text: 'UpSkill.',
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
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Enter the 6-digit code sent to your phone",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.phoneNumber,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // OTP input boxes
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(6, (index) {
                            return SizedBox(
                              width: 50,
                              height: 50,
                              child: TextField(
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                onChanged: (value) => _onChanged(value, index),
                                maxLength: 1,
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: InputDecoration(
                                  counterText: '',
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFD0D0D0),
                                      width: 2,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF2D8F3C),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 24),

                        // Verify button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed:
                                (_enteredCode.length == 6 && !_isVerifying)
                                ? _verifyOtp
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF56AB2F),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
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
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Resend text
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Didn't get code? ",
                              style: TextStyle(fontSize: 15),
                            ),
                            _isResending
                                ? const SizedBox(
                                    height: 15,
                                    width: 15,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: _resendCode,
                                    child: const Text(
                                      "Click to resend.",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Center(
                          child: TextButton(
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
