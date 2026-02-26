import 'package:flutter/material.dart';

class Question {
  static Widget question() {
    return const Text(
      "What do you want to learn?",
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }
}