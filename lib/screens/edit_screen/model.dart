import 'package:flutter/material.dart';

class DataObject {
  const DataObject({required this.img, required this.name, this.page = 0});

  final String name;
  final int page;
  final Image img;
}
