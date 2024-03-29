import 'package:flutter/material.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/exotelSDK/ExotelSDKClient.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:flutter_app/UI/home_page.dart';

class Incoming extends StatefulWidget {
  @override
  _IncomingState createState() => _IncomingState();
}

class _IncomingState extends State<Incoming> {

  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final String? dialTo = arguments['dialTo'];
    final String userId = arguments['userId'];
    final String password = arguments['password'];
    final String displayName = arguments['displayName'];
    final String accountSid = arguments['accountSid'];
    final String hostname = arguments['hostname'];
    final String callId = arguments['callId'];
    final String destination = arguments['destination'];


    return Scaffold(
      appBar: AppBar(
        title:  Text(
          'Exotel Voice Application',
          style: TextStyle(color: Colors.white), // Set text color to white
        ),
        backgroundColor: const Color(0xFF0800AF), // Set the app bar color to deep blue
      ),
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.center, // This will center the column vertically
        crossAxisAlignment: CrossAxisAlignment.center, // This will center the column horizontally
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding:  EdgeInsets.only(top: 80.0, bottom: 12.0),
                  child: Text(destination!, style: const TextStyle(fontSize: 20.0)),
                ),
                 Padding(
                  padding: EdgeInsets.only(top: 80.0, bottom: 12.0),
                  child: Text('Incoming', style: TextStyle(fontSize: 20.0)),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 30.0, bottom: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 200),
                      SizedBox(width: 65), // Add space
                      ElevatedButton(
                        onPressed: () {
                          ExotelSDKClient.getInstance().answer();
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            Navigator.pushReplacementNamed(
                              context,
                              '/connected',
                              arguments: {'destination': destination, 'userId': userId, 'password': password, 'displayName': displayName, 'accountSid': accountSid, 'hostname': hostname },
                            );
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF00C652), // background color
                          shape: CircleBorder(), // shape of button
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12), // padding
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/btn_call_normal.png',
                            width: 44.0,
                            height: 44.0,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(width: 20), // Add space
                      ElevatedButton(
                        onPressed: () {
                          ExotelSDKClient.getInstance().hangup();
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            Navigator.pushReplacementNamed(
                              context,
                              '/home',
                              arguments: {'userId': userId, 'password': password, 'displayName': displayName, 'accountSid': accountSid, 'hostname': hostname },
                            );
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFA224B), // background color
                          shape: CircleBorder(), // shape of button
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12), // padding
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/btn_hungup_normal.png',
                            width: 44.0,
                            height: 44.0,
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
            width: 150,
            child: ElevatedButton(
              //Raised Button
              onPressed: ()  {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushNamed(
                    context,
                    '/dtmf',
                    arguments: {'dialTo': dialTo, 'userId': userId, 'password': password, 'displayName': displayName, 'accountSid': accountSid, 'hostname': hostname },
                  );
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF969698), // Set the button color to blue
                shape: RoundedRectangleBorder( // Make the button rectangular
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
