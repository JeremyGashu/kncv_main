import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:kncv_flutter/core/hear_beat.dart';
import 'package:kncv_flutter/data/models/models.dart';

class LocationsRepository {
  final FirebaseFirestore database;

  LocationsRepository(this.database);
  Future<List<Region>> loadRegions() async {
    Box<Region> regionBox = Hive.box<Region>('regions');
    bool internetIsAvailable = await isConnectedToTheInternet();
    if (internetIsAvailable) {
      debugPrint('Regions from internet');
      var regionsCollection = await database.collection('regions');
      var collectionsData = await regionsCollection.get();
      List<Region> regions = collectionsData.docs.map((e) {
        return Region.fromJson(e.data());
      }).toList();
      await regionBox.clear();
      await regionBox.addAll(regions);

      return regions;
    } else {
      debugPrint('Regions from Cache');

      return regionBox.values.toList();
    }
  }
}
