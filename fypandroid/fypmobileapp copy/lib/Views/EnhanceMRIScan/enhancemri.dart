import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
// import 'package:tflite_flutter/tflite_flutter.dart';

class EnhanceMri extends StatefulWidget {
  const EnhanceMri({Key? key}) : super(key: key);

  @override
  State<EnhanceMri> createState() => _EnhanceMriState();
}

class _EnhanceMriState extends State<EnhanceMri> {
  static const modelPath = 'Assets/esrgan/esrgan-tf2.tflite';

  late final Interpreter interpreter;
  late final List<String> labels;

  Tensor? inputTensor;
  Tensor? outputTensor;

  String? imagePath;
  Uint8List? imageResult;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Load model and labels from assets
    loadModel();
  }

  @override
  void dispose() {
    interpreter.close();
    super.dispose();
  }

  // Clean old results when press some take picture button
  void cleanResult() {
    imagePath = null;
    imageResult = null;

    setState(() {});
  }

  // Load model
  Future<void> loadModel() async {
    final options = InterpreterOptions();

    // Use XNNPACK Delegate
    if (Platform.isAndroid) {
      options.addDelegate(XNNPackDelegate());
    }

    // Use GPU Delegate
    // doesn't work on emulator
    // if (Platform.isAndroid) {
    //   options.addDelegate(GpuDelegateV2());
    // }

    // Use Metal Delegate
    if (Platform.isIOS) {
      options.addDelegate(GpuDelegate());
    }

    // Load model from assets
    interpreter = await Interpreter.fromAsset(modelPath, options: options);
    // Get tensor input shape [1, 50, 50, 3]
    inputTensor = interpreter.getInputTensors().first;
    // Get tensor output shape [1, 200, 200, 3]
    outputTensor = interpreter.getOutputTensors().first;
    setState(() {});
    print('Interpreter loaded successfully');
  }

  // Process picked image
  Future<void> processImage(imagePath) async {
    if (imagePath != null) {
      final bytes = await File(imagePath).readAsBytes();
      final pickedImage = img.decodeImage(bytes);
      final image = img.copyResize(pickedImage!, width: 50, height: 50);

      // Get image matrix representation [50, 50, 3]
      final imageMatrix = List.generate(
        image.height,
        (y) => List.generate(
          image.width,
          (x) {
            final pixel = image.getPixel(x, y);
            return [pixel.r, pixel.g, pixel.b];
          },
        ),
      );

      setState(() {
        isLoading = true;
      });
      // Run model inference
      runInference(imageMatrix);
    }
  }

  // Run inference
  Future<void> runInference(
    List<List<List<num>>> imageMatrix,
  ) async {
    // Set tensor input [1, 50, 50, 3]
    final input = [imageMatrix];

    // Set tensor output [1, 200, 200, 3]
    final output = [
      List.generate(
        200,
        (index) => List.filled(200, [0.0, 0.0, 0.0]),
      )
    ];

    // Run inference
    interpreter.run(input, output);

    // Get first output tensor
    final result = output.first;

    final buffer = Uint8List.fromList(result
        .expand(
          (col) => col.expand(
            (pixel) => pixel.map((e) => e.toInt()),
          ),
        )
        .toList());

    // Build image from matrix
    final image = img.Image.fromBytes(
      width: 200,
      height: 200,
      bytes: buffer.buffer,
      numChannels: 3,
    );

    // Encode image in jpeg format
    imageResult = img.encodeJpg(image);
    setState(()
    {
      isLoading = false;
    }
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Enhance MRI Image',
            style: TextStyle(color: Colors.black),
          ),
        ),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: height * 0.02),
            const Text(
              'Select Image of MRI Scan',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 23,
              ),
            ),
            imageContainer(
              child: imagePath == null
                  ? const Center(child: Text('No image selected'))
                  : Image.file(
                      File(imagePath!),
                      fit: BoxFit.fill,
                    ),
            ),
            Text(
              isLoading ? 'Getting results...' : 'Result',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            imageContainer(
              child: imageResult == null
                  ? const Center(child: Text('High res image'))
                  : Image.memory(
                      imageResult!,
                      fit: BoxFit.fill,
                    ),
            ),
            ElevatedButton(
              onPressed: () {
                pickImageFromGallery();
              },
              child: const Text('Pick image'),
            )
          ],
        ),
      ),
    );
  }

  Widget imageContainer({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        height: 200,
        width: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
        child: child,
      ),
    );
  }

  void pickImageFromGallery() {
    final ImagePicker picker = ImagePicker();
    picker.pickImage(source: ImageSource.gallery).then((image) {
      setState(() {
        isLoading = true;
        if (image != null) {
          cleanResult();
          imagePath = image.path;
          processImage(image.path);
        }
      });
    });
  }
}
