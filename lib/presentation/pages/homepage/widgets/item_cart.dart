import 'package:flutter/material.dart';
import 'package:kncv_flutter/core/colors.dart';

Widget orderCard() {
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
                '21 01 01 347 / Woreda 13 Clinic',
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
                '1 Specimen',
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
                  'Draft',
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
              'Jul 20',
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
