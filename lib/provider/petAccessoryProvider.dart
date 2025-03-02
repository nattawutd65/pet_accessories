import 'package:flutter/foundation.dart';
import 'package:account/database/petAccessoryDB.dart';
import 'package:account/model/petAccessory.dart';

class PetAccessoryProvider with ChangeNotifier {
  List<PetAccessory> accessories = [];

  List<PetAccessory> getAccessories() {
    return accessories;
  }

  void initData() async {
    var db = PetAccessoryDB();
    accessories = await db.getAllAccessories();
    notifyListeners();
  }

  void addAccessory(PetAccessory accessory) async {
    var db = PetAccessoryDB();
    await db.insertAccessory(accessory);
    accessories = await db.getAllAccessories();
    notifyListeners();
  }

  void deleteAccessory(PetAccessory accessory) async {
    var db = PetAccessoryDB();
    await db.deleteAccessory(accessory);
    accessories = await db.getAllAccessories();
    notifyListeners();
  }

  void updateAccessory(PetAccessory accessory) async {
    var db = PetAccessoryDB();
    await db.updateAccessory(accessory);
    accessories = await db.getAllAccessories();
    notifyListeners();
  }
}
