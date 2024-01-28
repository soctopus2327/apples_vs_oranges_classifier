import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

void main() => runApp(ImageClassifierApp());

class ImageClassifierApp extends StatelessWidget {
 @override
 Widget build(BuildContext context) {
    return MaterialApp(
      home: ImageClassifierScreen(),
    );
 }
}

class ImageClassifierScreen extends StatefulWidget {
 @override
 _ImageClassifierScreenState createState() => _ImageClassifierScreenState();
}

class _ImageClassifierScreenState extends State<ImageClassifierScreen> {
 XFile? _pickedImage;
 File? _fileImage;
 List<dynamic> _output = [];

 @override
 void initState() {
    super.initState();
    loadModel();
 }

 loadModel() async {
    await Tflite.loadModel(
      model: 'assets/model_unquant.tflite',
      labels: 'assets/labels.txt',
    );
 }

 classifyImage(XFile image) async {
    setState(() {});

    _fileImage = File(image.path);

    var output = await Tflite.runModelOnImage(
      path: _fileImage!.path,
      numResults: 2,
      threshold: 0.001,
      imageMean: 127.5,
      imageStd: 127.5,
    );

    setState(() {
      _output = output!;
    });
 }

 Future<void> pickImage() async {
    final img = ImagePicker();
    var image = await img.pickImage(source: ImageSource.gallery);

    if (image == null) return;
    setState(() {
      _pickedImage = image; // Initialize the _pickedImage variable
    });

    // classifyImage(image); // Classify the picked image

    try {
        classifyImage(image);
    } catch (e) {
        print(e); // Print out the error message
    }
 }

 @override
 void dispose() {
    Tflite.close();
    super.dispose();
 }

 @override
 Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Classification App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _pickedImage == null
                ? Text('No image selected.')
                : Image.file(_fileImage!),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: pickImage,
              child: Text('Choose an Image'),
            ),
            SizedBox(height: 20.0),
            _output.isNotEmpty
                ? Text(
                    'Prediction: ${_output[0]['label']}\nConfidence: ${(_output[0]['confidence'] * 100).toStringAsFixed(2)}%',
                    style: TextStyle(fontSize: 18),
                 )
                : Text('Waiting for image classification...'),
          ],
        ),
      ),
    );
 }
}