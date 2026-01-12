import 'dart:convert';
import 'dart:typed_data';

import 'package:beadneko/constants.dart';
import 'package:beadneko/core/volc_signer.dart';
import 'package:dio/dio.dart';

class VolcImageSegmentationService {
  VolcImageSegmentationService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  Future<Uint8List> removeBackground(Uint8List imageBytes) async {
    if (ConstantsVolc.accessKey.isEmpty || ConstantsVolc.secretKey.isEmpty) {
      throw Exception('Volcengine access keys are not configured.');
    }

    final uri = _buildUri();
    final payload = jsonEncode({
      'image_base64': base64Encode(imageBytes),
    });

    final signer = VolcSigner(
      accessKey: ConstantsVolc.accessKey,
      secretKey: ConstantsVolc.secretKey,
      region: ConstantsVolc.region,
      service: ConstantsVolc.service,
    );
    final headers = signer.sign(
      method: 'POST',
      uri: uri,
      payload: payload,
    );

    final response = await _dio.postUri(
      uri,
      data: payload,
      options: Options(headers: headers, responseType: ResponseType.json),
    );

    final data = response.data is String
        ? jsonDecode(response.data as String)
        : response.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Unexpected response format from Volcengine.');
    }

    final imageBase64 = _extractBase64Image(data);
    if (imageBase64 == null || imageBase64.isEmpty) {
      throw Exception('No segmented image returned from Volcengine.');
    }

    return base64Decode(imageBase64);
  }

  Uri _buildUri() {
    final base = Uri.parse(ConstantsVolc.endpoint);
    return base.replace(
      path: base.path.isEmpty ? '/' : base.path,
      queryParameters: {
        'Action': ConstantsVolc.action,
        'Version': ConstantsVolc.version,
      },
    );
  }

  String? _extractBase64Image(Map<String, dynamic> data) {
    final candidates = <dynamic>[
      data['Result'],
      data['result'],
      data['data'],
      data['Data'],
    ];

    for (final candidate in candidates) {
      final result = _findImageInPayload(candidate);
      if (result != null) return result;
    }
    return null;
  }

  String? _findImageInPayload(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      for (final key in ['image', 'Image', 'foreground', 'mask', 'image_base64']) {
        final value = payload[key];
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
      }
      for (final value in payload.values) {
        final nested = _findImageInPayload(value);
        if (nested != null) return nested;
      }
    } else if (payload is List) {
      for (final item in payload) {
        final nested = _findImageInPayload(item);
        if (nested != null) return nested;
      }
    }
    return null;
  }
}
