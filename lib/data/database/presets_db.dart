import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../preset.dart';

class PresetsDatabase {
  static const String boxName = 'presets';
  late Box<Preset> _presets;

  Future<void> init() async {
    Hive.registerAdapter<Preset>(PresetAdapter());
    _presets = await Hive.openBox<Preset>(boxName);
  }

  Future<void> insertPreset(Preset preset) async {
    await _presets.add(preset);
  }

  ValueListenable<Box<Preset>> getAllPresets() {
    final presets = _presets.listenable();
    return presets;
  }

  Future<void> updatePreset(Preset existingPreset, Preset updatedPreset) async {
    if (_presets.containsKey(existingPreset.key)) {
      await _presets.put(existingPreset.key, updatedPreset);
    }
  }

  Future<void> deletePreset(Preset preset) async {
    if (_presets.containsKey(preset.key)) {
      await _presets.delete(preset.key);
    }
  }
}
