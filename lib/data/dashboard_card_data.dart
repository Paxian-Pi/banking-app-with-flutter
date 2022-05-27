class DashboardCard {
  final String balance;
  final String bank;
  final String accountNumber;
  final String userName;
  final String cardProvider;

  DashboardCard(this.balance, this.bank, this.accountNumber, this.userName,
      this.cardProvider);

  Map<String, dynamic> dashboardCardData() {
    final map = {
      'balance': balance,
      'accountNumber:': accountNumber,
      'username': userName,
    };

    return map;
  }
}

final List<DashboardCard> dashboardCardData = [
  DashboardCard(
    'Balance:',
    'hdfc-bank',
    'Acc/Number:',
    'Username:',
    'mastercard',
  ),
];
