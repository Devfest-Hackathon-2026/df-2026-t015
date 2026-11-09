import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/models/models.dart';
import '../../data/providers.dart';

/// 理由文の取得間隔（API 仕様: 1 秒間隔）
const explanationPollInterval = Duration(seconds: 1);

/// 理由文を待つ上限。超えたら failed と同じ扱いで定型文を出す。
const explanationPollTimeout = Duration(seconds: 20);

/// 遅れを伝える画面で受け取った組み直し案。組み直し案の画面と共有する。
final replanResultProvider =
    NotifierProvider.family<ReplanResultNotifier, ReplanResult?, String>(
      ReplanResultNotifier.new,
    );

class ReplanResultNotifier extends Notifier<ReplanResult?> {
  ReplanResultNotifier(this.itineraryId);

  final String itineraryId;

  @override
  ReplanResult? build() => null;

  /// POST /itineraries/:id/replans
  Future<ReplanResult> request(ReplanRequest request) async {
    final result = await ref
        .read(itineraryApiProvider)
        .createReplan(itineraryId, request);
    state = result;
    return result;
  }

  void clear() => state = null;
}

typedef ExplanationKey = ({
  String itineraryId,
  String replanId,
  String optionId,
});

/// 変更理由の文章（F-05）。ready か failed になるまで 1 秒ごとに取りに行く。
final explanationProvider = StreamProvider.autoDispose
    .family<Explanation, ExplanationKey>((ref, key) async* {
      final api = ref.watch(itineraryApiProvider);
      final deadline = DateTime.now().add(explanationPollTimeout);
      while (true) {
        final Explanation explanation;
        try {
          explanation = await api.getExplanation(
            key.itineraryId,
            key.replanId,
            optionId: key.optionId,
          );
        } catch (_) {
          // 理由文が取れなくても案の確定はできるようにする
          yield const Explanation(status: ExplanationStatus.failed);
          return;
        }
        yield explanation;
        if (explanation.status != ExplanationStatus.pending) return;
        if (DateTime.now().isAfter(deadline)) {
          yield const Explanation(status: ExplanationStatus.failed);
          return;
        }
        await Future<void>.delayed(explanationPollInterval);
      }
    });
