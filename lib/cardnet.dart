import 'package:cardnet/map/map.dart';
import 'package:cardnet/models/cardnet_response.dart';
import 'package:oxidized/oxidized.dart';
import 'package:zencillo_helpers/zencillo_helpers.dart';

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

  static Future<Result<FormaPagoDetalleModel, String>> payFull({
    required int idTurno,
    required int numeroTurno,
    required int idDocument,
    required double total,
    required double taxTotal,
    required double subTotal,
    required int idFormaPago,
    required int invoice,
  }) async {
    final result = await CardnetPlatform.instance.pay(
      amount: total,
      tax: taxTotal,
      invoice: invoice,
    );
    if (result.isErr()) {
      return Err(result.unwrapErr());
    }
    final data = result.unwrap();
    return Ok(data.toFormaPagoDetalle(
      idTurno: idTurno,
      numeroTurno: numeroTurno,
      idDocument: idDocument,
      total: total,
      taxTotal: taxTotal,
      subTotal: subTotal,
      idFormaPago: idFormaPago,
    ));
  }

  static Future<Result<FormaPagoDetalleModel, String>> payComplete({
    required double total,
    required double taxTotal,
    required double subTotal,
    required int invoice,
  }) async {
    final result = await CardnetPlatform.instance.pay(
      amount: total,
      tax: taxTotal,
      invoice: invoice,
    );
    if (result.isErr()) {
      return Err(result.unwrapErr());
    }
    final data = result.unwrap();
    return Ok(data.toFormaPagoDetalle(
      idTurno: 0,
      numeroTurno: 0,
      idDocument: 0,
      total: total,
      taxTotal: taxTotal,
      subTotal: subTotal,
      idFormaPago: 0,
    ));
  }

  static Future<Result<CardnetResponse, String>> printJson({
    required Map<String, dynamic> jsonPrint,
  }) {
    return CardnetPlatform.instance.printJson(
      jsonPrint: jsonPrint,
    );
  }

  static Future<Result<CardnetResponse, String>> printLinesQr({
    required List<String> lines,
    String? qr,
  }) {
    return CardnetPlatform.instance.printLinesQr(
      lines: lines,
      qr: qr,
    );
  }
}
