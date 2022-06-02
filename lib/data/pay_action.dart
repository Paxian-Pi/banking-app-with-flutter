class PayAction {
  final String actionName;
  final String description;
  final String iconPath;
  final String type;

  PayAction(this.actionName, this.description, this.iconPath, this.type);
}

final List<PayAction> actionData = [
  PayAction('Transfer', 'Transfer funds to other users', 'assets/icons/zap.svg', 'isTransfer'),
  PayAction('Withdraw', 'Withdraw funds from your wallet', 'assets/icons/zap.svg', 'isWithdrawal'),
  PayAction('Deposit', 'Deposit funds to you wallet', 'assets/icons/zap.svg', 'isDeposit'),
];
