import 'package:flutter/material.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/exotelSDK/ExotelSDKClient.dart';
import 'dart:async';
import '../Utils/ApplicationUtils.dart';
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

  bool isBluetoothEnabled = false;
  void toggleBluetooth() {
    setState(() {
      isBluetoothEnabled = !isBluetoothEnabled;
      if (isBluetoothEnabled) {
        ExotelSDKClient.getInstance().enableBluetooth();
      } else {
        ExotelSDKClient.getInstance().disableBluetooth();
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
    var mApplicationUtil = ApplicationUtils.getInstance(context);
    final String? dialTo = mApplicationUtil.mDialTo;
    final String? destination = mApplicationUtil.mDestination;
    final String display = dialTo ?? destination ?? " "; // Use the null-aware operator (??) to handle null values
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
                  padding: const EdgeInsets.only(top: 80.0, bottom: 0),
                  child: Text(display, style: const TextStyle(fontSize: 25.0)),
                ),
                Padding(
                    padding: EdgeInsets.only(top: 20.0, bottom: 12.0),
                    child: Text(
                      '${Duration(seconds: _callDuration).toString().substring(0, 7)}',
                      style: TextStyle(fontSize: 20.0),
                    )
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 50.0, bottom: 12.0),
                  child: Text('Connected', style: TextStyle(fontSize: 20.0)),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 70.0, bottom: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 200),
                      SizedBox(width: 5),
                      ElevatedButton.icon(onPressed: toggleSpeaker, icon: Icon(isSpeakerEnabled ? Icons.volume_off : Icons.volume_up, size: 42.0), label:Text("") ),
                      SizedBox(width: 5),
                      ElevatedButton.icon(onPressed: toggleBluetooth, icon: Icon(isBluetoothEnabled ? Icons.bluetooth_disabled : Icons.bluetooth, size: 42.0), label:Text("") ),
                      SizedBox(width: 0),
                      ElevatedButton.icon(onPressed: toggleMute, icon: Icon(isMuteEnabled ? Icons.mic_off : Icons.mic_sharp, size: 42.0), label:Text("") ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(width: 110),

                    GestureDetector(
                      onTap: () {
                        ExotelSDKClient.getInstance().hangup();
                      },
                      child: ClipOval(
                        child: Image.asset(
                          'assets/btn_hungup_normal.png',
                          width: 55.0, // Set your desired width
                          height: 55.0, // Set your desired height
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),

              ],
            ),
          ),
          SizedBox(height: 100),
          Container(
            width: 150,
            child: ElevatedButton(
              //Raised Button
              onPressed: ()  {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushNamed(
                    context,
                    '/dtmf',
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
