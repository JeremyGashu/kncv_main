import 'package:flutter/material.dart';
import 'package:kncv_flutter/core/colors.dart';

class OrderDetailPage extends StatelessWidget {
  static const String orderDetailPageRouteName = 'order detail page route name';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPageBackground,
      appBar: AppBar(
        backgroundColor: kColorsOrangeLight,
        leading: Icon(
          Icons.arrow_back,
          color: Colors.black,
        ),
        title: Text(
          'Order ID',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: Colors.black,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              color: Colors.black,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: ListView(
                primary: false,
                shrinkWrap: true,
                padding: EdgeInsets.all(10),
                physics: NeverScrollableScrollPhysics(),
                children: [
                  //sender
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue,
                      radius: 25,
                      child: Text(
                        'SE',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                    title: Text(
                      'Woreda 12 Clinic',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    trailing: Text(
                      'Sender',
                      style: TextStyle(color: kColorsOrangeLight, fontSize: 14),
                    ),
                  ),

                  //courier
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue,
                      radius: 25,
                      child: Text(
                        'RC',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                    title: Text(
                      'Abrham Debebe',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    trailing: Text(
                      'Receiver',
                      style: TextStyle(color: Colors.green, fontSize: 14),
                    ),
                  ),
                  //test center
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue,
                      radius: 25,
                      child: Text(
                        'TC',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                    title: Text(
                      'Zone 04 Test Center',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    trailing: Text(
                      'Test Center',
                      style: TextStyle(color: kColorsOrangeLight, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            //
            SliverToBoxAdapter(
              child: Divider(),
            ),
            SliverToBoxAdapter(
              child: ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  buildPatients(),
                  buildPatients(),
                  buildPatients(),
                  buildPatients(),
                  buildPatients(),
                  buildPatients(),
                  buildPatients(),
                  buildPatients(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container buildPatients() {
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
                  'Abebe Legesse',
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
                  '4 Specimens',
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
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_forward,
                  color: kColorsOrangeDark,
                ),
                onPressed: () {},
              ),
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: kColorsOrangeLight,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.delete_forever,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: kColorsOrangeLight,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.edit_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
