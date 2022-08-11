import 'dart:convert';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

void sendPushMessage(String body, String title, String token) async {
  try {
    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=AIzaSyAo62ZimMRMjmkwjhzwM-Ux_cpiOPAGT7A',
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
  } catch (e, stackTrace) {
    print(stackTrace);
    print(e);
  }
}
