import 'dart:convert';
import 'dart:math';
import 'package:payme/models/sign_up_form_model.dart';
import 'package:payme/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Cek apakah email sudah terdaftar
  Future<bool> checkEmail(String email) async {
    try {
      final res = await _supabase
          .from('users')
          .select('email')
          .eq('email', email.trim().toLowerCase())
          .maybeSingle();

      return res != null; // true jika email sudah ada
    } catch (e) {
      rethrow;
    }
  }

  // Registrasi Pengguna Baru
  Future<UserModel> signUp(SignUpFormModel data) async {
    try {
      // 1. Buat akun Auth di Supabase
      final AuthResponse authRes = await _supabase.auth.signUp(
        email: data.email!.trim().toLowerCase(),
        password: data.password!,
      );

      final user = authRes.user;
      if (user == null) {
        throw Exception('Gagal membuat akun autentikasi.');
      }

      final userId = user.id;
      String? avatarUrl;
      String? ktpUrl;

      // 2. Upload Foto Profil ke Storage (jika ada)
      if (data.profilePicture != null && data.profilePicture!.isNotEmpty) {
        try {
          final bytes = base64Decode(data.profilePicture!.split(',').last);
          final fileName =
              '$userId-avatar-${DateTime.now().millisecondsSinceEpoch}.png';

          await _supabase.storage.from('avatars').uploadBinary(
                fileName,
                bytes,
                fileOptions: const FileOptions(contentType: 'image/png'),
              );

          avatarUrl = _supabase.storage.from('avatars').getPublicUrl(fileName);
        } catch (_) {}
      }

      // 3. Upload Foto KTP ke Storage (jika ada)
      if (data.ktp != null && data.ktp!.isNotEmpty) {
        try {
          final bytes = base64Decode(data.ktp!.split(',').last);
          final fileName =
              '$userId-ktp-${DateTime.now().millisecondsSinceEpoch}.png';

          await _supabase.storage.from('documents').uploadBinary(
                fileName,
                bytes,
                fileOptions: const FileOptions(contentType: 'image/png'),
              );

          ktpUrl = _supabase.storage.from('documents').getPublicUrl(fileName);
        } catch (_) {}
      }

      // 4. Generate username unik
      final cleanName =
          (data.name ?? 'user').toLowerCase().replaceAll(RegExp(r'\s+'), '');
      final username = '$cleanName${Random().nextInt(900) + 100}';

      // 5. Simpan profil ke tabel public.users
      final userData = {
        'id': userId,
        'name': data.name ?? 'User',
        'email': data.email!.trim().toLowerCase(),
        'username': username,
        'pin': data.pin,
        'profile_picture': avatarUrl,
        'ktp_picture': ktpUrl,
        'is_verified': false,
      };

      await _supabase.from('users').insert(userData);

      // 6. Buat dompet digital virtual di public.wallets
      final random12 = List.generate(12, (_) => Random().nextInt(10)).join();
      final cardNumber = '5399$random12';

      final walletData = {
        'user_id': userId,
        'card_number': cardNumber,
        'balance': 100000, // Saldo awal bonus selamat datang Rp 100.000
      };

      await _supabase.from('wallets').insert(walletData);

      return UserModel.fromJson(userData, walletJson: walletData);
    } catch (e) {
      rethrow;
    }
  }

  // Login Pengguna
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final AuthResponse res = await _supabase.auth.signInWithPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      final user = res.user;
      if (user == null) {
        throw Exception('Login gagal, user tidak ditemukan.');
      }

      final userRes =
          await _supabase.from('users').select().eq('id', user.id).single();
      var walletRes = await _supabase
          .from('wallets')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (walletRes == null || walletRes['card_number'] == null) {
        final random12 =
            DateTime.now().millisecondsSinceEpoch.toString().substring(1, 13);
        final cardNumber = '5399$random12';
        final newWallet = {
          'user_id': user.id,
          'card_number': cardNumber,
          'balance': 100000,
        };
        await _supabase.from('wallets').upsert(newWallet);
        walletRes = newWallet;
      }

      return UserModel.fromJson(userRes, walletJson: walletRes);
    } catch (e) {
      rethrow;
    }
  }

  // Ambil Data Sesi Saat Ini
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final userRes =
          await _supabase.from('users').select().eq('id', user.id).single();
      var walletRes = await _supabase
          .from('wallets')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (walletRes == null || walletRes['card_number'] == null) {
        final random12 =
            DateTime.now().millisecondsSinceEpoch.toString().substring(1, 13);
        final cardNumber = '5399$random12';
        final newWallet = {
          'user_id': user.id,
          'card_number': cardNumber,
          'balance': 100000,
        };
        await _supabase.from('wallets').upsert(newWallet);
        walletRes = newWallet;
      }

      return UserModel.fromJson(userRes, walletJson: walletRes);
    } catch (e) {
      return null;
    }
  }

  // Logout
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Update Profil Pengguna
  Future<void> updateUser({
    required String name,
    required String username,
    required String email,
    String? password,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('Pengguna belum login.');

      final cleanUsername = username.replaceAll('@', '').trim().toLowerCase();

      // Cek apakah username sudah digunakan user lain
      final checkUser = await _supabase
          .from('users')
          .select('id')
          .eq('username', cleanUsername)
          .neq('id', user.id)
          .maybeSingle();

      if (checkUser != null) {
        throw Exception(
            'Username @$cleanUsername sudah digunakan pengguna lain.');
      }

      // Update data di tabel public.users
      final updateData = {
        'name': name.trim(),
        'username': cleanUsername,
        'email': email.trim().toLowerCase(),
      };

      await _supabase.from('users').update(updateData).eq('id', user.id);

      // Jika ganti password
      if (password != null && password.trim().isNotEmpty) {
        await _supabase.auth
            .updateUser(UserAttributes(password: password.trim()));
      }
    } catch (e) {
      rethrow;
    }
  }

  // Update PIN Keamanan
  Future<void> updatePin({
    required String oldPin,
    required String newPin,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('Pengguna belum login.');

      // Validasi PIN lama
      final currentProfile = await _supabase
          .from('users')
          .select('pin')
          .eq('id', user.id)
          .single();

      final actualPin = currentProfile['pin']?.toString();
      if (actualPin != oldPin.trim()) {
        throw Exception('PIN lama yang Anda masukkan tidak sesuai.');
      }

      if (newPin.trim().length != 6) {
        throw Exception('PIN baru harus berupa 6 digit angka.');
      }

      // Simpan PIN baru
      await _supabase
          .from('users')
          .update({'pin': newPin.trim()}).eq('id', user.id);
    } catch (e) {
      rethrow;
    }
  }
}
