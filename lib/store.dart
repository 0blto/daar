import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StorePage extends StatefulWidget {
  @override
  _StorePageState createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  final TextEditingController _storeController = TextEditingController();


  void _showPopup(String title, String message) {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('ОК'),
            ),
          ],
        );
      },);}

  Future<void> _logout() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.31.215:8000/api/v1/logout'),
        headers: {'Content-Type': 'application/json'},

      );
      if (response.statusCode == 200) {
          Navigator.pushReplacementNamed(context, '/');
      } else {
        Navigator.pushReplacementNamed(context, '/');
      }
      } catch (e) {
      // Ignored
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.logout_rounded, color: Colors.white),
          onPressed: () {
            _logout();
          },
        ),
        title: const Text(
          "Uzum Scan",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _storeController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter store name",
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // ignored
                  },
                  child: Text("Upload data"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_storeController.text == ''){
                      _showPopup('Ошибка', 'Введите название');
                    }else{
                    Navigator.pushNamed(context, '/scan_barcode');}
                  },
                  child: Text("Next"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}