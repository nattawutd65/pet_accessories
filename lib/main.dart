import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pet_accessories/provider/petAccessoryProvider.dart';
import 'package:pet_accessories/model/petAccessory.dart';
import 'package:pet_accessories/formScreen.dart';
import 'package:pet_accessories/editScreen.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => PetAccessoryProvider()),
      ],
      child: MaterialApp(
        title: 'Pet Accessories',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: '🐾 อุปกรณ์เสริมสัตว์เลี้ยง'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController searchController = TextEditingController();
  List<PetAccessory> filteredAccessories = [];
  String selectedCategory = "ทั้งหมด"; // ✅ ตัวแปรเก็บหมวดหมู่ที่เลือก
  Map<int, bool> expandedState = {}; // ✅ เก็บสถานะแสดง/ซ่อนรายละเอียด

  final List<String> categories = [
    "ทั้งหมด",
    "ปลอกคอ & สายจูง",
    "ที่นอน & บ้านสัตว์เลี้ยง",
    "อาหาร & อุปกรณ์ให้อาหาร",
    "อุปกรณ์ทำความสะอาด & อาบน้ำ",
    "เสื้อผ้า & เครื่องแต่งตัว",
    "ของเล่นสัตว์เลี้ยง",
    "อุปกรณ์ออกกำลังกาย",
    "กระเป๋า & รถเข็นสัตว์เลี้ยง",
  ];

  @override
  void initState() {
    super.initState();
    Provider.of<PetAccessoryProvider>(context, listen: false).initData();
  }

  void filterData() {
    final provider = Provider.of<PetAccessoryProvider>(context, listen: false);
    setState(() {
      filteredAccessories = provider.accessories
          .where((item) =>
              (selectedCategory == "ทั้งหมด" || item.category == selectedCategory) &&
              item.name.toLowerCase().contains(searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        title: Text(widget.title),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const FormScreen()));
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                // 🔹 Dropdown เลือกหมวดหมู่
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    labelText: "📂 เลือกหมวดหมู่",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.category, color: Colors.teal),
                  ),
                  items: categories.map((category) {
                    return DropdownMenuItem(value: category, child: Text(category));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                      filterData();
                    });
                  },
                ),
                const SizedBox(height: 10),

                // 🔹 ช่องค้นหา
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: "🔍 ค้นหาอุปกรณ์...",
                    prefixIcon: const Icon(Icons.search, color: Colors.teal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    filterData();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<PetAccessoryProvider>(
              builder: (context, provider, child) {
                final items = (filteredAccessories.isEmpty && searchController.text.isEmpty)
                    ? provider.accessories.where((item) => selectedCategory == "ทั้งหมด" || item.category == selectedCategory).toList()
                    : filteredAccessories;

                if (items.isEmpty) {
                  return const Center(
                    child: Text(
                      '🐶 ไม่มีอุปกรณ์ในหมวดหมู่นี้',
                      style: TextStyle(fontSize: 24, color: Colors.teal),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    PetAccessory data = items[index];
                    bool isExpanded = expandedState[data.keyID ?? 0] ?? false;

                    return Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: data.imageUrl.contains('assets/')
                                ? Image.asset(data.imageUrl, width: 60, height: 60, fit: BoxFit.cover)
                                : data.imageUrl.isNotEmpty
                                    ? Image.file(File(data.imageUrl), width: 60, height: 60, fit: BoxFit.cover)
                                    : const Icon(Icons.image, size: 50, color: Colors.grey),
                            title: Text(
                              data.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text("หมวดหมู่: ${data.category}"),
                            trailing: Wrap(
                              spacing: 5,
                              alignment: WrapAlignment.center,
                              children: [
                                Text(
                                  '${data.price.toStringAsFixed(2)} ฿',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => EditScreen(accessory: data)),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('ยืนยันการลบ'),
                                          content: Text('คุณต้องการลบ "${data.name}" หรือไม่?'),
                                          actions: [
                                            TextButton(
                                              child: const Text('ยกเลิก'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            TextButton(
                                              child: const Text('🗑️ ลบอุปกรณ์'),
                                              onPressed: () {
                                                provider.deleteAccessory(data);
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                            onTap: () {
                              setState(() {
                                expandedState[data.keyID ?? 0] = !isExpanded;
                              });
                            },
                          ),
                          if (isExpanded)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Text(
                                data.description.isNotEmpty ? data.description : "ไม่มีรายละเอียด",
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
