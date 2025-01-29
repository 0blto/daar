import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:uzum_scan/AddProduct.dart';

void main() => runApp(MaterialApp(
  theme: ThemeData(primaryColor: const Color(0xFF6F2DA8)),
  home: const BarcodeScannerWithController(),
  debugShowCheckedModeBanner: false, // Убираем debug надпись
));

class BarcodeScannerWithController extends StatefulWidget {
  const BarcodeScannerWithController({super.key});

  @override
  _BarcodeScannerWithControllerState createState() =>
      _BarcodeScannerWithControllerState();
}

class _BarcodeScannerWithControllerState
    extends State<BarcodeScannerWithController> {
  late final MobileScannerController controller;

  bool isScanning = true; // Флаг для предотвращения повторного уведомления
  bool isTorchOn = false; // Флаг состояния вспышки

  void startScanning() {
    setState(() {
      isScanning = true;
      controller.start();
    });
  }


  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(
      torchEnabled: false, // flashlight выключена по умолчанию
    );
    controller.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Uzum Scan",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: Icon(
              isTorchOn ? Icons.flash_on : Icons.flash_off,
              color: isTorchOn ? Colors.yellow : Colors.white,
            ),
            onPressed: () {
              setState(() {
                isTorchOn = !isTorchOn;
              });
              controller.toggleTorch(); // Переключение вспышки
            },
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: MobileScanner(
              controller: controller,
              errorBuilder: (
                  BuildContext context,
                  MobileScannerException error,
                  Widget? child,
                  ) {
                return ScannerErrorWidget(error: error);
              },
              fit: BoxFit.cover, // Камера растягивается по всему экрану
              onDetect: (BarcodeCapture barcode) {
                if (!isScanning) return; // Если уже отсканировано, ничего не делать

                if (barcode.barcodes.isNotEmpty) {
                  final String code = barcode.barcodes.first.rawValue ?? 'Unknown';
                  final String type = barcode.barcodes.first.format.name;
                  isScanning = false; // Блокируем дальнейшие считывания
                  controller.stop(); // Останавливаем камеру
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddProduct(type: type, barcode: code, onBack: startScanning,),
                    ),
                  );
                  // _showBarcodeDialog(context, code, type); // Показываем попап
                }
              },
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    'Отсканируйте код',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  width: 280,
                  height: 160,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                      width: 4.0,
                    ),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showBarcodeDialog(BuildContext context, String barcode, String type) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Распознан код:", textAlign: TextAlign.center,),
          content: Text('Value: $barcode\nType: $type'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                isScanning = true; // Снова разрешаем сканирование
                controller.start(); // Запускаем камеру
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class ScannerErrorWidget extends StatelessWidget {
  const ScannerErrorWidget({super.key, required this.error});

  final MobileScannerException error;

  @override
  Widget build(BuildContext context) {
    String errorMessage;

    switch (error.errorCode) {
      case MobileScannerErrorCode.controllerUninitialized:
        errorMessage = 'Controller not ready.';
        break;
      case MobileScannerErrorCode.permissionDenied:
        errorMessage = 'Permission denied';
        break;
      default:
        errorMessage = 'Generic Error';
        break;
    }

    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Icon(Icons.error, color: Colors.white),
            ),
            Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
