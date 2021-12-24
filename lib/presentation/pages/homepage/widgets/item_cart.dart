import 'package:flutter/material.dart';
import 'package:kncv_flutter/core/colors.dart';
import 'package:kncv_flutter/data/models/models.dart';

Widget orderCard(Order order) {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(
        20,
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.tester_name ?? '',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kTextColorLight.withOpacity(0.8),
                ),
              ),
              SizedBox(
                height: 7,
              ),
              Text(
                '${order.patients!.length} Patients',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                height: 7,
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    20,
                  ),
                  color: getColorFromStatus(order.status ?? ''),
                ),
                child: Text(
                  '${order.status}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        Column(
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_forward,
                color: kColorsOrangeDark,
              ),
              onPressed: () {},
            ),
            Text(
              '${order.created_at}',
              style: TextStyle(
                color: kTextColorLight.withOpacity(0.5),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Color getColorFromStatus(String status) {
  switch (status) {
    case 'Draft':
      return Colors.orange;
    case 'Waiting Confirmation':
      return Colors.yellow[800]!;
    case 'On Delivery':
      return Colors.blue;
    case 'Rejected':
      return Colors.red;
    default:
      return Colors.green;
  }
}

Widget orderCardReceiver(Order order) {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(
        20,
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.tester_name ?? '',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kTextColorLight.withOpacity(0.8),
                ),
              ),
              SizedBox(
                height: 7,
              ),
              Text(
                '${order.patients!.length} Patients Specimens',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                height: 7,
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    20,
                  ),
                  color: Colors.green,
                ),
                child: Text(
                  '${order.status}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        Column(
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_forward,
                color: kColorsOrangeDark,
              ),
              onPressed: () {},
            ),
            Text(
              '${order.created_at}',
              style: TextStyle(
                color: kTextColorLight.withOpacity(0.5),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
