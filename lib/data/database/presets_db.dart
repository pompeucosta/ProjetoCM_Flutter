import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../preset.dart';

class PresetsDatabase {
  static const String boxName = 'presets';

  Future<void> insertPreset(Preset preset) async {
    final box = await Hive.openBox(boxName);
    await box.add(preset);
    await box.close();
  }

  Future<List<Preset>> getAllPresets() async {
    final box = await Hive.openBox(boxName);
    final presets = box.values.toList().cast<Preset>();
    await box.close();
    return presets;
  }

  Future<void> updatePreset(Preset existingPreset, Preset updatedPreset) async {
    final box = await Hive.openBox(boxName);
    if (box.containsKey(existingPreset.key)) {
      await box.put(existingPreset.key, updatedPreset);
    }
    await box.close();
  }

  Future<void> deletePreset(Preset preset) async {
    final box = await Hive.openBox(boxName);
    if (box.containsKey(preset.key)) {
      await box.delete(preset.key);
    }
    await box.close();
  }
}
