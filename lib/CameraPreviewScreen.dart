import 'package:flutter/material.dart';

import 'CameraPhotoGallery.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.primary, title: Container(child: Text("Aveiro - Portugal"), alignment: Alignment.centerRight,),),
      body: Center(
        child: CameraScreenContent()
      ),
    );
  }

  
}


class CameraScreenContent extends StatefulWidget {
  const CameraScreenContent({super.key});

  @override
  _CameraScreenContentState createState() => _CameraScreenContentState();
}

class _CameraScreenContentState extends State<CameraScreenContent> {

void _takePhoto() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CameraGalleryScreen()),
      );
}

 @override
  Widget build(BuildContext context) {
    return Scaffold(
          body: CameraPreview(),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: FloatingActionButton.large(
                onPressed: _takePhoto,
                tooltip: 'Take photo',
                backgroundColor: Colors.white,
                child: Icon(Icons.camera_alt, color: Theme.of(context).colorScheme.primary,),
              ),
        );

  }

}

class CameraPreview extends StatefulWidget {
  const CameraPreview({super.key});

  @override
  _CameraPreviewState createState() => _CameraPreviewState();
}

class _CameraPreviewState extends State<CameraPreview> {

 @override
  Widget build(BuildContext context) {
    return Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage(
                  "images/camerapreview.jpg", bundle: DefaultAssetBundle.of(context),
                ),
              )),
              alignment: Alignment.center,
              
           );
  
  }
  
}