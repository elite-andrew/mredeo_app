import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:redeo_app/config/app_routes.dart';
import 'package:redeo_app/widgets/common/app_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),

              // Circle Avatar (Left aligned)
              const CircleAvatar(
                radius: 40,
                backgroundColor: Color(0xFF6A7180),
              ),

              const SizedBox(height: 30),

              // Welcome Text
              const Text(
                'Welcome to  MREDEO Pay',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please enter your registration number and password.',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 30),

              // Email/Phone Input
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAFBF0),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: Colors.black38),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Email or Phone Number',
                    hintStyle: TextStyle(
                      color: Colors.grey, // softer placeholder color
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 23),

              // Password Input
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAFBF0),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: Colors.black38),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        obscureText: _obscurePassword,
                        decoration: const InputDecoration(
                          hintText: 'Password',
                          hintStyle: TextStyle(
                            color: Colors.grey, // softer placeholder color
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      child: Text(
                        _obscurePassword ? 'Show' : 'Hide',
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 120),

              // Sign In Button
              AppButton(
                onPressed: () {
                  context.go(AppRoutes.login);
                },
                text: 'Sign In',
              ),


              const Spacer(),

              // Bottom Links
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      // TODO: join/signup
                    },
                    child: const Text(
                      'Join',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.go(AppRoutes.forgotPassword);
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
