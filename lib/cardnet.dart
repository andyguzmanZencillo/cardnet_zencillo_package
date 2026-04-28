import 'package:cardnet/models/cardnet_response.dart';
import 'package:oxidized/oxidized.dart';

import 'cardnet_platform_interface.dart';

class Cardnet {
  static Future<Result<CardnetResponse, String>> pay({
    required double amount,
    required double tax,
    required int invoice,
  }) {
    return CardnetPlatform.instance.pay(
      amount: amount,
      tax: tax,
      invoice: invoice,
    );
  }

  static Future<Result<CardnetResponse, String>> printJson({
    required Map<String, dynamic> jsonPrint,
  }) {
    return CardnetPlatform.instance.printJson(
      jsonPrint: jsonPrint,
    );
  }
}
