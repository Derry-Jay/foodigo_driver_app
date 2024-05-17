import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:foodigo_driver_app/route_generator.dart';
import 'package:foodigo_driver_app/helpers/custom_trace.dart';
import 'package:foodigo_driver_app/pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:global_configuration/global_configuration.dart';
import 'pages/app_pages.dart';
import 'pages/driver_tasks_page.dart';
import 'repos/settings_repository.dart' as settingRepo;
import 'models/setting.dart';
import 'package:foodigo_driver_app/pages/login_page.dart';
// import 'package:firebase_core/firebase_core.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
  print(message.notification.title);

  flutterLocalNotificationsPlugin.show(
      message.data.hashCode,
      message.data['title'],
      message.data['body'],
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channel.description,
          playSound: true,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound('loud_notification'),
        ),
      ));
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'Foodigo2021Driver', // id
  'Foodigo', // title
  'Foodigofooddeliveryapp', // description
  importance: Importance.high,
  enableVibration: true,
  // priority: Priority.Max,
  enableLights: true,
  playSound: true,
  sound: RawResourceAndroidNotificationSound('loud_notification'),
);
const androidPlatformChannel = AndroidNotificationDetails(
  'Foodigo2021Driver',
  'Foodigo',
  'Foodigofooddeliveryapp',
  // color: Color.fromARGB(255, 0, 0, 0),
  importance: Importance.high,
  playSound: true,
  priority: Priority.high,
  sound: RawResourceAndroidNotificationSound('loud_notification'),
  showWhen: false,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GlobalConfiguration().loadFromAsset("configurations");
  // await Firebase.initializeApp(
  //         name: "com.foodigo.driver",
  //         options: FirebaseOptions(
  //             apiKey: "AIzaSyDkAmR5qa7tVYbpYyaJuGqgCYVNFqYCEAs",
  //             appId: "1:189510283821:android:efe3295aaf2c9bba81bea4",
  //             messagingSenderId: "Foodigo",
  //             projectId: "driver-29e3f"))
  //     .then((value) {
  //   final firebaseMessaging = FirebaseMessaging.instance;
  //   //configureFirebase(firebaseMessaging);
  // }).catchError((e) {
  //   print("Hi");
  //   print(e);
  //   print("Hi");
  // });

  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // await Firebase.initializeApp();
  // SharedPreferences prefs = await SharedPreferences.getInstance();
  // var token = prefs.getString('apiToken');
  print(CustomTrace(StackTrace.current,
      message: "base_url: ${GlobalConfiguration().getValue('base_url')}"));
  print(CustomTrace(StackTrace.current,
      message:
          "api_base_url: ${GlobalConfiguration().getValue('api_base_url')}"));
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

// ignore: must_be_immutable
class _MyAppState extends State<MyApp> {
  String token;
  var driverid;
  Future<SharedPreferences> _sharedPrefs = SharedPreferences.getInstance();
  final firebaseMessaging = FirebaseMessaging.instance;
  // MyApp(
  //   this.token,
  // );
  // This widget is the root of your application.
  @override
  void initState() {
    super.initState();

    firebaseMessaging.setForegroundNotificationPresentationOptions(
        sound: true, badge: true, alert: true);
    firebaseMessaging.requestPermission(sound: true, badge: true, alert: true);
    var initialzationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/logo');
    var initializationSettings =
        InitializationSettings(android: initialzationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: notificationSelected);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Firebase Push Notification Arrived");
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      // method1();

      if (notification.title == 'Order accepted by another driver') {
        //setValues();
        // flutterLocalNotificationsPlugin.show(
        //     notification.hashCode,
        //     notification.title,
        //     notification.body,
        //     NotificationDetails(
        //       android: AndroidNotificationDetails(
        //         channel.id,
        //         channel.name,
        //         channel.description,
        //         icon: android?.smallIcon,
        //       ),
        //     ));
      } else {
        if (notification != null && android != null) {
          flutterLocalNotificationsPlugin.show(
              notification.hashCode,
              notification.title,
              notification.body,
              NotificationDetails(
                android: AndroidNotificationDetails(
                  channel.id,
                  channel.name,
                  channel.description,
                  icon: android?.smallIcon,
                  playSound: true,
                  priority: Priority.high,
                  sound:
                      RawResourceAndroidNotificationSound('loud_notification'),
                ),
              ));
        }
      }
    });

    FirebaseMessaging.onBackgroundMessage((RemoteMessage message) {
      if (message.notification.title == 'Order accepted by another driver') {
        print('worked');
        return null;
      } else {
        return _firebaseMessagingBackgroundHandler(message);
      }
    });

    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    //   print("Firebase Push Notification Arrived");
    //   RemoteNotification notification = message.notification;
    //   AndroidNotification android = message.notification?.android;});
    //getToken();
    //getTopics();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: settingRepo.setting,
        builder: (context, Setting _setting, _) {
          return MaterialApp(
            navigatorKey: settingRepo.navigatorKey,
            title: _setting.appName,
            onGenerateRoute: RouteGenerator.generateRoute,
            debugShowCheckedModeBanner: false,
            locale: _setting.mobileLanguage.value,
            home: LoginPage(),
            theme: ThemeData(
                brightness: _setting.brightness.value,
                fontFamily: "Montserrat",
                floatingActionButtonTheme: FloatingActionButtonThemeData(
                    elevation: 0, foregroundColor: Colors.white),
                primaryColor: Color(0xffffffff)),
          );
        });
  }

  Future notificationSelected(String payload) async {
    Navigator.of(context).pushReplacementNamed('/pages', arguments: 1);
  }

  // getToken() async {
  //   token = await FirebaseMessaging.instance.getToken();
  //   setState(() {
  //     token = token;
  //   });
  //   print("Device token : $token");
  // }
}
