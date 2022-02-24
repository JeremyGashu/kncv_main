import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';

Future sendSMS(
    {BuildContext? context,
    required String to,
    required dynamic payload,
    required int action}) async {
  bool? granted = await Telephony.instance.requestSmsPermissions;
  if (granted == true) {
    await Telephony.instance.sendSms(
      to: '0936951272',
      message: jsonEncode(
        {
          'action': action,
          'payload': payload,
        },
      ),
      isMultipart: true,
      statusListener: (SendStatus status) {
        if (context != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Sending SMS...!')));
          if (status == SendStatus.SENT) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('SMS is Sent!')));
          } else if (status == SendStatus.DELIVERED) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('SMS is Delivered!')));
          }
        }
      },
    );
  } else {
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please grant permissin to send SMS!')));
    }
  }
}

Future sendResponseSMS(
    {BuildContext? context,
    required String to,
    required dynamic payload,
    required int action}) async {
  bool? granted = await Telephony.instance.requestSmsPermissions;
  if (granted == true) {
    await Telephony.instance.sendSms(
      to: '0936951272',
      message: jsonEncode(
        {
          'action': action,
          'payload': payload,
        },
      ),
      isMultipart: true,
      statusListener: (SendStatus status) {
        if (context != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Sending SMS...!')));
          if (status == SendStatus.SENT) {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('SMS is Sent!')));
          } else if (status == SendStatus.DELIVERED) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('SMS is Delivered!')));
          }
        }
      },
    );
  } else {
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please grant permissin to send SMS!')));
    }
  }
}
