import 'package:flutter/material.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registration"),
        backgroundColor: Colors.green,
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 2) {
            setState(() => _currentStep += 1);
          }
        },
        steps: [
          Step(
            title: const Text("Account Type"),
            content: Column(
              children: [
                _buildOptionButton("Register as Service Provider"),
                const SizedBox(height: 15),
                _buildOptionButton("Register as Normal User"),
                const SizedBox(height: 15),
                _buildOptionButton("Signup For Training"),
                const SizedBox(height: 15),
                _buildOptionButton("Request For Advert"),
              ],
            ),
          ),
          Step(
            title: const Text("Basic Information"),
            content: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: "Name"),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: "Phone Number"),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: "Gender"),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: "Resident Address"),
                ),
              ],
            ),
          ),
          Step(
            title: const Text("Location & Security"),
            content: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: "Location"),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: "Email Address"),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: "Password"),
                  obscureText: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(String text) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(text),
      ),
    );
  }
}