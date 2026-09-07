import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:payme/models/sign_up_form_model.dart';
import 'package:payme/models/user_model.dart';
import 'package:payme/service/auth_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService = AuthService();

  AuthBloc() : super(AuthInitial()) {
    on<AuthCheckEmail>((event, emit) async {
      try {
        emit(AuthLoading());
        final isEmailExist = await _authService.checkEmail(event.email);
        if (isEmailExist) {
          emit(const AuthFailed(
              'Email sudah terdaftar, silakan gunakan email lain atau login.'));
        } else {
          emit(AuthCheckEmailSuccess());
        }
      } catch (e) {
        emit(AuthFailed(e.toString()));
      }
    });

    on<AuthRegister>((event, emit) async {
      try {
        emit(AuthLoading());
        final user = await _authService.signUp(event.data);
        emit(AuthSuccess(user));
      } catch (e) {
        emit(AuthFailed(e.toString()));
      }
    });

    on<AuthLogin>((event, emit) async {
      try {
        emit(AuthLoading());
        final user = await _authService.signIn(
          email: event.email,
          password: event.password,
        );
        emit(AuthSuccess(user));
      } catch (e) {
        emit(AuthFailed(e.toString()));
      }
    });

    on<AuthGetCurrentUser>((event, emit) async {
      try {
        emit(AuthLoading());
        final user = await _authService.getCurrentUser();
        if (user != null) {
          emit(AuthSuccess(user));
        } else {
          emit(AuthInitial());
        }
      } catch (e) {
        emit(AuthFailed(e.toString()));
      }
    });

    on<AuthLogout>((event, emit) async {
      try {
        emit(AuthLoading());
        await _authService.signOut();
        emit(AuthInitial());
      } catch (e) {
        emit(AuthFailed(e.toString()));
      }
    });
  }
}
