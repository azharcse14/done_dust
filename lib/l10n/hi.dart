part of '../l10n.dart';

class SHi extends S {
  const SHi();

  @override
  String get code => 'hi';

  /// "काम" is the same in singular and plural.
  @override
  String _tasks(int c) => '$c काम';

  // Dates
  @override
  List<String> get weekdays =>
      const ['सोमवार', 'मंगलवार', 'बुधवार', 'गुरुवार', 'शुक्रवार', 'शनिवार', 'रविवार'];
  @override
  List<String> get weekdaysShort => const ['सोम', 'मंगल', 'बुध', 'गुरु', 'शुक्र', 'शनि', 'रवि'];
  @override
  List<String> get weekdayInitials => const ['सो', 'मं', 'बु', 'गु', 'शु', 'श', 'र'];
  @override
  List<String> get months => const [
        'जन॰',
        'फ़र॰',
        'मार्च',
        'अप्रैल',
        'मई',
        'जून',
        'जुल॰',
        'अग॰',
        'सित॰',
        'अक्टू॰',
        'नव॰',
        'दिस॰'
      ];
  @override
  String due(String day) => '$day तक';
  @override
  String get dueToday => 'आज तक';
  @override
  String get dueTomorrow => 'कल तक';
  @override
  String overdue(int days) => '$days दिन की देरी';

  // Common
  @override
  String get undo => 'पहले जैसा करें';
  @override
  String get delete => 'हटाएँ';
  @override
  String get archive => 'आर्काइव';
  @override
  String get stats => 'आँकड़े';
  @override
  String get addTask => 'काम जोड़ें';
  @override
  String streak(int d) => '$d दिन का सिलसिला';

  // Main screen
  @override
  String get myTasks => 'मेरे काम';
  @override
  String get emptyJar => 'खाली जार';
  @override
  String jarWith(int c) => 'जार में पूरे किए गए ${_tasks(c)} के अक्षर';
  @override
  String get allDone => 'सब हो गया। अब सुकून के पल का आनंद लें।';
  @override
  String goalReached(int g) => 'आज का लक्ष्य पूरा: आज $g काम हुए।';
  @override
  String added(int c) => '${_tasks(c)} जोड़े गए';
  @override
  String duplicated(String t) => '“$t” की कॉपी बनाई गई';
  @override
  String deleted(String t) => '“$t” हटाया गया';
  @override
  String get nothingToArchive => 'आर्काइव करने के लिए कुछ नहीं है। पहले कोई काम पूरा करें।';
  @override
  String archived(int c) => '${_tasks(c)} आर्काइव किए गए';
  @override
  String jarFull(int c) => 'जार भर गया। सबसे पुराने ${_tasks(c)} आर्काइव में भेजे गए।';
  @override
  String get listEmpty => 'सूची खाली है।';
  @override
  String copied(int c) => '${_tasks(c)} क्लिपबोर्ड पर कॉपी किए गए';
  @override
  String get noMatch => 'कोई काम मेल नहीं खाता।';
  @override
  String get clearSearch => 'खोज साफ़ करें';
  @override
  String get themeSystem => 'सिस्टम';
  @override
  String get themeLight => 'लाइट';
  @override
  String get themeDark => 'डार्क';
  @override
  String doneOfGoal(int d, int g) => 'आज $g में से $d पूरे';
  @override
  String get nothingToday => 'आज अभी तक कुछ पूरा नहीं हुआ';
  @override
  String doneToday(int d) => 'आज $d पूरे';
  @override
  String goalPercent(int p) => 'आज के लक्ष्य का $p प्रतिशत';
  @override
  String listPercent(int p) => 'सूची का $p प्रतिशत पूरा';
  @override
  String get closeSearch => 'खोज बंद करें';
  @override
  String get searchAndSort => 'खोजें और क्रम बदलें';
  @override
  String get more => 'और';
  @override
  String get copyList => 'सूची कॉपी करें';
  @override
  String get emptyTheJar => 'पूरे हुए काम आर्काइव करें';
  @override
  String get sound => 'आवाज़';
  @override
  String get vibration => 'वाइब्रेशन';
  @override
  String get settings => 'सेटिंग्स';
  @override
  String get dailyGoal => 'रोज़ का लक्ष्य';
  @override
  String get dailyGoalHint => 'हर दिन पूरे करने वाले काम';
  @override
  String get off => 'बंद';
  @override
  String get theme => 'थीम';
  @override
  String get language => 'भाषा';
  @override
  String get soundHint => 'टिक और सरसराहट की आवाज़';
  @override
  String get vibrationHint => 'अक्षरों का गिरना महसूस करें';
  @override
  String legend(String day) => '$day को पूरे हुए अक्षर इस रंग में जमते हैं';
  @override
  String get searchTasks => 'काम खोजें';
  @override
  String get showAll => 'सभी';
  @override
  String get showOpen => 'बाकी';
  @override
  String get showDone => 'पूरे';
  @override
  String get sortNewest => 'नए पहले';
  @override
  String get sortPriority => 'प्राथमिकता';
  @override
  String get sortDue => 'अंतिम तिथि';
  @override
  String get nothingOnList => 'सूची में कुछ नहीं है';
  @override
  String get emptyHint => 'एक काम जोड़ें, फिर उस पर टिक करें — उसके अक्षर जार में गिर जाएँगे।';
  @override
  String get gestureHint =>
      'बदलने के लिए काम को दबाकर रखें · हटाने के लिए स्वाइप करें · जार खाली करने के लिए फ़ोन हिलाएँ';

  // Task editor
  @override
  String get lowHint => 'हल्के अक्षर, जो गिरकर उछलते हैं।';
  @override
  String get normalHint => 'अक्षर रेत की तरह जमते हैं।';
  @override
  String get highHint => 'मोटे, भारी अक्षर, जो दूसरों को धकेल देते हैं।';
  @override
  String get editTask => 'काम बदलें';
  @override
  String get newTask => 'नया काम';
  @override
  String get whatNeedsDoing => 'क्या करना है?';
  @override
  String get whatNeedsDoingMany => 'क्या करना है? कई काम जोड़ने के लिए सूची पेस्ट करें।';
  @override
  String get low => 'कम';
  @override
  String get normal => 'सामान्य';
  @override
  String get high => 'ज़्यादा';
  @override
  String get today => 'आज';
  @override
  String get tomorrow => 'कल';
  @override
  String get pickDate => 'तारीख चुनें';
  @override
  String get removeDueDate => 'अंतिम तिथि हटाएँ';
  @override
  String get duplicate => 'कॉपी बनाएँ';
  @override
  String get saveChanges => 'बदलाव सेव करें';
  @override
  String addMany(int c) => '${_tasks(c)} जोड़ें';

  @override
  String get noteHint => 'नोट (वैकल्पिक)';
  @override
  String get pinToTop => 'ऊपर पिन करें';
  @override
  String get unpin => 'पिन हटाएँ';
  @override
  String get repeatNever => 'एक बार';
  @override
  String get repeatDaily => 'रोज़';
  @override
  String get repeatWeekly => 'हर हफ़्ते';

  @override
  String get showOverdue => 'देरी वाले';
  @override
  String overdueCount(int c) => '$c में देरी';
  @override
  String get reminders => 'अंतिम तिथि के रिमाइंडर';
  @override
  String get remindersHint => 'अंतिम दिन सुबह 9:00 बजे सूचना';
  @override
  String get remindersBlocked => 'सूचनाएँ बंद हैं। सिस्टम सेटिंग्स में उन्हें चालू करें।';
  @override
  String get smartDateHint => 'टिप: तारीख तय करने के लिए आखिर में “कल” या “शुक्रवार” लिखें';

  @override
  String get jarStyle => 'जार के रंग';
  @override
  String get jarStyleHint => 'नए पूरे हुए कामों के लिए';
  @override
  String jarStyleName(int i) => const ['हफ़्ते के दिन', 'सूर्यास्त', 'समुद्र', 'एक रंग'][i];
  @override
  String get backup => 'बैकअप';
  @override
  String get copyBackup => 'बैकअप कॉपी करें';
  @override
  String get restoreFromClipboard => 'क्लिपबोर्ड से वापस लाएँ';
  @override
  String get backupCopied => 'बैकअप कॉपी हो गया। इसे किसी सुरक्षित जगह पेस्ट करें।';
  @override
  String get restoreQ => 'यह बैकअप वापस लाएँ?';
  @override
  String get restoreBody => 'आपकी मौजूदा सूची और आर्काइव की जगह क्लिपबोर्ड का बैकअप आ जाएगा।';
  @override
  String get restore => 'वापस लाएँ';
  @override
  String get restored => 'बैकअप वापस आ गया।';
  @override
  String get notABackup => 'क्लिपबोर्ड में कोई Done Dust बैकअप नहीं है।';
  @override
  String get restoreAll => 'सब वापस लाएँ';
  @override
  String get restoreAllQ => 'आर्काइव के सभी काम वापस लाएँ?';
  @override
  String get restoreAllBody => 'वे आपकी सूची में बाकी कामों की तरह लौट आएँगे।';

  @override
  String get alarm => 'अलार्म';
  @override
  String alarmAt(String time) => 'अलार्म $time';
  @override
  String get removeAlarm => 'अलार्म हटाएँ';
  @override
  String get stopwatch => 'स्टॉपवॉच';
  @override
  String get startStopwatch => 'स्टॉपवॉच शुरू करें';
  @override
  String get pauseStopwatch => 'स्टॉपवॉच रोकें';

  // Archive
  @override
  String get deletedFromArchive => 'आर्काइव से हटाया गया';
  @override
  String get clearArchiveQ => 'आर्काइव खाली करें?';
  @override
  String get clearArchiveBody => 'आर्काइव किए गए काम हमेशा के लिए हट जाएँगे।';
  @override
  String get keep => 'रखें';
  @override
  String get clearArchive => 'आर्काइव खाली करें';
  @override
  String get searchArchive => 'आर्काइव में खोजें';
  @override
  String get archiveEmpty =>
      'फ़ोन हिलाने पर, या ⋮ › पूरे हुए काम आर्काइव करें दबाने पर, पूरे हुए काम यहाँ आते हैं।';
  @override
  String noArchiveMatch(String q) => '“$q” से कोई आर्काइव किया गया काम मेल नहीं खाता।';
  @override
  String doneOn(String day) => '$day को पूरा';
  @override
  String get reopenTask => 'काम फिर से खोलें';

  // Stats
  @override
  String statsLine(int total, int open, int streakDays) =>
      'कुल $total पूरे · $open बाकी · ${streak(streakDays)}';
  @override
  String milestone(int d) => '$d दिन का सिलसिला! अक्षर यूँ ही गिरते रहें।';
  @override
  String bestStreak(int d) => 'सबसे लंबा सिलसिला: $d दिन';
  @override
  String weekLine(String now, String last) => 'इस हफ़्ते $now · पिछले हफ़्ते $last';
  @override
  String get last12Weeks => 'पिछले 12 हफ़्ते';
  @override
  String heatCell(String day, int c) => '$day: $c पूरे';
  @override
  String bestDay(String day) => 'सबसे अच्छा दिन: $day';
  @override
  String finishedOn(String day, int c) => '$day: $c पूरे';

  // First-launch tasks
  @override
  List<String> get starterTasks => const [
        'मुझ पर टिक करें और अक्षरों को गिरते देखें',
        'ढेर खिसकाने के लिए फ़ोन झुकाएँ',
        'ज़रूरी काम मोटे होते हैं और पत्थर की तरह गिरते हैं',
        'गिरे हुए अक्षर को खींचें, या ढेर पर टैप करें',
        'काम को उड़ाने के लिए उसे बगल में स्वाइप करें',
        'जार को आर्काइव में खाली करने के लिए फ़ोन हिलाएँ',
      ];
}
