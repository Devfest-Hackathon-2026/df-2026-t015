#!/usr/bin/env bash
# 開発規約（docs/iterinerary_app_ui_fac.docx 7.4）のうち、機械的に検出できるものを確かめる。
#   - StatefulWidget を使わない（HookWidget / HookConsumerWidget で書く）
#   - Color(0x… を theme.dart 以外に書かない
# マジックナンバーは lint で検出できないため、レビューで確認する。
set -euo pipefail
cd "$(dirname "$0")/.."

status=0

if grep -rn --include='*.dart' --exclude='*.g.dart' --exclude='*.freezed.dart' \
  'extends StatefulWidget' lib; then
  echo '::error::StatefulWidget ではなく HookWidget / HookConsumerWidget を使ってください'
  status=1
fi

if grep -rn --include='*.dart' --exclude='*.g.dart' --exclude='*.freezed.dart' \
  'Color(0x' lib | grep -v '^lib/theme\.dart:'; then
  echo '::error::色は lib/theme.dart に定義し、Theme から参照してください'
  status=1
fi

if [ "$status" -eq 0 ]; then
  echo '規約チェック: OK'
fi
exit "$status"
