import 'package:flutter/material.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/exotelSDK/ExotelSDKClient.dart';

class Ringing extends StatefulWidget {
  @override
  _RingingState createState() => _RingingState();
}

class _RingingState extends State<Ringing> {
  String? state; // Define state variable
  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final String dialTo = arguments['dialTo'];
    final String userId = arguments['userId'];
    final String password = arguments['password'];
    final String displayName = arguments['displayName'];
    final String accountSid = arguments['accountSid'];
    final String hostname = arguments['hostname'];
    String? state = arguments['state'];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
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
            padding: const EdgeInsets.symmetric(horizontal: 130.0, vertical: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 80.0, bottom: 12.0),
                  child: Text(dialTo, style: const TextStyle(fontSize: 25.0)),
                ),
                 Padding(
                  padding: EdgeInsets.only(top: 80.0, bottom: 12.0),
                  child: Text('$state', style: TextStyle(fontSize: 20.0)),
                ),
                SizedBox(height: 200),
                Padding(
                  padding: const EdgeInsets.only(top: 30.0, bottom: 12.0),
                  child: GestureDetector(
                    onTap:() {
                      ExotelSDKClient.getInstance().hangup();
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.pushReplacementNamed(
                          context,
                          '/home',
                          arguments: {'dialTo': dialTo, 'userId': userId, 'password': password, 'displayName': displayName, 'accountSid': accountSid, 'hostname': hostname },
                        );});
                    },
                    child: ClipOval(
                      child: Image.asset(
                        'assets/btn_hungup_normal.png',
                        width: 55.0,
                        height: 55.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
