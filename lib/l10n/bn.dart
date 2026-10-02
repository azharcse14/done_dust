part of '../l10n.dart';

class SBn extends S {
  const SBn();

  @override
  String get code => 'bn';

  /// Bangla digits, so "5" reads "৫".
  @override
  String n(num v) => '$v'.replaceAllMapped(RegExp(r'\d'), (m) => '০১২৩৪৫৬৭৮৯'[int.parse(m[0]!)]);

  @override
  String _tasks(int c) => '${n(c)}টি কাজ';

  // Dates
  @override
  List<String> get weekdays =>
      const ['সোমবার', 'মঙ্গলবার', 'বুধবার', 'বৃহস্পতিবার', 'শুক্রবার', 'শনিবার', 'রবিবার'];
  @override
  List<String> get weekdaysShort => const ['সোম', 'মঙ্গল', 'বুধ', 'বৃহঃ', 'শুক্র', 'শনি', 'রবি'];
  @override
  List<String> get weekdayInitials => const ['সো', 'ম', 'বু', 'বৃ', 'শু', 'শ', 'র'];
  @override
  List<String> get months => const [
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
      ];
  @override
  String due(String day) => '$day পর্যন্ত';
  @override
  String get dueToday => 'আজকের মধ্যে';
  @override
  String get dueTomorrow => 'আগামীকালের মধ্যে';
  @override
  String overdue(int days) => '${n(days)} দিন দেরি';

  // Common
  @override
  String get undo => 'ফিরিয়ে আনুন';
  @override
  String get delete => 'মুছুন';
  @override
  String get archive => 'আর্কাইভ';
  @override
  String get stats => 'পরিসংখ্যান';
  @override
  String get addTask => 'কাজ যোগ করুন';
  @override
  String streak(int d) => '${n(d)} দিনের ধারা';

  // Main screen
  @override
  String get myTasks => 'আমার কাজ';
  @override
  String get emptyJar => 'খালি বয়াম';
  @override
  String jarWith(int c) => 'বয়ামে ${_tasks(c)} শেষ করার অক্ষর';
  @override
  String get allDone => 'সব শেষ। এবার একটু বিশ্রাম নিন।';
  @override
  String goalReached(int g) => 'আজকের লক্ষ্য পূরণ: আজ ${n(g)}টি শেষ।';
  @override
  String added(int c) => '${_tasks(c)} যোগ হয়েছে';
  @override
  String duplicated(String t) => '“$t” কপি হয়েছে';
  @override
  String deleted(String t) => '“$t” মুছে ফেলা হয়েছে';
  @override
  String get nothingToArchive => 'আর্কাইভ করার কিছু নেই। আগে একটি কাজ শেষ করুন।';
  @override
  String archived(int c) => '${_tasks(c)} আর্কাইভ হয়েছে';
  @override
  String jarFull(int c) => 'বয়াম ভরে গেছে। সবচেয়ে পুরোনো ${_tasks(c)} আর্কাইভে সরানো হয়েছে।';
  @override
  String get listEmpty => 'তালিকা খালি।';
  @override
  String copied(int c) => '${_tasks(c)} ক্লিপবোর্ডে কপি হয়েছে';
  @override
  String get noMatch => 'কোনো কাজ মেলেনি।';
  @override
  String get clearSearch => 'খোঁজা মুছুন';
  @override
  String get themeSystem => 'সিস্টেম';
  @override
  String get themeLight => 'লাইট';
  @override
  String get themeDark => 'ডার্ক';
  @override
  String doneOfGoal(int d, int g) => 'আজ ${n(g)}টির মধ্যে ${n(d)}টি শেষ';
  @override
  String get nothingToday => 'আজ এখনো কিছু শেষ হয়নি';
  @override
  String doneToday(int d) => 'আজ ${n(d)}টি শেষ';
  @override
  String goalPercent(int p) => 'আজকের লক্ষ্যের ${n(p)} শতাংশ';
  @override
  String listPercent(int p) => 'তালিকার ${n(p)} শতাংশ শেষ';
  @override
  String get closeSearch => 'খোঁজা বন্ধ করুন';
  @override
  String get searchAndSort => 'খুঁজুন ও সাজান';
  @override
  String get more => 'আরও';
  @override
  String get copyList => 'তালিকা কপি করুন';
  @override
  String get emptyTheJar => 'শেষ করা কাজ আর্কাইভ করুন';
  @override
  String get sound => 'শব্দ';
  @override
  String get vibration => 'ভাইব্রেশন';
  @override
  String get settings => 'সেটিংস';
  @override
  String get dailyGoal => 'দৈনিক লক্ষ্য';
  @override
  String get dailyGoalHint => 'প্রতিদিন কয়টি কাজ শেষ করবেন';
  @override
  String get off => 'বন্ধ';
  @override
  String get theme => 'থিম';
  @override
  String get language => 'ভাষা';
  @override
  String get soundHint => 'টিক আর হুশ শব্দ';
  @override
  String get vibrationHint => 'অক্ষর পড়লে কাঁপুনি';
  @override
  String legend(String day) => '$day শেষ করা অক্ষর এই রঙে জমে';
  @override
  String get searchTasks => 'কাজ খুঁজুন';
  @override
  String get showAll => 'সব';
  @override
  String get showOpen => 'বাকি';
  @override
  String get showDone => 'শেষ';
  @override
  String get sortNewest => 'নতুন আগে';
  @override
  String get sortPriority => 'গুরুত্ব';
  @override
  String get sortDue => 'শেষ তারিখ';
  @override
  String get nothingOnList => 'তালিকায় কিছু নেই';
  @override
  String get emptyHint => 'একটি কাজ যোগ করুন, তারপর টিক দিন — অক্ষরগুলো বয়ামে পড়ে যাবে।';
  @override
  String get gestureHint => 'এডিট করতে চেপে ধরুন · মুছতে সোয়াইপ করুন · বয়াম খালি করতে ফোন ঝাঁকান';

  // Task editor
  @override
  String get lowHint => 'হালকা অক্ষর, পড়লে লাফিয়ে ওঠে।';
  @override
  String get normalHint => 'অক্ষর বালির মতো জমে।';
  @override
  String get highHint => 'মোটা, ভারী অক্ষর, অন্যদের ঠেলে সরায়।';
  @override
  String get editTask => 'কাজ এডিট করুন';
  @override
  String get newTask => 'নতুন কাজ';
  @override
  String get whatNeedsDoing => 'কী করতে হবে?';
  @override
  String get whatNeedsDoingMany => 'কী করতে হবে? অনেকগুলো যোগ করতে তালিকা পেস্ট করুন।';
  @override
  String get low => 'কম';
  @override
  String get normal => 'সাধারণ';
  @override
  String get high => 'বেশি';
  @override
  String get today => 'আজ';
  @override
  String get tomorrow => 'আগামীকাল';
  @override
  String get pickDate => 'তারিখ বাছুন';
  @override
  String get removeDueDate => 'শেষ তারিখ সরান';
  @override
  String get duplicate => 'কপি করুন';
  @override
  String get saveChanges => 'পরিবর্তন সেভ করুন';
  @override
  String addMany(int c) => '${_tasks(c)} যোগ করুন';

  @override
  String get noteHint => 'নোট (ঐচ্ছিক)';
  @override
  String get pinToTop => 'উপরে পিন করুন';
  @override
  String get unpin => 'পিন সরান';
  @override
  String get repeatNever => 'একবার';
  @override
  String get repeatDaily => 'প্রতিদিন';
  @override
  String get repeatWeekly => 'প্রতি সপ্তাহে';

  @override
  String get showOverdue => 'মেয়াদোত্তীর্ণ';
  @override
  String overdueCount(int c) => '${n(c)}টি দেরি হয়েছে';
  @override
  String get reminders => 'শেষ তারিখের রিমাইন্ডার';
  @override
  String get remindersHint => 'শেষ দিনে সকাল ৯টায় নোটিফিকেশন';
  @override
  String get remindersBlocked => 'নোটিফিকেশন বন্ধ আছে। সিস্টেম সেটিংসে চালু করুন।';
  @override
  String get smartDateHint => 'টিপ: শেষে “আগামীকাল” বা “শুক্রবার” লিখলে তারিখ বসবে';

  @override
  String get jarStyle => 'বয়ামের রং';
  @override
  String get jarStyleHint => 'নতুন শেষ করা কাজের জন্য';
  @override
  String jarStyleName(int i) => const ['সপ্তাহের দিন', 'সূর্যাস্ত', 'সাগর', 'এক রং'][i];
  @override
  String get backup => 'ব্যাকআপ';
  @override
  String get copyBackup => 'ব্যাকআপ কপি করুন';
  @override
  String get restoreFromClipboard => 'ক্লিপবোর্ড থেকে ফেরান';
  @override
  String get backupCopied => 'ব্যাকআপ কপি হয়েছে। নিরাপদ কোথাও পেস্ট করে রাখুন।';
  @override
  String get restoreQ => 'এই ব্যাকআপ ফেরাবেন?';
  @override
  String get restoreBody => 'আপনার এখনকার তালিকা ও আর্কাইভ ক্লিপবোর্ডের ব্যাকআপ দিয়ে বদলে যাবে।';
  @override
  String get restore => 'ফেরান';
  @override
  String get restored => 'ব্যাকআপ ফেরানো হয়েছে।';
  @override
  String get notABackup => 'ক্লিপবোর্ডে কোনো Done Dust ব্যাকআপ নেই।';
  @override
  String get restoreAll => 'সব ফেরান';
  @override
  String get restoreAllQ => 'আর্কাইভের সব কাজ ফেরাবেন?';
  @override
  String get restoreAllBody => 'কাজগুলো তালিকায় আবার খোলা কাজ হিসেবে ফিরবে।';

  @override
  String get alarm => 'অ্যালার্ম';
  @override
  String alarmAt(String time) => 'অ্যালার্ম $time';
  @override
  String get removeAlarm => 'অ্যালার্ম সরান';
  @override
  String get stopwatch => 'স্টপওয়াচ';
  @override
  String get startStopwatch => 'স্টপওয়াচ চালু করুন';
  @override
  String get pauseStopwatch => 'স্টপওয়াচ থামান';

  // Archive
  @override
  String get deletedFromArchive => 'আর্কাইভ থেকে মুছে ফেলা হয়েছে';
  @override
  String get clearArchiveQ => 'আর্কাইভ খালি করবেন?';
  @override
  String get clearArchiveBody => 'আর্কাইভের কাজগুলো চিরতরে মুছে যাবে।';
  @override
  String get keep => 'রাখুন';
  @override
  String get clearArchive => 'আর্কাইভ খালি করুন';
  @override
  String get searchArchive => 'আর্কাইভে খুঁজুন';
  @override
  String get archiveEmpty =>
      'ফোন ঝাঁকালে, অথবা ⋮ › শেষ করা কাজ আর্কাইভ করুন চাপলে, শেষ করা কাজ এখানে আসবে।';
  @override
  String noArchiveMatch(String q) => '“$q” এর সাথে কোনো আর্কাইভ কাজ মেলেনি।';
  @override
  String doneOn(String day) => '$day শেষ';
  @override
  String get reopenTask => 'কাজটি আবার খুলুন';

  // Stats
  @override
  String statsLine(int total, int open, int streakDays) =>
      'মোট ${n(total)}টি শেষ · ${n(open)}টি বাকি · ${streak(streakDays)}';
  @override
  String milestone(int d) => '${n(d)} দিনের ধারা! এভাবেই চালিয়ে যান।';
  @override
  String bestStreak(int d) => 'সেরা ধারা: ${n(d)} দিন';
  @override
  String weekLine(String now, String last) => 'এই সপ্তাহে $now · গত সপ্তাহে $last';
  @override
  String get last12Weeks => 'গত ১২ সপ্তাহ';
  @override
  String heatCell(String day, int c) => '$day: ${n(c)}টি শেষ';
  @override
  String bestDay(String day) => 'সেরা দিন: $day';
  @override
  String finishedOn(String day, int c) => '$day: ${n(c)}টি শেষ';

  // First-launch tasks
  @override
  List<String> get starterTasks => const [
        'আমাকে টিক দিন, অক্ষরগুলো পড়ে যেতে দেখুন',
        'স্তূপটা সরাতে ফোন কাত করুন',
        'জরুরি কাজ মোটা, পাথরের মতো পড়ে',
        'পড়ে যাওয়া অক্ষর টেনে আনুন, বা স্তূপে ট্যাপ করুন',
        'কাজ উড়িয়ে দিতে পাশে সোয়াইপ করুন',
        'বয়াম আর্কাইভে খালি করতে ফোন ঝাঁকান',
      ];
}
