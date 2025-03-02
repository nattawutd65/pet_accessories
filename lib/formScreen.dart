import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../model/petAccessory.dart';
import '../provider/petAccessoryProvider.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController =
      TextEditingController(); // ✅ เพิ่มช่องรายละเอียด
  String selectedCategory = 'ปลอกคอ & สายจูง';
  File? _image;

  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        title: const Text('➕ เพิ่มอุปกรณ์สัตว์เลี้ยง'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 ช่องกรอกชื่ออุปกรณ์
              TextFormField(
                decoration: InputDecoration(
                  labelText: '🐾 ชื่ออุปกรณ์',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.pets, color: Colors.teal),
                ),
                controller: nameController,
                validator: (value) =>
                    value!.isEmpty ? "กรุณากรอกชื่ออุปกรณ์" : null,
              ),
              const SizedBox(height: 12),

              // 🔹 ช่องกรอกราคา
              TextFormField(
                decoration: InputDecoration(
                  labelText: '💰 ราคา',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  prefixIcon:
                      const Icon(Icons.attach_money, color: Colors.teal),
                ),
                keyboardType: TextInputType.number,
                controller: priceController,
                validator: (value) {
                  if (value!.isEmpty) return "กรุณากรอกราคา";
                  if (double.tryParse(value) == null)
                    return "กรุณากรอกเป็นตัวเลข";
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // 🔹 ช่องกรอกรายละเอียด
              TextFormField(
                decoration: InputDecoration(
                  labelText: '📝 รายละเอียด',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.description, color: Colors.teal),
                ),
                controller: descriptionController,
                maxLines: 3, // ✅ ให้พิมพ์ได้หลายบรรทัด
              ),
              const SizedBox(height: 12),

              // 🔹 เลือกหมวดหมู่
              DropdownButtonFormField(
                value: selectedCategory,
                decoration: InputDecoration(
                  labelText: '📂 หมวดหมู่',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  prefixIcon: const Icon(Icons.category, color: Colors.teal),
                ),
                items: [
                  "ปลอกคอ & สายจูง",
                  "ที่นอน & บ้านสัตว์เลี้ยง",
                  "อาหาร & อุปกรณ์ให้อาหาร",
                  "อุปกรณ์ทำความสะอาด & อาบน้ำ",
                  "เสื้อผ้า & เครื่องแต่งตัว",
                  "ของเล่นสัตว์เลี้ยง",
                  "อุปกรณ์ออกกำลังกาย",
                  "กระเป๋า & รถเข็นสัตว์เลี้ยง",
                ].map((category) {
                  return DropdownMenuItem(
                      value: category, child: Text(category));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value.toString();
                  });
                },
              ),
              const SizedBox(height: 16),

              // 🔹 ปุ่มเลือกรูปภาพ
              ElevatedButton(
                onPressed: pickImage,
                child: const Text('📸 เลือกรูปภาพอุปกรณ์'),
              ),

              // 🔹 แสดงรูปภาพที่เลือก
              if (_image != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Image.file(
                    _image!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

              // 🔹 ปุ่มเพิ่มอุปกรณ์
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      var provider = Provider.of<PetAccessoryProvider>(context,
                          listen: false);

                      PetAccessory accessory = PetAccessory(
                        name: nameController.text,
                        price: double.parse(priceController.text),
                        category: selectedCategory,
                        description:
                            descriptionController.text, // ✅ บันทึกรายละเอียด
                        imageUrl: _image?.path ?? '',
                        date: DateTime.now(),
                      );

                      provider.addAccessory(accessory);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('✅ เพิ่มอุปกรณ์'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
