import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Utils/ApplicationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../exotelSDK/ExotelSDKClient.dart';
import 'home_page.dart';
import '../main.dart';

class LoginPage extends StatefulWidget {
  final Function(String, String, String, String) onLoggedin;

  const LoginPage({Key? key, required this.onLoggedin}) : super(key: key);
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController userIdController = TextEditingController(text: ''); //adding text for temporary purpose
  TextEditingController passwordController = TextEditingController(text: '');
  TextEditingController displayNameController = TextEditingController(text: '');
  TextEditingController accountSidController = TextEditingController(text: 'exotel1810');
  TextEditingController hostnameController = TextEditingController(text: "https://bellatrix.apac-sg.exotel.in/v1");
  bool showAdvancedSettings = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Add a listener to the userIdController
    userIdController.addListener(() {
      // Update the displayNameController with the value of userIdController
      displayNameController.text = userIdController.text;
    });
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed
    userIdController.dispose();
    passwordController.dispose();
    displayNameController.dispose();
    accountSidController.dispose();
    hostnameController.dispose();
    super.dispose();
  }

  // void logInButton() async{
  //   log("login button function start");
  //   String response = "";
  //   try {
  //     // [sdk-initialization-flow] send message from flutter to android for exotel client SDK initialization
  //     final String value = await FlutterChannelHandler.logIn();
  //     //loading UI
  //     response = value;
  //     log(response);
  //   } catch (e) {
  //     response = "Failed to Invoke: '${e.toString()}'.";
  //     log(response);
  //   }
  //
  // }

  @override
  Widget build(BuildContext context) {
    var mApplicationUtil = ApplicationUtils.getInstance(context);
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.0, 0.0), // near the top right
            radius: 1.0,
            colors: [
              Color(0xFFA4DAF8), // starting color
              Colors.blue, // intermediate color
              Color(0xFF0800AF), // ending color
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.1, // 10% of screen width as horizontal padding
              vertical: MediaQuery.of(context).size.height * 0.05, // 5% of screen height as vertical padding
            ),
            child: Column(
              children: <Widget>[
                SizedBox(height: MediaQuery.of(context).size.height * 0.15), // 15% of screen height
                RichText(
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Welcome to \n',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width * 0.05, // 5% of screen width as font size
                          fontWeight: FontWeight.bold,
                          shadows: <Shadow>[
                            Shadow(
                              offset: Offset(2.0, 2.0),
                              blurRadius: 3.0,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ],
                        ),
                      ),
                      TextSpan(
                        text: 'Exotel Voice App demo!!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width * 0.05, // 5% of screen width as font size
                          fontStyle: FontStyle.italic,
                          shadows: <Shadow>[
                            Shadow(
                              offset: Offset(2.0, 2.0),
                              blurRadius: 3.0,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.1), // 10% of screen height
                Material(
                  elevation: 10.0,
                  borderRadius: BorderRadius.circular(50.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      "assets/exotel_logo.png",
                      width: MediaQuery.of(context).size.width * 0.2, // 20% of screen width
                      height: MediaQuery.of(context).size.width * 0.2, // 20% of screen width
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.05), // 5% of screen height
                TextField(
                  controller: userIdController,
                  decoration: InputDecoration(
                    labelText: 'User ID',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF0800AF), // Set the border color to blue
                        width: 2.0, // Set the border width
                      ),
                    ),
                    fillColor: Colors.white, // Set fill color to white
                    filled: true, // Don't forget this
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: const BorderSide(
                        color: Color(0xFF0800AF), // Set the border color to blue
                        width: 2.0, // Set the border width
                      ),
                    ),
                    fillColor: Colors.white, // Set fill color to white
                    filled: true,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      showAdvancedSettings = !showAdvancedSettings;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 50.0),
                        child: const Text(
                          'Advanced Settings',
                          style: TextStyle(
                            color: Color(0xFF0405B4),
                            decoration: TextDecoration.underline,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(showAdvancedSettings ? Icons.arrow_drop_up : Icons.arrow_drop_down, size: 42.0),
                        onPressed: () {
                          setState(() {
                            showAdvancedSettings = !showAdvancedSettings;
                          });                },
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: showAdvancedSettings,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      TextField(
                        controller: displayNameController,
                        decoration: InputDecoration(
                          labelText: 'Display Name',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF0800AF),
                              width: 2.0,
                            ),
                          ),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: accountSidController,
                        decoration: InputDecoration(
                          labelText: 'Account SID',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF0800AF),
                              width: 2.0,
                            ),
                          ),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: hostnameController,
                        decoration: InputDecoration(
                          labelText: 'Hostname',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF0800AF),
                              width: 2.0,
                            ),
                          ),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                // SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                Container(
                  width: MediaQuery.of(context).size.width * 0.4, // 40% of screen width
                  child: ElevatedButton(
                    onPressed: () async {
                      String userId = userIdController.text;
                      String password = passwordController.text;
                      String? displayName = displayNameController.text;
                      if (displayName == null || displayName.isEmpty) {
                        displayName = userIdController.text;
                      }
                      String accountSid = accountSidController.text;
                      String hostname = hostnameController.text;
                      String response = "";
                      try {
                        response = await ExotelSDKClient.getInstance().logIn(userId, password, accountSid, hostname);
                        mApplicationUtil.setUserId(userId);
                        mApplicationUtil.setPassword(password);
                        mApplicationUtil.displayName(displayName);
                        mApplicationUtil.setAccountSid(accountSid);
                        mApplicationUtil.setHostName(hostname);
                        mApplicationUtil.showLoadingDialog(response);
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        await prefs.setString('userId', userId);
                        await prefs.setString('password', password);
                        await prefs.setString('displayName', displayName);
                        await prefs.setString('accountSid', accountSid);
                        await prefs.setString('hostname', hostname);
                      } catch (e) {
                        mApplicationUtil.showToast("Error while login");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0800AF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                    ),
                    child: const Text(
                      'LOGIN',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
