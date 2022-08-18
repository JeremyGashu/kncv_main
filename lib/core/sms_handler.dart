import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kncv_flutter/core/message_codes.dart';
import 'package:telephony/telephony.dart';

Future sendSMS({BuildContext? context, required String to, required dynamic payload, required int action}) async {
  if (kIsWeb) {
    return true;
  }
  bool? granted = await Telephony.instance.requestSmsPermissions;
  if (granted == true) {
    await Telephony.instance.sendSms(
      to: to,
      message: jsonEncode(
        {
          'action': action,
          'payload': payload,
        },
      ),
      isMultipart: true,
      statusListener: (SendStatus status) {
        if (context != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sending SMS...!')));
          if (status == SendStatus.SENT) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('SMS is Sent!')));
          } else if (status == SendStatus.DELIVERED) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('SMS is Delivered!')));
          }
        }
      },
    );
  } else {
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please grant permissin to send SMS!')));
    }
  }
}

Future sendCustomSMS({BuildContext? context, required String to, required String body}) async {
  bool? granted = await Telephony.instance.requestSmsPermissions;
  if (granted == true) {
    if (kIsWeb) {
      return true;
    }

    try {
      await Telephony.instance.sendSms(
        to: '0941998907',
        message: jsonEncode(
          {
            'action': SEND_NOTIFICATION_SMS,
            'payload': {
              'to': to,
              'body': body,
            }
          },
        ),
        isMultipart: true,
        statusListener: (SendStatus status) {
          if (context != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sending SMS...!')));
            if (status == SendStatus.SENT) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('SMS is Sent!')));
            } else if (status == SendStatus.DELIVERED) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('SMS is Delivered!')));
            }
          }
        },
      );
    } catch (e) {
      // print(e);
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please grant permissin to send SMS!')));
      }
    }
  } else {
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please grant permissin to send SMS!')));
    }
  }
}

// Future sendResponseSMS(
//     {BuildContext? context,
//     required String to,
//     required dynamic payload,
//     required int action}) async {
//   bool? granted = await Telephony.instance.requestSmsPermissions;
//   if (granted == true) {
//     await Telephony.instance.sendSms(
//       to: to,
//       message: jsonEncode(
//         {
//           'action': action,
//           'payload': payload,
//         },
//       ),
//       isMultipart: true,
//       statusListener: (SendStatus status) {
//         if (context != null) {
//           ScaffoldMessenger.of(context)
//               .showSnackBar(const SnackBar(content: Text('Sending SMS...!')));
//           if (status == SendStatus.SENT) {
//             ScaffoldMessenger.of(context)
//                 .showSnackBar(const SnackBar(content: Text('SMS is Sent!')));
//           } else if (status == SendStatus.DELIVERED) {
//             ScaffoldMessenger.of(context).hideCurrentSnackBar();
//             ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('SMS is Delivered!')));
//           }
//         }
//       },
//     );
//   } else {
//     if (context != null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Please grant permissin to send SMS!')));
//     }
//   }
// }

Future sendSmsViaListenerToEndUser({BuildContext? context, required String to, required dynamic payload, required int action}) async {
  if (kIsWeb) {
    return true;
  }

  try {
    bool? granted = await Telephony.instance.requestSmsPermissions;
    if (granted == true) {
      await Telephony.instance.sendSms(
        to: '0941998907',
        message: jsonEncode(
          {
            'action': SEND_SMS_TO_LISTENER,
            'payload': payload,
            'notify_action': action,
            'to': to,
          },
        ),
        isMultipart: true,
        statusListener: (SendStatus status) {
          if (context != null) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sending SMS...!')));
            if (status == SendStatus.SENT) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('SMS is Sent!')));
            } else if (status == SendStatus.DELIVERED) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('SMS is Delivered!')));
            }
          }
        },
      );
    } else {
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please grant permissin to send SMS!')));
      }
    }
  } catch (e) {
    // print(e);
  }
}
