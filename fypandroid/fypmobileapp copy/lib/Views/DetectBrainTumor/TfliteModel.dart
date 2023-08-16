import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class TfliteModel extends StatefulWidget {
  const TfliteModel({Key? key}) : super(key: key);

  @override
  _TfliteModelState createState() => _TfliteModelState();
}

class _TfliteModelState extends State<TfliteModel> {
  //-----------------------------------------------------
  static const modelPath = 'Assets/detecttumor/braintumor.tflite';
  static const labelPath = 'Assets/detecttumor/labels.txt';

  late final Interpreter interpreter;
  late final List<String> labels;

  Tensor? inputTensor;
  Tensor? outputTensor;

  Map<String, double> classification = {};

  img.Image? image;

  double tumorRes = 0;

  String imgPath = '';

  bool detailedRes = false;
  final controller = ScreenshotController();
  //-----------------------------------------------------

  @override
  void initState() {
    super.initState();
    // Load model and labels from assets
    loadModel();
    loadLabels();
  }

  @override
  void dispose() {
    interpreter.close();
    super.dispose();
  }

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
    inputTensor = interpreter.getInputTensors().first;
    outputTensor = interpreter.getOutputTensors().first;
    print(inputTensor.toString());
    print(outputTensor.toString());
    setState(() {});
    print('Interpreter loaded successfully');
  }

  // Load labels from assets
  Future<void> loadLabels() async {
    final labelTxt = await rootBundle.loadString(labelPath);
    labels = labelTxt.split('\n');
    print('Labels loaded successfully.');
  }

  // Process picked image
  Future<void> processImage({required String imagePath}) async {
    final imageData = File(imagePath).readAsBytesSync();

    // Decode image using package:image/image.dart (https://pub.dev/image)
    image = img.decodeImage(imageData)!;
    setState(() {});

    // Resize image for model input (Model input shape is [150,150 ,3])
    final imageInput = img.copyResize(
      image!,
      width: 150,
      height: 150,
    );

    // Get image matrix representation [150, 150, 3]
    final imageMatrix = List.generate(
      imageInput.height,
      (y) => List.generate(
        imageInput.width,
        (x) {
          final pixel = imageInput.getPixel(x, y);
          return [pixel.r, pixel.g, pixel.b];
        },
      ),
    );

    // Run model inference
    runInference(imageMatrix);
  }
  //Save and download to gallery
  Future<String> saveimage(Uint8List bytes) async {
    await [Permission.storage].request();
    final time = DateTime.now()
        .toIso8601String()
        .replaceAll('.', '-')
        .replaceAll(':', '-');
    final name = 'screenshot_$time';
    final result = await ImageGallerySaver.saveImage(bytes, name: name);
    return result['filePath'];
  }
  //Share method
  Future saveandshare(Uint8List bytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final image = File('${directory.path}/flutter.png');
    image.writeAsBytesSync(bytes);

    await Share.shareFiles([image.path]);
  }


  Future<void> runInference(
    List<List<List<num>>> imageMatrix,
  ) async {
    // Set tensor input [1, 150, 150, 3]
    final input = [imageMatrix];
    // Set tensor output [1, 4]
    final output = [List<double>.filled(4, 0)];

    // Run inference
    interpreter.run(input, output);

    // Get first output tensor
    final result = output.first;

    // Set classification map {label: points}
    classification = <String, double>{};

    for (var i = 0; i < result.length; i++) {
      if (result[i] != 0) {
        // Set label: points
        classification[labels[i]] = result[i];
      }
    }
    List<double> maxRes = classification.values.toList();
    maxRes.remove(classification['no_tumor']);
    maxRes.sort((b, a) => a.compareTo(b));
    tumorRes = maxRes.first;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Screenshot(
      controller: controller,
      child: Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text(
              'Detect Brain Tumor',
              style: TextStyle(color: Colors.black),
            ),
          ),
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: height * 0.03),
            const Text(
              'Select Image of MRI Scan',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 23,
              ),
            ),
            SizedBox(height: height * 0.02),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                height: height * 0.3,
                width: width,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: imgPath.isNotEmpty
                    ? Image.file(File(imgPath))
                    : const Center(
                        child: Text(
                          'No Image Selected',
                        ),
                      ),
              ),
            ),
            InkWell(
              onTap: () {
                pickImageFromGallery();
              },
              child: Container(
              height: height/14,
              width: width/1.4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.black54,
              ),
              alignment: Alignment.center,
              child: const Text('Input Image',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Results',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  resultContainer(
                    result: classification['no_tumor'] ?? 0,
                    text: 'No Tumor',
                    width: width,
                    color: Colors.green,
                  ),
                  resultContainer(
                    result: tumorRes,
                    text: 'Tumor',
                    width: width,
                  ),
                  Center(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          if (detailedRes) {
                            detailedRes = false;
                          } else {
                            detailedRes = true;
                          }
                        }
                        );
                      },
                      child: Container(
                        height: height/14,
                        width: width/1.4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.black54,
                        ),
                        alignment: Alignment.center,
                      child: const Text('View detailed Result',
                        style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  ),
                  ),
                  detailedRes
                      ? resultContainer(
                          result: classification['glioma_tumor'] ?? 0,
                          text: 'Glioma Tumor',
                          width: width,
                        )
                      : const SizedBox(),
                  detailedRes
                      ? resultContainer(
                          result: classification['meningioma_tumor'] ?? 0,
                          text: 'Meningioma Tumor',
                          width: width,
                        )
                      : const SizedBox(),
                  detailedRes
                      ? resultContainer(
                          result: classification['pituitary_tumor'] ?? 0,
                          text: 'Pituitary Tumor',
                          width: width,
                        )
                      : const SizedBox(),
               SizedBox(height: 25),
               InkWell(
                onTap: () async {
                  final image = await controller.capture();
                  if (image == null) return;
                  await saveimage(image);
                },
                 child: Container(
                   height: height/14,
                   width: width/1.4,
                   decoration: BoxDecoration(
                     borderRadius: BorderRadius.circular(5),
                     color: Colors.black54,
                   ),
                   alignment: Alignment.center,
                   child: const Text('Download Results',
                     style: TextStyle(
                       color: Colors.white,
                       fontWeight: FontWeight.bold,
                       fontSize: 22,
                     ),
                   ),
                 ),
              ),
                  SizedBox(height: 25),
                  InkWell(
                    onTap: () async {
                      final image = await controller.capture();
                      saveandshare(image!);
                    },
                    child: Container(
                      height: height/14,
                      width: width/1.4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.black54,
                      ),
                      alignment: Alignment.center,
                      child: const Text('Share Results',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget resultContainer(
      {required double result,
      Color? color,
      required String text,
      required double width}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              height: 40,
              width: width * result + 10,
              decoration: BoxDecoration(
                color: color ?? Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(11.0),
                child: Text(
                  '${(result * 100).toStringAsFixed(2)}%',
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void pickImageFromGallery() {
    final ImagePicker picker = ImagePicker();
    picker.pickImage(source: ImageSource.gallery).then((image) {
      setState(() {
        if (image != null) {
          imgPath = image.path;
          processImage(imagePath: image.path);
        }
      });
    });
  }
}
