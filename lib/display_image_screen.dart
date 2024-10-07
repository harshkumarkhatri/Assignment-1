import 'dart:io';

import 'package:flutter/material.dart';

class DisplayImageScreen extends StatelessWidget {
  const DisplayImageScreen({
    super.key,
    required this.imagePath,
  });

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Display picture",
        ),
      ),
      body: Image.file(
        File(
          imagePath,
        ),
      ),
    );
  }
}
