enum TransactionType {
  expense,    // Chi tiêu
  deposit,    // Nộp tiền
  transfer,   // Chuyển tiền
}

extension TransactionTypeExtension on TransactionType {
  String get displayName {
    switch (this) {
      case TransactionType.expense:
        return 'Chi tiêu';
      case TransactionType.deposit:
        return 'Nộp tiền';
      case TransactionType.transfer:
        return 'Chuyển tiền';
    }
  }

  String get value {
    switch (this) {
      case TransactionType.expense:
        return 'expense';
      case TransactionType.deposit:
        return 'deposit';
      case TransactionType.transfer:
        return 'transfer';
    }
  }

  static TransactionType fromString(String value) {
    switch (value) {
      case 'expense':
        return TransactionType.expense;
      case 'deposit':
        return TransactionType.deposit;
      case 'transfer':
        return TransactionType.transfer;
      default:
        return TransactionType.expense;
    }
  }
}