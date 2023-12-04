import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'edit_preset_page.dart';
import 'data/preset.dart';
import 'data/database/presets_db.dart';

class ListCard extends StatelessWidget {
  final Preset preset;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ListCard(this.preset, this.onEdit, this.onDelete, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: const EdgeInsets.all(8.0),
        child: ListTile(
          title: Text(preset.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  "${preset.duration.inHours}:${(preset.duration.inMinutes % 60).toString().padLeft(2, '0')}:${(preset.duration.inSeconds % 60).toString().padLeft(2, '0')}"),
              if (preset.twoWay) const Text("Two way"),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(onPressed: onEdit, icon: const Icon(Icons.edit)),
              IconButton(onPressed: onDelete, icon: const Icon(Icons.delete))
            ],
          ),
        ));
  }
}

class PresetsPage extends StatefulWidget {
  PresetsPage({super.key});

  final PresetsDatabase db = PresetsDatabase();

  @override
  State<PresetsPage> createState() => _PresetsPageState();
}

class _PresetsPageState extends State<PresetsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Presets")),
      ),
      body: FutureBuilder(
          future: widget.db.getAllPresets(),
          builder: ((context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final presets = snapshot.data ?? [];
              return ListView.builder(
                  itemCount: presets.length,
                  itemBuilder: (context, index) {
                    Preset currentPreset = presets[index];
                    return ListCard(currentPreset, () {
                      navigateToEditPage(context, currentPreset,
                          (preset) async {
                        await widget.db.updatePreset(currentPreset, preset);
                      });
                    }, () async {
                      await widget.db.deletePreset(currentPreset);
                      setState(() {});
                    });
                  });
            }
          })),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            navigateToEditPage(context, null, (preset) async {
              await widget.db.insertPreset(preset);
            });
          },
          child: const Icon(Icons.add)),
    );
  }

  void navigateToEditPage(BuildContext context, Preset? preset,
      Future<void> Function(Preset preset) onResultReturned) async {
    final result = await Navigator.push<Preset>(
      context,
      MaterialPageRoute<Preset>(
        builder: (context) => EditPage(preset),
      ),
    );

    if (result != null) {
      await onResultReturned(result);
      setState(() {});
    }
  }
}
