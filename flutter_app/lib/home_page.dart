import 'package:flutter/material.dart';
import 'exotelSDK/ExotelSDKClient.dart';
import 'login_page.dart';
import 'main.dart';
import 'call_page.dart';
import 'Utils/ApplicationUtils.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {


  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    var mApplicationUtil = ApplicationUtils.getInstance(context);
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final String userId = arguments['userId'];
    final String password = arguments['password'];
    final String displayName = arguments['displayName'];
    final String accountSid = arguments['accountSid'];
    final String hostname = arguments['hostname'];
    TextEditingController dialNumberController = TextEditingController(text: "8123674275");

    Future<String> getVersion() async{
      String ver;
       ver = await mApplicationUtil.mVersion;
      return ver;
    }

    Future<String?> getStatus() async{
      String? status;
      status = await mApplicationUtil.mStatus;
      return status;
    }

    Future<void> showVersionDialog() async {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return FutureBuilder<String>(
            future: getVersion(),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return AlertDialog(
                  title: Text('Loading...'),
                  content: CircularProgressIndicator(),
                );
              } else {
                return AlertDialog(
                  title: Text('SDK Details'),
                  content: Text('${snapshot.data}'),
                  actions: <Widget>[
                    TextButton(
                      child: Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              }
            },
          );
        },
      );
    }



    void showDropdownDialog(BuildContext context) {
      int? dropdownValue1 = 3;
      String? dropdownValue2 = "NO_ISSUE";

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: Text('Last Call Feedback'),
                  content: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: 180.0, minWidth: 300), // Adjust this value to change the dialog height
                      child: Column(
                        children: <Widget>[
                          Text('Rating:'), // Heading for the first dropdown
                          DropdownButton<int?>(
                            value: dropdownValue1,
                            onChanged: (int? newValue) {
                              setState(() {
                                dropdownValue1 = newValue;
                              });
                            },
                            items: <int?>[1 , 2, 3, 4, 5]
                                .map<DropdownMenuItem<int?>>((int? value) {
                              return DropdownMenuItem<int?>(
                                value: value,
                                child: Text('${value ?? 3}'),
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 30),
                          Text('Dropdown 2:'), // Heading for the second dropdown
                          DropdownButton<String?>(
                            value: dropdownValue2,
                            onChanged: (String? newValue) {
                              setState(() {
                                dropdownValue2 = newValue;
                              });
                            },
                            items: <String>["NO_ISSUE", "ECHO", "NO_AUDIO", "HIGH_LATENCY", "CHOPPY_AUDIO", "BACKGROUND_NOISE"]
                                .map<DropdownMenuItem<String?>>((String? value) {
                              return DropdownMenuItem<String?>(
                                value: value,
                                child: Text(value ?? "NO_ISSUE"),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text('CANCEL'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: Text('OK'),
                      onPressed: () {
                        ExotelSDKClient.getInstance().lastCallFeedback(dropdownValue1, dropdownValue2);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              }
          );
        },
      );
    }


    void showAccountDetails(){
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Account Details'),
            content: Text('Subscriber Name: $userId \n \n Account SID: $accountSid \n \n Base URL: $hostname'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    void showReportProblem(BuildContext context) {
      final TextEditingController controller = TextEditingController();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Description'),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(hintText: ""),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  String description = controller.text;
                  final Duration day = Duration(days: 1);
                  final int uploadLogNumDays = 7;
                  final DateTime endDate = DateTime.now();
                  final DateTime startDate = endDate.subtract(day * uploadLogNumDays);
                  print('User input: $description, startDate: $startDate, endDate: $endDate');
                  ExotelSDKClient.getInstance().uploadLogs(startDate, endDate, description);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }


    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text(
                      'Exotel Voice Application',
                      style: TextStyle(color: Colors.white),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onSelected: (String result) {
                        switch (result) {
                          case 'Button 1':
                          // Handle Button 1 press
                            ExotelSDKClient.getInstance().logout();
                            mApplicationUtil.navigateToStart();
                            print('Button 1 pressed');
                            break;
                          case 'Button 2':
                          // Handle Button 2 press
                            showReportProblem(context);
                            print('Button 2 pressed');
                            break;
                          case 'Button 3':
                            ExotelSDKClient.getInstance().checkVersionDetails();
                            showVersionDialog();
                            print('Button 3 pressed');
                            break;
                          case 'Button 4':
                          // Handle Button 4 press
                            showDropdownDialog(context);
                            print('Button 4 pressed');
                            break;
                          case 'Button 5':
                            showAccountDetails();
                            print('Button 5 pressed');
                            break;
                        }
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'Button 1',
                          child: Text('Logout'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Button 2',
                          child: Text('Report Problem'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Button 3',
                          child: Text('SDK Details'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Button 4',
                          child: Text('Last Call Feedback'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Button 5',
                          child: Text('Account Details'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 11.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      '1234567890', // Replace with actual user id
                      style: TextStyle(color: Color(0xFFBCBCBE)),
                    ),
                    FutureBuilder<String?>(
                      future: getStatus(),
                      builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else {
                          String? status = snapshot.data;
                          return Text(
                            '$status',
                            style: status == "Ready" ? TextStyle(color: Color(0xFF47FF00)) : TextStyle(color: Colors.red),
                          );
                        }
                      },
                    ),
                  ],
                ),
              )

            ],
          ),
          bottom: const TabBar(
            indicatorColor: Colors.white, // Color of the line under the selected tab
            labelColor: Colors.white, // Color of the selected tab text
            unselectedLabelColor: Colors.grey, // Color of the unselected tab text
            tabs: [
              Tab(child: Text('Dial', style: TextStyle(fontSize: 18.0))), // Set your desired font size
              Tab(child: Text('Contacts', style: TextStyle(fontSize: 18.0))),
              Tab(child: Text('Recent Calls', style: TextStyle(fontSize: 18.0))),
            ],
          ),
          backgroundColor: const Color(0xFF0800AF),
        ),
        body: TabBarView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 0), // Added horizontal and vertical padding
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.only(top: 80.0, bottom: 12.0),
                    child: Text('Dial To', style: TextStyle(fontSize: 20.0)),
                  ),
                  TextField(
                    controller: dialNumberController,
                    decoration: InputDecoration(
                      labelText: 'Enter Number',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(
                          color: Color(0xFF0800AF), // Set the border color to blue
                          width: 2.0, // Set the border width
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0, bottom: 12.0),
                    child:ElevatedButton(
                      onPressed: () {
                        String dialTo = dialNumberController.text;
                        mApplicationUtil.setDialTo(dialTo);
                        ExotelSDKClient.getInstance().call(userId,dialTo);
                        // WidgetsBinding.instance.addPostFrameCallback((_) {
                        //   Navigator.pushReplacementNamed(
                        //     context,
                        //     '/connected',
                        //     arguments: {'dialTo': dialTo, 'userId': userId, 'password': password, 'displayName': displayName, 'accountSid': accountSid, 'hostname': hostname },
                        //   );});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2E42BF), // background color
                        shape: CircleBorder(), // shape of button
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12), // padding
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/call_icon.PNG', // Replace with your icon path
                          width: 35.0, // Set your desired width
                          height: 35.0, // Set your desired height
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Center(child: Text('Contacts Page')),
            const Center(child: Text('Recent Calls Page')),
          ],
        ),
      ),
    );
  }
}
