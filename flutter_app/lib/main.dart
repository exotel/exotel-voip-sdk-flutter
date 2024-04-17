import 'package:flutter_app/Utils/ApplicationSharedPreferenceData.dart';
import 'package:flutter_app/exotelSDK/ExotelVoiceClient.dart';

import 'Utils/ApplicationUtils.dart';
import 'package:flutter/material.dart';
import 'UI/login_page.dart';
import 'UI/home_page.dart';
import 'exotelSDK/ExotelSDKClient.dart';
import 'UI/call_page.dart';
import 'callStates/connected.dart';
import 'callStates/ringing.dart';
import 'callStates/dtmf_page.dart';
import 'callStates/incoming.dart';
import 'package:firebase_core/firebase_core.dart';
import 'exotelSDK/ExotelVoiceClientFactory.dart';
import 'firebase_options.dart';
import 'Service/PushNotificationService.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ChangeNotifierProvider(
    create: (context) => CallList(),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ExotelVoiceClient exotelVoiceClient = ExotelVoiceClientFactory.getExotelVoiceClient();
    var mApplicationUtil = ApplicationUtils.getInstance(context);
    mApplicationUtil.setupLocalNotification();
    exotelVoiceClient.setExotelSDKCallback(mApplicationUtil);
    exotelVoiceClient.registerPlatformChannel();
    PushNotificationService pushNotificationService = PushNotificationService.getInstance();
    pushNotificationService.initialize();

    return MaterialApp(
      navigatorKey: navigatorKey,
      initialRoute: '/',
      routes: {
        '/home': (context) => HomePage(),
        '/call': (context) => CallPage(),
        '/ringing': (context) => Ringing(),
        '/connected': (context) => Connected(),
        '/incoming': (context) => Incoming(),
        '/dtmf': (context) => DtmfPage(),
      },
      debugShowCheckedModeBanner: false,
      title: ' Exotel Sample App',
      theme: ThemeData(
        // Your theme data
      ),
      home: FutureBuilder<bool>(
        future: checkIfUserIsLoggedIn(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // Show loading spinner while waiting for future to complete
          } else {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              mApplicationUtil.requestPermissions(); // Request permissions at app launch
              return (snapshot.data ?? false) ? const HomePage() : LoginPage(
                onLoggedin: (userId, password, accountSid, hostname) {
                  Navigator.pushReplacementNamed(
                    context,
                    '/home',
                  );
                },
              );
            }
          }
        },
      ),
    );
  }

  Future<bool> checkIfUserIsLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(ApplicationSharedPreferenceData.IS_LOGGED_IN.toString()) ?? false;
  }
}
