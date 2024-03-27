import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/ExotelSDKClient.dart';

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
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final String dialTo = arguments['dialTo'];
    final String userId = arguments['userId'];
    final String password = arguments['password'];
    final String displayName = arguments['displayName'];
    final String accountSid = arguments['accountSid'];
    final String hostname = arguments['hostname'];

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
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              childAspectRatio: 2,
              padding: EdgeInsets.all(20),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: <String>[
                '1', '2', '3',
                '4', '5', '6',
                '7', '8', '9',
                '*', '0', '#',
              ].map((key) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () => handleKeyTap(key),
                    child: Text(key, style: TextStyle(fontSize: 24)),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.grey.shade500, // text color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ), // shape of button
                      elevation: 10, // elevation of button
                    ),
                  ),
                );
              }).toList(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 125.0, vertical: 0),
              child: Text(
                'DTMF Input: $dtmfInput',
                style: TextStyle(fontSize: 24.0, color: Colors.grey.shade700), // Change the text color to grey
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 125.0, vertical: 0),
              child: ElevatedButton(
              child: Text('HIDE KEYPAD',style: TextStyle(color: Colors.white),),
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
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
