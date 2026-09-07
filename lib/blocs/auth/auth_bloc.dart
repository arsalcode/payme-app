import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AuthEvent>((event, emit) {
      if (event is AuthCheckEmail) {
        try {} catch (e) {
          emit(AuthFailed(e.toString()));
        }
      }
      // TODO: implement event handler
    });
  }
}
