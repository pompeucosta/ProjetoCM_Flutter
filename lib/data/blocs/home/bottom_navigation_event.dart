part of 'bottom_navigation_bloc.dart';

sealed class BottomNavigationEvent extends Equatable {
  const BottomNavigationEvent();
}

class TabChangedEvent extends BottomNavigationEvent {
  final int selectedIndex;

  const TabChangedEvent(this.selectedIndex);

  @override
  List<Object?> get props => [selectedIndex];
}

class SessionStartedEvent extends BottomNavigationEvent {
  const SessionStartedEvent();

  @override
  List<Object?> get props => [];
}

class SessionEndedEvent extends BottomNavigationEvent {
  const SessionEndedEvent();

  @override
  List<Object?> get props => [];
}
