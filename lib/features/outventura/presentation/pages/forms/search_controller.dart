import 'package:flutter/material.dart';

class SearchFieldController {
  final TextEditingController controller = TextEditingController();
  String query = '';

  void clear() {
    controller.clear();
    query = '';
  }

  void dispose() => controller.dispose();
}
