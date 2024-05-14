import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/main.dart';

import '../Utils/ApplicationUtils.dart';

class DtmfPage extends StatefulWidget {
  @override
  _DtmfPageState createState() => _DtmfPageState();
}

class _DtmfPageState extends State<DtmfPage> {
  String dtmfInput = '';

  void handleKeyTap(String key) {
    setState(() {
      dtmfInput = key; // store only the last pressed key
    });
    ApplicationUtils.getInstance(context).sendDtmf(dtmfInput);
  }

  @override
  Widget build(BuildContext context) {
    final double appBarHeight = MediaQuery.of(context).size.height * 0.1;
    final double buttonPadding = MediaQuery.of(context).size.width * 0.1;
    final double keypadSize = MediaQuery.of(context).size.width * 0.7;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Exotel Voice Application',
          style: TextStyle(color: Colors.white), // Set text color to white
        ),
        backgroundColor: const Color(0xFF0800AF), // Set the app bar color to deep blue
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: appBarHeight),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              childAspectRatio: 2,
              padding: EdgeInsets.all(buttonPadding),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: <String>[
                '1', '2', '3',
                '4', '5', '6',
                '7', '8', '9',
                '*', '0', '#',
              ].map((key) {
                return Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: ElevatedButton(
                    onPressed: () => handleKeyTap(key),
                    child: Text(key, style: TextStyle(fontSize: 20, color: Colors.black87)),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.grey.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                      elevation: 5,
                    ),
                  ),
                );
              }).toList(),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: buttonPadding * 3, vertical: buttonPadding),
              child: ElevatedButton(
                child: Text('HIDE KEYPAD', style: TextStyle(color: Colors.black)),
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: buttonPadding, vertical: MediaQuery.of(context).size.height * 0.3),
              child: Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  'DTMF Input: $dtmfInput',
                  style: TextStyle(fontSize: 20.0, color: Colors.grey.shade700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
