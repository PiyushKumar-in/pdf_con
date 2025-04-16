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
  void compressPDF(String compression) async {
    print(html.window.location);
    FilePickerResult? res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      allowedExtensions: ['pdf'],
    );

    if (res != null && res.count != 0) {
      for (final file in res.files) {
        final url = Uri.parse("http://localhost:8080/compress");
        final req = http.MultipartRequest("POST", url);
        req.fields["compression"] = compression;
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
        } else if (response.statusCode == 501 && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Could not Compress with given constraints 😞"),
            ),
          );
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
            onPressed: () {
              String compression = "low";
              showDialog(
                context: context,
                barrierDismissible: false,
                builder:
                    (ctx) => AlertDialog(
                      title: Text("Select Compression"),
                      actions: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                OutlinedButton(
                                  onPressed: () {
                                    compression = "low";
                                    compressPDF(compression);
                                    Navigator.of(ctx).pop();
                                  },
                                  child: Text("Low"),
                                ),
                                SizedBox(width: 20),
                                OutlinedButton(
                                  onPressed: () {
                                    compression = "medium";
                                    compressPDF(compression);
                                    Navigator.of(ctx).pop();
                                  },
                                  child: Text("Medium"),
                                ),
                                SizedBox(width: 20),
                                OutlinedButton(
                                  onPressed: () {
                                    compression = "high";
                                    compressPDF(compression);
                                    Navigator.of(ctx).pop();
                                  },
                                  child: Text("High"),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                OutlinedButton(
                                  onPressed: () {
                                    compression = "30";
                                    compressPDF(compression);
                                    Navigator.of(ctx).pop();
                                  },
                                  child: Text("< 30%"),
                                ),
                                SizedBox(width: 20),
                                OutlinedButton(
                                  onPressed: () {
                                    compression = "50";
                                    compressPDF(compression);
                                    Navigator.of(ctx).pop();
                                  },
                                  child: Text("< 50%"),
                                ),
                                SizedBox(width: 20),
                                OutlinedButton(
                                  onPressed: () {
                                    compression = "80";
                                    compressPDF(compression);
                                    Navigator.of(ctx).pop();
                                  },
                                  child: Text("< 80%"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
              );
            },
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
