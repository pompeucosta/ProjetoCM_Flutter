import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:run_route/data/blocs/running_session/running_session_bloc.dart';

class CameraGalleryScreen extends StatefulWidget {
  final String imagePath;
  final RunningSessionBloc sessionBloc;
  const CameraGalleryScreen(this.imagePath, this.sessionBloc, {super.key});

  @override
  _CameraGalleryScreenState createState() => _CameraGalleryScreenState();
}

class _CameraGalleryScreenState extends State<CameraGalleryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
              body: PhotoTakenContent(widget.imagePath, widget.sessionBloc),
            );
  }
}

class PhotoTakenContent extends StatefulWidget {
  final String imagePath;
  final RunningSessionBloc sessionBloc;
  const PhotoTakenContent(this.imagePath, this.sessionBloc, {super.key});

  @override
  _PhotoTakenContentState createState() => _PhotoTakenContentState();
}

class _PhotoTakenContentState extends State<PhotoTakenContent> {

  @override
  Widget build(BuildContext context) {
    Image img = Image.file(File(widget.imagePath));
    return Scaffold(
      body: Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.cover,
              image: img.image,
          ),
      ),
      alignment: Alignment.bottomCenter,
      child: PhotoOptions(widget.imagePath, widget.sessionBloc),
    ),
    );
  }
}

class PhotoOptions extends StatefulWidget {
  final String imagePath;
  final RunningSessionBloc sessionBloc;
  const PhotoOptions(this.imagePath, this.sessionBloc, {super.key});

  @override
  _PhotoOptionsState createState() => _PhotoOptionsState();
}

class _PhotoOptionsState extends State<PhotoOptions> {
  void _returnToLastScreen() {
    Navigator.pop(context);
  }

  void _savePhoto(context) async {

    if (await Permission.photos.request().isGranted){

      Directory directory = await getApplicationDocumentsDirectory();
      Directory? externalStorage = await getExternalStorageDirectory();
      if (externalStorage is Directory) {
        print("External Storage: ${externalStorage.path}");
        directory = externalStorage;
      }

      directory = Directory("${directory.path}/images/");
      Directory imagesDirectory = await directory.create(recursive: true);

      int timestamp = DateTime.now().millisecondsSinceEpoch;
      final String path = '${imagesDirectory.path}RunRoute_$timestamp.jpg';

      //print(path);
      File newimage = File(path);
      await newimage.create();
      newimage = await File(widget.imagePath).copy(path);

      if(await newimage.exists()){
        widget.sessionBloc.add(PhotoTakenEvent(path));
        final snackBar = SnackBar(content: const Text('Photo saved successfully'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      else
      {
        final snackBar = SnackBar(content: const Text('Couldn\'t save photo'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }


    }
    else
    {
      final snackBar = SnackBar(content: const Text('Needs permission to save file'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: _returnToLastScreen,
                child: const Text("Discard"),
              )),
          Container(
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: () {_savePhoto(context);},
                child: const Text("Save photo"),
              )),
        ]);
  }
}
