import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kncv_flutter/data/models/models.dart';

class TesterCourierRepository {
  final FirebaseFirestore database;
  final FirebaseAuth auth;

  TesterCourierRepository(this.database, this.auth);
  Future<Map<String, List<TesterCourier>>> loadTestersAndCouriers() async {
    String? currentUserId = auth.currentUser?.uid;

    Map<String, List<TesterCourier>> data = {'couriers': [], 'testers': []};
    var usersCollection = await database.collection('users');

    var userData =
        await usersCollection.where('user_id', isEqualTo: currentUserId).get();
    List filteredUser = userData.docs.map((e) => e.data()).toList();
    if (filteredUser.length > 0) {
      Map user = filteredUser[0];
      var testCenterData = await database
          .collection('test_centers')
          .where('zone', isEqualTo: user["institution.zone"])
          .get();

      var couriersData = await database
          .collection('users')
          .where('type', isEqualTo: 'COURIER_ADMIN')
          .where('zone', isEqualTo: user['institution.zone'])
          .get();
      data['testers'] = testCenterData.docs
          .map((e) => Tester.fromJson({...e.data(), 'id': e.id}))
          .toList();

      data['couriers'] = couriersData.docs
          .map(
              (e) => Courier.fromJson({...e.data(), 'id': e.data()['user_id']}))
          .toList();
    }
    return data;
  }
}
