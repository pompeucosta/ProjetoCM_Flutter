part of 'home_bloc.dart';

enum AppTab { home, presets, session, history }

final class HomeState extends Equatable {
  const HomeState(
      {this.selectedTab = AppTab.home, this.includeSession = false});
  final AppTab selectedTab;
  final bool includeSession;

  HomeState copyWith({AppTab? selectedTab, bool? includeSession}) {
    return HomeState(
        selectedTab: selectedTab ?? this.selectedTab,
        includeSession: includeSession ?? this.includeSession);
  }

  @override
  List<Object> get props => [selectedTab, includeSession];
}
