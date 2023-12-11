import 'package:flutter/material.dart';
import 'SessionInProgress.dart';

class CameraGalleryScreen extends StatefulWidget {
  const CameraGalleryScreen({super.key});

  @override
  _CameraGalleryScreenState createState() => _CameraGalleryScreenState();
}

class _CameraGalleryScreenState extends State<CameraGalleryScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PhotoTakenContent(),
    );
  }
 
}

class PhotoTakenContent extends StatefulWidget {
  const PhotoTakenContent({super.key});

  @override
  _PhotoTakenContentState createState() => _PhotoTakenContentState();
}

class _PhotoTakenContentState extends State<PhotoTakenContent> {

void _takePhoto() {
  
}

 @override
  Widget build(BuildContext context) {
    return Scaffold(
          body: CameraPreview(),
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
              alignment: Alignment.bottomCenter,
              child: PhotoOptions(),
           );
  
  }
  
}

class PhotoOptions extends StatefulWidget {
  const PhotoOptions({super.key});

  @override
  _PhotoOptionsState createState() => _PhotoOptionsState();
}

class _PhotoOptionsState extends State<PhotoOptions> {

void _returnToLastScreen() {
      Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
                      child: Row( mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(padding: EdgeInsets.all(10),
                                              child: CustomButton(text: "Discard", onPressed: _returnToLastScreen,)),
                                    Container(padding: EdgeInsets.all(10),
                                              child: CustomButton(text: "Save photo", onPressed: _returnToLastScreen,)),
                                  ]  
                              )
                    );
  }

}