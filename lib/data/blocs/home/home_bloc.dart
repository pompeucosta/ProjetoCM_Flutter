import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeState()) {
    on<TabChangedEvent>((event, emit) {
      if (event.selectedIndex >= AppTab.values.length) {
        print(event.selectedIndex.toString() +
            " >= " +
            AppTab.values.length.toString());
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
