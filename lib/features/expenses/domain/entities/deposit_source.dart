enum DepositSource {
  salary,      // Lương
  bonus,       // Thưởng
  business,    // Kinh doanh
  investment,  // Đầu tư
  gift,        // Quà tặng
  loan,        // Vay mượn
  other,       // Khác
}

extension DepositSourceExtension on DepositSource {
  String get displayName {
    switch (this) {
      case DepositSource.salary:
        return 'Lương';
      case DepositSource.bonus:
        return 'Thưởng';
      case DepositSource.business:
        return 'Kinh doanh';
      case DepositSource.investment:
        return 'Đầu tư';
      case DepositSource.gift:
        return 'Quà tặng';
      case DepositSource.loan:
        return 'Vay mượn';
      case DepositSource.other:
        return 'Khác';
    }
  }

  String get value {
    switch (this) {
      case DepositSource.salary:
        return 'salary';
      case DepositSource.bonus:
        return 'bonus';
      case DepositSource.business:
        return 'business';
      case DepositSource.investment:
        return 'investment';
      case DepositSource.gift:
        return 'gift';
      case DepositSource.loan:
        return 'loan';
      case DepositSource.other:
        return 'other';
    }
  }

  static DepositSource fromString(String value) {
    switch (value) {
      case 'salary':
        return DepositSource.salary;
      case 'bonus':
        return DepositSource.bonus;
      case 'business':
        return DepositSource.business;
      case 'investment':
        return DepositSource.investment;
      case 'gift':
        return DepositSource.gift;
      case 'loan':
        return DepositSource.loan;
      case 'other':
        return DepositSource.other;
      default:
        return DepositSource.other;
    }
  }
}