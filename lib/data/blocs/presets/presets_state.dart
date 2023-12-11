part of 'presets_bloc.dart';

enum PresetsOverviewStatus { initial, loading, loaded, success, failure }

final class PresetsOverviewState extends Equatable {
  final PresetsOverviewStatus status;
  final ValueListenable<Box<Preset>>? presets;

  const PresetsOverviewState(
      {this.status = PresetsOverviewStatus.initial, this.presets});

  PresetsOverviewState copyWith(
      {PresetsOverviewStatus Function()? status,
      ValueListenable<Box<Preset>> Function()? presets}) {
    return PresetsOverviewState(
        status: status != null ? status() : this.status,
        presets: presets != null ? presets() : this.presets);
  }

  @override
  List<Object?> get props => [status];
}
