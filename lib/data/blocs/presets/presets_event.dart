part of 'presets_bloc.dart';

sealed class PresetsEvent extends Equatable {
  const PresetsEvent();
}

class LoadPresetsEvent extends PresetsEvent {
  @override
  List<Object?> get props => [];
}

class InsertPresetEvent extends PresetsEvent {
  final Preset preset;

  const InsertPresetEvent(this.preset);

  @override
  List<Object?> get props => [preset];
}

class UpdatePresetEvent extends PresetsEvent {
  final Preset currentPreset;
  final Preset updatedPreset;

  const UpdatePresetEvent(this.currentPreset, this.updatedPreset);

  @override
  List<Object?> get props => [currentPreset, updatedPreset];
}

class DeletePresetEvent extends PresetsEvent {
  final Preset presetToDelete;

  const DeletePresetEvent(this.presetToDelete);

  @override
  List<Object?> get props => [presetToDelete];
}
