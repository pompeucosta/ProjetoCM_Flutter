import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data/models/preset.dart';

class EditPage extends StatefulWidget {
  final Preset? preset;

  const EditPage(this.preset, {super.key});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  late TextEditingController nameController;
  late TextEditingController hoursController;
  late TextEditingController minutesController;
  late TextEditingController secondsController;
  late TextEditingController distanceController;
  late bool twoWay;
  late bool isEntryValid;

  @override
  void initState() {
    super.initState();

    nameController =
        TextEditingController(text: widget.preset?.name ?? "Run Preset");
    hoursController = TextEditingController(
        text: widget.preset?.duration.inHours.toString() ?? "0");
    minutesController = TextEditingController(
        text: ((widget.preset?.duration.inMinutes ?? 0) % 60).toString());
    secondsController = TextEditingController(
        text: ((widget.preset?.duration.inSeconds ?? 0) % 60).toString());
    distanceController =
        TextEditingController(text: widget.preset?.distance.toString() ?? "0");
    twoWay = widget.preset?.twoWay ?? false;
    isEntryValid = checkValidity();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Center(child: Text("Edit Preset"))),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Name"),
                  onChanged: (value) => updateValidity(),
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  children: [
                    const Text("Duration: "),
                    const SizedBox(width: 16.0),
                    Flexible(
                        child: TextField(
                      controller: hoursController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        RangeTextInputFormatter(min: 0, max: 23),
                      ],
                      onChanged: (value) => updateValidity(),
                      decoration: const InputDecoration(labelText: "Hours"),
                    )),
                    const SizedBox(width: 8),
                    Flexible(
                      child: TextField(
                        controller: minutesController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          RangeTextInputFormatter(min: 0, max: 59),
                        ],
                        onChanged: (value) => updateValidity(),
                        decoration: const InputDecoration(labelText: "Minutes"),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: TextField(
                        controller: secondsController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          RangeTextInputFormatter(min: 0, max: 59),
                        ],
                        onChanged: (value) => updateValidity(),
                        decoration: const InputDecoration(labelText: "Seconds"),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: distanceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Distance (km)"),
                  onChanged: (value) => updateValidity(),
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    const Text("Two Way: "),
                    Switch(
                      value: twoWay,
                      onChanged: (value) {
                        setState(() {
                          twoWay = value;
                        });
                      },
                    )
                  ],
                ),
                const SizedBox(height: 16.0),
                Center(
                    child: ElevatedButton(
                        onPressed:
                            isEntryValid ? () => saveChanges(context) : null,
                        child: const Text("Save Preset")))
              ],
            ))));
  }

  bool checkValidity() {
    int hours = int.tryParse(hoursController.text) ?? 0;
    int minutes = int.tryParse(minutesController.text) ?? 0;
    int seconds = int.tryParse(secondsController.text) ?? 0;
    double distance = double.tryParse(distanceController.text) ?? -1;

    return (hours * 3600 + minutes * 60 + seconds) > 0 &&
        nameController.text.isNotEmpty &&
        distance > 0;
  }

  void updateValidity() {
    setState(() {
      isEntryValid = checkValidity();
    });
  }

  void saveChanges(BuildContext context) {
    String name = nameController.text;
    int hours = int.tryParse(hoursController.text) ?? 0;
    int minutes = int.tryParse(minutesController.text) ?? 0;
    int seconds = int.tryParse(secondsController.text) ?? 0;
    double distance = double.tryParse(distanceController.text) ?? 0;

    Preset pr = Preset(
      name: name,
      twoWay: twoWay,
      durationInSeconds: hours * 3600 + minutes * 60 + seconds,
      distance: distance * 1000,
    );

    Navigator.pop(context, pr);
  }
}

class RangeTextInputFormatter extends TextInputFormatter {
  final int min;
  final int max;

  RangeTextInputFormatter({required this.min, required this.max});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final int parsedValue = int.tryParse(newValue.text) ?? 0;
    final int clampedValue = parsedValue.clamp(min, max);
    final String newText = clampedValue.toString();

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
