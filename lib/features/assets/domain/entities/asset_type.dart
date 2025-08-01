enum AssetType {
  paymentAccount('payment_account', 'Tài khoản thanh toán'),
  savingsAccount('savings_account', 'Tài khoản tiết kiệm'),
  gold('gold', 'Vàng'),
  loan('loan', 'Cho vay'),
  realEstate('real_estate', 'Bất động sản'),
  other('other', 'Khác');

  const AssetType(this.value, this.displayName);

  final String value;
  final String displayName;

  static AssetType fromString(String value) {
    return AssetType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => AssetType.other,
    );
  }

  @override
  String toString() => value;
}