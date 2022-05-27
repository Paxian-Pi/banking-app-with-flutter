class Transaction {
  final String type;
  final String date;
  final String amount;

  Transaction(this.type, this.date, this.amount);
}

final List<Transaction> transactionData = [
  Transaction('Deposited', 'May 23, 09:00', '660'),
  Transaction('Transferred', 'May 23, 09:30', '1020'),
  Transaction('Transferred', 'May 23, 09:45', '3420'),
  Transaction('Withdrawn', 'May 23, 13:00', '180'),
];
