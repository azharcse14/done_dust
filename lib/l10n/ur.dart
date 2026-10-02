part of '../l10n.dart';

class SUr extends S {
  const SUr();

  @override
  String get code => 'ur';

  /// Urdu "کام" is the same in singular and plural.
  @override
  String _tasks(int c) => '$c کام';

  // Dates
  @override
  List<String> get weekdays => const ['پیر', 'منگل', 'بدھ', 'جمعرات', 'جمعہ', 'ہفتہ', 'اتوار'];
  @override
  List<String> get weekdaysShort => const ['پیر', 'منگل', 'بدھ', 'جمعرات', 'جمعہ', 'ہفتہ', 'اتوار'];
  @override
  List<String> get weekdayInitials => const ['پ', 'م', 'ب', 'ج', 'ج', 'ہ', 'ا'];
  @override
  List<String> get months => const [
        'جنوری',
        'فروری',
        'مارچ',
        'اپریل',
        'مئی',
        'جون',
        'جولائی',
        'اگست',
        'ستمبر',
        'اکتوبر',
        'نومبر',
        'دسمبر'
      ];
  @override
  String formatDay(DateTime d) =>
      '${weekdaysShort[d.weekday - 1]}، ${n(d.day)} ${months[d.month - 1]}';
  @override
  String due(String day) => '$day تک';
  @override
  String get dueToday => 'آج تک';
  @override
  String get dueTomorrow => 'کل تک';
  @override
  String overdue(int days) => '$days دن تاخیر';

  // Common
  @override
  String get undo => 'واپس کریں';
  @override
  String get delete => 'حذف کریں';
  @override
  String get archive => 'آرکائیو';
  @override
  String get stats => 'اعداد و شمار';
  @override
  String get addTask => 'کام شامل کریں';
  @override
  String streak(int d) => '$d دن کا تسلسل';

  // Main screen
  @override
  String get myTasks => 'میرے کام';
  @override
  String get emptyJar => 'خالی مرتبان';
  @override
  String jarWith(int c) => 'مرتبان جس میں ${_tasks(c)} مکمل ہونے کے حروف ہیں';
  @override
  String get allDone => 'سب مکمل۔ اب سکون سے رہیں۔';
  @override
  String goalReached(int g) => 'روزانہ ہدف پورا: آج $g مکمل۔';
  @override
  String added(int c) => '${_tasks(c)} شامل ہو گئے';
  @override
  String duplicated(String t) => '“$t” کی نقل بن گئی';
  @override
  String deleted(String t) => '“$t” حذف ہو گیا';
  @override
  String get nothingToArchive => 'ابھی آرکائیو کرنے کو کچھ نہیں۔ پہلے کوئی کام مکمل کریں۔';
  @override
  String archived(int c) => '${_tasks(c)} آرکائیو ہو گئے';
  @override
  String jarFull(int c) => 'مرتبان بھر گیا۔ سب سے پرانے ${_tasks(c)} آرکائیو میں منتقل کر دیے گئے۔';
  @override
  String get listEmpty => 'فہرست خالی ہے۔';
  @override
  String copied(int c) => '${_tasks(c)} کلپ بورڈ پر کاپی ہو گئے';
  @override
  String get noMatch => 'کوئی کام نہیں ملا۔';
  @override
  String get clearSearch => 'تلاش صاف کریں';
  @override
  String get themeSystem => 'سسٹم';
  @override
  String get themeLight => 'لائٹ';
  @override
  String get themeDark => 'ڈارک';
  @override
  String doneOfGoal(int d, int g) => 'آج $g میں سے $d مکمل';
  @override
  String get nothingToday => 'آج ابھی کچھ مکمل نہیں ہوا';
  @override
  String doneToday(int d) => 'آج $d مکمل';
  @override
  String goalPercent(int p) => 'روزانہ ہدف کا $p فیصد';
  @override
  String listPercent(int p) => 'فہرست کا $p فیصد مکمل';
  @override
  String get closeSearch => 'تلاش بند کریں';
  @override
  String get searchAndSort => 'تلاش اور ترتیب';
  @override
  String get more => 'مزید';
  @override
  String get copyList => 'فہرست کاپی کریں';
  @override
  String get emptyTheJar => 'مکمل کام آرکائیو کریں';
  @override
  String get sound => 'آواز';
  @override
  String get vibration => 'وائبریشن';
  @override
  String get settings => 'ترتیبات';
  @override
  String get dailyGoal => 'روزانہ ہدف';
  @override
  String get dailyGoalHint => 'ہر دن مکمل کرنے کے کام';
  @override
  String get off => 'بند';
  @override
  String get theme => 'تھیم';
  @override
  String get language => 'زبان';
  @override
  String get soundHint => 'ٹک اور سرسراہٹ';
  @override
  String get vibrationHint => 'حروف گرنے کو محسوس کریں';
  @override
  String legend(String day) => '$day کو مکمل ہونے والے حروف اس رنگ میں جمتے ہیں';
  @override
  String get searchTasks => 'کام تلاش کریں';
  @override
  String get showAll => 'سب';
  @override
  String get showOpen => 'باقی';
  @override
  String get showDone => 'مکمل';
  @override
  String get sortNewest => 'نئے پہلے';
  @override
  String get sortPriority => 'ترجیح';
  @override
  String get sortDue => 'آخری تاریخ';
  @override
  String get nothingOnList => 'فہرست میں کچھ نہیں';
  @override
  String get emptyHint => 'کام شامل کریں، پھر اس پر نشان لگائیں تاکہ اس کے حروف مرتبان میں گریں۔';
  @override
  String get gestureHint => 'ترمیم کے لیے دبائے رکھیں · حذف کے لیے سوائپ کریں · مرتبان خالی کرنے کے لیے فون ہلائیں';

  // Task editor
  @override
  String get lowHint => 'ہلکے حروف جو گر کر اچھلتے ہیں۔';
  @override
  String get normalHint => 'حروف ریت کی طرح جمتے ہیں۔';
  @override
  String get highHint => 'موٹے، بھاری حروف جو دوسروں کو ہٹا دیتے ہیں۔';
  @override
  String get editTask => 'کام میں ترمیم';
  @override
  String get newTask => 'نیا کام';
  @override
  String get whatNeedsDoing => 'کیا کرنا ہے؟';
  @override
  String get whatNeedsDoingMany => 'کیا کرنا ہے؟ کئی کام شامل کرنے کے لیے فہرست پیسٹ کریں۔';
  @override
  String get low => 'کم';
  @override
  String get normal => 'عام';
  @override
  String get high => 'زیادہ';
  @override
  String get today => 'آج';
  @override
  String get tomorrow => 'کل';
  @override
  String get pickDate => 'تاریخ منتخب کریں';
  @override
  String get removeDueDate => 'آخری تاریخ ہٹائیں';
  @override
  String get duplicate => 'نقل بنائیں';
  @override
  String get saveChanges => 'تبدیلیاں محفوظ کریں';
  @override
  String addMany(int c) => '${_tasks(c)} شامل کریں';

  @override
  String get noteHint => 'نوٹ (اختیاری)';
  @override
  String get pinToTop => 'اوپر پن کریں';
  @override
  String get unpin => 'پن ہٹائیں';
  @override
  String get repeatNever => 'ایک بار';
  @override
  String get repeatDaily => 'روزانہ';
  @override
  String get repeatWeekly => 'ہفتہ وار';

  @override
  String get showOverdue => 'تاخیر شدہ';
  @override
  String overdueCount(int c) => '$c تاخیر شدہ';
  @override
  String get reminders => 'آخری تاریخ کی یاد دہانیاں';
  @override
  String get remindersHint => 'آخری دن صبح 9 بجے اطلاع';
  @override
  String get remindersBlocked => 'اطلاعات بند ہیں۔ سسٹم ترتیبات میں اجازت دیں۔';
  @override
  String get smartDateHint => 'مشورہ: تاریخ لگانے کے لیے آخر میں “کل” یا “جمعہ” لکھیں';

  @override
  String get jarStyle => 'مرتبان کے رنگ';
  @override
  String get jarStyleHint => 'نئے مکمل ہونے والے کاموں کے لیے';
  @override
  String jarStyleName(int i) => const ['ہفتے کے دن', 'غروبِ آفتاب', 'سمندر', 'یک رنگ'][i];
  @override
  String get backup => 'بیک اپ';
  @override
  String get copyBackup => 'بیک اپ کاپی کریں';
  @override
  String get restoreFromClipboard => 'کلپ بورڈ سے بحال کریں';
  @override
  String get backupCopied => 'بیک اپ کاپی ہو گیا۔ اسے کسی محفوظ جگہ پیسٹ کر لیں۔';
  @override
  String get restoreQ => 'یہ بیک اپ بحال کریں؟';
  @override
  String get restoreBody => 'آپ کی موجودہ فہرست اور آرکائیو کلپ بورڈ والے بیک اپ سے بدل جائیں گے۔';
  @override
  String get restore => 'بحال کریں';
  @override
  String get restored => 'بیک اپ بحال ہو گیا۔';
  @override
  String get notABackup => 'کلپ بورڈ میں Done Dust کا کوئی بیک اپ نہیں۔';
  @override
  String get restoreAll => 'سب بحال کریں';
  @override
  String get restoreAllQ => 'آرکائیو کے سب کام واپس لائیں؟';
  @override
  String get restoreAllBody => 'یہ کام آپ کی فہرست میں باقی کاموں کے طور پر واپس آ جائیں گے۔';

  @override
  String get alarm => 'الارم';
  @override
  String alarmAt(String time) => 'الارم $time';
  @override
  String get removeAlarm => 'الارم ہٹائیں';
  @override
  String get stopwatch => 'اسٹاپ واچ';
  @override
  String get startStopwatch => 'اسٹاپ واچ شروع کریں';
  @override
  String get pauseStopwatch => 'اسٹاپ واچ روکیں';

  // Archive
  @override
  String get deletedFromArchive => 'آرکائیو سے حذف ہو گیا';
  @override
  String get clearArchiveQ => 'آرکائیو صاف کریں؟';
  @override
  String get clearArchiveBody => 'آرکائیو کے کام ہمیشہ کے لیے حذف ہو جائیں گے۔';
  @override
  String get keep => 'رہنے دیں';
  @override
  String get clearArchive => 'آرکائیو صاف کریں';
  @override
  String get searchArchive => 'آرکائیو میں تلاش کریں';
  @override
  String get archiveEmpty =>
      'فون ہلانے پر، یا ⋮ › مکمل کام آرکائیو کریں دبانے پر، مکمل کام یہاں آتے ہیں۔';
  @override
  String noArchiveMatch(String q) => '“$q” سے کوئی آرکائیو کام نہیں ملا۔';
  @override
  String doneOn(String day) => '$day کو مکمل';
  @override
  String get reopenTask => 'کام دوبارہ کھولیں';

  // Stats
  @override
  String statsLine(int total, int open, int streakDays) =>
      'کل $total مکمل · $open باقی · ${streak(streakDays)}';
  @override
  String milestone(int d) => '$d دن کا تسلسل! یوں ہی جاری رکھیں۔';
  @override
  String bestStreak(int d) => 'بہترین تسلسل: $d دن';
  @override
  String weekLine(String now, String last) => 'اس ہفتے $now · پچھلے ہفتے $last';
  @override
  String get last12Weeks => 'پچھلے 12 ہفتے';
  @override
  String heatCell(String day, int c) => '$day: $c مکمل';
  @override
  String bestDay(String day) => 'بہترین دن: $day';
  @override
  String finishedOn(String day, int c) => '$day: $c مکمل';

  // First-launch tasks
  @override
  List<String> get starterTasks => const [
        'مجھ پر نشان لگائیں اور حروف گرتے دیکھیں',
        'ڈھیر کو سرکانے کے لیے فون جھکائیں',
        'اہم کام موٹے ہوتے ہیں اور پتھر کی طرح گرتے ہیں',
        'گرا ہوا حرف گھسیٹیں، یا ڈھیر پر ٹیپ کریں',
        'کام اڑانے کے لیے اسے ایک طرف سوائپ کریں',
        'مرتبان آرکائیو میں خالی کرنے کے لیے فون ہلائیں',
      ];
}
