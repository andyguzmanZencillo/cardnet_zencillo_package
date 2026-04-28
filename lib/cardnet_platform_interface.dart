import 'package:cardnet/cardnet_method_channel.dart';
import 'package:cardnet/models/cardnet_response.dart';
import 'package:oxidized/oxidized.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class CardnetPlatform extends PlatformInterface {
  CardnetPlatform() : super(token: _token);

  static final Object _token = Object();

  static CardnetPlatform _instance = MethodChannelCardnet();

  static CardnetPlatform get instance => _instance;

  static set instance(CardnetPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<Result<CardnetResponse, String>> pay({
    required double amount,
    required double tax,
    required int invoice,
  });

  Future<Result<CardnetResponse, String>> printJson({
    required Map<String, dynamic> jsonPrint,
  });
}
