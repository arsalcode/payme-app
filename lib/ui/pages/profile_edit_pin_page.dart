import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:payme/blocs/auth/auth_bloc.dart';
import 'package:payme/service/auth_service.dart';
import 'package:payme/shared/theme.dart';
import 'package:payme/ui/widgets/buttons.dart';
import 'package:payme/ui/widgets/forms.dart';

class ProfileEditPinPage extends StatefulWidget {
  const ProfileEditPinPage({super.key});

  @override
  State<ProfileEditPinPage> createState() => _ProfileEditPinPageState();
}

class _ProfileEditPinPageState extends State<ProfileEditPinPage> {
  final TextEditingController oldPinController = TextEditingController();
  final TextEditingController newPinController = TextEditingController();
  final TextEditingController confirmPinController = TextEditingController();

  final AuthService _authService = AuthService();
  bool isLoading = false;

  @override
  void dispose() {
    oldPinController.dispose();
    newPinController.dispose();
    confirmPinController.dispose();
    super.dispose();
  }

  Future<void> handleUpdatePin() async {
    final oldPin = oldPinController.text.trim();
    final newPin = newPinController.text.trim();
    final confirmPin = confirmPinController.text.trim();

    if (oldPin.isEmpty || newPin.isEmpty || confirmPin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Semua kolom PIN wajib diisi!'),
        ),
      );
      return;
    }

    if (newPin.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('PIN baru harus terdiri dari 6 digit angka!'),
        ),
      );
      return;
    }

    if (newPin != confirmPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Konfirmasi PIN baru tidak cocok!'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await _authService.updatePin(
        oldPin: oldPin,
        newPin: newPin,
      );

      if (mounted) {
        context.read<AuthBloc>().add(AuthGetCurrentUser());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('PIN transaksi berhasil diperbarui!'),
          ),
        );

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
        title: const Text('Edit PIN Keamanan'),
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
                  title: 'Old PIN (6 Digit)',
                  controller: oldPinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                CustomFormFailed(
                  title: 'New PIN (6 Digit)',
                  controller: newPinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                CustomFormFailed(
                  title: 'Confirm New PIN',
                  controller: confirmPinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 32),
                CustomFilledButtons(
                  title: isLoading ? 'Menyimpan PIN...' : 'Update PIN Now',
                  onPressed: isLoading ? () {} : handleUpdatePin,
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