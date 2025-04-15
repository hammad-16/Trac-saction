import 'package:flutter/material.dart';
import 'package:khatabook/main.dart';
import 'package:khatabook/services/business_name.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _showTextField = false;
  String typedName = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        title: const Text("Settings"),
      ),
      body: Column(
        children: [
          Container(
            height: 62,
            width: 360,
            child: Card(
              color: Colors.grey.shade100,
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text(
                      "Change User Name",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showTextField = true;
                      });

                      // Focus after UI builds
                      Future.delayed(const Duration(milliseconds: 100), () {
                        FocusScope.of(context).requestFocus(_focusNode);
                      });
                    },
                    child: const Icon(Icons.keyboard_arrow_right, size: 35),
                  ),
                ],
              ),
            ),
          ),

          // Show TextField if activated
          if (_showTextField)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _nameController,
                focusNode: _focusNode,
                onChanged: (value) {
                  setState(() {
                    BusinessName.name = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Enter your name',
                  border: OutlineInputBorder(),
                ),
              ),
            ),

        ],
      ),
    );
  }
}
