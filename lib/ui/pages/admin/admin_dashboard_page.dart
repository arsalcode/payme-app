import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:payme/shared/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final SupabaseClient _supabase = Supabase.instance.client;

  int selectedTab = 0; // 0: KYC Verification, 1: Audit Mutasi, 2: Semua User
  bool isLoading = true;

  List<Map<String, dynamic>> pendingKycUsers = [];
  List<Map<String, dynamic>> allUsers = [];
  List<Map<String, dynamic>> allTransactions = [];

  int totalUsers = 0;
  int totalPendingKyc = 0;
  int totalBalance = 0;
  int totalTransactions = 0;

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // 1. Ambil data pengguna
      final usersRes = await _supabase
          .from('users')
          .select()
          .order('created_at', ascending: false);

      final usersList = List<Map<String, dynamic>>.from(usersRes);

      // 2. Ambil data dompet (wallets)
      final walletsRes = await _supabase.from('wallets').select();
      final walletsList = List<Map<String, dynamic>>.from(walletsRes);

      int sumBalance = 0;
      for (var w in walletsList) {
        sumBalance += (w['balance'] as num?)?.toInt() ?? 0;
      }

      // Gabungkan data wallet ke users
      for (var u in usersList) {
        final matchWallet = walletsList.firstWhere(
          (w) => w['user_id'] == u['id'],
          orElse: () => {},
        );
        u['card_number'] = matchWallet['card_number'] ?? '-';
        u['balance'] = matchWallet['balance'] ?? 0;
      }

      // 3. Ambil data riwayat transaksi
      final txRes = await _supabase
          .from('transactions')
          .select()
          .order('created_at', ascending: false);
      final txList = List<Map<String, dynamic>>.from(txRes);

      final pendingList = usersList.where((u) {
        final isVerified = u['is_verified'] == true;
        final hasKtp = u['ktp_picture'] != null &&
            u['ktp_picture'].toString().isNotEmpty;
        return !isVerified && hasKtp;
      }).toList();

      setState(() {
        allUsers = usersList;
        pendingKycUsers = pendingList;
        allTransactions = txList;

        totalUsers = usersList.length;
        totalPendingKyc = pendingList.length;
        totalBalance = sumBalance;
        totalTransactions = txList.length;

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> approveKyc(String userId, String userName) async {
    try {
      await _supabase
          .from('users')
          .update({'is_verified': true}).eq('id', userId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text('Berhasil memverifikasi KYC untuk $userName!'),
        ),
      );

      loadDashboardData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Gagal verifikasi: $e'),
        ),
      );
    }
  }

  Future<void> rejectKyc(String userId, String userName) async {
    try {
      await _supabase.from('users').update({
        'is_verified': false,
        'ktp_picture': null,
      }).eq('id', userId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.orange,
          content: Text('Dokumen KTP $userName ditolak dan dihapus.'),
        ),
      );

      loadDashboardData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Gagal menolak: $e'),
        ),
      );
    }
  }

  void showKtpDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Dokumen KTP - ${user['name']}'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (user['ktp_picture'] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    user['ktp_picture'],
                    height: 280,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Text('Gagal memuat gambar KTP'),
                    ),
                  ),
                )
              else
                const Text('User belum mengunggah foto KTP.'),
              const SizedBox(height: 16),
              Text(
                'Username: @${user['username']} | Email: ${user['email']}',
                style: greyTextStyle.copyWith(fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          if (user['is_verified'] != true) ...[
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(context);
                rejectKyc(user['id'], user['name']);
              },
              child: const Text('Tolak'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                Navigator.pop(context);
                approveKyc(user['id'], user['name']);
              },
              child: const Text('Approve Verifikasi'),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0D1117),
      body: Row(
        children: [
          // 1. SIDEBAR NAVIGASI
          buildSidebar(),

          // 2. KONTEN UTAMA DASHBOARD
          Expanded(
            child: Column(
              children: [
                buildTopHeader(),
                Expanded(
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.blue),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(28),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // KARTU STATISTIK
                              buildStatCards(),
                              const SizedBox(height: 32),

                              // KONTEN TAB AKTIF
                              if (selectedTab == 0) buildKycTab(),
                              if (selectedTab == 1) buildAuditTab(),
                              if (selectedTab == 2) buildUsersTab(),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSidebar() {
    return Container(
      width: 250,
      color: const Color(0xff161B22),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/img_logo_light.png',
                width: 120,
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'ADMIN',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          buildSidebarItem(
            icon: Icons.verified_user_outlined,
            title: 'Verifikasi KYC',
            badge: totalPendingKyc > 0 ? '$totalPendingKyc' : null,
            isSelected: selectedTab == 0,
            onTap: () => setState(() => selectedTab = 0),
          ),
          buildSidebarItem(
            icon: Icons.receipt_long_outlined,
            title: 'Audit Transaksi',
            isSelected: selectedTab == 1,
            onTap: () => setState(() => selectedTab = 1),
          ),
          buildSidebarItem(
            icon: Icons.people_alt_outlined,
            title: 'Semua Pengguna',
            isSelected: selectedTab == 2,
            onTap: () => setState(() => selectedTab = 2),
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.arrow_back, color: Colors.white70),
            title: const Text(
              'Ke Aplikasi Mobile',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home-page',
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildSidebarItem({
    required IconData icon,
    required String title,
    String? badge,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: isSelected
            ? Border.all(color: Colors.blue.withOpacity(0.5))
            : null,
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          color: isSelected ? Colors.blue : Colors.white70,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        trailing: badge != null
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Widget buildTopHeader() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: Color(0xff161B22),
        border: Border(
          bottom: BorderSide(color: Color(0xff30363D), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            selectedTab == 0
                ? 'Verifikasi Dokumen KYC (KTP)'
                : selectedTab == 1
                    ? 'Audit Seluruh Mutasi Transaksi'
                    : 'Manajemen Akun & Saldo Pengguna',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: loadDashboardData,
            icon: const Icon(Icons.refresh, color: Colors.blue),
            tooltip: 'Segarkan Data',
          ),
        ],
      ),
    );
  }

  Widget buildStatCards() {
    final formattedBalance = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(totalBalance);

    return Row(
      children: [
        Expanded(
          child: buildCardItem(
            title: 'Total Pengguna',
            value: '$totalUsers User',
            icon: Icons.person_outline,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: buildCardItem(
            title: 'Menunggu KYC',
            value: '$totalPendingKyc Dokumen',
            icon: Icons.pending_actions,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: buildCardItem(
            title: 'Total Saldo Beredar',
            value: formattedBalance,
            icon: Icons.account_balance_wallet_outlined,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: buildCardItem(
            title: 'Total Transaksi',
            value: '$totalTransactions Transaksi',
            icon: Icons.swap_horiz,
            color: Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget buildCardItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xff161B22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xff30363D)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white60, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildKycTab() {
    if (pendingKycUsers.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: const Color(0xff161B22),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xff30363D)),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green, size: 48),
              SizedBox(height: 12),
              Text(
                'Tidak ada antrean verifikasi KYC',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(height: 4),
              Text(
                'Semua pengguna yang mengunggah KTP sudah terverifikasi!',
                style: TextStyle(color: Colors.white60, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff161B22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xff30363D)),
      ),
      child: DataTable(
        headingTextStyle: const TextStyle(
          color: Colors.white70,
          fontWeight: FontWeight.bold,
        ),
        dataTextStyle: const TextStyle(color: Colors.white),
        columns: const [
          DataColumn(label: Text('PENGGUNA')),
          DataColumn(label: Text('USERNAME')),
          DataColumn(label: Text('DOKUMEN KTP')),
          DataColumn(label: Text('STATUS')),
          DataColumn(label: Text('AKSI')),
        ],
        rows: pendingKycUsers.map((user) {
          return DataRow(
            cells: [
              DataCell(
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: user['profile_picture'] != null
                          ? NetworkImage(user['profile_picture'])
                          : const AssetImage('assets/images/img_profile.png')
                              as ImageProvider,
                    ),
                    const SizedBox(width: 10),
                    Text(user['name'] ?? '-'),
                  ],
                ),
              ),
              DataCell(Text('@${user['username'] ?? "-"}')),
              DataCell(
                TextButton.icon(
                  icon: const Icon(Icons.remove_red_eye, size: 16),
                  label: const Text('Lihat Foto KTP'),
                  onPressed: () => showKtpDialog(user),
                ),
              ),
              DataCell(
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Pending Review',
                    style: TextStyle(color: Colors.orange, fontSize: 12),
                  ),
                ),
              ),
              DataCell(
                Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      onPressed: () => approveKyc(user['id'], user['name']),
                      child: const Text('Approve',
                          style: TextStyle(fontSize: 12)),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      onPressed: () => rejectKyc(user['id'], user['name']),
                      child:
                          const Text('Tolak', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget buildAuditTab() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff161B22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xff30363D)),
      ),
      child: DataTable(
        headingTextStyle: const TextStyle(
          color: Colors.white70,
          fontWeight: FontWeight.bold,
        ),
        dataTextStyle: const TextStyle(color: Colors.white),
        columns: const [
          DataColumn(label: Text('WAKTU')),
          DataColumn(label: Text('TIPE')),
          DataColumn(label: Text('DESKRIPSI')),
          DataColumn(label: Text('NOMINAL')),
          DataColumn(label: Text('STATUS')),
        ],
        rows: allTransactions.map((tx) {
          final isIncome = tx['transaction_type'] == 'topup' ||
              tx['transaction_type'] == 'transfer_in';

          final amountFormatted = NumberFormat.currency(
            locale: 'id',
            symbol: 'Rp ',
            decimalDigits: 0,
          ).format((tx['amount'] as num?)?.toInt() ?? 0);

          final date = tx['created_at'] != null
              ? DateFormat('dd MMM yyyy, HH:mm')
                  .format(DateTime.parse(tx['created_at']).toLocal())
              : '-';

          return DataRow(
            cells: [
              DataCell(Text(date, style: const TextStyle(fontSize: 13))),
              DataCell(
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isIncome
                        ? Colors.green.withOpacity(0.15)
                        : Colors.red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tx['transaction_type'] ?? '-',
                    style: TextStyle(
                      color: isIncome ? Colors.green : Colors.redAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              DataCell(Text(tx['title'] ?? '-')),
              DataCell(
                Text(
                  (isIncome ? '+ ' : '- ') + amountFormatted,
                  style: TextStyle(
                    color: isIncome ? Colors.green : Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              DataCell(
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tx['status'] ?? 'success',
                    style: const TextStyle(color: Colors.blue, fontSize: 11),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget buildUsersTab() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff161B22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xff30363D)),
      ),
      child: DataTable(
        headingTextStyle: const TextStyle(
          color: Colors.white70,
          fontWeight: FontWeight.bold,
        ),
        dataTextStyle: const TextStyle(color: Colors.white),
        columns: const [
          DataColumn(label: Text('PENGGUNA')),
          DataColumn(label: Text('USERNAME')),
          DataColumn(label: Text('VIRTUAL CARD')),
          DataColumn(label: Text('SALDO WALLET')),
          DataColumn(label: Text('STATUS KYC')),
        ],
        rows: allUsers.map((user) {
          final isVerified = user['is_verified'] == true;
          final balanceFormatted = NumberFormat.currency(
            locale: 'id',
            symbol: 'Rp ',
            decimalDigits: 0,
          ).format(user['balance'] ?? 0);

          return DataRow(
            cells: [
              DataCell(
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: user['profile_picture'] != null
                          ? NetworkImage(user['profile_picture'])
                          : const AssetImage('assets/images/img_profile.png')
                              as ImageProvider,
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(user['name'] ?? '-'),
                        Text(
                          user['email'] ?? '-',
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              DataCell(Text('@${user['username'] ?? "-"}')),
              DataCell(Text(user['card_number'] ?? '-')),
              DataCell(
                Text(
                  balanceFormatted,
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              DataCell(
                Row(
                  children: [
                    Icon(
                      isVerified ? Icons.check_circle : Icons.cancel,
                      color: isVerified ? Colors.green : Colors.grey,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isVerified ? 'Verified' : 'Unverified',
                      style: TextStyle(
                        color: isVerified ? Colors.green : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
