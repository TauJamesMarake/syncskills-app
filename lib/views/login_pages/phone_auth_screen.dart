import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _otpSent = false;
  String? _errorMessage;

  final supabase = Supabase.instance.client;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sednOTP() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (mounted) {
        final phone = _phoneController.text.trim();

        await supabase.auth.signInWithOtp(phone: phone);

        setState(() {
          _otpSent = true;
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('OTP sent successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } on AuthException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occured';
      });
    }
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter the OTP';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final otp = _otpController.text.trim();
      final phone = _phoneController.text.trim();

      final response = await supabase.auth.verifyOTP(
        type: OtpType.sms,
        phone: phone,
        token: otp,
      );

      if (response.session != null) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(title: const Text('Home')),
                body: const Center(child: const Text('Logged in succefully')),
              ),
            ),
          );
        }
        // if (mounted) {
        //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Phone number verified succefully'),
        //   backgroundColor: Colors.green,),);
        // }
      }
    } on AuthException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An unexpected error occurred';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Phone Authentication Screen')),
    );
  }
}
