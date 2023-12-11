import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:run_route/data/database/presets_db.dart';

import '../../models/preset.dart';

part 'presets_event.dart';
part 'presets_state.dart';

class PresetsBloc extends Bloc<PresetsEvent, PresetsOverviewState> {
  final PresetsDatabase _presetsDatabase;

  PresetsBloc(this._presetsDatabase) : super(const PresetsOverviewState()) {
    on<LoadPresetsEvent>((event, emit) async {
      emit(state.copyWith(status: () => PresetsOverviewStatus.loading));
      final presets = _presetsDatabase.getAllPresets();
      print(presets.value.values.length);
      emit(state.copyWith(
          presets: () => presets, status: () => PresetsOverviewStatus.loaded));
    });
    on<UpdatePresetEvent>((event, emit) async {
      try {
        await _presetsDatabase.updatePreset(
            event.currentPreset, event.updatedPreset);
        emit(state.copyWith(status: () => PresetsOverviewStatus.success));
      } catch (error) {
        emit(state.copyWith(status: () => PresetsOverviewStatus.failure));
      }
    });
    on<DeletePresetEvent>((event, emit) async {
      try {
        await _presetsDatabase.deletePreset(event.presetToDelete);
        emit(state.copyWith(status: () => PresetsOverviewStatus.success));
      } catch (error) {
        emit(state.copyWith(status: () => PresetsOverviewStatus.failure));
      }
    });
    on<InsertPresetEvent>((event, emit) async {
      try {
        await _presetsDatabase.insertPreset(event.preset);
        emit(state.copyWith(status: () => PresetsOverviewStatus.success));
      } catch (error) {
        emit(state.copyWith(status: () => PresetsOverviewStatus.failure));
      }
    });
  }
}
