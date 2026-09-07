import 'package:flutter/material.dart';
import 'package:payme/models/user_model.dart';
import 'package:payme/service/transaction_service.dart';
import 'package:payme/shared/theme.dart';
import 'package:payme/ui/pages/transfer_amount_page.dart';
import 'package:payme/ui/widgets/buttons.dart';
import 'package:payme/ui/widgets/transfer_result_user_item.dart';

class TransferPage extends StatefulWidget {
  const TransferPage({super.key});

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  final TextEditingController searchController =
      TextEditingController(text: '');
  final TransactionService _transactionService = TransactionService();

  List<UserModel> searchResults = [];
  UserModel? selectedUser;
  bool isLoading = false;

  void onSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    final results = await _transactionService.searchUsers(query.trim());

    setState(() {
      searchResults = results;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 24,
        ),
        children: [
          const SizedBox(
            height: 30,
          ),
          Text(
            'Search Recipient',
            style: blackTextStyle.copyWith(
              fontSize: 16,
              fontWeight: semiBold,
            ),
          ),
          const SizedBox(
            height: 14,
          ),
          TextFormField(
            controller: searchController,
            onChanged: onSearch,
            decoration: InputDecoration(
              hintText: 'by Username (e.g. arsal)',
              hintStyle: greyTextStyle,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Text(
            'Search Results',
            style: blackTextStyle.copyWith(
              fontSize: 16,
              fontWeight: semiBold,
            ),
          ),
          const SizedBox(
            height: 14,
          ),
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          else if (searchResults.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Center(
                child: Text(
                  searchController.text.isEmpty
                      ? 'Ketik username untuk mencari teman'
                      : 'Pengguna tidak ditemukan',
                  style: greyTextStyle,
                ),
              ),
            )
          else
            Wrap(
              spacing: 17,
              runSpacing: 17,
              children: searchResults.map((user) {
                final isSelected = selectedUser?.id == user.id;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedUser = user;
                    });
                  },
                  child: TransferResultUserItem(
                    imageUrl: user.profilePicture != null &&
                            user.profilePicture!.isNotEmpty
                        ? user.profilePicture!
                        : 'assets/images/img_frend1.png',
                    name: user.name ?? 'User',
                    username: user.username ?? 'user',
                    isVerified: user.isVerified ?? false,
                    isSelected: isSelected,
                  ),
                );
              }).toList(),
            ),
          const SizedBox(
            height: 60,
          ),
          CustomFilledButtons(
            title: 'Continue',
            onPressed: () {
              final targetUsername = selectedUser?.username ??
                  searchController.text.replaceAll('@', '').trim();

              if (targetUsername.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.red,
                    content: Text('Silakan pilih atau ketik username penerima'),
                  ),
                );
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TransferAmmountPage(
                    recipientUsername: targetUsername,
                  ),
                ),
              );
            },
          ),
          const SizedBox(
            height: 50,
          ),
        ],
      ),
    );
  }
}
