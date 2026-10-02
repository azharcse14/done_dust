import 'dart:ui';

/// UI strings for the chosen language; the store swaps this when it changes.
// ponytail: "system" reads the phone's language at startup, so changing it there needs a restart.
var s = S.forLanguage('system');

const supportedLocales = [Locale('en'), Locale('bn')];

class S {
  const S(this.bn);

  /// [code] is 'system', 'en' or 'bn'.
  factory S.forLanguage(String code) => S(
      code == 'bn' || code == 'system' && PlatformDispatcher.instance.locale.languageCode == 'bn');

  final bool bn;

  Locale get locale => bn ? const Locale('bn') : const Locale('en');

  String _t(String en, String bangla) => bn ? bangla : en;

  /// Bangla digits in Bangla, so "5" reads "৫".
  String n(num v) =>
      bn ? '$v'.replaceAllMapped(RegExp(r'\d'), (m) => '০১২৩৪৫৬৭৮৯'[int.parse(m[0]!)]) : '$v';

  String _tasks(int c) => bn ? '${n(c)}টি কাজ' : '$c ${c == 1 ? 'task' : 'tasks'}';

  // Dates
  List<String> get weekdays => bn
      ? const ['সোমবার', 'মঙ্গলবার', 'বুধবার', 'বৃহস্পতিবার', 'শুক্রবার', 'শনিবার', 'রবিবার']
      : const ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  List<String> get weekdaysShort => bn
      ? const ['সোম', 'মঙ্গল', 'বুধ', 'বৃহঃ', 'শুক্র', 'শনি', 'রবি']
      : const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  List<String> get weekdayInitials => bn
      ? const ['সো', 'ম', 'বু', 'বৃ', 'শু', 'শ', 'র']
      : const ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  List<String> get months => bn
      ? const [
          'জানু',
          'ফেব্রু',
          'মার্চ',
          'এপ্রি',
          'মে',
          'জুন',
          'জুলা',
          'আগ',
          'সেপ্টে',
          'অক্টো',
          'নভে',
          'ডিসে'
        ]
      : const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  String formatDay(DateTime d) =>
      '${weekdaysShort[d.weekday - 1]}, ${n(d.day)} ${months[d.month - 1]}';
  String due(String day) => _t('Due $day', '$day পর্যন্ত');
  String get dueToday => _t('Due today', 'আজকের মধ্যে');
  String get dueTomorrow => _t('Due tomorrow', 'আগামীকালের মধ্যে');
  String overdue(int days) =>
      bn ? '${n(days)} দিন দেরি' : 'Overdue $days ${days == 1 ? 'day' : 'days'}';

  // Common
  String get undo => _t('Undo', 'ফিরিয়ে আনুন');
  String get delete => _t('Delete', 'মুছুন');
  String get archive => _t('Archive', 'আর্কাইভ');
  String get stats => _t('Stats', 'পরিসংখ্যান');
  String get addTask => _t('Add task', 'কাজ যোগ করুন');
  String streak(int d) => bn ? '${n(d)} দিনের ধারা' : '$d-day streak';

  // Main screen
  String get myTasks => _t('My tasks', 'আমার কাজ');
  String get emptyJar => _t('Empty jar', 'খালি বয়াম');
  String jarWith(int c) =>
      _t('Jar with letters of ${_tasks(c)} finished', 'বয়ামে ${_tasks(c)} শেষ করার অক্ষর');
  String get allDone => _t('All done. Enjoy the quiet.', 'সব শেষ। এবার একটু বিশ্রাম নিন।');
  String goalReached(int g) =>
      _t('Daily goal reached: $g done today.', 'আজকের লক্ষ্য পূরণ: আজ ${n(g)}টি শেষ।');
  String added(int c) => _t('Added ${_tasks(c)}', '${_tasks(c)} যোগ হয়েছে');
  String duplicated(String t) => _t('Duplicated “$t”', '“$t” কপি হয়েছে');
  String deleted(String t) => _t('Deleted “$t”', '“$t” মুছে ফেলা হয়েছে');
  String get nothingToArchive => _t('Nothing to archive yet. Finish a task first.',
      'আর্কাইভ করার কিছু নেই। আগে একটি কাজ শেষ করুন।');
  String archived(int c) => _t('Archived ${_tasks(c)}', '${_tasks(c)} আর্কাইভ হয়েছে');
  String jarFull(int c) => _t(
      'Jar is full. Moved ${_tasks(c).replaceFirst(' ', ' oldest ')} to the archive.',
      'বয়াম ভরে গেছে। সবচেয়ে পুরোনো ${_tasks(c)} আর্কাইভে সরানো হয়েছে।');
  String get listEmpty => _t('The list is empty.', 'তালিকা খালি।');
  String copied(int c) =>
      _t('Copied ${_tasks(c)} to the clipboard', '${_tasks(c)} ক্লিপবোর্ডে কপি হয়েছে');
  String get noMatch => _t('No task matches.', 'কোনো কাজ মেলেনি।');
  String get clearSearch => _t('Clear search', 'খোঁজা মুছুন');
  String get themeSystem => _t('System', 'সিস্টেম');
  String get themeLight => _t('Light', 'লাইট');
  String get themeDark => _t('Dark', 'ডার্ক');
  String doneOfGoal(int d, int g) => _t('$d of $g done today', 'আজ ${n(g)}টির মধ্যে ${n(d)}টি শেষ');
  String get nothingToday => _t('Nothing done today yet', 'আজ এখনো কিছু শেষ হয়নি');
  String doneToday(int d) => _t('$d done today', 'আজ ${n(d)}টি শেষ');
  String goalPercent(int p) => _t('$p percent of the daily goal', 'আজকের লক্ষ্যের ${n(p)} শতাংশ');
  String listPercent(int p) => _t('$p percent of the list finished', 'তালিকার ${n(p)} শতাংশ শেষ');
  String get closeSearch => _t('Close search', 'খোঁজা বন্ধ করুন');
  String get searchAndSort => _t('Search and sort', 'খুঁজুন ও সাজান');
  String get more => _t('More', 'আরও');
  String archiveCount(int c) => c == 0 ? archive : '$archive (${n(c)})';
  String get copyList => _t('Copy list', 'তালিকা কপি করুন');
  String get emptyTheJar => _t('Archive finished tasks', 'শেষ করা কাজ আর্কাইভ করুন');
  String get sound => _t('Sound', 'শব্দ');
  String get vibration => _t('Vibration', 'ভাইব্রেশন');
  String get settings => _t('Settings', 'সেটিংস');
  String get dailyGoal => _t('Daily goal', 'দৈনিক লক্ষ্য');
  String get dailyGoalHint => _t('Tasks to finish each day', 'প্রতিদিন কয়টি কাজ শেষ করবেন');
  String get off => _t('Off', 'বন্ধ');
  String get theme => _t('Theme', 'থিম');
  String get language => _t('Language', 'ভাষা');
  String get soundHint => _t('Ticks and whooshes', 'টিক আর হুশ শব্দ');
  String get vibrationHint => _t('Feel letters land', 'অক্ষর পড়লে কাঁপুনি');
  String legend(String day) =>
      _t('Letters finished on $day settle in this colour', '$day শেষ করা অক্ষর এই রঙে জমে');
  String get searchTasks => _t('Search tasks', 'কাজ খুঁজুন');
  String get showAll => _t('All', 'সব');
  String get showOpen => _t('Open', 'বাকি');
  String get showDone => _t('Done', 'শেষ');
  String get sortNewest => _t('Newest', 'নতুন আগে');
  String get sortPriority => _t('Priority', 'গুরুত্ব');
  String get sortDue => _t('Due date', 'শেষ তারিখ');
  String get nothingOnList => _t('Nothing on the list', 'তালিকায় কিছু নেই');
  String get emptyHint => _t('Add a task, then check it off to drop its letters into the jar.',
      'একটি কাজ যোগ করুন, তারপর টিক দিন — অক্ষরগুলো বয়ামে পড়ে যাবে।');
  String get gestureHint => _t(
      'Long-press a task to edit · swipe to delete · shake to empty the jar',
      'এডিট করতে চেপে ধরুন · মুছতে সোয়াইপ করুন · বয়াম খালি করতে ফোন ঝাঁকান');

  // Task editor
  String get lowHint =>
      _t('Light letters that bounce when they land.', 'হালকা অক্ষর, পড়লে লাফিয়ে ওঠে।');
  String get normalHint => _t('Letters settle like sand.', 'অক্ষর বালির মতো জমে।');
  String get highHint =>
      _t('Bold, heavy letters that push others aside.', 'মোটা, ভারী অক্ষর, অন্যদের ঠেলে সরায়।');
  String get editTask => _t('Edit task', 'কাজ এডিট করুন');
  String get newTask => _t('New task', 'নতুন কাজ');
  String get whatNeedsDoing => _t('What needs doing?', 'কী করতে হবে?');
  String get whatNeedsDoingMany => _t('What needs doing? Paste a list to add many.',
      'কী করতে হবে? অনেকগুলো যোগ করতে তালিকা পেস্ট করুন।');
  String get low => _t('Low', 'কম');
  String get normal => _t('Normal', 'সাধারণ');
  String get high => _t('High', 'বেশি');
  String get today => _t('Today', 'আজ');
  String get tomorrow => _t('Tomorrow', 'আগামীকাল');
  String get pickDate => _t('Pick date', 'তারিখ বাছুন');
  String get removeDueDate => _t('Remove due date', 'শেষ তারিখ সরান');
  String get duplicate => _t('Duplicate', 'কপি করুন');
  String get saveChanges => _t('Save changes', 'পরিবর্তন সেভ করুন');
  String addMany(int c) => _t('Add ${_tasks(c)}', '${_tasks(c)} যোগ করুন');

  String get noteHint => _t('Note (optional)', 'নোট (ঐচ্ছিক)');
  String get pinToTop => _t('Pin to top', 'উপরে পিন করুন');
  String get unpin => _t('Unpin', 'পিন সরান');
  String get repeatNever => _t('Once', 'একবার');
  String get repeatDaily => _t('Daily', 'প্রতিদিন');
  String get repeatWeekly => _t('Weekly', 'প্রতি সপ্তাহে');

  String get showOverdue => _t('Overdue', 'মেয়াদোত্তীর্ণ');
  String overdueCount(int c) => _t('$c overdue', '${n(c)}টি দেরি হয়েছে');
  String get reminders => _t('Due date reminders', 'শেষ তারিখের রিমাইন্ডার');
  String get remindersHint =>
      _t('A notification at 9 AM on the due day', 'শেষ দিনে সকাল ৯টায় নোটিফিকেশন');
  String get remindersBlocked => _t('Notifications are blocked. Allow them in system settings.',
      'নোটিফিকেশন বন্ধ আছে। সিস্টেম সেটিংসে চালু করুন।');
  String get smartDateHint => _t('Tip: end with “tomorrow” or “fri” to set a date',
      'টিপ: শেষে “আগামীকাল” বা “শুক্রবার” লিখলে তারিখ বসবে');

  // Archive
  String get deletedFromArchive => _t('Deleted from archive', 'আর্কাইভ থেকে মুছে ফেলা হয়েছে');
  String get clearArchiveQ => _t('Clear the archive?', 'আর্কাইভ খালি করবেন?');
  String get clearArchiveBody =>
      _t('Archived tasks will be deleted for good.', 'আর্কাইভের কাজগুলো চিরতরে মুছে যাবে।');
  String get keep => _t('Keep', 'রাখুন');
  String get clearArchive => _t('Clear archive', 'আর্কাইভ খালি করুন');
  String get searchArchive => _t('Search archive', 'আর্কাইভে খুঁজুন');
  String get archiveEmpty => _t(
      'Finished tasks come here when you shake your phone, or tap ⋮ › Archive finished tasks.',
      'ফোন ঝাঁকালে, অথবা ⋮ › শেষ করা কাজ আর্কাইভ করুন চাপলে, শেষ করা কাজ এখানে আসবে।');
  String noArchiveMatch(String q) =>
      _t('No archived task matches “$q”.', '“$q” এর সাথে কোনো আর্কাইভ কাজ মেলেনি।');
  String doneOn(String day) => _t('Done $day', '$day শেষ');
  String get reopenTask => _t('Reopen task', 'কাজটি আবার খুলুন');

  // Stats
  String statsLine(int total, int open, int streakDays) => bn
      ? 'মোট ${n(total)}টি শেষ · ${n(open)}টি বাকি · ${streak(streakDays)}'
      : '$total finished in total · $open open · ${streak(streakDays)}';
  String bestDay(String day) => _t('Best day: $day', 'সেরা দিন: $day');
  String finishedOn(String day, int c) => _t('$day: $c finished', '$day: ${n(c)}টি শেষ');

  // First-launch tasks
  List<String> get starterTasks => bn
      ? const [
          'আমাকে টিক দিন, অক্ষরগুলো পড়ে যেতে দেখুন',
          'স্তূপটা সরাতে ফোন কাত করুন',
          'জরুরি কাজ মোটা, পাথরের মতো পড়ে',
          'পড়ে যাওয়া অক্ষর টেনে আনুন, বা স্তূপে ট্যাপ করুন',
          'কাজ উড়িয়ে দিতে পাশে সোয়াইপ করুন',
          'বয়াম আর্কাইভে খালি করতে ফোন ঝাঁকান',
        ]
      : const [
          'Check me off and watch the letters fall',
          'Tilt your phone to slide the pile',
          'Important tasks are bold and fall like stone',
          'Drag a fallen letter, or tap the pile',
          'Swipe a task sideways to blow it away',
          'Shake the phone to empty the jar into the archive',
        ];
}
