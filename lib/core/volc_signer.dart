import 'dart:convert';

import 'package:crypto/crypto.dart';

class VolcSigner {
  VolcSigner({
    required this.accessKey,
    required this.secretKey,
    required this.region,
    required this.service,
  });

  final String accessKey;
  final String secretKey;
  final String region;
  final String service;

  Map<String, String> sign({
    required String method,
    required Uri uri,
    required String payload,
    Map<String, String>? headers,
    DateTime? now,
  }) {
    final requestTime = (now ?? DateTime.now()).toUtc();
    final timestamp = _formatTimestamp(requestTime);
    final dateStamp = _formatDate(requestTime);

    final payloadHash = sha256.convert(utf8.encode(payload)).toString();
    final canonicalUri = uri.path.isEmpty ? '/' : uri.path;
    final canonicalQuery = _canonicalizeQuery(uri.queryParametersAll);

    final lowerHeaders = <String, String>{
      'content-type': 'application/json',
      'host': uri.host,
      'x-date': timestamp,
      'x-content-sha256': payloadHash,
    };
    if (headers != null) {
      for (final entry in headers.entries) {
        lowerHeaders[entry.key.toLowerCase()] = entry.value.trim();
      }
    }

    final sortedHeaderKeys = lowerHeaders.keys.toList()..sort();
    final canonicalHeaders = sortedHeaderKeys
        .map((key) => '$key:${lowerHeaders[key]!.trim()}')
        .join('\n');
    final signedHeaders = sortedHeaderKeys.join(';');

    final canonicalRequest = [
      method.toUpperCase(),
      canonicalUri,
      canonicalQuery,
      '$canonicalHeaders\n',
      signedHeaders,
      payloadHash,
    ].join('\n');

    final credentialScope = '$dateStamp/$region/$service/request';
    final stringToSign = [
      'HMAC-SHA256',
      timestamp,
      credentialScope,
      sha256.convert(utf8.encode(canonicalRequest)).toString(),
    ].join('\n');

    final signingKey = _getSignatureKey(secretKey, dateStamp, region, service);
    final signature =
        Hmac(sha256, signingKey).convert(utf8.encode(stringToSign)).toString();

    final authorization =
        'HMAC-SHA256 Credential=$accessKey/$credentialScope, '
        'SignedHeaders=$signedHeaders, '
        'Signature=$signature';

    return {
      'Content-Type': 'application/json',
      'Host': uri.host,
      'X-Date': timestamp,
      'X-Content-Sha256': payloadHash,
      'Authorization': authorization,
    };
  }

  List<int> _getSignatureKey(
    String key,
    String dateStamp,
    String region,
    String service,
  ) {
    final kDate = _sign(utf8.encode('VOLC$key'), dateStamp);
    final kRegion = _sign(kDate, region);
    final kService = _sign(kRegion, service);
    return _sign(kService, 'request');
  }

  List<int> _sign(List<int> key, String msg) {
    return Hmac(sha256, key).convert(utf8.encode(msg)).bytes;
  }

  String _canonicalizeQuery(Map<String, List<String>> parameters) {
    if (parameters.isEmpty) return '';
    final items = <String>[];
    final sortedKeys = parameters.keys.toList()..sort();
    for (final key in sortedKeys) {
      final values = [...?parameters[key]]..sort();
      for (final value in values) {
        items.add('${Uri.encodeQueryComponent(key)}='
            '${Uri.encodeQueryComponent(value)}');
      }
    }
    return items.join('&');
  }

  String _formatDate(DateTime time) {
    final year = time.year.toString().padLeft(4, '0');
    final month = time.month.toString().padLeft(2, '0');
    final day = time.day.toString().padLeft(2, '0');
    return '$year$month$day';
  }

  String _formatTimestamp(DateTime time) {
    final date = _formatDate(time);
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final second = time.second.toString().padLeft(2, '0');
    return '${date}T${hour}${minute}${second}Z';
  }
}
