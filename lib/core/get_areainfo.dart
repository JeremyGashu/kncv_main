import 'package:kncv_flutter/data/models/models.dart';

Map<String?, String?> getAreaInfo(
    Region? region, String? zoneCode, String? woredaCode) {
  Map<String?, String?> areaInfo = {'region': '', 'zone': '', 'woreda': ''};
  areaInfo['region'] = region?.name;
  region?.zones.forEach((element) {
    if (element.code == zoneCode) {
      areaInfo['zone'] = element.name;
      element.woredas.forEach((woreda) {
        if (woreda.code == woredaCode) {
          areaInfo['woreda'] = woreda.name;
        }
      });
    }
  });

  return areaInfo;
}
