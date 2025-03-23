import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img_man;
import 'package:flutter/material.dart';
import 'package:pdf_con/screens/edit_screen/model.dart';
import 'package:pdf_con/screens/edit_screen/select_order.dart';
import 'package:pdf_render/pdf_render.dart';

class PdfDisplay extends StatefulWidget {
  const PdfDisplay({
    super.key,
    required this.pickedResult,
    required this.changeHeading,
  });
  final void Function(String str) changeHeading;

  final FilePickerResult pickedResult;

  @override
  State<PdfDisplay> createState() => _PdfDisplayState();
}

class _PdfDisplayState extends State<PdfDisplay> {
  List<DataObject> dataObj = [];
  Map<DataObject, bool> current = {};
  Widget? _selectOrder;
  List<DataObject> _selectedDataObj = [];

  void setup() async {
    final res = await compute(getImages, widget.pickedResult.files);
    setState(() {
      dataObj = res;
      _selectedDataObj = dataObj;
    });
    widget.changeHeading("Select Images");
  }

  void update(DataObject obj) {
    if (current.containsKey(obj)) {
      current[obj] = !current[obj]!;
      setState(() {
        _selectedDataObj =
            dataObj.where((elem) => (current[elem] == true)).toList();
      });
    } else {
      current[obj] = true;
    }
  }

  @override
  void initState() {
    setup();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (dataObj.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 8),
            Text(
              "Opening PDF...",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );
    }
    if (_selectOrder != null) return _selectOrder!;
    return Stack(
      children: [
        Positioned.fill(
          child: LayoutBuilder(
            builder: (ctx, consts) {
              return GridView.count(
                crossAxisCount: (consts.maxWidth / 200).toInt(),
                children:
                    dataObj
                        .map(
                          (elem) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: PdfDisplayTile(obj: elem, func: update),
                          ),
                        )
                        .toList(),
              );
            },
          ),
        ),
        Positioned.fill(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(
                width: 300,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed:
                      (_selectedDataObj.isEmpty)
                          ? null
                          : () {
                            setState(() {
                              _selectOrder = SelectOrderPDF(
                                dataObj: _selectedDataObj,
                              );
                            });
                            widget.changeHeading("Choose Order");
                          },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Next: Choose Order",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      SizedBox(width: 5),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }
}

class PdfDisplayTile extends StatefulWidget {
  const PdfDisplayTile({super.key, required this.obj, required this.func});
  final DataObject obj;
  final void Function(DataObject obj) func;

  @override
  State<PdfDisplayTile> createState() => _PdfDisplayTileState();
}

class _PdfDisplayTileState extends State<PdfDisplayTile> {
  bool selected = true;
  late String _name;

  @override
  void initState() {
    if (widget.obj.name.toLowerCase().contains('.pdf')) {
      _name = "Page: ${widget.obj.page}, File: ${widget.obj.name}";
    } else {
      _name = "Image: ${widget.obj.name}";
    }
    widget.func(widget.obj);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: _name,
      child: InkWell(
        onTap: () {
          setState(() {
            selected = !selected;
          });
          widget.func(widget.obj);
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(color: Colors.black12),
                child: widget.obj.img,
              ),
            ),
            if (selected)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withAlpha(100),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 40,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

Future<List<DataObject>> getImages(List<PlatformFile> tmp) async {
  List<DataObject> objects = [];

  for (PlatformFile file in tmp) {
    if (file.bytes == null) continue;

    if (file.extension != 'pdf') {
      objects.add(
        DataObject(
          img: Image.memory(
            file.bytes!,
            height: 200,
            width: 200,
            fit: BoxFit.contain,
          ),
          name: file.name,
        ),
      );
    } else {
      final doc = await PdfDocument.openFile(file.path!);

      for (int i = 1; i < doc.pageCount; i++) {
        final page = await doc.getPage(i);
        final image = await page.render();
        final img = await image.createImageDetached();
        final bytesData = await img.toByteData(format: ImageByteFormat.png);

        final dec = img_man.decodePng(bytesData!.buffer.asUint8List())!;
        final buff = img_man.encodePng(img_man.flipVertical(dec));

        objects.add(
          DataObject(
            img: Image.memory(
              buff,
              height: 200,
              width: 200,
              fit: BoxFit.contain,
            ),
            name: file.name,
            page: i,
          ),
        );
      }
    }
  }
  return objects;
}
