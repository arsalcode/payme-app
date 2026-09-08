import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:payme/blocs/auth/auth_bloc.dart';
import 'package:payme/service/auth_service.dart';
import 'package:payme/shared/theme.dart';
import 'package:payme/ui/widgets/buttons.dart';
import 'package:payme/ui/widgets/forms.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final AuthService _authService = AuthService();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      usernameController.text = authState.user.username ?? '';
      nameController.text = authState.user.name ?? '';
      emailController.text = authState.user.email ?? '';
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> handleUpdateProfile() async {
    final username = usernameController.text.trim();
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Username, Nama Lengkap, dan Email wajib diisi!'),
        ),
      );
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Format email tidak valid!'),
        ),
      );
      return;
    }

    if (password.isNotEmpty && password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Kata sandi baru minimal harus 6 karakter!'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await _authService.updateUser(
        name: name,
        username: username,
        email: email,
        password: password.isNotEmpty ? password : null,
      );

      // Sinkronkan ulang data di AuthBloc agar instan berubah di Home
      if (mounted) {
        context.read<AuthBloc>().add(AuthGetCurrentUser());

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/profile-edit-succes',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(e.toString().replaceAll('Exception: ', '')),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightkBackgroundColor,
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomFormFailed(
                  title: 'Username',
                  controller: usernameController,
                ),
                const SizedBox(height: 16),
                CustomFormFailed(
                  title: 'Full Name',
                  controller: nameController,
                ),
                const SizedBox(height: 16),
                CustomFormFailed(
                  title: 'Email Address',
                  controller: emailController,
                ),
                const SizedBox(height: 16),
                CustomFormFailed(
                  title: 'New Password (Opsional)',
                  controller: passwordController,
                  obscureText: true,
                ),
                const SizedBox(height: 8),
                Text(
                  '*Kosongkan kata sandi jika tidak ingin mengubah password.',
                  style: greyTextStyle.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 32),
                CustomFilledButtons(
                  title: isLoading ? 'Menyimpan Perubahan...' : 'Update Now',
                  onPressed: isLoading ? () {} : handleUpdateProfile,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
