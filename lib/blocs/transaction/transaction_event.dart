part of 'transaction_bloc.dart';

sealed class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class TransactionTopUpEvent extends TransactionEvent {
  final int amount;
  final String bankName;

  const TransactionTopUpEvent({
    required this.amount,
    required this.bankName,
  });

  @override
  List<Object?> get props => [amount, bankName];
}

class TransactionTransferEvent extends TransactionEvent {
  final int amount;
  final String recipientUsername;

  const TransactionTransferEvent({
    required this.amount,
    required this.recipientUsername,
  });

  @override
  List<Object?> get props => [amount, recipientUsername];
}

class TransactionBuyDataEvent extends TransactionEvent {
  final int amount;
  final String providerName;
  final String packageName;

  const TransactionBuyDataEvent({
    required this.amount,
    required this.providerName,
    required this.packageName,
  });

  @override
  List<Object?> get props => [amount, providerName, packageName];
}

class TransactionWithdrawEvent extends TransactionEvent {
  final int amount;
  final String method;

  const TransactionWithdrawEvent({
    required this.amount,
    required this.method,
  });

  @override
  List<Object?> get props => [amount, method];
}

class TransactionPayServiceEvent extends TransactionEvent {
  final int amount;
  final String serviceTitle;
  final String serviceType;

  const TransactionPayServiceEvent({
    required this.amount,
    required this.serviceTitle,
    required this.serviceType,
  });

  @override
  List<Object?> get props => [amount, serviceTitle, serviceType];
}

class TransactionGetLatestEvent extends TransactionEvent {}
