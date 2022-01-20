import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kncv_flutter/data/models/models.dart';

class LocationsRepository {
  final FirebaseFirestore database;

  LocationsRepository(this.database);
  Future<List<Region>> loadRegions() async {
    var regionsCollection = await database.collection('regions');
    var collectionsData = await regionsCollection.get();
    List<Region> regions = collectionsData.docs.map((e) {
      return Region.fromJson(e.data());
    }).toList();

    return regions;
  }
}
