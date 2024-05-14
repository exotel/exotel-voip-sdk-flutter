import 'package:flutter/material.dart';
import 'package:flutter_app/main.dart';
import 'dart:async';
import '../Utils/ApplicationUtils.dart';

class Connected extends StatefulWidget {
  @override
  _ConnectedState createState() => _ConnectedState();
}

class _ConnectedState extends State<Connected> {
  bool isSpeakerEnabled = false;
  bool isMuteEnabled = false;
  bool isBluetoothEnabled = false;
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
          (Timer timer) => setState(() {
        _callDuration++;
      }),
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
    final double buttonSize = MediaQuery.of(context).size.width * 0.15;
    final double buttonPadding = MediaQuery.of(context).size.width * 0.02;
    final double topPadding = MediaQuery.of(context).size.height * 0.1;
    Widget _buildRoundButton({
      required VoidCallback onPressed,
      required Widget icon,
    }) {
      return InkWell(
        onTap: onPressed,
        child: Container(
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            color: Colors.grey, // Set your desired button color
            shape: BoxShape.circle, // Make the button completely round
          ),
          child: Center(child: icon),
        ),
      );
    }
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1, vertical: 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1, bottom: 0),
                    child: Text(display, style: const TextStyle(fontSize: 25.0)),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.03, bottom: MediaQuery.of(context).size.height * 0.01),
                    child: Text(
                      '${Duration(seconds: _callDuration).toString().substring(0, 7)}',
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 50.0, bottom: 12.0),
                    child: Text('Connected', style: TextStyle(fontSize: 20.0)),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.07, bottom: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        _buildRoundButton(
                          onPressed: toggleSpeaker,
                          icon: Icon(isSpeakerEnabled ? Icons.volume_off : Icons.volume_up, size: buttonSize),
                        ),
                        _buildRoundButton(
                          onPressed: toggleBluetooth,
                          icon: Icon(isBluetoothEnabled ? Icons.bluetooth_disabled : Icons.bluetooth, size: buttonSize),
                        ),
                        _buildRoundButton(
                          onPressed: toggleMute,
                          icon: Icon(isMuteEnabled ? Icons.mic_off : Icons.mic_sharp, size: buttonSize),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: topPadding),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          mApplicationUtil.hangup();
                          Navigator.pushReplacementNamed(
                            context,
                            '/home',
                          );
                        },
                        child: ClipOval(
                          child: Image.asset(
                            'assets/btn_hungup_normal.png',
                            width: buttonSize,
                            height: buttonSize,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: topPadding),
            Container(
              width: MediaQuery.of(context).size.width * 0.43,
              child: ElevatedButton(
                onPressed: () {
                  WidgetsBinding.instance!.addPostFrameCallback((_) {
                    Navigator.pushNamed(
                      context,
                      '/dtmf',
                    );
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
                child: const Text(
                  'SHOW KEYPAD',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void toggleSpeaker() {
    setState(() {
      isSpeakerEnabled = !isSpeakerEnabled;
      if (isSpeakerEnabled) {
        ApplicationUtils.getInstance(context).enableSpeaker();
      } else {
        ApplicationUtils.getInstance(context).disableSpeaker();
      }
    });
  }

  void toggleMute() {
    setState(() {
      isMuteEnabled = !isMuteEnabled;
      if (isMuteEnabled) {
        ApplicationUtils.getInstance(context).mute();
      } else {
        ApplicationUtils.getInstance(context).unmute();
      }
    });
  }

  void toggleBluetooth() {
    setState(() {
      isBluetoothEnabled = !isBluetoothEnabled;
      if (isBluetoothEnabled) {
        ApplicationUtils.getInstance(context).enableBluetooth();
      } else {
        ApplicationUtils.getInstance(context).disableBluetooth();
      }
    });
  }
}
