import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddProduct extends StatefulWidget {
  final String type;
  final String barcode;
  final VoidCallback onBack;

  const AddProduct({
    super.key,
    required this.type,
    required this.barcode,
    required this.onBack,
  });

  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final TextEditingController priceController = TextEditingController();
  XFile? productPhoto; // Для хранения фото товара
  XFile? pricePhoto; // Для хранения фото цены
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            widget.onBack(); // Вызываем коллбэк для изменения isScanning
            Navigator.pop(context);
          },
        ),
        title: Center(
          child: Text(widget.barcode, style: const TextStyle(color: Colors.white), textAlign: TextAlign.center),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              widget.onBack(); // Вызываем коллбэк для изменения isScanning
              Navigator.pop(context);
            },
          ),
        ],
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Фото товара:', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _pickImage(isProductPhoto: true),
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(25),
                  image: productPhoto != null
                      ? DecorationImage(
                    image: FileImage(File(productPhoto!.path)),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
                child: productPhoto == null
                    ? const Center(
                  child: Text('Добавить фото', style: TextStyle(color: Color(0xFF6F2DA8))),
                )
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            const Text('Фото цены:', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _pickImage(isProductPhoto: false),
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(25),
                  image: pricePhoto != null
                      ? DecorationImage(
                    image: FileImage(File(pricePhoto!.path)),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
                child: pricePhoto == null
                    ? const Center(
                  child: Text('Добавить фото', style: TextStyle(color: Color(0xFF6F2DA8))),
                )
                    : null,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Ввод цены:',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    textStyle: const TextStyle(color: Colors.white),
                  ),
                  onPressed: _saveData,
                  child: const Text('Сохранить', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage({required bool isProductPhoto}) async {
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      setState(() {
        if (isProductPhoto) {
          productPhoto = pickedImage;
        } else {
          pricePhoto = pickedImage;
        }
      });
      _showPhotoAddedToast(context);
    }
  }

  Future<void> _saveData() async {
    if (productPhoto == null) {
      _showErrorToast(context, 'Фото товара отсутствует');
      return;
    }
    if (pricePhoto == null && priceController.text.isEmpty) {
      _showErrorToast(context, 'Введите цену или добавьте фото цены');
      return;
    }

    // Сохранение фотографий
    if (productPhoto != null) {
      if (pricePhoto != null) {
        await _savePhotoToGallery(pricePhoto!.path, '${widget.barcode}_price.png');
        await _savePhotoToGallery(productPhoto!.path, '${widget.barcode}_product.png');
      } else if(priceController.text.isNotEmpty){
        await _savePhotoToGallery(productPhoto!.path, '${widget.barcode}_${priceController.text}_product.png');
      }
    }


    _showDataSavedToast(context);
    widget.onBack(); // Изменяем состояние isScanning
    Navigator.pop(context); // Возвращаемся назад
  }

  Future<void> _savePhotoToGallery(String path, String fileName) async {
    final File file = File(path);
    final String newPath = '/storage/emulated/0/Pictures/$fileName';
    await file.copy(newPath);
  }

  void _showPhotoAddedToast(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Фото добавлено'),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showDataSavedToast(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Данные сохранены'),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.red,
      ),
    );
  }
}
