import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pdf_con/screens/edit_screen/pdf_display.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({super.key});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  Widget? _tmp;
  String _heading = "Upload PDF/Images";

  void changeHeading(String str) {
      setState(() {
        _heading = str;
      });
    }

  void uploadPDF() async {
    FilePickerResult? res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      allowedExtensions: ['pdf', 'jpeg', 'png', 'svg'],
    );

    if (res != null || res!.count == 0) {
      setState(() {
        _tmp = PdfDisplay(pickedResult: res, changeHeading: changeHeading);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_heading, style: Theme.of(context).textTheme.bodyLarge),
      ),
      body:
          (_tmp == null)
              ? Center(
                child: SizedBox(
                  width: 200,
                  child: OutlinedButton(
                    onPressed: uploadPDF,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.upload_rounded),
                        Text("Upload PDF"),
                      ],
                    ),
                  ),
                ),
              )
              : _tmp,
    );
  }
}
