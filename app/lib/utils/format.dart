import 'package:intl/intl.dart';

import '../constants/app_strings.dart';
import '../data/models/models.dart';

/// 画面に出す値の書式。
abstract final class Format {
  static final _time = DateFormat('HH:mm');
  static final _yen = NumberFormat.decimalPattern('ja');
  static const _weekdays = ['月', '火', '水', '木', '金', '土', '日'];
  static const _minutesPerHour = 60;
  static const _hhmmSeparator = ':';
  static const _pad = 2;

  /// 12:50
  static String time(DateTime dateTime) => _time.format(dateTime.toLocal());

  /// 3,800円
  static String yen(int amount) =>
      '${_yen.format(amount)}${AppStrings.yenUnit}';

  /// 47分
  static String minutes(int minutes) => '$minutes${AppStrings.minutesUnit}';

  /// 11月14日（土）。date は YYYY-MM-DD。
  static String dateJa(String date) {
    final d = DateTime.parse(date);
    return '${d.month}月${d.day}日（${_weekdays[d.weekday - DateTime.monday]}）';
  }

  /// 料金。目安なら「目安 1,500円」、不明なら「料金不明」と、推測で断定しない。
  static String price(Price price) {
    final amount = price.amount;
    if (amount == null || price.kind == PriceKind.unknown) {
      return AppStrings.priceUnknown;
    }
    final text = yen(amount);
    return price.kind == PriceKind.estimate
        ? '${AppStrings.estimate} $text'
        : text;
  }

  /// TimeOfDay 相当（時・分）を HH:mm にする
  static String hhmm(int hour, int minute) =>
      '${hour.toString().padLeft(_pad, '0')}$_hhmmSeparator${minute.toString().padLeft(_pad, '0')}';

  /// HH:mm を (時, 分) にする
  static (int, int) parseHhmm(String value) {
    final parts = value.split(_hhmmSeparator);
    return (int.parse(parts.first), int.parse(parts.last));
  }

  /// YYYY-MM-DD
  static String isoDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  /// 1時間以上の分数を「1時間20分」のように書く
  static String duration(int minutes) {
    if (minutes < _minutesPerHour) return Format.minutes(minutes);
    final h = minutes ~/ _minutesPerHour;
    final m = minutes % _minutesPerHour;
    return m == 0 ? '$h時間' : '$h時間$m${AppStrings.minutesUnit}';
  }
}
