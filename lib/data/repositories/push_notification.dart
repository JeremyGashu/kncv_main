import 'dart:convert';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

const String SERVRE_KEY =
    'AAAAm8l0eAs:APA91bG5Wr9DjasD8AxxRV_alAUeiqHU1jgCtPI-8mI0KItcduJgqWxIcqEFGsxXKoc9mi2XS0CysvXC_Hm02KPhmvQsFlS7lhUyfHxBLj669bblBW8yz-8mCJilTt8H_AmltliEBDKf';

void sendPushMessage(String body, String title, String? token) async {
  if (token == null) return;
  print('Being sent to $token');
  try {
    http.Response response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$SERVRE_KEY',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': body,
            'title': title,
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done'
          },
          "to": token,
        },
      ),
    );
    print('Notification Reponse => ${response.body} ${response.statusCode}');
  } catch (e, stackTrace) {
    print(stackTrace);
    print(e);
  }
}
