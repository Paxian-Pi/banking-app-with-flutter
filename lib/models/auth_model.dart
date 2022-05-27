// Login model
import 'package:banking_app/auth/signup.dart';

import 'package:banking_app/auth/signup.dart';

class LoginResponseModel {
  final String token;
  final String error;

  LoginResponseModel({required this.token, required this.error});

  factory LoginResponseModel.fromJson(final json) {
    return LoginResponseModel(
        token: json['token'] ?? "", error: json['error'] ?? "");
  }
}

class LoginRequestModel {
  String email;
  String password;

  LoginRequestModel({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    final map = {
      'email': email.trim(),
      'password': password.trim(),
    };
    return map;
  }
}

// Signup model
class SignupResponseModel {
  final String newUser;
  final String error;

  SignupResponseModel({required this.newUser, required this.error});

  factory SignupResponseModel.fromJson(final json) {
    return SignupResponseModel(
        newUser: json['newUser'] ?? "", error: json['error'] ?? "");
  }
}

class SignupRequestModel {
  String fullname;
  String email;
  String password;
  String password2;

  SignupRequestModel(
      {required this.fullname,
      required this.email,
      required this.password,
      required this.password2});

  Map<String, dynamic> toJson() {
    final map = {
      'fullname': fullname.trim(),
      'email': email.trim(),
      'password': password.trim(),
      'password2': password2.trim(),
    };
    return map;
  }
}

class UserResponseObjectModel {
  final String objectData;

  UserResponseObjectModel({required this.objectData});

  factory UserResponseObjectModel.fromJson(final json) {
    return UserResponseObjectModel(objectData: json['objectData'] ?? "");
  }
}

class UserResponseArrayModel {
  final String arrayData;

  UserResponseArrayModel({required this.arrayData});

  factory UserResponseArrayModel.fromJson(final json) {
    return UserResponseArrayModel(arrayData: json[0]['arrayData'] ?? "");
  }
}

class CreateBankAccountRequestModel {
  String accountNumber;
  String transactionPIN;

  CreateBankAccountRequestModel(
      {required this.accountNumber, required this.transactionPIN});

  Map<String, dynamic> toJson() {
    final map = {
      'accountNumber': accountNumber.trim(),
      'transactionPIN': transactionPIN.trim(),
    };
    return map;
  }
}

class WithdrawalRequestModel {
  String withdrawAmount;
  String recipientBank;
  String recipientAccountNumber;

  WithdrawalRequestModel(
      {required this.withdrawAmount,
      required this.recipientBank,
      required this.recipientAccountNumber});

  Map<String, dynamic> toJson() {
    final map = {
      'withdrawAmount': withdrawAmount,
      'recipientBank': recipientBank,
      'recipientAccountNumber': recipientAccountNumber
    };
    return map;
  }
}

class TransferRequestModel {
  String transferAmount;
  String recipientAccountNumber;
  String recipientName;

  TransferRequestModel(
      {required this.transferAmount,
      required this.recipientAccountNumber,
      required this.recipientName});

  Map<String, dynamic> toJson() {
    final map = {
      'transferAmount': transferAmount,
      'recipientAccountNumber': recipientAccountNumber,
      'recipientName': recipientName
    };
    return map;
  }
}

class DepositRequestModel {
  String depositeAmount;

  DepositRequestModel({required this.depositeAmount});

  Map<String, dynamic> toJson() {
    final map = {
      'depositeAmount': depositeAmount
    };
    return map;
  }
}
