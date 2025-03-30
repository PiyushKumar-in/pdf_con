import 'package:flutter/material.dart';
import 'package:pdf_con/captcha.dart';
import 'package:pdf_con/screens/edit_screen/edit_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Select Task",
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  SizedBox(height: 50),
                  SizedBox(
                    width: 210,
                    child: OutlinedButton(
                      onPressed: () {},
                      child: Text("Merge PDF/Image"),
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: 210,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => EditScreen()),
                        );
                      },
                      child: Text("Edit PDF/Image"),
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: 210,
                    child: OutlinedButton(
                      onPressed: () {},
                      child: Text("Compress PDF/Image"),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Made with 💖 by Piyush Kumar\nin India",
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
