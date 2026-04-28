import 'dart:convert';

import 'package:cardnet/models/cardnet_response.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:oxidized/oxidized.dart';

import 'cardnet_platform_interface.dart';

class MethodChannelCardnet extends CardnetPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('cardnet');

  @override
  Future<Result<CardnetResponse, String>> pay({
    required double amount,
    required double tax,
    required int invoice,
  }) async {
    try {
      final result = await methodChannel.invokeMethod("pay", {
        "amount": amount,
        "tax": tax,
        "invoice": invoice,
      });

      return _parseCardnetResponse(result);
    } catch (e) {
      return Err("Excepción inesperada en Cardnet: $e");
    }
  }

  Result<CardnetResponse, String> _parseCardnetResponse(dynamic result) {
    if (result == null) {
      return const Err("No se recibió respuesta de Cardnet");
    }

    if (result is Map) {
      final data = CardnetResponse.fromJson(
        Map<String, dynamic>.from(result),
      );

      if (data.code == 1) return Err(data.message);
      return Ok(data);
    }

    if (result is String) {
      try {
        final decoded = jsonDecode(result);

        if (decoded is Map) {
          final data = CardnetResponse.fromJson(
            Map<String, dynamic>.from(decoded),
          );

          if (data.code == 1) return Err(data.message);
          return Ok(data);
        } else {
          return const Err("Cardnet devolvió texto que no es un JSON válido");
        }
      } catch (e) {
        return Err("Error al convertir respuesta de Cardnet: $e");
      }
    }

    return Err("Tipo de respuesta no soportado: ${result.runtimeType}");
  }

  @override
  Future<Result<CardnetResponse, String>> printJson({
    required Map<String, dynamic> jsonPrint,
  }) async {
    try {
      final result = await methodChannel.invokeMethod("print", {
        "json": jsonEncode(jsonPrint),
      });

      return _parseCardnetResponse(result);
    } catch (e) {
      return Err("Excepción inesperada imprimiendo en Cardnet: $e");
    }
  }
}
