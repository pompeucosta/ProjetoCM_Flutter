import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'bottom_navigation_event.dart';
part 'bottom_navigation_state.dart';

class BottomNavigationBloc
    extends Bloc<BottomNavigationEvent, BottomNavigationState> {
  BottomNavigationBloc() : super(const BottomNavigationState()) {
    on<TabChangedEvent>((event, emit) {
      if (event.selectedIndex >= AppTab.values.length) {
        print("invalid index");
      } else {
        emit(state.copyWith(selectedTab: AppTab.values[event.selectedIndex]));
      }
    });
    on<SessionStartedEvent>((event, emit) {
      emit(state.copyWith(includeSession: true));
    });
    on<SessionEndedEvent>((event, emit) {
      emit(state.copyWith(includeSession: false));
    });
  }
}
