import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:payme/models/transaction_model.dart';
import 'package:payme/service/transaction_service.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionService _transactionService = TransactionService();

  TransactionBloc() : super(TransactionInitial()) {
    on<TransactionTopUpEvent>((event, emit) async {
      try {
        emit(TransactionLoading());
        await _transactionService.topUp(
          amount: event.amount,
          bankName: event.bankName,
        );
        emit(const TransactionSuccess('Top Up berhasil!'));
      } catch (e) {
        emit(TransactionFailed(e.toString()));
      }
    });

    on<TransactionTransferEvent>((event, emit) async {
      try {
        emit(TransactionLoading());
        await _transactionService.transfer(
          amount: event.amount,
          recipientUsername: event.recipientUsername,
        );
        emit(const TransactionSuccess('Transfer saldo berhasil!'));
      } catch (e) {
        emit(TransactionFailed(e.toString()));
      }
    });

    on<TransactionBuyDataEvent>((event, emit) async {
      try {
        emit(TransactionLoading());
        await _transactionService.buyDataPackage(
          amount: event.amount,
          providerName: event.providerName,
          packageName: event.packageName,
        );
        emit(const TransactionSuccess('Pembelian paket data berhasil!'));
      } catch (e) {
        emit(TransactionFailed(e.toString()));
      }
    });

    on<TransactionGetLatestEvent>((event, emit) async {
      try {
        emit(TransactionLoading());
        final transactions = await _transactionService.getLatestTransactions();
        emit(TransactionLatestLoaded(transactions));
      } catch (e) {
        emit(TransactionFailed(e.toString()));
      }
    });
  }
}
