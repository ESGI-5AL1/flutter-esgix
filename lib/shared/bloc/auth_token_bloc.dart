import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'auth_token_event.dart';
part 'auth_token_state.dart';

class AuthTokenBloc extends Bloc<AuthTokenEvent, AuthTokenState> {
  AuthTokenBloc() : super(AuthTokenInitial()) {
    on<GetAuthToken>((event, emit) {
      // TODO: implement event handler
    });
  }
}
