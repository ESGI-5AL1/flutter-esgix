import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'bloc_counter_event.dart';
part 'bloc_counter_state.dart';

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(CounterInitial()) {
    on<CounterEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
