import 'package:flashchat_app/components/rounded_button.dart';
import 'package:flashchat_app/constants/constants.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Hero(
              tag: 'logo',
              child: SizedBox(
                height: 200,
                child: Image.asset('images/logo.png'),
              ),
            ),
            const SizedBox(height: 48.0),
            TextField(
              style: const TextStyle(color: Colors.black),
              onChanged: (value) {},
              decoration: kTextFieldDecoration.copyWith(
                hintText: 'Enter your email',
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              style: const TextStyle(color: Colors.black),
              onChanged: (value) {},
              decoration: kTextFieldDecoration.copyWith(
                hintText: 'Enter your Password',
              ),
            ),
            RoundedButton(
              title: 'Log In',
              color: Colors.lightBlueAccent,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
