import 'package:flutter/material.dart';
import 'package:uzum_scan/login_page.dart';
import 'package:uzum_scan/scan_barcode.dart';
import 'package:uzum_scan/store.dart';

void main() => runApp(MaterialApp(
      theme: ThemeData(primaryColor: const Color(0xFF6F2DA8)),

      debugShowCheckedModeBanner: false,
  initialRoute: '/',
  routes: {
    '/': (context) => const LoginPage(),
    '/store': (context) => StorePage(),
    '/scan_barcode': (context) => const BarcodeScannerWithController(),
  },
    ));
