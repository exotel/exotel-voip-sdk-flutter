import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/exotelSDK/ExotelSDKClient.dart';

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
    ExotelSDKClient.getInstance().sendDtmf(dtmfInput);
  }

  // Widget buildKey(String key) {
  //   return Expanded(
  //     child: TextButton(
  //       child: Text(key, style: TextStyle(fontSize: 36.0)),
  //       onPressed: () => handleKeyTap(key),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
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
            SizedBox(height: 10 ),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              childAspectRatio: 2,
              padding: EdgeInsets.all(50),
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
                      foregroundColor: Colors.black, backgroundColor: Colors.grey.shade400, // text color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ), // shape of button
                      elevation: 5, // elevation of button
                    ),
                  ),
                );
              }).toList(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 135.0, vertical: 10),
              child: ElevatedButton(
              child: Text('HIDE KEYPAD',style: TextStyle(color: Colors.black),),
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
              padding: const EdgeInsets.symmetric(horizontal: 125.0, vertical: 250),
              child: Container(
                padding: EdgeInsets.all(16.0), // Add padding to the container
                decoration: BoxDecoration(
                  color: Colors.grey.shade200, // Set box color to grey
                  borderRadius: BorderRadius.circular(10.0), // Add border radius
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
