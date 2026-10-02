part of '../l10n.dart';

class SFr extends S {
  const SFr();

  @override
  String get code => 'fr';

  @override
  String _tasks(int c) => '$c ${c <= 1 ? 'tâche' : 'tâches'}';

  String _days(int d) => '$d ${d <= 1 ? 'jour' : 'jours'}';

  // Dates
  @override
  List<String> get weekdays =>
      const ['lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi', 'dimanche'];
  @override
  List<String> get weekdaysShort => const ['lun.', 'mar.', 'mer.', 'jeu.', 'ven.', 'sam.', 'dim.'];
  @override
  List<String> get weekdayInitials => const ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
  @override
  List<String> get months => const [
        'janv.',
        'févr.',
        'mars',
        'avr.',
        'mai',
        'juin',
        'juil.',
        'août',
        'sept.',
        'oct.',
        'nov.',
        'déc.'
      ];
  @override
  String formatDay(DateTime d) => '${weekdaysShort[d.weekday - 1]} ${d.day} ${months[d.month - 1]}';
  @override
  String due(String day) => 'Échéance : $day';
  @override
  String get dueToday => 'Échéance aujourd’hui';
  @override
  String get dueTomorrow => 'Échéance demain';
  @override
  String overdue(int days) => 'En retard de ${_days(days)}';

  // Common
  @override
  String get undo => 'Annuler';
  @override
  String get delete => 'Supprimer';
  @override
  String get archive => 'Archives';
  @override
  String get stats => 'Statistiques';
  @override
  String get addTask => 'Ajouter une tâche';
  @override
  String streak(int d) => 'Série de ${_days(d)}';

  // Main screen
  @override
  String get myTasks => 'Mes tâches';
  @override
  String get emptyJar => 'Bocal vide';
  @override
  String jarWith(int c) => 'Bocal contenant les lettres de ${_tasks(c)} terminées';
  @override
  String get allDone => 'Tout est fait. Profitez du calme.';
  @override
  String goalReached(int g) => 'Objectif du jour atteint : $g faites aujourd’hui.';
  @override
  String added(int c) => '${_tasks(c)} ${c <= 1 ? 'ajoutée' : 'ajoutées'}';
  @override
  String duplicated(String t) => '« $t » dupliquée';
  @override
  String deleted(String t) => '« $t » supprimée';
  @override
  String get nothingToArchive => 'Rien à archiver pour l’instant. Terminez d’abord une tâche.';
  @override
  String archived(int c) => '${_tasks(c)} ${c <= 1 ? 'archivée' : 'archivées'}';
  @override
  String jarFull(int c) => c <= 1
      ? 'Le bocal est plein. La tâche la plus ancienne a été archivée.'
      : 'Le bocal est plein. Les $c tâches les plus anciennes ont été archivées.';
  @override
  String get listEmpty => 'La liste est vide.';
  @override
  String copied(int c) =>
      '${_tasks(c)} ${c <= 1 ? 'copiée' : 'copiées'} dans le presse-papiers';
  @override
  String get noMatch => 'Aucune tâche ne correspond.';
  @override
  String get clearSearch => 'Effacer la recherche';
  @override
  String get themeSystem => 'Système';
  @override
  String get themeLight => 'Clair';
  @override
  String get themeDark => 'Sombre';
  @override
  String doneOfGoal(int d, int g) => '$d sur $g faites aujourd’hui';
  @override
  String get nothingToday => 'Rien de fait aujourd’hui pour l’instant';
  @override
  String doneToday(int d) => '$d ${d <= 1 ? 'faite' : 'faites'} aujourd’hui';
  @override
  String goalPercent(int p) => '$p pour cent de l’objectif du jour';
  @override
  String listPercent(int p) => '$p pour cent de la liste terminé';
  @override
  String get closeSearch => 'Fermer la recherche';
  @override
  String get searchAndSort => 'Rechercher et trier';
  @override
  String get more => 'Plus';
  @override
  String get copyList => 'Copier la liste';
  @override
  String get emptyTheJar => 'Archiver les tâches terminées';
  @override
  String get sound => 'Son';
  @override
  String get vibration => 'Vibration';
  @override
  String get settings => 'Réglages';
  @override
  String get dailyGoal => 'Objectif du jour';
  @override
  String get dailyGoalHint => 'Tâches à terminer chaque jour';
  @override
  String get off => 'Désactivé';
  @override
  String get theme => 'Thème';
  @override
  String get language => 'Langue';
  @override
  String get soundHint => 'Tic-tac et souffles';
  @override
  String get vibrationHint => 'Sentez les lettres tomber';
  @override
  String legend(String day) => 'Les lettres terminées le $day se déposent dans cette couleur';
  @override
  String get searchTasks => 'Rechercher des tâches';
  @override
  String get showAll => 'Toutes';
  @override
  String get showOpen => 'À faire';
  @override
  String get showDone => 'Faites';
  @override
  String get sortNewest => 'Plus récentes';
  @override
  String get sortPriority => 'Priorité';
  @override
  String get sortDue => 'Échéance';
  @override
  String get nothingOnList => 'Rien dans la liste';
  @override
  String get emptyHint =>
      'Ajoutez une tâche, puis cochez-la pour faire tomber ses lettres dans le bocal.';
  @override
  String get gestureHint =>
      'Appui long pour modifier · balayez pour supprimer · secouez pour vider le bocal';

  // Task editor
  @override
  String get lowHint => 'Des lettres légères qui rebondissent en tombant.';
  @override
  String get normalHint => 'Les lettres se déposent comme du sable.';
  @override
  String get highHint => 'Des lettres grasses et lourdes qui bousculent les autres.';
  @override
  String get editTask => 'Modifier la tâche';
  @override
  String get newTask => 'Nouvelle tâche';
  @override
  String get whatNeedsDoing => 'Que faut-il faire ?';
  @override
  String get whatNeedsDoingMany =>
      'Que faut-il faire ? Collez une liste pour en ajouter plusieurs.';
  @override
  String get low => 'Basse';
  @override
  String get normal => 'Normale';
  @override
  String get high => 'Haute';
  @override
  String get today => 'Aujourd’hui';
  @override
  String get tomorrow => 'Demain';
  @override
  String get pickDate => 'Choisir une date';
  @override
  String get removeDueDate => 'Retirer l’échéance';
  @override
  String get duplicate => 'Dupliquer';
  @override
  String get saveChanges => 'Enregistrer';
  @override
  String addMany(int c) => 'Ajouter ${_tasks(c)}';

  @override
  String get noteHint => 'Note (facultatif)';
  @override
  String get pinToTop => 'Épingler en haut';
  @override
  String get unpin => 'Désépingler';
  @override
  String get repeatNever => 'Une fois';
  @override
  String get repeatDaily => 'Chaque jour';
  @override
  String get repeatWeekly => 'Chaque semaine';

  @override
  String get showOverdue => 'En retard';
  @override
  String overdueCount(int c) => '$c en retard';
  @override
  String get reminders => 'Rappels d’échéance';
  @override
  String get remindersHint => 'Une notification à 9 h le jour de l’échéance';
  @override
  String get remindersBlocked =>
      'Les notifications sont bloquées. Autorisez-les dans les réglages du système.';
  @override
  String get smartDateHint => 'Astuce : terminez par « demain » ou « vendredi » pour fixer une date';

  @override
  String get jarStyle => 'Couleurs du bocal';
  @override
  String get jarStyleHint => 'pour les tâches tout juste terminées';
  @override
  String jarStyleName(int i) => const ['Jours', 'Coucher de soleil', 'Océan', 'Mono'][i];
  @override
  String get backup => 'Sauvegarde';
  @override
  String get copyBackup => 'Copier la sauvegarde';
  @override
  String get restoreFromClipboard => 'Restaurer depuis le presse-papiers';
  @override
  String get backupCopied => 'Sauvegarde copiée. Collez-la en lieu sûr.';
  @override
  String get restoreQ => 'Restaurer cette sauvegarde ?';
  @override
  String get restoreBody =>
      'Votre liste et vos archives actuelles seront remplacées par la sauvegarde du presse-papiers.';
  @override
  String get restore => 'Restaurer';
  @override
  String get restored => 'Sauvegarde restaurée.';
  @override
  String get notABackup => 'Le presse-papiers ne contient aucune sauvegarde Done Dust.';
  @override
  String get restoreAll => 'Tout restaurer';
  @override
  String get restoreAllQ => 'Remettre toutes les tâches archivées ?';
  @override
  String get restoreAllBody => 'Elles reviendront dans votre liste comme tâches à faire.';

  @override
  String get alarm => 'Alarme';
  @override
  String alarmAt(String time) => 'Alarme $time';
  @override
  String get removeAlarm => 'Supprimer l’alarme';
  @override
  String get stopwatch => 'Chronomètre';
  @override
  String get startStopwatch => 'Démarrer le chronomètre';
  @override
  String get pauseStopwatch => 'Mettre en pause le chronomètre';

  // Archive
  @override
  String get deletedFromArchive => 'Supprimée des archives';
  @override
  String get clearArchiveQ => 'Vider les archives ?';
  @override
  String get clearArchiveBody => 'Les tâches archivées seront définitivement supprimées.';
  @override
  String get keep => 'Garder';
  @override
  String get clearArchive => 'Vider les archives';
  @override
  String get searchArchive => 'Rechercher dans les archives';
  @override
  String get archiveEmpty =>
      'Les tâches terminées arrivent ici quand vous secouez le téléphone ou touchez ⋮ › Archiver les tâches terminées.';
  @override
  String noArchiveMatch(String q) => 'Aucune tâche archivée ne correspond à « $q ».';
  @override
  String doneOn(String day) => 'Faite le $day';
  @override
  String get reopenTask => 'Rouvrir la tâche';

  // Stats
  @override
  String statsLine(int total, int open, int streakDays) =>
      '$total ${total <= 1 ? 'terminée' : 'terminées'} au total · $open à faire · ${streak(streakDays)}';
  @override
  String milestone(int d) => 'Série de ${_days(d)} ! Que la poussière continue de tomber.';
  @override
  String bestStreak(int d) => 'Meilleure série : ${_days(d)}';
  @override
  String weekLine(String now, String last) => 'Cette semaine $now · semaine dernière $last';
  @override
  String get last12Weeks => '12 dernières semaines';
  @override
  String heatCell(String day, int c) => '$day : $c ${c <= 1 ? 'terminée' : 'terminées'}';
  @override
  String bestDay(String day) => 'Meilleur jour : $day';
  @override
  String finishedOn(String day, int c) => '$day : $c ${c <= 1 ? 'terminée' : 'terminées'}';

  // First-launch tasks
  @override
  List<String> get starterTasks => const [
        'Cochez-moi et regardez les lettres tomber',
        'Inclinez le téléphone pour faire glisser le tas',
        'Les tâches importantes sont en gras et tombent comme des pierres',
        'Faites glisser une lettre tombée, ou touchez le tas',
        'Balayez une tâche sur le côté pour la faire s’envoler',
        'Secouez le téléphone pour vider le bocal dans les archives',
      ];
}
