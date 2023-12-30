import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';

class CameraCubit extends Cubit<CameraDescription> {
  CameraCubit(camera) : super(camera);

}
