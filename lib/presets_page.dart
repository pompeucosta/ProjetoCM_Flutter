import 'package:flutter/material.dart';
import 'edit_preset_page.dart';
import 'preset.dart';

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

  final List<Preset> presets = [
    Preset("test", false, const Duration(hours: 0, minutes: 0, seconds: 30)),
    Preset("ola ola", true, const Duration(hours: 0, minutes: 30, seconds: 15)),
    Preset("diaria", false, const Duration(hours: 1, minutes: 0, seconds: 0))
  ];
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
      body: ListView.builder(
          itemCount: widget.presets.length,
          itemBuilder: (context, index) {
            return ListCard(widget.presets[index], () {
              navigateToEditPage(context, index);
            }, () {
              deletePreset(index);
            });
          }),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            navigateToEditPage(context, -1);
          },
          child: const Icon(Icons.add)),
    );
  }

  void navigateToEditPage(BuildContext context, int index) async {
    final result = await Navigator.push<Preset>(
      context,
      MaterialPageRoute<Preset>(
        builder: (context) =>
            EditPage(index == -1 ? null : widget.presets[index]),
      ),
    );

    if (result != null) {
      setState(() {
        if (index == -1) {
          widget.presets.add(result);
        } else {
          widget.presets[index] = result;
        }
      });
    }
  }

  void deletePreset(int index) {
    setState(() {
      widget.presets.removeAt(index);
    });
  }
}
