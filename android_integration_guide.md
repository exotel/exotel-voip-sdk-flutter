# Flutter integration with Android ExotelSDK Guide 

This is guide to integrate exotel client SDK with flutter. 

In this integration , 

1. A flutter compliance Native Android project has been created which will be mediator between flutter and exotel Client SDK.

2. Exotel Client SDK will be imported in flutter compliance Native Android project.

3. This flutter compliant android project is nothing but the translator, which will translate flutter channels message to exotelSDK API invocation and vice versa.


## Questions

#### How to add exotel SDK to Android Project
Exotel SDK is integrated as per [integration guide](https://github.com/exotel/exotel-voip-sdk-android/blob/main/Exotel%20Voice%20Client%20Android%20SDK%20Integration%20Guide.pdf) (refer section 4.1.2) from [exotel-voip-sdk-android repo](https://github.com/exotel/exotel-voip-sdk-android).

#### How to communicate from flutter app to Android Translator project?

- Create a MethodChannel and register the channel name, generally using “***package name/identity***” as the channel name.
- An asynchronous call is initiated through **invokeMethod**.

    ```
    class _SampleAppState extends State<SampleApp> {
        static const androidChannel = MethodChannel('android/exotel_sdk');
        ...
        void callNativeMethod() async{
            ...
            await androidChannel.invokeMethod('nativeMethod');
            ...
        }
    ...
    }
    ```
    Next, the following functions are implemented in native (android):
- Create a MethodChannel using the same registration string as the flutter.
- Implement the nativeMethod.
- Return the result to flutter through result.

    ```
    public class MainActivity extends FlutterActivity {
        private ExotelSDKChannel exotelSDKChannel;
        @Override
        public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
            GeneratedPluginRegistrant.registerWith(flutterEngine);

            exotelSDKChannel = new ExotelSDKChannel(flutterEngine,this);
            exotelSDKChannel.registerMethodChannel();
        }
    }
    ```

    ```
    public class ExotelSDKChannel {
        private static final String CHANNEL = "android/exotel_sdk";
        private MethodChannel channel;
        public ExotelSDKChannel(FlutterEngine flutterEngine, Context context) {
            this.flutterEngine = flutterEngine;
            this.context = context;
        }
        void registerMethodChannel() {
            channel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(),CHANNEL);
            channel.setMethodCallHandler(
                    ((call, result) -> {
                        System.out.println("Entered in Native Android");
                        switch (call.method) {
                            case "nativeMethod":
                                // write your code
                                result.success("ok");
                            default:
                                break;
                        }
                    })
            );
        }

    }
    ```



#### How to communicate from android translator project to exotel SDK?
Please refer `VoiceAppService` class of android translator which is 
communicate to exotel SDK and implemented as per  [integration guide](https://github.com/exotel/exotel-voip-sdk-android/blob/main/Exotel%20Voice%20Client%20Android%20SDK%20Integration%20Guide.pdf)  from [exotel-voip-sdk-android repo](https://github.com/exotel/exotel-voip-sdk-android).
    
##### Example of SDK Inialization 
  1. android translator then get the subscriber token 
  2. android translator then call initialize method of exotel client SDK with crdentials and subscriber token.


#### How to handle event from exotelSDK in android translator?
Please refer `VoiceAppService` class of android translator which has which has implemented listener events as per [integration guide](https://github.com/exotel/exotel-voip-sdk-android/blob/main/Exotel%20Voice%20Client%20Android%20SDK%20Integration%20Guide.pdf)  from [exotel-voip-sdk-android repo](https://github.com/exotel/exotel-voip-sdk-android).


#### How to handle event from android translator to flutter app?

- The code implementation of android calling flutter is similar to that of flutter calling native (android) which via invokeMethod.
  ```
  public class ExotelSDKChannel {
    ...
    public void callFlutterMethod() {
        channel.invokeMethod("changeUI");
    }
  }
  ```
- The flutter mainly implements the registration of MethodCallHandler:

    ```
    class _SampleAppState extends State<SampleApp> {
        static const androidChannel = MethodChannel('android/exotel_sdk');

        @override
        void initState() {
            super.initState();
            androidChannel.setMethodCallHandler(flutterCallHandler);
        }

        Future<String> flutterCallHandler(MethodCall call) async {
            switch (call.method) {  
            case "changeUI":
                // update UI
                break;
            default:
                break;
            }
            return "ok";
        }
    }
    ```


## Notes

- **MethodChannel** is used for demo / integration purpose. There  are other platform channels also also available which can be implemented as per design and use case.

---

Go to [README.md](README.md)
