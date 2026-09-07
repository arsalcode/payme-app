import 'package:payme/models/transaction_model.dart';
import 'package:payme/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String get _currentUserId {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Pengguna belum login.');
    return user.id;
  }

  // 1. Top Up Saldo
  Future<void> topUp({
    required int amount,
    required String bankName,
  }) async {
    try {
      final userId = _currentUserId;

      // Ambil saldo dompet saat ini
      final wallet = await _supabase
          .from('wallets')
          .select()
          .eq('user_id', userId)
          .single();

      final currentBalance = (wallet['balance'] as num).toInt();
      final newBalance = currentBalance + amount;

      // Perbarui saldo dompet
      await _supabase
          .from('wallets')
          .update({'balance': newBalance}).eq('user_id', userId);

      // Catat mutasi di tabel transactions
      await _supabase.from('transactions').insert({
        'user_id': userId,
        'transaction_type': 'topup',
        'title': 'Top Up $bankName',
        'amount': amount,
        'status': 'success',
      });
    } catch (e) {
      rethrow;
    }
  }

  // 2. Transfer Saldo Antar Pengguna
  Future<void> transfer({
    required int amount,
    required String recipientUsername,
  }) async {
    try {
      final senderId = _currentUserId;

      // Ambil profil dan dompet pengirim
      final sender =
          await _supabase.from('users').select().eq('id', senderId).single();
      final senderWallet = await _supabase
          .from('wallets')
          .select()
          .eq('user_id', senderId)
          .single();

      final senderBalance = (senderWallet['balance'] as num).toInt();
      if (senderBalance < amount) {
        throw Exception('Saldo tidak mencukupi untuk melakukan transfer.');
      }

      // Cari penerima berdasarkan username
      final cleanUsername = recipientUsername.replaceAll('@', '').trim();
      final recipient = await _supabase
          .from('users')
          .select()
          .ilike('username', cleanUsername)
          .maybeSingle();

      if (recipient == null) {
        throw Exception('Pengguna @$cleanUsername tidak ditemukan.');
      }

      final recipientId = recipient['id'];
      if (recipientId == senderId) {
        throw Exception('Anda tidak dapat mentransfer saldo ke akun sendiri.');
      }

      // Ambil dompet penerima
      final recipientWallet = await _supabase
          .from('wallets')
          .select()
          .eq('user_id', recipientId)
          .single();

      final recipientBalance = (recipientWallet['balance'] as num).toInt();

      // Potong saldo pengirim
      await _supabase
          .from('wallets')
          .update({'balance': senderBalance - amount}).eq('user_id', senderId);

      // Tambah saldo penerima
      await _supabase
          .from('wallets')
          .update({'balance': recipientBalance + amount}).eq(
              'user_id', recipientId);

      // Catat mutasi untuk pengirim
      await _supabase.from('transactions').insert({
        'user_id': senderId,
        'transaction_type': 'transfer_out',
        'title': 'Transfer to @${recipient['username']}',
        'amount': amount,
        'status': 'success',
      });

      // Catat mutasi untuk penerima
      await _supabase.from('transactions').insert({
        'user_id': recipientId,
        'transaction_type': 'transfer_in',
        'title': 'Transfer from @${sender['username']}',
        'amount': amount,
        'status': 'success',
      });
    } catch (e) {
      rethrow;
    }
  }

  // 3. Pembelian Paket Data Seluler
  Future<void> buyDataPackage({
    required int amount,
    required String providerName,
    required String packageName,
  }) async {
    try {
      final userId = _currentUserId;

      final wallet = await _supabase
          .from('wallets')
          .select()
          .eq('user_id', userId)
          .single();

      final currentBalance = (wallet['balance'] as num).toInt();
      if (currentBalance < amount) {
        throw Exception('Saldo tidak mencukupi untuk pembelian paket data.');
      }

      // Potong saldo
      await _supabase
          .from('wallets')
          .update({'balance': currentBalance - amount}).eq('user_id', userId);

      // Catat transaksi
      await _supabase.from('transactions').insert({
        'user_id': userId,
        'transaction_type': 'payment',
        'title': '$providerName $packageName',
        'amount': amount,
        'status': 'success',
      });
    } catch (e) {
      rethrow;
    }
  }

  // 4. Ambil Riwayat Transaksi Terkini
  Future<List<TransactionModel>> getLatestTransactions() async {
    try {
      final userId = _currentUserId;

      final List<dynamic> res = await _supabase
          .from('transactions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(10);

      return res
          .map((item) => TransactionModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // 5. Cari Pengguna untuk Transfer
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      final userId = _currentUserId;

      final List<dynamic> res = await _supabase
          .from('users')
          .select()
          .ilike('username', '%$query%')
          .neq('id', userId)
          .limit(10);

      return res
          .map((item) => UserModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
