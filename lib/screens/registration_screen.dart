import 'package:flashchat_app/components/rounded_button.dart';
import 'package:flashchat_app/constants/constants.dart';
import 'package:flutter/material.dart';

class RegistrationScreen extends StatefulWidget {
  static const String id = 'registration_screen';
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => RegistrationScreenState();
}

class RegistrationScreenState extends State<RegistrationScreen> {
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
                height: 200.0,
                child: Image.asset('images/logo.png'),
              ),
            ),
            const SizedBox(
              height: 48.0,
            ),
            TextField(
                onChanged: (value) {},
                decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Enter an email to register',
                )),
            const SizedBox(
              height: 8.0,
            ),
            TextField(
                onChanged: (value) {},
                decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Create a password',
                )),
            const SizedBox(
              height: 24.0,
            ),
            RoundedButton(
              title: 'Register',
              color: Colors.blueAccent,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
