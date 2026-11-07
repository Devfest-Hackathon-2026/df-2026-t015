/// 画面に出す文言。「リスケジュール」などの言い方を避け、話し言葉に近い表現にする。
abstract final class AppStrings {
  static const appTitle = 'Iterinerary';

  // 共通
  static const back = '戻る';
  static const retry = 'もう一度読み込む';
  static const loading = '読み込んでいます…';
  static const genericError = 'うまく読み込めませんでした';
  static const minutesUnit = '分';
  static const yenUnit = '円';
  static const estimate = '目安';
  static const priceUnknown = '料金不明';
  static const unchanged = '（変わらず）';

  // 旅程一覧（F-08、F-09、F-11）
  static const listTitle = 'わたしの旅程';
  static const listSubtitle = '1 日ごとに旅程をつくれます';
  static const listTodayPrefix = '今日・';
  static const listUpcoming = 'これから';
  static const listPast = '終わった旅';
  static const listEmpty = 'まだ旅程がありません。\n下のボタンから作ってみましょう';
  static const listCreate = '新しい旅程を作る';
  static const listDepartSuffix = ' 発';
  static const listArriveSuffix = ' 着';
  static const listArrow = ' → ';
  static const listPlaceSeparator = '・';
  static const listPlaceCountSuffix = 'か所';
  static const listMorePlacesPrefix = ' ほか';
  static const listDaysLeftPrefix = 'あと';
  static const listDaysLeftSuffix = '日';
  static const listTomorrow = '明日';
  static const listExpiresSuffix = 'に自動で消えます';
  static const listMenuSuffix = ' の操作';
  static const listActionEdit = '名前と日付を変える';
  static const listActionCopy = '別の日にコピーする';
  static const listActionDelete = 'この旅程を削除する';
  static const listClose = '閉じる';
  static const listDeleteConfirm = 'この旅程を削除しますか？\n削除すると元に戻せません。';
  static const listDeleteButton = '削除する';
  static const listCancel = 'やめる';
  static const listEditTitle = '名前と日付を変える';
  static const listEditNameLabel = '旅程の名前';
  static const listEditDateLabel = '旅行日';
  static const listEditSave = '変更する';
  static const listCopyHelp = 'コピー先の旅行日を選ぶ';
  static const listEdited = '旅程を変更しました';
  static const listCopied = '旅程をコピーしました';
  static const listDeleted = '旅程を削除しました';

  // 3.1 行き先と優先度
  static const planTitle = 'どこに行きたいですか？';
  static const planSubtitle = '大事な所に優先度をつけてください';
  static const planAddLabel = '行き先を追加';
  static const planAddHint = '場所の名前や、したいことを入力';
  static const planAddButton = '追加';
  static const planStart = '出発';
  static const planStartUnset = '出発地を選ぶ';
  static const planEndBy = '終わりたい時刻';
  static const planSubmit = '旅程を作る';
  static const planUpdate = '旅程を作り直す';
  static const planEmpty = '行きたい場所を追加してください';
  static const planInterpretHeader = 'こんな場所はどうですか';
  static const planStayPrefix = '滞在 ';
  static const planStayPickerTitle = '滞在時間';
  static const planRemove = '外す';
  static const planTooMany = '行き先は 10 件までです';
  static const planNeedStart = '出発地を選んでください';
  static const planDefaultTitleSuffix = 'の旅';
  static const planMustInfeasible = '「必須」の予定がすべては入りきりません。優先度か終わりたい時刻を見直してください';
  static const planEndInfeasible = '行き先を外しても、終わりたい時刻までに終わる場所に着けません。時刻を見直してください';
  static const planItineraryLimit = '保存できる旅程の上限に達しています。使わない旅程を削除してください';
  static const planStartSearchTitle = '出発地を探す';

  // 3.2 今日の旅程
  static const todayMoveTotal = '移動の合計';
  static const todayPriceTotal = '料金の目安';
  static const todayEndAt = '終わる時刻';
  static const todayNextMovePrefix = '次の移動まで あと';
  static const todayDone = '済み';
  static const todayCurrent = 'いまここ';
  static const todayDelayButton = '予定より遅れている';
  static const todayEditButton = '行き先を編集する';
  static const todayDropped = '入りきらなかった行き先';
  static const walk = '徒歩';
  static const bus = 'バス';
  static const train = '電車';
  static const taxi = 'タクシー';
  static const departSuffix = ' 発';

  // 3.3 遅れを伝える
  static const delayTopBar = '遅れを伝える';
  static const delayTitle = 'どのくらい\n遅れていますか？';
  static const delayCurrentPrefix = 'いま：';
  static const delayCurrentStaySuffix = ' まで滞在予定';
  static const delayPickTime = '時刻を指定する';
  static const delayOkTitle = 'このままで間に合います';
  static const delayOkBody = 'この遅れなら、旅程を変える必要はありません。';
  static const delayLateTitleSuffix = 'の遅れで、次の予定に間に合いません';
  static const delayGoReplan = '組み直してもらう';
  static const delayBackToItinerary = '旅程に戻る';
  static const delayOverOneHour = '1時間以上';
  static const delayChecking = '影響を確かめています…';

  // 3.4 組み直し案
  static const replanTopBar = '組み直し案';
  static const replanBackToDelay = '遅れの入力に戻る';
  static const replanChangesPrefix = '変更点（';
  static const replanChangesSuffix = '件）';
  static const replanExplanationPending = '組み直した理由をまとめています…';
  static const replanExplanationFailed = '遅れに合わせて、必須の予定に間に合うよう組み直しました。';
  static const replanAccept = 'この案で確定する';
  static const replanOtherOption = 'ほかの案を見る';
  static const replanKeepOriginal = '元の旅程のまま';
  static const replanReplace = '置き換え';
  static const replanRetime = '時刻を調整';
  static const replanKeep = 'そのまま';
  static const replanDrop = '外す';
  static const replanStayChangedPrefix = '滞在は ';
  static const replanUntil = ' まで';
  static const replanArrow = ' → ';
  static const replanKeepTimeSuffix = ' 発は変わりません';
  static const replanConflict = '旅程がほかの操作で更新されています。もう一度遅れを伝えてください';
  static const replanExpired = '組み直し案の期限が切れました。もう一度遅れを伝えてください';

  // 優先度
  static const priorityMust = '必須';
  static const priorityWant = 'できれば';
  static const priorityOptional = '余裕があれば';
}
