import 'package:flutter/material.dart';

class ConstantsKeyCache {
  ConstantsKeyCache._();
  static String keyLanguageCode = 'LANGUAGE_CODE';
  static String keyThemeMode = 'THEME_MODE';
  static String keyAccessToken = "ACCESS_TOKEN";
  static String keyRefreshToken = "REFRESH_TOKEN";
  static String keyFCMToken = "FCM_TOKEN";
  static String keyIsFirst = "IS_FIRST";
  static String keyUser = "USER";
}

class ConstantsHttp {
  ConstantsHttp._();

  static const String baseUrl = '';
}

class ConstantsVolc {
  ConstantsVolc._();

  static const String accessKey =
      String.fromEnvironment('VOLC_ACCESS_KEY', defaultValue: '');
  static const String secretKey =
      String.fromEnvironment('VOLC_SECRET_KEY', defaultValue: '');
  static const String region =
      String.fromEnvironment('VOLC_REGION', defaultValue: 'cn-north-1');
  static const String service =
      String.fromEnvironment('VOLC_SERVICE', defaultValue: 'visual');
  static const String endpoint =
      String.fromEnvironment('VOLC_ENDPOINT', defaultValue: 'https://visual.volcengineapi.com/');
  static const String action =
      String.fromEnvironment('VOLC_SEGMENT_ACTION', defaultValue: 'SegmentImage');
  static const String version =
      String.fromEnvironment('VOLC_SEGMENT_VERSION', defaultValue: '2020-08-26');
}

const appBarHeight = kToolbarHeight;
const tileHeight = 55.0;
