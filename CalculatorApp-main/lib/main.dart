import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:expressions/expressions.dart';  // For expression evaluation

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
          bottomSheetTheme: const BottomSheetThemeData(
            backgroundColor: Colors.transparent,
          ),
        ),
        home: const CalculatorScreen(),
      ),
    );
  }
}

// ImagePicker Provider
class ImagePickerProvider extends ChangeNotifier {
  File? _image;
  File? get image => _image;

  void updateImage(File image) {
    _image = image;
    notifyListeners();
  }
}

// Calculator Controller (GetX)
class CalculatorController extends GetxController {
  var input = ''.obs;
  var result = '0'.obs;

  void onNumberPress(String value) {
    input.value += value;
  }

  void onOperatorPress(String operator) {
    input.value += operator;
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
      
      // Format the result to 2 decimal places
      return resultValue.toStringAsFixed(2);
    } catch (e) {
      return 'Error';
    }
  }
}

// Calculator Screen
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final CalculatorController controller = Get.put(CalculatorController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(() => Text(
                      controller.input.value,
                      style: const TextStyle(fontSize: 32, color: Colors.black54),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 2) {
            Get.to(() => const DocumentUploadScreen());
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.cloud), label: 'Provider'),
          BottomNavigationBarItem(icon: Icon(Icons.code), label: 'GetX'),
          BottomNavigationBarItem(icon: Icon(Icons.upload), label: 'Upload'),
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
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(fontSize: 24, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

// Document Upload Screen
class DocumentUploadScreen extends StatefulWidget {
  const DocumentUploadScreen({super.key});

  @override
  _DocumentUploadScreenState createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null) {
        context.read<ImagePickerProvider>().updateImage(File(image.path));
        Get.snackbar(
          'Success',
          'Image uploaded successfully',
          backgroundColor: Colors.green.withOpacity(0.1),
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to upload image',
        backgroundColor: Colors.red.withOpacity(0.1),
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> _pickDocumentFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (image != null) {
        context.read<ImagePickerProvider>().updateImage(File(image.path));
        Get.snackbar(
          'Success',
          'Document photo captured successfully',
          backgroundColor: Colors.green.withOpacity(0.1),
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to capture document',
        backgroundColor: Colors.red.withOpacity(0.1),
        duration: const Duration(seconds: 2),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = context.watch<ImagePickerProvider>().image;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Document'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'Take a photo of document',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Please ensure photos are clear and visible',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            if (image != null)
              Container(
                margin: const EdgeInsets.all(16),
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.deepPurple),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const Spacer(),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Choose from Gallery'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                backgroundColor: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickDocumentFromCamera,
              child: const Text('Take a Photo'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                backgroundColor: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
