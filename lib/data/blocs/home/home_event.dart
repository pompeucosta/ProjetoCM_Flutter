part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();
}

class TabChangedEvent extends HomeEvent {
  final int selectedIndex;

  const TabChangedEvent(this.selectedIndex);

  @override
  List<Object?> get props => [selectedIndex];
}

class SessionStartedEvent extends HomeEvent {
  const SessionStartedEvent();

  @override
  List<Object?> get props => [];
}

class SessionEndedEvent extends HomeEvent {
  const SessionEndedEvent();

  @override
  List<Object?> get props => [];
}
