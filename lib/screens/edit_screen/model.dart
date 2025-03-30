import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class DataObject {
  const DataObject({required this.img, required this.name,required this.file, this.page = 0});

  final String name;
  final int page;
  final Image img;
  final PlatformFile file;
}
