import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import '../../models/user.dart';


part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserInitial()) {
    on<SetUser>((event, emit) {
      emit(UserLoaded(user: event.user));
    });

    on<ClearUser>((event, emit) {
      emit(UserInitial());
    });
  }
}