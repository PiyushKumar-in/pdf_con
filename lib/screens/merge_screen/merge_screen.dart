import 'package:download/download.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'dart:html' as html;

class MergeScreen extends StatefulWidget {
  const MergeScreen({super.key});

  @override
  State<MergeScreen> createState() => MergeScreenState();
}

class MergeScreenState extends State<MergeScreen> {
  void compressPDF() async {
    // print(html.window.location);
    FilePickerResult? res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      allowedExtensions: ['pdf'],
    );

    if (res != null && res.count != 0) {
      final url = Uri.parse("http://localhost/merge");
      final req = http.MultipartRequest("POST", url);
      for (int i = 0; i < res.files.length; i++) {
        req.files.add(
          http.MultipartFile.fromBytes(
            "file$i",
            res.files[i].bytes!,
            filename: res.files[i].name,
          ),
        );
      }
      final response = await req.send();
      if (response.statusCode == 200) {
        final data = await response.stream.toBytes();
        download(Stream.fromIterable(data), "merged_${res.files[0].name}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Merge PDF",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
      body: Center(
        child: SizedBox(
          width: 200,
          child: OutlinedButton(
            onPressed: compressPDF,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Icon(Icons.upload_rounded), Text("Upload PDF")],
            ),
          ),
        ),
      ),
    );
  }
}
