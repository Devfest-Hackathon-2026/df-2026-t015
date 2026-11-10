import 'package:freezed_annotation/freezed_annotation.dart';

/// サーバーに送る日時の書式（RFC3339、タイムゾーン付き）。
///
/// `DateTime.toIso8601String()` は端末のローカル時刻だとオフセットが付かず、
/// サーバー（Go の `time.RFC3339`）で解析できないため、UTC に直して `Z` を付ける。
/// 小数秒は Go の解析でも受け付けられる。
String toRfc3339(DateTime dateTime) => dateTime.toUtc().toIso8601String();

/// [DateTime] を [toRfc3339] の書式で読み書きする。
class Rfc3339Converter implements JsonConverter<DateTime, String> {
  const Rfc3339Converter();

  @override
  DateTime fromJson(String json) => DateTime.parse(json);

  @override
  String toJson(DateTime object) => toRfc3339(object);
}
