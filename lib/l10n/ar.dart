part of '../l10n.dart';

class SAr extends S {
  const SAr();

  @override
  String get code => 'ar';

  @override
  String _tasks(int c) => c == 1
      ? 'مهمة واحدة'
      : c == 2
          ? 'مهمتان'
          : c >= 3 && c <= 10
              ? '$c مهام'
              : '$c مهمة';

  /// Genitive/accusative form, for after a verb object or a noun.
  String _tasksOf(int c) => c == 2 ? 'مهمتين' : _tasks(c);

  String _days(int d) => d == 1
      ? 'يوم واحد'
      : d == 2
          ? 'يومين'
          : d >= 3 && d <= 10
              ? '$d أيام'
              : '$d يومًا';

  // Dates
  @override
  List<String> get weekdays =>
      const ['الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];
  @override
  List<String> get weekdaysShort => const ['إثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة', 'سبت', 'أحد'];
  @override
  List<String> get weekdayInitials => const ['ن', 'ث', 'ر', 'خ', 'ج', 'س', 'ح'];
  @override
  List<String> get months => const [
        'يناير',
        'فبراير',
        'مارس',
        'أبريل',
        'مايو',
        'يونيو',
        'يوليو',
        'أغسطس',
        'سبتمبر',
        'أكتوبر',
        'نوفمبر',
        'ديسمبر'
      ];
  @override
  String formatDay(DateTime d) =>
      '${weekdaysShort[d.weekday - 1]}، ${n(d.day)} ${months[d.month - 1]}';
  @override
  String due(String day) => 'تستحق $day';
  @override
  String get dueToday => 'تستحق اليوم';
  @override
  String get dueTomorrow => 'تستحق غدًا';
  @override
  String overdue(int days) => 'متأخرة ${_days(days)}';

  // Common
  @override
  String get undo => 'تراجع';
  @override
  String get delete => 'حذف';
  @override
  String get archive => 'الأرشيف';
  @override
  String get stats => 'الإحصاءات';
  @override
  String get addTask => 'إضافة مهمة';
  @override
  String streak(int d) => 'سلسلة ${_days(d)}';

  // Main screen
  @override
  String get myTasks => 'مهامي';
  @override
  String get emptyJar => 'جرة فارغة';
  @override
  String jarWith(int c) => 'جرة فيها حروف ${_tasksOf(c)} منجزة';
  @override
  String get allDone => 'أنجزت كل شيء. استمتع بالهدوء.';
  @override
  String goalReached(int g) => 'تحقق الهدف اليومي: أنجزت $g اليوم.';
  @override
  String added(int c) => 'أُضيفت ${_tasks(c)}';
  @override
  String duplicated(String t) => 'نُسخت “$t”';
  @override
  String deleted(String t) => 'حُذفت “$t”';
  @override
  String get nothingToArchive => 'لا شيء للأرشفة بعد. أنجز مهمة أولًا.';
  @override
  String archived(int c) => 'أُرشفت ${_tasks(c)}';
  @override
  String jarFull(int c) =>
      'الجرة ممتلئة. نُقلت ${c == 1 ? 'أقدم مهمة' : 'أقدم ${_tasksOf(c)}'} إلى الأرشيف.';
  @override
  String get listEmpty => 'القائمة فارغة.';
  @override
  String copied(int c) => 'نُسخت ${_tasks(c)} إلى الحافظة';
  @override
  String get noMatch => 'لا توجد مهمة مطابقة.';
  @override
  String get clearSearch => 'مسح البحث';
  @override
  String get themeSystem => 'النظام';
  @override
  String get themeLight => 'فاتح';
  @override
  String get themeDark => 'داكن';
  @override
  String doneOfGoal(int d, int g) => 'أنجزت $d من $g اليوم';
  @override
  String get nothingToday => 'لم تُنجز شيئًا اليوم بعد';
  @override
  String doneToday(int d) => 'أنجزت $d اليوم';
  @override
  String goalPercent(int p) => '$p بالمئة من الهدف اليومي';
  @override
  String listPercent(int p) => 'أُنجز $p بالمئة من القائمة';
  @override
  String get closeSearch => 'إغلاق البحث';
  @override
  String get searchAndSort => 'البحث والترتيب';
  @override
  String get more => 'المزيد';
  @override
  String get copyList => 'نسخ القائمة';
  @override
  String get emptyTheJar => 'أرشفة المهام المنجزة';
  @override
  String get sound => 'الصوت';
  @override
  String get vibration => 'الاهتزاز';
  @override
  String get settings => 'الإعدادات';
  @override
  String get dailyGoal => 'الهدف اليومي';
  @override
  String get dailyGoalHint => 'عدد المهام المطلوب إنجازها يوميًا';
  @override
  String get off => 'إيقاف';
  @override
  String get theme => 'المظهر';
  @override
  String get language => 'اللغة';
  @override
  String get soundHint => 'نقرات وأصوات حفيف';
  @override
  String get vibrationHint => 'اشعر بسقوط الحروف';
  @override
  String legend(String day) => 'الحروف المنجزة يوم $day تستقر بهذا اللون';
  @override
  String get searchTasks => 'البحث في المهام';
  @override
  String get showAll => 'الكل';
  @override
  String get showOpen => 'المفتوحة';
  @override
  String get showDone => 'المنجزة';
  @override
  String get sortNewest => 'الأحدث';
  @override
  String get sortPriority => 'الأولوية';
  @override
  String get sortDue => 'تاريخ الاستحقاق';
  @override
  String get nothingOnList => 'لا شيء في القائمة';
  @override
  String get emptyHint => 'أضف مهمة، ثم ضع علامة عليها لتسقط حروفها في الجرة.';
  @override
  String get gestureHint => 'اضغط مطولًا على مهمة لتعديلها · اسحب للحذف · هزّ الهاتف لتفريغ الجرة';

  // Task editor
  @override
  String get lowHint => 'حروف خفيفة ترتد عند سقوطها.';
  @override
  String get normalHint => 'حروف تستقر كالرمل.';
  @override
  String get highHint => 'حروف عريضة ثقيلة تدفع غيرها جانبًا.';
  @override
  String get editTask => 'تعديل المهمة';
  @override
  String get newTask => 'مهمة جديدة';
  @override
  String get whatNeedsDoing => 'ما الذي يجب إنجازه؟';
  @override
  String get whatNeedsDoingMany => 'ما الذي يجب إنجازه؟ الصق قائمة لإضافة عدة مهام.';
  @override
  String get low => 'منخفضة';
  @override
  String get normal => 'عادية';
  @override
  String get high => 'عالية';
  @override
  String get today => 'اليوم';
  @override
  String get tomorrow => 'غدًا';
  @override
  String get pickDate => 'اختر تاريخًا';
  @override
  String get removeDueDate => 'إزالة تاريخ الاستحقاق';
  @override
  String get duplicate => 'نسخ';
  @override
  String get saveChanges => 'حفظ التغييرات';
  @override
  String addMany(int c) => 'إضافة ${_tasksOf(c)}';

  @override
  String get noteHint => 'ملاحظة (اختيارية)';
  @override
  String get pinToTop => 'تثبيت في الأعلى';
  @override
  String get unpin => 'إلغاء التثبيت';
  @override
  String get repeatNever => 'مرة واحدة';
  @override
  String get repeatDaily => 'يوميًا';
  @override
  String get repeatWeekly => 'أسبوعيًا';

  @override
  String get showOverdue => 'المتأخرة';
  @override
  String overdueCount(int c) => '$c متأخرة';
  @override
  String get reminders => 'تذكيرات الاستحقاق';
  @override
  String get remindersHint => 'إشعار في التاسعة صباحًا يوم الاستحقاق';
  @override
  String get remindersBlocked => 'الإشعارات محظورة. اسمح بها من إعدادات النظام.';
  @override
  String get smartDateHint => 'تلميح: اختم بـ “غدًا” أو “الجمعة” لتحديد التاريخ';

  @override
  String get jarStyle => 'ألوان الجرة';
  @override
  String get jarStyleHint => 'للمهام المنجزة حديثًا';
  @override
  String jarStyleName(int i) => const ['أيام الأسبوع', 'الغروب', 'المحيط', 'لون واحد'][i];
  @override
  String get backup => 'النسخ الاحتياطي';
  @override
  String get copyBackup => 'نسخ النسخة الاحتياطية';
  @override
  String get restoreFromClipboard => 'الاستعادة من الحافظة';
  @override
  String get backupCopied => 'نُسخت النسخة الاحتياطية. الصقها في مكان آمن.';
  @override
  String get restoreQ => 'استعادة هذه النسخة الاحتياطية؟';
  @override
  String get restoreBody => 'ستُستبدل قائمتك وأرشيفك الحاليان بالنسخة الاحتياطية الموجودة في الحافظة.';
  @override
  String get restore => 'استعادة';
  @override
  String get restored => 'استُعيدت النسخة الاحتياطية.';
  @override
  String get notABackup => 'لا توجد نسخة احتياطية من Done Dust في الحافظة.';
  @override
  String get restoreAll => 'استعادة الكل';
  @override
  String get restoreAllQ => 'إعادة كل المهام المؤرشفة؟';
  @override
  String get restoreAllBody => 'ستعود إلى قائمتك كمهام مفتوحة.';

  @override
  String get alarm => 'منبّه';
  @override
  String alarmAt(String time) => 'منبّه $time';
  @override
  String get removeAlarm => 'إزالة المنبّه';
  @override
  String get stopwatch => 'ساعة الإيقاف';
  @override
  String get startStopwatch => 'تشغيل ساعة الإيقاف';
  @override
  String get pauseStopwatch => 'إيقاف ساعة الإيقاف مؤقتًا';

  // Archive
  @override
  String get deletedFromArchive => 'حُذفت من الأرشيف';
  @override
  String get clearArchiveQ => 'مسح الأرشيف؟';
  @override
  String get clearArchiveBody => 'ستُحذف المهام المؤرشفة نهائيًا.';
  @override
  String get keep => 'إبقاء';
  @override
  String get clearArchive => 'مسح الأرشيف';
  @override
  String get searchArchive => 'البحث في الأرشيف';
  @override
  String get archiveEmpty =>
      'تصل المهام المنجزة إلى هنا عندما تهزّ هاتفك، أو تضغط ⋮ › أرشفة المهام المنجزة.';
  @override
  String noArchiveMatch(String q) => 'لا توجد مهمة مؤرشفة تطابق “$q”.';
  @override
  String doneOn(String day) => 'أُنجزت $day';
  @override
  String get reopenTask => 'إعادة فتح المهمة';

  // Stats
  @override
  String statsLine(int total, int open, int streakDays) =>
      '$total منجزة إجمالًا · $open مفتوحة · ${streak(streakDays)}';
  @override
  String milestone(int d) => 'سلسلة ${_days(d)}! واصل إسقاط الغبار.';
  @override
  String bestStreak(int d) => 'أفضل سلسلة: ${_days(d)}';
  @override
  String weekLine(String now, String last) => 'هذا الأسبوع $now · الأسبوع الماضي $last';
  @override
  String get last12Weeks => 'آخر 12 أسبوعًا';
  @override
  String heatCell(String day, int c) => '$day: $c منجزة';
  @override
  String bestDay(String day) => 'أفضل يوم: $day';
  @override
  String finishedOn(String day, int c) => '$day: $c منجزة';

  // First-launch tasks
  @override
  List<String> get starterTasks => const [
        'ضع علامة عليّ وشاهد الحروف تتساقط',
        'أمِل هاتفك لتنزلق الكومة',
        'المهام المهمة عريضة وتسقط كالحجر',
        'اسحب حرفًا ساقطًا، أو انقر على الكومة',
        'اسحب مهمة جانبًا لتطيّرها',
        'هزّ الهاتف لتفريغ الجرة في الأرشيف',
      ];
}
