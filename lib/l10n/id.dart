part of '../l10n.dart';

class SId extends S {
  const SId();

  @override
  String get code => 'id';

  @override
  String _tasks(int c) => '$c tugas';

  // Dates
  @override
  List<String> get weekdays => const ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
  @override
  List<String> get weekdaysShort => const ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
  @override
  List<String> get weekdayInitials => const ['S', 'S', 'R', 'K', 'J', 'S', 'M'];
  @override
  List<String> get months =>
      const ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
  @override
  String due(String day) => 'Tenggat $day';
  @override
  String get dueToday => 'Tenggat hari ini';
  @override
  String get dueTomorrow => 'Tenggat besok';
  @override
  String overdue(int days) => 'Terlambat $days hari';

  // Common
  @override
  String get undo => 'Urungkan';
  @override
  String get delete => 'Hapus';
  @override
  String get archive => 'Arsip';
  @override
  String get stats => 'Statistik';
  @override
  String get addTask => 'Tambah tugas';
  @override
  String streak(int d) => 'Beruntun $d hari';

  // Main screen
  @override
  String get myTasks => 'Tugasku';
  @override
  String get emptyJar => 'Toples kosong';
  @override
  String jarWith(int c) => 'Toples berisi huruf dari ${_tasks(c)} yang selesai';
  @override
  String get allDone => 'Semua beres. Nikmati ketenangannya.';
  @override
  String goalReached(int g) => 'Target harian tercapai: $g selesai hari ini.';
  @override
  String added(int c) => '${_tasks(c)} ditambahkan';
  @override
  String duplicated(String t) => '“$t” diduplikasi';
  @override
  String deleted(String t) => '“$t” dihapus';
  @override
  String get nothingToArchive => 'Belum ada yang bisa diarsipkan. Selesaikan satu tugas dulu.';
  @override
  String archived(int c) => '${_tasks(c)} diarsipkan';
  @override
  String jarFull(int c) => 'Toples penuh. $c tugas terlama dipindahkan ke arsip.';
  @override
  String get listEmpty => 'Daftar kosong.';
  @override
  String copied(int c) => '${_tasks(c)} disalin ke papan klip';
  @override
  String get noMatch => 'Tidak ada tugas yang cocok.';
  @override
  String get clearSearch => 'Hapus pencarian';
  @override
  String get themeSystem => 'Sistem';
  @override
  String get themeLight => 'Terang';
  @override
  String get themeDark => 'Gelap';
  @override
  String doneOfGoal(int d, int g) => '$d dari $g selesai hari ini';
  @override
  String get nothingToday => 'Belum ada yang selesai hari ini';
  @override
  String doneToday(int d) => '$d selesai hari ini';
  @override
  String goalPercent(int p) => '$p persen dari target harian';
  @override
  String listPercent(int p) => '$p persen daftar selesai';
  @override
  String get closeSearch => 'Tutup pencarian';
  @override
  String get searchAndSort => 'Cari dan urutkan';
  @override
  String get more => 'Lainnya';
  @override
  String get copyList => 'Salin daftar';
  @override
  String get emptyTheJar => 'Arsipkan tugas selesai';
  @override
  String get sound => 'Suara';
  @override
  String get vibration => 'Getaran';
  @override
  String get settings => 'Pengaturan';
  @override
  String get dailyGoal => 'Target harian';
  @override
  String get dailyGoalHint => 'Tugas yang diselesaikan tiap hari';
  @override
  String get off => 'Mati';
  @override
  String get theme => 'Tema';
  @override
  String get language => 'Bahasa';
  @override
  String get soundHint => 'Detak dan desir';
  @override
  String get vibrationHint => 'Rasakan huruf mendarat';
  @override
  String legend(String day) => 'Huruf yang selesai pada $day mengendap dengan warna ini';
  @override
  String get searchTasks => 'Cari tugas';
  @override
  String get showAll => 'Semua';
  @override
  String get showOpen => 'Belum';
  @override
  String get showDone => 'Selesai';
  @override
  String get sortNewest => 'Terbaru';
  @override
  String get sortPriority => 'Prioritas';
  @override
  String get sortDue => 'Tenggat';
  @override
  String get nothingOnList => 'Daftar masih kosong';
  @override
  String get emptyHint => 'Tambahkan tugas, lalu centang agar hurufnya jatuh ke dalam toples.';
  @override
  String get gestureHint =>
      'Tekan lama tugas untuk mengedit · geser untuk menghapus · guncang untuk mengosongkan toples';

  // Task editor
  @override
  String get lowHint => 'Huruf ringan yang memantul saat mendarat.';
  @override
  String get normalHint => 'Huruf mengendap seperti pasir.';
  @override
  String get highHint => 'Huruf tebal dan berat yang menyingkirkan yang lain.';
  @override
  String get editTask => 'Edit tugas';
  @override
  String get newTask => 'Tugas baru';
  @override
  String get whatNeedsDoing => 'Apa yang perlu dikerjakan?';
  @override
  String get whatNeedsDoingMany => 'Apa yang perlu dikerjakan? Tempel daftar untuk menambah banyak.';
  @override
  String get low => 'Rendah';
  @override
  String get normal => 'Normal';
  @override
  String get high => 'Tinggi';
  @override
  String get today => 'Hari ini';
  @override
  String get tomorrow => 'Besok';
  @override
  String get pickDate => 'Pilih tanggal';
  @override
  String get removeDueDate => 'Hapus tenggat';
  @override
  String get duplicate => 'Duplikat';
  @override
  String get saveChanges => 'Simpan perubahan';
  @override
  String addMany(int c) => 'Tambah ${_tasks(c)}';

  @override
  String get noteHint => 'Catatan (opsional)';
  @override
  String get pinToTop => 'Sematkan di atas';
  @override
  String get unpin => 'Lepas sematan';
  @override
  String get repeatNever => 'Sekali';
  @override
  String get repeatDaily => 'Harian';
  @override
  String get repeatWeekly => 'Mingguan';

  @override
  String get showOverdue => 'Terlambat';
  @override
  String overdueCount(int c) => '$c terlambat';
  @override
  String get reminders => 'Pengingat tenggat';
  @override
  String get remindersHint => 'Notifikasi pukul 09.00 pada hari tenggat';
  @override
  String get remindersBlocked => 'Notifikasi diblokir. Izinkan di pengaturan sistem.';
  @override
  String get smartDateHint => 'Tips: akhiri dengan “besok” atau “jumat” untuk mengatur tanggal';

  @override
  String get jarStyle => 'Warna toples';
  @override
  String get jarStyleHint => 'untuk tugas yang baru selesai';
  @override
  String jarStyleName(int i) => const ['Hari', 'Senja', 'Laut', 'Mono'][i];
  @override
  String get backup => 'Cadangan';
  @override
  String get copyBackup => 'Salin cadangan';
  @override
  String get restoreFromClipboard => 'Pulihkan dari papan klip';
  @override
  String get backupCopied => 'Cadangan disalin. Tempel di tempat yang aman.';
  @override
  String get restoreQ => 'Pulihkan cadangan ini?';
  @override
  String get restoreBody => 'Daftar dan arsipmu saat ini akan diganti dengan cadangan di papan klip.';
  @override
  String get restore => 'Pulihkan';
  @override
  String get restored => 'Cadangan dipulihkan.';
  @override
  String get notABackup => 'Tidak ada cadangan Done Dust di papan klip.';
  @override
  String get restoreAll => 'Pulihkan semua';
  @override
  String get restoreAllQ => 'Kembalikan semua tugas yang diarsipkan?';
  @override
  String get restoreAllBody => 'Tugas akan kembali ke daftarmu sebagai tugas yang belum selesai.';

  @override
  String get alarm => 'Alarm';
  @override
  String alarmAt(String time) => 'Alarm $time';
  @override
  String get removeAlarm => 'Hapus alarm';
  @override
  String get stopwatch => 'Stopwatch';
  @override
  String get startStopwatch => 'Mulai stopwatch';
  @override
  String get pauseStopwatch => 'Jeda stopwatch';

  // Archive
  @override
  String get deletedFromArchive => 'Dihapus dari arsip';
  @override
  String get clearArchiveQ => 'Kosongkan arsip?';
  @override
  String get clearArchiveBody => 'Tugas yang diarsipkan akan dihapus permanen.';
  @override
  String get keep => 'Simpan';
  @override
  String get clearArchive => 'Kosongkan arsip';
  @override
  String get searchArchive => 'Cari di arsip';
  @override
  String get archiveEmpty =>
      'Tugas selesai masuk ke sini saat kamu mengguncang ponsel, atau ketuk ⋮ › Arsipkan tugas selesai.';
  @override
  String noArchiveMatch(String q) => 'Tidak ada tugas arsip yang cocok dengan “$q”.';
  @override
  String doneOn(String day) => 'Selesai $day';
  @override
  String get reopenTask => 'Buka lagi tugas';

  // Stats
  @override
  String statsLine(int total, int open, int streakDays) =>
      '$total selesai total · $open belum · ${streak(streakDays)}';
  @override
  String milestone(int d) => 'Beruntun $d hari! Biarkan debunya terus jatuh.';
  @override
  String bestStreak(int d) => 'Beruntun terbaik: $d hari';
  @override
  String weekLine(String now, String last) => 'Minggu ini $now · minggu lalu $last';
  @override
  String get last12Weeks => '12 minggu terakhir';
  @override
  String heatCell(String day, int c) => '$day: $c selesai';
  @override
  String bestDay(String day) => 'Hari terbaik: $day';
  @override
  String finishedOn(String day, int c) => '$day: $c selesai';

  // First-launch tasks
  @override
  List<String> get starterTasks => const [
        'Centang aku dan lihat hurufnya berjatuhan',
        'Miringkan ponsel untuk menggeser tumpukan',
        'Tugas penting tebal dan jatuh seperti batu',
        'Seret huruf yang jatuh, atau ketuk tumpukannya',
        'Geser tugas ke samping untuk menerbangkannya',
        'Guncang ponsel untuk mengosongkan toples ke arsip',
      ];
}
