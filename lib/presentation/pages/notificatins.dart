import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kncv_flutter/core/colors.dart';
import 'package:kncv_flutter/data/models/models.dart';

class NotificationsPage extends StatelessWidget {
  static const String notificationsRouteName = 'notificatins page route name';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPageBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: kColorsOrangeLight,
        title: Text('Notification'),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: StreamBuilder<QuerySnapshot>(
            stream: getNotificationSnapshot(),
            builder: (context, snapshot) {
              List<NotificationModel> notifications = [];
              if (snapshot.hasData) {
                notifications =
                    getNotificationsFromQuerySnapshot(snapshot.data);
              }
              return ListView(
                children:
                    notifications.map((e) => notificationCard(e)).toList(),
              );
            }),
      ),
    );
  }
}

List<NotificationModel> getNotificationsFromQuerySnapshot(
    QuerySnapshot? snapshot) {
  List<NotificationModel> notifications = [];
  notifications = snapshot!.docs
      .map((e) => NotificationModel.fromJson(
          {...e.data() as Map<String, dynamic>, 'id': e.id}))
      .toList();
  return notifications;
}

Stream<QuerySnapshot<Map<String, dynamic>>> getNotificationSnapshot() {
  return FirebaseFirestore.instance
      .collection('notifications')
      .where('user_id', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
      .orderBy('seen')
      .orderBy('date',descending: true)
      .snapshots();
}

Widget notificationCard(NotificationModel notificationModel) {
  return Container(
    padding: EdgeInsets.only(top: 30, bottom: 30, left: 20, right: 20),
    margin: EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      color: notificationModel.seen
          ? Colors.white
          : Colors.orange.withOpacity(0.1),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${notificationModel.content ?? ''}'),
              SizedBox(
                height: 10,
              ),
              Text(
                '${notificationModel.timestamp ?? ''}',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
        !notificationModel.seen
            ? GestureDetector(
                onTap: () {
                  FirebaseFirestore.instance
                      .collection('notifications')
                      .doc(notificationModel.id)
                      .update({'seen': true});
                  print(notificationModel.id);
                },
                child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                    ),
                    child: Center(
                        child: Icon(
                      Icons.close,
                      color: Colors.orange,
                    ))),
              )
            : Container(),
      ],
    ),
  );
}

Future<bool >addNotification(
    {required String orderId,
    required String content,
    String? courierContent,
    String? senderContent,
    String? testerContent,
    bool courier = true,
    bool sender = true,
    bool tester = true}) async {
  try {
    var database = FirebaseFirestore.instance;
  var ordersCollection = await database.collection('orders').doc(orderId).get();
  Order order = Order.fromJson(ordersCollection.data() as Map<String, dynamic>);
  List<String?> sendList = [];
  var dateTime = DateTime.now();
  int month = dateTime.month;
  int day = dateTime.day;
  int year = dateTime.year;

  int hour = dateTime.hour;
  int minutes = dateTime.minute;
  if (sender) {
    NotificationModel newNotification = NotificationModel(
      content: senderContent ?? content,
      seen: false,
      userId: order.senderId,
      timestamp: '$day-$month-$year at $hour:$minutes',
      date: DateTime.now(),
    );

    await FirebaseFirestore.instance
        .collection('notifications')
        .add(newNotification.toJson());
  }
  if (courier) {
    NotificationModel newNotification = NotificationModel(
      content: courierContent ?? content,
      seen: false,
      userId: order.courierId,
      timestamp: '$day-$month-$year at $hour:$minutes',
      date: DateTime.now(),
    );

    await FirebaseFirestore.instance
        .collection('notifications')
        .add(newNotification.toJson());
  }
  if (tester) {
    var testers = await getTestCenterAdminsFromTestCenterId(order.testCenterId);
    testers.forEach((element) {
      sendList.add(element);
    });
  }

  sendList.forEach((element) async {
    NotificationModel newNotification = NotificationModel(
      content: testerContent ?? content,
      seen: false,
      userId: element,
      timestamp: '$day-$month-$year at $hour:$minutes',
      date: DateTime.now(),
    );

    await FirebaseFirestore.instance
        .collection('notifications')
        .add(newNotification.toJson());
  });

  return true;
  } catch (e) {
    return false;
  }
}

Future<List<String?>> getTestCenterAdminsFromTestCenterId(String? id) async {
  List<String?> testCenterAdmins = [];
  var testCenters = await FirebaseFirestore.instance
      .collection('users')
      .where('test_center_id', isEqualTo: id)
      .where('type', isEqualTo: 'TEST_CENTER_ADMIN')
      .get();
  testCenterAdmins =
      testCenters.docs.map((e) => e.data()['user_id'] as String).toList();
  return testCenterAdmins;
}
