import 'package:flutter/material.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/exotelSDK/ExotelSDKClient.dart';
import '../Utils/ApplicationUtils.dart';

class Ringing extends StatefulWidget {
  @override
  _RingingState createState() => _RingingState();
}

class _RingingState extends State<Ringing> {
  String? state; // Define state variable
  @override
  Widget build(BuildContext context) {
    var mApplicationUtil = ApplicationUtils.getInstance(context);
    final String? dialTo = mApplicationUtil.mDialTo;
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    String? state = arguments['state'];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Exotel Voice Application',
          style: TextStyle(color: Colors.white), // Set text color to white
        ),
        backgroundColor: const Color(0xFF0800AF), // Set the app bar color to deep blue
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // This will center the column horizontally
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.2, vertical: MediaQuery.of(context).size.height * 0.1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1, bottom: MediaQuery.of(context).size.height * 0.02),
                    child: Text(dialTo!, style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.08)),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1, bottom: MediaQuery.of(context).size.height * 0.02),
                    child: Text('$state', style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.06)),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                  Padding(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.05, bottom: MediaQuery.of(context).size.height * 0.02),
                    child: GestureDetector(
                      onTap:() {
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
                          width: MediaQuery.of(context).size.width * 0.15,
                          height: MediaQuery.of(context).size.width * 0.15,
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
      ),
    );


  }
}
