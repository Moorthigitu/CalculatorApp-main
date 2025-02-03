import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:expressions/expressions.dart';
import 'package:flutter/foundation.dart' show kIsWeb, Platform;

import 'package:intl/intl.dart';
import 'package:device_info_plus/device_info_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ImagePickerProvider()),
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Document Upload App',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
        ),
        home: MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    ProviderScreen(),
    CalculatorScreen(),
    DocumentUploadScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud),
            label: 'Provider',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'GetX',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.upload),
            label: 'Upload',
          ),
        ],
      ),
    );
  }
}

class ProviderScreen extends StatelessWidget {
  const ProviderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //appBar: AppBar(title: const Text('Provider Example')),
        body: CalculatorScreen());
  }
}

class ImagePickerProvider extends ChangeNotifier {
  File? _image;
  File? get image => _image;

  void updateImage(File image) {
    _image = image;
    notifyListeners();
  }
}

class CalculatorController extends GetxController {
  var input = ''.obs;
  var result = '0'.obs;

  void onNumberPress(String value) {
    if (value == '.') {
      if (!input.value.contains('.') ||
          input.value.split(RegExp(r'[+\-*/=]')).last.contains('.')) {
        input.value += value;
      }
    } else {
      input.value += value;
    }
  }

  void onOperatorPress(String operator) {
    if (input.isNotEmpty &&
        RegExp(r'[0-9.]').hasMatch(input.value[input.value.length - 1])) {
      input.value += operator;
    }
  }

  void onClear() {
    input.value = '';
    result.value = '0';
  }

  void onBackspace() {
    if (input.value.isNotEmpty) {
      input.value = input.value.substring(0, input.value.length - 1);
    }
  }

  void onCalculate() {
    try {
      result.value = _evaluateExpression(input.value);
    } catch (e) {
      result.value = 'Error';
    }
  }

  String _evaluateExpression(String expression) {
    try {
      expression = expression.replaceAll('x', '*').replaceAll('÷', '/');
      final exp = Expression.parse(expression);
      final evaluator = ExpressionEvaluator();
      final resultValue = evaluator.eval(exp, {});

      if (expression.contains('/0')) return 'Error: Division by zero';

      NumberFormat formatter = NumberFormat()
        ..minimumFractionDigits = 0
        ..maximumFractionDigits = 3;
      return formatter.format(resultValue);
    } catch (e) {
      return 'Error: Invalid Expression';
    }
  }
}

class CalculatorScreen extends StatelessWidget {
  final CalculatorController controller = Get.put(CalculatorController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calculator')),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Obx(() => Text(
                      controller.input.value,
                      style:
                          const TextStyle(fontSize: 32, color: Colors.black54),
                    )),
                Obx(() => Text(
                      controller.result.value,
                      style: const TextStyle(fontSize: 48, color: Colors.black),
                    )),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: GridView.count(
              padding: const EdgeInsets.all(12),
              crossAxisCount: 4,
              children: [
                _buildButton('C', onTap: controller.onClear),
                _buildButton('%', onTap: () => controller.onOperatorPress('%')),
                _buildButton('⌫', onTap: controller.onBackspace),
                _buildButton('÷', onTap: () => controller.onOperatorPress('÷')),
                _buildButton('7', onTap: () => controller.onNumberPress('7')),
                _buildButton('8', onTap: () => controller.onNumberPress('8')),
                _buildButton('9', onTap: () => controller.onNumberPress('9')),
                _buildButton('x', onTap: () => controller.onOperatorPress('x')),
                _buildButton('4', onTap: () => controller.onNumberPress('4')),
                _buildButton('5', onTap: () => controller.onNumberPress('5')),
                _buildButton('6', onTap: () => controller.onNumberPress('6')),
                _buildButton('-', onTap: () => controller.onOperatorPress('-')),
                _buildButton('1', onTap: () => controller.onNumberPress('1')),
                _buildButton('2', onTap: () => controller.onNumberPress('2')),
                _buildButton('3', onTap: () => controller.onNumberPress('3')),
                _buildButton('+', onTap: () => controller.onOperatorPress('+')),
                _buildButton('0', onTap: () => controller.onNumberPress('0')),
                _buildButton('.', onTap: () => controller.onNumberPress('.')),
                _buildButton('00', onTap: () => controller.onNumberPress('00')),
                _buildButton('=',
                    color: Colors.deepPurple, onTap: controller.onCalculate),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String label,
      {Color color = Colors.orange, required Function() onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        alignment: Alignment.center,
        child: Text(label,
            style: const TextStyle(fontSize: 24, color: Colors.white)),
      ),
    );
  }
}

class DocumentUploadScreen extends StatelessWidget {
  final ImagePicker _picker = ImagePicker();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  Future<Permission> _getGalleryPermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      return androidInfo.version.sdkInt >= 33
          ? Permission.photos
          : Permission.storage;
    }
    return Permission.photos;
  }

  Future<void> _handleImagePick(String type) async {
    try {
      final permission =
          type == 'gallery' ? await _getGalleryPermission() : Permission.camera;

      final status = await permission.request();

      if (status.isGranted) {
        final XFile? file = await (type == 'gallery'
            ? _picker.pickImage(source: ImageSource.gallery)
            : _picker.pickImage(source: ImageSource.camera));

        if (file != null) {
          _updateImage(file);
        } else {
          Get.snackbar('Cancelled', 'No file selected');
        }
      } else {
        Get.snackbar('Permission Required', 'Please enable access to continue');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick media: ${e.toString()}');
    }
  }

  void _updateImage(XFile file) {
    final context = Get.context!;
    context.read<ImagePickerProvider>().updateImage(File(file.path));
    Get.snackbar('Success', 'File selected successfully');
  }

  @override
  Widget build(BuildContext context) {
    final image = context.watch<ImagePickerProvider>().image;

    return Scaffold(
      appBar: AppBar(title: const Text('Upload Document')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text('Document Upload',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('Ensure documents are clear and valid',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 20),
            if (image != null)
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.deepPurple),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(image, fit: BoxFit.cover),
                  ),
                ),
              ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => _handleImagePick('gallery'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Choose from Gallery'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _handleImagePick('camera'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Take Photo'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
