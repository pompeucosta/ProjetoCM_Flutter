import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'dart:async';
import 'dart:io';

import 'camera_photo_gallery.dart';
import 'data/blocs/camera_cubit.dart';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;
  const CameraScreen(this.camera, {super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.primary, title: Container(child: Text("Aveiro - Portugal"), alignment: Alignment.centerRight,),),
      body: Center(
        child: CameraScreenContent(widget.camera)
      ),
    );
  }

  
}


class CameraScreenContent extends StatefulWidget {
  final CameraDescription camera;
  const CameraScreenContent(this.camera, {super.key});

  @override
  _CameraScreenContentState createState() => _CameraScreenContentState();
}

class _CameraScreenContentState extends State<CameraScreenContent> {

  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.high,

    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

void _takePhoto(context) async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            await _controller.setFlashMode(FlashMode.off);

            // Attempt to take a picture and get the file `image`
            // where it was saved.
            final image = await _controller.takePicture();

            if (!mounted) return;

            // If the picture was taken, display it on a new screen.
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CameraGalleryScreen(image.path),
              ),
            );
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }

}

 @override
  Widget build(BuildContext context) {
    

    return Scaffold(
          body: FutureBuilder<void>(
                future: _initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    // If the Future is complete, display the preview.
                    return CameraPreview(_controller);
                  } else {
                    // Otherwise, display a loading indicator.
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: FloatingActionButton.large(
                onPressed: () async {_takePhoto(context);},
                tooltip: 'Take photo',
                backgroundColor: Colors.white,
                child: Icon(Icons.camera_alt, color: Theme.of(context).colorScheme.primary,),
              ),
        );

  }

}
