import 'package:flutter/material.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/ExotelSDKClient.dart';
import 'dart:async';

class Connected extends StatefulWidget {
  @override
  _ConnectedState createState() => _ConnectedState();
}

class _ConnectedState extends State<Connected> {
  @override
  bool isSpeakerEnabled = false;
  void toggleSpeaker() {
    setState(() {
      isSpeakerEnabled = !isSpeakerEnabled;
      if (isSpeakerEnabled) {
        ExotelSDKClient.getInstance().enableSpeaker();
      } else {
        ExotelSDKClient.getInstance().disableSpeaker();
      }
    });
  }

  bool isMuteEnabled = false;
  void toggleMute() {
    setState(() {
      isMuteEnabled = !isMuteEnabled;
      if (isMuteEnabled) {
        ExotelSDKClient.getInstance().mute();
      } else {
        ExotelSDKClient.getInstance().unmute();
      }
    });
  }

  Timer? _timer;
  int _callDuration = 0;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(
      Duration(seconds: 1),
          (Timer timer) => setState(
            () {
          _callDuration++;
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final String? dialTo = arguments['dialTo'];
    final String userId = arguments['userId'];
    final String password = arguments['password'];
    final String displayName = arguments['displayName'];
    final String accountSid = arguments['accountSid'];
    final String hostname = arguments['hostname'];
    final String? callId = arguments['callId'];
    final String? destination = arguments['destination'];
    final String display = dialTo ?? destination ?? ''; // Use the null-aware operator (??) to handle null values
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
            padding: const EdgeInsets.symmetric(horizontal: 65.0, vertical: 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 80.0, bottom: 12.0),
                  child: Text(display, style: const TextStyle(fontSize: 20.0)),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 80.0, bottom: 12.0),
                  child: Text('Connected', style: TextStyle(fontSize: 20.0)),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 80.0, bottom: 12.0),
                  child: Text(
                    'Call Duration: ${Duration(seconds: _callDuration).toString().substring(0, 7)}',
                    style: TextStyle(fontSize: 20.0),
                  )
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30.0, bottom: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 200), // Add space
                      ElevatedButton(
                        onPressed: () {
                          ExotelSDKClient.getInstance().hangup();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFA224B), // background color
                          shape: CircleBorder(), // shape of button
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12), // padding
                        ),
                        child: Image.asset(
                          'assets/btn_hungup_normal.png',
                          width: 44.0,
                          height: 44.0,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 20), // Add space
                      ElevatedButton.icon(
                        onPressed: () {
                          toggleSpeaker;
                        },
                        icon: Icon(isSpeakerEnabled ? Icons.volume_off : Icons.volume_up, size: 42.0),
                        label: Text(''),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey, // background color
                          shape: CircleBorder(),// shape of button
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12), // padding
                        ),
                      ),
                      SizedBox(width: 20), // Add space
                      ElevatedButton.icon(
                        onPressed: toggleMute,
                        icon: Icon(isMuteEnabled ? Icons.mic_off : Icons.mic_sharp, size: 42.0),
                        label: Text(''),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey, // background color
                          shape: CircleBorder(), // shape of button
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12), // padding
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
                backgroundColor: Colors.grey, // Set the button color to blue
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
