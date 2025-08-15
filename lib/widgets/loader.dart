import 'package:flutter/material.dart';
import 'dart:async';

class Loader extends StatefulWidget {
  const Loader({super.key});

  @override
  State<Loader> createState() => _LoaderState();
}

class _LoaderState extends State<Loader> {
  final List<Color> _colors = [
    Colors.green,
    Colors.blue,
    Colors.red,
    Colors.orange,
    Colors.purple,
  ];
  Color _currentColor = Colors.green;
  int _currentIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _currentColor = _colors[_currentIndex];
    _timer = Timer.periodic(const Duration(milliseconds: 700), (timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % _colors.length;
        _currentColor = _colors[_currentIndex];
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: _currentColor,
      ),
    );
  }
}