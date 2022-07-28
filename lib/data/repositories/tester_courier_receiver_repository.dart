import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kncv_flutter/core/hear_beat.dart';
import 'package:kncv_flutter/data/models/models.dart';

class TesterCourierRepository {
  final FirebaseFirestore database;
  final FirebaseAuth auth;

  TesterCourierRepository(this.database, this.auth);
  Future<Map<String, List<TesterCourier>>> loadTestersAndCouriers() async {
    Box<Tester> testerBox = Hive.box<Tester>('test_centers');
    Box<Courier> couriersBox = Hive.box<Courier>('couriers');
    Map<String, List<TesterCourier>> data = {'couriers': [], 'testers': []};
    String? currentUserId = auth.currentUser?.uid;

    bool internetAvailable = await isConnectedToTheInternet();
    if (internetAvailable) {
      // debugPrint('Courier and Test Centers From Internet');

      var usersCollection = await database.collection('users');

      var userData = await usersCollection.where('user_id', isEqualTo: currentUserId).get();
      List filteredUser = userData.docs.map((e) => e.data()).toList();
      if (filteredUser.length > 0) {
        Map user = filteredUser[0];
        var testCenterData = await database.collection('test_centers').where('region', isEqualTo: user["institution.region"]).get();

        var couriersData = await database.collection('users').where('type', isEqualTo: 'COURIER_ADMIN').where('region', isEqualTo: user['institution.region']).get();
        List<Tester> testers = testCenterData.docs.map((e) => Tester.fromJson({...e.data(), 'id': e.id})).toList();
        data['testers'] = testers;
        await testerBox.clear();
        await testerBox.addAll(testers);

        List<Courier> couriers = couriersData.docs.map((e) => Courier.fromJson({...e.data(), 'id': e.data()['user_id']})).toList();
        data['couriers'] = couriers;
        await couriersBox.clear();
        await couriersBox.addAll(couriers);
      }
      return data;
    } else {
      // debugPrint('Couriers and Test Centers From Cache');
      List<Tester> testers = testerBox.values.toList();
      List<Courier> couriers = couriersBox.values.toList();
      data['couriers'] = couriers;
      data['testers'] = testers;
      return data;
    }
  }
}
