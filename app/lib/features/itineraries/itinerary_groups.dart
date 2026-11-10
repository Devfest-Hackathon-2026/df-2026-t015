import '../../data/models/models.dart';
import '../../utils/format.dart';

/// 旅程一覧の「今日」「これから」「終わった旅」の分け方。
///
/// API は旅行日の新しい順に返すため、分けるのは端末の日付を基準にクライアントで行う
/// （docs/iterinerary_API.docx 4. GET /me/itineraries）。
class ItineraryGroups {
  const ItineraryGroups({
    required this.today,
    required this.upcoming,
    required this.past,
  });

  /// [now] の日付を基準に分ける。
  ///
  /// - 今日：同じ日付の旅程を複数作れるため、リストで持つ
  /// - これから：近い日から順に並べる
  /// - 終わった旅：新しい日から順に並べる
  factory ItineraryGroups.from(List<ItineraryListEntry> entries, DateTime now) {
    final todayDate = Format.isoDate(now);
    // YYYY-MM-DD は文字列の比較で日付の前後が決まる
    final today = entries
        .where(
          (e) =>
              e.date.compareTo(todayDate) <= 0 &&
              Format.isoDate(e.end.arriveAt.toLocal()).compareTo(todayDate) >=
                  0,
        )
        .toList();
    final upcoming =
        entries.where((e) => e.date.compareTo(todayDate) > 0).toList()
          ..sort((a, b) => a.date.compareTo(b.date));
    final past =
        entries
            .where(
              (e) =>
                  Format.isoDate(e.end.arriveAt.toLocal())
                      .compareTo(todayDate) <
                  0,
            )
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
    return ItineraryGroups(today: today, upcoming: upcoming, past: past);
  }

  final List<ItineraryListEntry> today;
  final List<ItineraryListEntry> upcoming;
  final List<ItineraryListEntry> past;

  bool get isEmpty => today.isEmpty && upcoming.isEmpty && past.isEmpty;
}

/// 旅行日まで何日あるか（今日なら 0）
int daysUntil(String date, DateTime now) {
  final target = DateTime.parse(date);
  final today = DateTime(now.year, now.month, now.day);
  return DateTime(
    target.year,
    target.month,
    target.day,
  ).difference(today).inDays;
}
