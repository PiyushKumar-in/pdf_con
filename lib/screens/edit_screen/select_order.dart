import 'package:flutter/material.dart';
import 'package:pdf_con/screens/edit_screen/model.dart';

class SelectOrderPDF extends StatefulWidget {
  const SelectOrderPDF({super.key, required this.dataObj});
  final List<DataObject> dataObj;

  @override
  State<SelectOrderPDF> createState() => _SelectOrderPDFState();
}

class _SelectOrderPDFState extends State<SelectOrderPDF> {
  List<Widget> _current = [];
  @override
  void initState() {
    for (int i = 0; i < widget.dataObj.length; i++) {
      _current.add(
        PdfSwapTile(obj: widget.dataObj[i], index: i, func: moveRight),
      );
    }
    super.initState();
  }

  void moveRight(int index) {
    _current = [];
    final tmp = widget.dataObj[index - 1];
    widget.dataObj[index - 1] = widget.dataObj[index];
    widget.dataObj[index] = tmp;
    setState(() {
      for (int i = 0; i < widget.dataObj.length; i++) {
        _current.add(
          PdfSwapTile(obj: widget.dataObj[i], index: i, func: moveRight),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, consts) {
        return GridView.count(
          crossAxisCount: (consts.maxWidth / 200).toInt(),
          children: _current,
        );
      },
    );
  }
}

class PdfSwapTile extends StatelessWidget {
  const PdfSwapTile({
    super.key,
    required this.obj,
    required this.index,
    required this.func,
  });
  final DataObject obj;
  final int index;
  final void Function(int index) func;

  @override
  Widget build(BuildContext context) {
    String name;
    if (obj.name.toLowerCase().contains('.pdf')) {
      name = "Page: ${obj.page}, File: ${obj.name}";
    } else {
      name = "Image: ${obj.name}";
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Tooltip(
        message: name,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(color: Colors.black12),
                child: obj.img,
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withAlpha(150),
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Page: ${index + 1}",
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
            if (index != 0)
              Positioned.fill(
                child: Center(
                  child: FilledButton(
                    onPressed: () {
                      func(index);
                    },
                    child: Text("< Move Right"),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
