import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import '../model/petAccessory.dart';

class PetAccessoryDB {
  static const String dbName = 'pet_accessories.db';
  static const String storeName = 'accessories';

  Future<Database> openDatabase() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String dbPath = join(appDir.path, dbName);
    return await databaseFactoryIo.openDatabase(dbPath);
  }

  // ✅ เพิ่มอุปกรณ์พร้อม "รายละเอียด"
  Future<int> insertAccessory(PetAccessory item) async {
    final db = await openDatabase();
    final store = intMapStoreFactory.store(storeName);

    final keyID = await store.add(db, {
      'name': item.name,
      'price': item.price,
      'date': item.date?.toIso8601String(),
      'category': item.category,
      'imageUrl': item.imageUrl,
      'description': item.description, // ✅ เพิ่มฟิลด์รายละเอียด
    });

    db.close();
    return keyID;
  }

  // ✅ ดึงข้อมูลอุปกรณ์ทั้งหมด
  Future<List<PetAccessory>> getAllAccessories() async {
  final db = await openDatabase();
  final store = intMapStoreFactory.store(storeName);

  final snapshot = await store.find(
    db,
    finder: Finder(sortOrders: [SortOrder('date', false)]),
  );

  final accessories = snapshot.map((record) {
    return PetAccessory(
      keyID: record.key,
      name: record['name'].toString(),
      price: double.parse(record['price'].toString()),
      date: (record['date'] != null && record['date'].toString().isNotEmpty)
          ? DateTime.parse(record['date'].toString())
          : DateTime.now(), // ✅ ป้องกัน `null` และใช้ค่าปัจจุบันแทน
      category: record['category'].toString(),
      imageUrl: record['imageUrl'].toString(),
      description: record['description']?.toString() ?? '',
    );
  }).toList();

  db.close();
  return accessories;
}


  // ✅ อัปเดตอุปกรณ์พร้อม "รายละเอียด"
  Future<void> updateAccessory(PetAccessory item) async {
    final db = await openDatabase();
    final store = intMapStoreFactory.store(storeName);

    await store.record(item.keyID!).update(db, {
      'name': item.name,
      'price': item.price,
      'date': item.date?.toIso8601String(),
      'category': item.category,
      'imageUrl': item.imageUrl,
      'description': item.description, // ✅ อัปเดตรายละเอียด
    });

    db.close();
  }

  // ✅ ลบอุปกรณ์
  Future<void> deleteAccessory(PetAccessory item) async {
    final db = await openDatabase();
    final store = intMapStoreFactory.store(storeName);

    await store.record(item.keyID!).delete(db);
    db.close();
  }
}
