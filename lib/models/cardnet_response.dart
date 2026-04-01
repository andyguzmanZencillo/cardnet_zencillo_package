import 'package:cardnet/extension/get_pro.dart';

class CardnetResponse {
  final int code;
  final String message;
  final String autorizationCode;
  final String value;
  final String tax;
  final String receipt;
  final String rrn;
  final String terminalId;
  final String timeDate;
  final String responseCode;
  final String franchise;
  final String accountType;
  final String quotas;
  final String lastFourDigitsCard;
  final String merchantPosId;
  final int idInvoice;
  final double amountSend;
  final double taxSend;
  final int isla;
  final String data;

  CardnetResponse({
    required this.code,
    required this.message,
    required this.autorizationCode,
    required this.value,
    required this.tax,
    required this.receipt,
    required this.rrn,
    required this.terminalId,
    required this.timeDate,
    required this.responseCode,
    required this.franchise,
    required this.accountType,
    required this.quotas,
    required this.lastFourDigitsCard,
    required this.merchantPosId,
    required this.idInvoice,
    required this.amountSend,
    required this.taxSend,
    required this.isla,
    required this.data,
  });

  factory CardnetResponse.fromJson(Map<String, dynamic> json) {
    final data = json.getPro('data', <String, dynamic>{});
    data.addEntries({'message': json.getPro('message', '')}.entries);
    return CardnetResponse(
      code: json.getPro('code', 0),
      message: json.getPro('message', ''),
      autorizationCode: data.getPro('autorizationCode', ''),
      value: data.getPro('value', ''),
      tax: data.getPro('tax', ''),
      receipt: data.getPro('receipt', ''),
      rrn: data.getPro('rrn', ''),
      terminalId: data.getPro('terminalId', ''),
      timeDate: data.getPro('timeDate', ''),
      responseCode: data.getPro('responseCode', ''),
      franchise: data.getPro('franchise', ''),
      accountType: data.getPro('accountType', ''),
      quotas: data.getPro('quotas', ''),
      lastFourDigitsCard: data.getPro('lastFourDigitsCard', ''),
      merchantPosId: data.getPro('merchantPosId', ''),
      idInvoice: data.getPro('idInvoice', 0),
      amountSend: data.getPro('amountSend', 0.0),
      taxSend: data.getPro('taxSend', 0.0),
      isla: data.getPro(
        'isla',
        0,
      ),
      data: data.toString(),
    );
  }

  /*CardnetResponse.fromJson(Map<String, dynamic> json)
      : message = json.getPro('message', ''),
        autorizationCode = json.getPro('autorizationCode', ''),
        value = json.getPro('value', ''),
        tax = json.getPro('tax', ''),
        receipt = json.getPro('receipt', ''),
        rrn = json.getPro('rrn', ''),
        terminalId = json.getPro('terminalId', ''),
        timeDate = json.getPro('timeDate', ''),
        responseCode = json.getPro('responseCode', ''),
        franchise = json.getPro('franchise', ''),
        accountType = json.getPro('accountType', ''),
        quotas = json.getPro('quotas', ''),
        lastFourDigitsCard = json.getPro('lastFourDigitsCard', ''),
        merchantPosId = json.getPro('merchantPosId', ''),
        idInvoice = json.getPro('idInvoice', 0),
        amountSend = json.getPro('amountSend', 0.0),
        taxSend = json.getPro('taxSend', 0),
        isla = json.getPro('isla', 0);*/
}
