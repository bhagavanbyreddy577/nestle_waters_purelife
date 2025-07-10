import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nestle_waters_purelife/features/auth/signin/presentation/bloc/signin_bloc.dart';
import 'package:nestle_waters_purelife/features/auth/signin/screens/signin.dart';
import 'package:nestle_waters_purelife/features/auth/signup/presentation/bloc/signup_bloc.dart';
import 'package:nestle_waters_purelife/features/auth/signup/presentation/screens/signup.dart';
import 'package:nestle_waters_purelife/features/auth/signup/presentation/screens/signup_screen.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: TabBar(
            indicator: UnderlineTabIndicator(borderSide: BorderSide(width: 6.0,color: Colors.black),
            insets: EdgeInsets.symmetric(horizontal: 120.0)),
             
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 19) ,
            indicatorColor: Colors.black,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
            tabs: [
              Tab(text: 'Sign in'),
              Tab(text: 'Sign up'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            BlocProvider(
              create: (_) => SigninBloc(),
              child: Signin(),
            ),
            BlocProvider(
              create: (_) => SignupBloc(),
              child: Signup(),
            ),
          ],
        ),
      ),
    );
  }
}

class ContinueButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool enabled;

  const ContinueButton(
      {super.key, required this.onPressed, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            color: Colors.transparent,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Left part: Continue text
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: const BoxDecoration(
                  color: Color(0xFFE6007E), // Magenta pink
                  borderRadius:
                      BorderRadius.horizontal(left: Radius.circular(40)),
                ),
                alignment: Alignment.center,
                height: double.infinity,
                child: const Text(
                  "Continue",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Right part: Arrow icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFF001F3F), // Dark navy
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
