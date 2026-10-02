part of '../l10n.dart';

class SZh extends S {
  const SZh();

  @override
  String get code => 'zh';

  @override
  String _tasks(int c) => '$c项任务';

  // Dates
  @override
  List<String> get weekdays => const ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];
  @override
  List<String> get weekdaysShort => const ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
  @override
  List<String> get weekdayInitials => const ['一', '二', '三', '四', '五', '六', '日'];
  @override
  List<String> get months =>
      const ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月'];
  @override
  String formatDay(DateTime d) => '${months[d.month - 1]}${d.day}日 ${weekdaysShort[d.weekday - 1]}';
  @override
  String due(String day) => '$day到期';
  @override
  String get dueToday => '今天到期';
  @override
  String get dueTomorrow => '明天到期';
  @override
  String overdue(int days) => '已逾期$days天';

  // Common
  @override
  String get undo => '撤销';
  @override
  String get delete => '删除';
  @override
  String get archive => '归档';
  @override
  String get stats => '统计';
  @override
  String get addTask => '添加任务';
  @override
  String streak(int d) => '连续$d天';

  // Main screen
  @override
  String get myTasks => '我的任务';
  @override
  String get emptyJar => '空罐子';
  @override
  String jarWith(int c) => '罐子里装着已完成的${_tasks(c)}的字母';
  @override
  String get allDone => '全部完成，享受片刻宁静吧。';
  @override
  String goalReached(int g) => '已达成每日目标：今天完成了$g项。';
  @override
  String added(int c) => '已添加${_tasks(c)}';
  @override
  String duplicated(String t) => '已复制“$t”';
  @override
  String deleted(String t) => '已删除“$t”';
  @override
  String get nothingToArchive => '暂无可归档的内容，先完成一项任务吧。';
  @override
  String archived(int c) => '已归档${_tasks(c)}';
  @override
  String jarFull(int c) => '罐子满了，已将最早的${_tasks(c)}移至归档。';
  @override
  String get listEmpty => '列表为空。';
  @override
  String copied(int c) => '已将${_tasks(c)}复制到剪贴板';
  @override
  String get noMatch => '没有匹配的任务。';
  @override
  String get clearSearch => '清除搜索';
  @override
  String get themeSystem => '跟随系统';
  @override
  String get themeLight => '浅色';
  @override
  String get themeDark => '深色';
  @override
  String doneOfGoal(int d, int g) => '今天已完成 $d/$g';
  @override
  String get nothingToday => '今天还没有完成任何任务';
  @override
  String doneToday(int d) => '今天已完成$d项';
  @override
  String goalPercent(int p) => '已完成每日目标的百分之$p';
  @override
  String listPercent(int p) => '已完成列表的百分之$p';
  @override
  String get closeSearch => '关闭搜索';
  @override
  String get searchAndSort => '搜索和排序';
  @override
  String get more => '更多';
  @override
  String get copyList => '复制列表';
  @override
  String get emptyTheJar => '归档已完成的任务';
  @override
  String get sound => '声音';
  @override
  String get vibration => '振动';
  @override
  String get settings => '设置';
  @override
  String get dailyGoal => '每日目标';
  @override
  String get dailyGoalHint => '每天要完成的任务数';
  @override
  String get off => '关闭';
  @override
  String get theme => '主题';
  @override
  String get language => '语言';
  @override
  String get soundHint => '滴答声和嗖嗖声';
  @override
  String get vibrationHint => '感受字母落下';
  @override
  String legend(String day) => '$day完成的字母会以这种颜色沉积';
  @override
  String get searchTasks => '搜索任务';
  @override
  String get showAll => '全部';
  @override
  String get showOpen => '未完成';
  @override
  String get showDone => '已完成';
  @override
  String get sortNewest => '最新';
  @override
  String get sortPriority => '优先级';
  @override
  String get sortDue => '截止日期';
  @override
  String get nothingOnList => '列表中没有任务';
  @override
  String get emptyHint => '添加一项任务，完成后勾选，它的字母就会落进罐子里。';
  @override
  String get gestureHint => '长按任务可编辑 · 滑动可删除 · 摇一摇可清空罐子';

  // Task editor
  @override
  String get lowHint => '轻盈的字母，落地时会弹起。';
  @override
  String get normalHint => '字母像沙子一样沉积。';
  @override
  String get highHint => '粗重的字母，会把其他字母挤开。';
  @override
  String get editTask => '编辑任务';
  @override
  String get newTask => '新任务';
  @override
  String get whatNeedsDoing => '要做什么？';
  @override
  String get whatNeedsDoingMany => '要做什么？粘贴列表可一次添加多项。';
  @override
  String get low => '低';
  @override
  String get normal => '普通';
  @override
  String get high => '高';
  @override
  String get today => '今天';
  @override
  String get tomorrow => '明天';
  @override
  String get pickDate => '选择日期';
  @override
  String get removeDueDate => '移除截止日期';
  @override
  String get duplicate => '复制';
  @override
  String get saveChanges => '保存更改';
  @override
  String addMany(int c) => '添加${_tasks(c)}';

  @override
  String get noteHint => '备注（可选）';
  @override
  String get pinToTop => '置顶';
  @override
  String get unpin => '取消置顶';
  @override
  String get repeatNever => '一次';
  @override
  String get repeatDaily => '每天';
  @override
  String get repeatWeekly => '每周';

  @override
  String get showOverdue => '已逾期';
  @override
  String overdueCount(int c) => '$c项逾期';
  @override
  String get reminders => '截止日期提醒';
  @override
  String get remindersHint => '在截止当天 9:00 发送通知';
  @override
  String get remindersBlocked => '通知已被禁止，请在系统设置中允许。';
  @override
  String get smartDateHint => '提示：以“明天”或“周五”结尾即可设置日期';

  @override
  String get jarStyle => '罐子颜色';
  @override
  String get jarStyleHint => '用于新完成的任务';
  @override
  String jarStyleName(int i) => const ['工作日', '日落', '海洋', '单色'][i];
  @override
  String get backup => '备份';
  @override
  String get copyBackup => '复制备份';
  @override
  String get restoreFromClipboard => '从剪贴板恢复';
  @override
  String get backupCopied => '备份已复制，请粘贴到安全的地方。';
  @override
  String get restoreQ => '恢复此备份？';
  @override
  String get restoreBody => '当前的列表和归档将被剪贴板中的备份替换。';
  @override
  String get restore => '恢复';
  @override
  String get restored => '备份已恢复。';
  @override
  String get notABackup => '剪贴板中没有 Done Dust 备份。';
  @override
  String get restoreAll => '全部恢复';
  @override
  String get restoreAllQ => '恢复所有已归档的任务？';
  @override
  String get restoreAllBody => '它们会作为未完成任务回到列表中。';

  @override
  String get alarm => '闹钟';
  @override
  String alarmAt(String time) => '闹钟 $time';
  @override
  String get removeAlarm => '移除闹钟';
  @override
  String get stopwatch => '秒表';
  @override
  String get startStopwatch => '开始计时';
  @override
  String get pauseStopwatch => '暂停计时';

  // Archive
  @override
  String get deletedFromArchive => '已从归档中删除';
  @override
  String get clearArchiveQ => '清空归档？';
  @override
  String get clearArchiveBody => '已归档的任务将被永久删除。';
  @override
  String get keep => '保留';
  @override
  String get clearArchive => '清空归档';
  @override
  String get searchArchive => '搜索归档';
  @override
  String get archiveEmpty => '摇一摇手机，或点按 ⋮ › 归档已完成的任务，已完成的任务就会出现在这里。';
  @override
  String noArchiveMatch(String q) => '没有与“$q”匹配的已归档任务。';
  @override
  String doneOn(String day) => '$day完成';
  @override
  String get reopenTask => '重新打开任务';

  // Stats
  @override
  String statsLine(int total, int open, int streakDays) =>
      '共完成$total项 · $open项未完成 · ${streak(streakDays)}';
  @override
  String milestone(int d) => '连续$d天！继续让字母落下吧。';
  @override
  String bestStreak(int d) => '最长连续：$d天';
  @override
  String weekLine(String now, String last) => '本周 $now · 上周 $last';
  @override
  String get last12Weeks => '最近 12 周';
  @override
  String heatCell(String day, int c) => '$day：完成$c项';
  @override
  String bestDay(String day) => '最佳一天：$day';
  @override
  String finishedOn(String day, int c) => '$day：完成$c项';

  // First-launch tasks
  @override
  List<String> get starterTasks => const [
        '勾选我，看字母纷纷落下',
        '倾斜手机，让字母堆滑动',
        '重要任务字体加粗，像石头一样落下',
        '拖动落下的字母，或点按字母堆',
        '横向滑动任务，把它吹走',
        '摇一摇手机，把罐子清空到归档',
      ];
}
