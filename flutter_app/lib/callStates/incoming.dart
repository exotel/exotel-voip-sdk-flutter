import 'package:flutter/material.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/exotelSDK/ExotelSDKClient.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:flutter_app/UI/home_page.dart';
import '../Utils/ApplicationUtils.dart';
class Incoming extends StatefulWidget {
  @override
  _IncomingState createState() => _IncomingState();
}

class _IncomingState extends State<Incoming> {

  @override
  Widget build(BuildContext context) {
    var mApplicationUtil = ApplicationUtils.getInstance(context);
    final String? dialTo = mApplicationUtil.mDialTo;
    final String? destination = mApplicationUtil.mDestination;


    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Exotel Voice Application',
          style: TextStyle(color: Colors.white), // Set text color to white
        ),
        backgroundColor: const Color(0xFF0800AF), // Set the app bar color to deep blue
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // This will center the column horizontally
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1, vertical: MediaQuery.of(context).size.height * 0.05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.2, bottom: MediaQuery.of(context).size.height * 0.02),
                  child: Text(destination!, style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.08)),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.02),
                  child: Text('Incoming', style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.06)),
                ),
                Padding(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.05, bottom: MediaQuery.of(context).size.height * 0.02),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          ExotelSDKClient.getInstance().answer();
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            Navigator.pushReplacementNamed(
                              context,
                              '/connected',
                            );
                          });
                        },
                        child: ClipOval(
                          child: Image.asset(
                            'assets/btn_call_normal.png',
                            width: MediaQuery.of(context).size.width * 0.13,
                            height: MediaQuery.of(context).size.width * 0.13,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.1), // Add space
                      GestureDetector(
                        onTap: () {
                          ExotelSDKClient.getInstance().hangup();
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            Navigator.pushReplacementNamed(
                              context,
                              '/home',
                            );
                          });
                        },
                        child: ClipOval(
                          child: Image.asset(
                            'assets/btn_hungup_normal.png',
                            width: MediaQuery.of(context).size.width * 0.13,
                            height: MediaQuery.of(context).size.width * 0.13,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.4,
            child: ElevatedButton(
              onPressed: () {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushNamed(
                    context,
                    '/dtmf',
                  );
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF969698), // Set the button color to blue
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
              child: const Text(
                'SHOW KEYPAD',
                style: TextStyle(color: Colors.black), // Set text color to white
              ),
            ),
          ),
        ],
      ),
    );

  }
}
