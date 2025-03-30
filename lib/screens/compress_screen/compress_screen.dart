import 'package:download/download.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf_con/captcha.dart';
import 'dart:html' as html;

class CompressScreen extends StatefulWidget {
  const CompressScreen({super.key});

  @override
  State<CompressScreen> createState() => _CompressScreenState();
}

class _CompressScreenState extends State<CompressScreen> {
  void compressPDF() async {
    print(html.window.location);
    FilePickerResult? res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      allowedExtensions: ['pdf'],
    );

    if (res != null && res.count != 0) {
      for (final file in res.files) {
        final url = Uri.parse("http://localhost/compress");
        final req = http.MultipartRequest("POST", url);
        req.files.add(
          http.MultipartFile.fromBytes(
            "file",
            file.bytes!,
            filename: file.name,
          ),
        );
        final response = await req.send();
        if (response.statusCode == 200) {
          final data = await response.stream.toBytes();
          download(Stream.fromIterable(data), "compressed_${file.name}");
          if (context.mounted) {
            showDialog(
              context: context,
              builder:
                  (ctx) => AlertDialog(
                    content: Captcha(
                      ctx: ctx,
                      size:
                          (MediaQuery.of(context).size.shortestSide < 500)
                              ? 200
                              : 300,
                    ),
                  ),
              barrierDismissible: false,
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Compress PDF",
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
