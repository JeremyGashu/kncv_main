import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kncv_flutter/core/colors.dart';
import 'package:kncv_flutter/data/models/models.dart';
import 'package:kncv_flutter/data/repositories/push_notification.dart';
import 'package:kncv_flutter/presentation/pages/orders/order_detail_page_tester.dart';
import 'package:kncv_flutter/presentation/pages/orders/order_detailpage.dart';

import 'orders/order_detail_page_courier.dart';

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
              return Align(
                alignment: Alignment.center,
                child: Container(
                  constraints: BoxConstraints(maxWidth: 700),
                  child: notifications.length == 0 ? Text('No unread notification.', textAlign: TextAlign.center,) : ListView(
                    children: notifications.map((e) {
                      return GestureDetector(
                        onTap: () {
                          switch (e.action) {
                            case NotificationAction.NavigateToOrderDetalCourier:
                              Navigator.pushNamed(
                                      context,
                                      OrderDetailCourier
                                          .orderDetailCourierPageRouteName,
                                      arguments: e.payload?['orderId'])
                                  .then((value) => {
                                        FirebaseFirestore.instance
                                            .collection('notifications')
                                            .doc(e.id)
                                            .update({'seen': true}).then(
                                                (value) => {})
                                      });

                              break;
                            case NotificationAction.NavigateToOrderDetalSender:
                              Navigator.pushNamed(context,
                                      OrderDetailPage.orderDetailPageRouteName,
                                      arguments: e.payload?['orderId'])
                                  .then((value) => {
                                        FirebaseFirestore.instance
                                            .collection('notifications')
                                            .doc(e.id)
                                            .update({'seen': true}).then(
                                                (value) => {})
                                      });

                              break;
                            case NotificationAction.NavigateToOrderDetalTester:
                              Navigator.pushNamed(
                                      context,
                                      OrderDetailTester
                                          .orderDetailTesterPageRouteName,
                                      arguments: e.payload?['orderId'])
                                  .then((value) => {
                                        FirebaseFirestore.instance
                                            .collection('notifications')
                                            .doc(e.id)
                                            .update({'seen': true})
                                      });

                              break;
                            default:
                              return;
                          }
                        },
                        child: notificationCard(e),
                      );
                    }).toList(),
                  ),
                ),
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
      .orderBy('date', descending: true)
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
                  // print(notificationModel.id);
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

enum NotificationAction {
  NavigateToOrderDetalSender,
  NavigateToOrderDetalCourier,
  NavigateToOrderDetalTester,
  // NavigateToTestResultPage,
  // NavigateToPatientInfoPageSender,
  // NavigateToPatientInfoPageCourier,
  // NavigateToPatientInfoPageTester,
}

Future<bool> addNotification(
    {required String orderId,
    required String content,
    String? courierContent,
    String? senderContent,
    String? testerContent,
    NotificationAction? senderAction,
    NotificationAction? courierAction,
    NotificationAction? testerAction,
    Map? payload,
    bool courier = true,
    bool sender = true,
    bool tester = true}) async {
  try {
    var database = FirebaseFirestore.instance;
    var ordersCollection =
        await database.collection('orders').doc(orderId).get();
        // print('loaded order ${ordersCollection.data()?['tester_id']}');
    Order order =
        Order.fromJson(ordersCollection.data() as Map<String, dynamic>);
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
          action: senderAction,
          payload: payload);

      await FirebaseFirestore.instance
          .collection('notifications')
          .add(newNotification.toJson());

      sendPushMessage(senderContent ?? content, 'Order Update!',
          await getUserTokenFromUID(order.senderId));
    }
    if (courier) {
      NotificationModel newNotification = NotificationModel(
          content: courierContent ?? content,
          seen: false,
          userId: order.courierId,
          timestamp: '$day-$month-$year at $hour:$minutes',
          date: DateTime.now(),
          action: courierAction,
          payload: payload);

      await FirebaseFirestore.instance
          .collection('notifications')
          .add(newNotification.toJson());

      sendPushMessage(testerContent ?? content, 'Order Update!',
          await getUserTokenFromUID(order.courierId));
    }
    if (tester) {
      var testers =
          await getTestCenterAdminsFromTestCenterId(order.testCenterId);
      print('Test Center ID ==> ${order.testCenterId}');
      testers.forEach((element) {
        sendList.add(element);
      });
    }

    print('Send List ==> $sendList');

    sendList.forEach((element) async {
      NotificationModel newNotification = NotificationModel(
        content: testerContent ?? content,
        seen: false,
        userId: element,
        timestamp: '$day-$month-$year at $hour:$minutes',
        date: DateTime.now(),
        action: testerAction,
        payload: payload,
      );

      await FirebaseFirestore.instance
          .collection('notifications')
          .add(newNotification.toJson());
      String? t = await getUserTokenFromUID(element);

      if (t != null) {
        sendPushMessage(testerContent ?? content, 'Order Update!', t);
      }
    });

    // sendList.forEach((element) async {});

    return true;
  } catch (e) {
    // throw Exception(e);
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

Future<String?> getUserTokenFromUID(String? uid) async {
  DocumentSnapshot user =
      await FirebaseFirestore.instance.collection('tokens').doc(uid).get();
  Map? userData = user.data() as Map?;
  print('User Data ==> $userData');
  return userData?['deviceToken'];
}
