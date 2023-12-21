part of 'bottom_navigation_bloc.dart';

enum AppTab { home, presets, history, session }

final class BottomNavigationState extends Equatable {
  const BottomNavigationState(
      {this.selectedTab = AppTab.home, this.includeSession = false});
  final AppTab selectedTab;
  final bool includeSession;

  BottomNavigationState copyWith({AppTab? selectedTab, bool? includeSession}) {
    return BottomNavigationState(
        selectedTab: selectedTab ?? this.selectedTab,
        includeSession: includeSession ?? this.includeSession);
  }

  @override
  List<Object> get props => [selectedTab, includeSession];
}
