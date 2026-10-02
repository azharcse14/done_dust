part of '../l10n.dart';

class SEs extends S {
  const SEs();

  @override
  String get code => 'es';

  @override
  String _tasks(int c) => '$c ${c == 1 ? 'tarea' : 'tareas'}';

  // Dates
  @override
  List<String> get weekdays =>
      const ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'];
  @override
  List<String> get weekdaysShort => const ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];
  @override
  List<String> get weekdayInitials => const ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
  @override
  List<String> get months =>
      const ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sept', 'oct', 'nov', 'dic'];
  @override
  String due(String day) => 'Vence $day';
  @override
  String get dueToday => 'Vence hoy';
  @override
  String get dueTomorrow => 'Vence mañana';
  @override
  String overdue(int days) => 'Vencida hace $days ${days == 1 ? 'día' : 'días'}';

  // Common
  @override
  String get undo => 'Deshacer';
  @override
  String get delete => 'Eliminar';
  @override
  String get archive => 'Archivo';
  @override
  String get stats => 'Estadísticas';
  @override
  String get addTask => 'Añadir tarea';
  @override
  String streak(int d) => 'Racha de $d ${d == 1 ? 'día' : 'días'}';

  // Main screen
  @override
  String get myTasks => 'Mis tareas';
  @override
  String get emptyJar => 'Tarro vacío';
  @override
  String jarWith(int c) => 'Tarro con las letras de ${_tasks(c)} terminadas';
  @override
  String get allDone => 'Todo hecho. Disfruta de la calma.';
  @override
  String goalReached(int g) => 'Meta diaria cumplida: $g hechas hoy.';
  @override
  String added(int c) => '${c == 1 ? 'Añadida' : 'Añadidas'} ${_tasks(c)}';
  @override
  String duplicated(String t) => '«$t» duplicada';
  @override
  String deleted(String t) => '«$t» eliminada';
  @override
  String get nothingToArchive => 'Aún no hay nada que archivar. Termina una tarea primero.';
  @override
  String archived(int c) => '${c == 1 ? 'Archivada' : 'Archivadas'} ${_tasks(c)}';
  @override
  String jarFull(int c) => c == 1
      ? 'El tarro está lleno. La tarea más antigua se movió al archivo.'
      : 'El tarro está lleno. Las $c tareas más antiguas se movieron al archivo.';
  @override
  String get listEmpty => 'La lista está vacía.';
  @override
  String copied(int c) => '${c == 1 ? 'Copiada' : 'Copiadas'} ${_tasks(c)} al portapapeles';
  @override
  String get noMatch => 'Ninguna tarea coincide.';
  @override
  String get clearSearch => 'Borrar búsqueda';
  @override
  String get themeSystem => 'Sistema';
  @override
  String get themeLight => 'Claro';
  @override
  String get themeDark => 'Oscuro';
  @override
  String doneOfGoal(int d, int g) => '$d de $g hechas hoy';
  @override
  String get nothingToday => 'Nada hecho hoy todavía';
  @override
  String doneToday(int d) => '$d hechas hoy';
  @override
  String goalPercent(int p) => '$p por ciento de la meta diaria';
  @override
  String listPercent(int p) => '$p por ciento de la lista terminado';
  @override
  String get closeSearch => 'Cerrar búsqueda';
  @override
  String get searchAndSort => 'Buscar y ordenar';
  @override
  String get more => 'Más';
  @override
  String get copyList => 'Copiar lista';
  @override
  String get emptyTheJar => 'Archivar tareas terminadas';
  @override
  String get sound => 'Sonido';
  @override
  String get vibration => 'Vibración';
  @override
  String get settings => 'Ajustes';
  @override
  String get dailyGoal => 'Meta diaria';
  @override
  String get dailyGoalHint => 'Tareas que terminar cada día';
  @override
  String get off => 'Desactivado';
  @override
  String get theme => 'Tema';
  @override
  String get language => 'Idioma';
  @override
  String get soundHint => 'Clics y zumbidos';
  @override
  String get vibrationHint => 'Siente caer las letras';
  @override
  String legend(String day) => 'Las letras terminadas el $day se asientan en este color';
  @override
  String get searchTasks => 'Buscar tareas';
  @override
  String get showAll => 'Todas';
  @override
  String get showOpen => 'Pendientes';
  @override
  String get showDone => 'Hechas';
  @override
  String get sortNewest => 'Más recientes';
  @override
  String get sortPriority => 'Prioridad';
  @override
  String get sortDue => 'Vencimiento';
  @override
  String get nothingOnList => 'No hay nada en la lista';
  @override
  String get emptyHint => 'Añade una tarea y márcala para que sus letras caigan al tarro.';
  @override
  String get gestureHint =>
      'Mantén pulsada una tarea para editarla · desliza para eliminar · agita para vaciar el tarro';

  // Task editor
  @override
  String get lowHint => 'Letras ligeras que rebotan al caer.';
  @override
  String get normalHint => 'Las letras se asientan como arena.';
  @override
  String get highHint => 'Letras gruesas y pesadas que apartan a las demás.';
  @override
  String get editTask => 'Editar tarea';
  @override
  String get newTask => 'Nueva tarea';
  @override
  String get whatNeedsDoing => '¿Qué hay que hacer?';
  @override
  String get whatNeedsDoingMany => '¿Qué hay que hacer? Pega una lista para añadir varias.';
  @override
  String get low => 'Baja';
  @override
  String get normal => 'Normal';
  @override
  String get high => 'Alta';
  @override
  String get today => 'Hoy';
  @override
  String get tomorrow => 'Mañana';
  @override
  String get pickDate => 'Elegir fecha';
  @override
  String get removeDueDate => 'Quitar vencimiento';
  @override
  String get duplicate => 'Duplicar';
  @override
  String get saveChanges => 'Guardar cambios';
  @override
  String addMany(int c) => 'Añadir ${_tasks(c)}';

  @override
  String get noteHint => 'Nota (opcional)';
  @override
  String get pinToTop => 'Fijar arriba';
  @override
  String get unpin => 'Desfijar';
  @override
  String get repeatNever => 'Una vez';
  @override
  String get repeatDaily => 'Cada día';
  @override
  String get repeatWeekly => 'Cada semana';

  @override
  String get showOverdue => 'Vencidas';
  @override
  String overdueCount(int c) => '$c ${c == 1 ? 'vencida' : 'vencidas'}';
  @override
  String get reminders => 'Recordatorios de vencimiento';
  @override
  String get remindersHint => 'Una notificación a las 9:00 el día del vencimiento';
  @override
  String get remindersBlocked =>
      'Las notificaciones están bloqueadas. Permítelas en los ajustes del sistema.';
  @override
  String get smartDateHint => 'Consejo: termina con “mañana” o “viernes” para poner una fecha';

  @override
  String get jarStyle => 'Colores del tarro';
  @override
  String get jarStyleHint => 'para las tareas recién terminadas';
  @override
  String jarStyleName(int i) => const ['Días de la semana', 'Atardecer', 'Océano', 'Mono'][i];
  @override
  String get backup => 'Copia de seguridad';
  @override
  String get copyBackup => 'Copiar copia de seguridad';
  @override
  String get restoreFromClipboard => 'Restaurar desde el portapapeles';
  @override
  String get backupCopied => 'Copia de seguridad copiada. Pégala en un lugar seguro.';
  @override
  String get restoreQ => '¿Restaurar esta copia de seguridad?';
  @override
  String get restoreBody =>
      'Tu lista y tu archivo actuales se sustituirán por la copia del portapapeles.';
  @override
  String get restore => 'Restaurar';
  @override
  String get restored => 'Copia de seguridad restaurada.';
  @override
  String get notABackup => 'El portapapeles no contiene una copia de seguridad de Done Dust.';
  @override
  String get restoreAll => 'Restaurar todo';
  @override
  String get restoreAllQ => '¿Devolver todas las tareas archivadas?';
  @override
  String get restoreAllBody => 'Volverán a tu lista como tareas pendientes.';

  @override
  String get alarm => 'Alarma';
  @override
  String alarmAt(String time) => 'Alarma $time';
  @override
  String get removeAlarm => 'Quitar alarma';
  @override
  String get stopwatch => 'Cronómetro';
  @override
  String get startStopwatch => 'Iniciar cronómetro';
  @override
  String get pauseStopwatch => 'Pausar cronómetro';

  // Archive
  @override
  String get deletedFromArchive => 'Eliminada del archivo';
  @override
  String get clearArchiveQ => '¿Vaciar el archivo?';
  @override
  String get clearArchiveBody => 'Las tareas archivadas se eliminarán para siempre.';
  @override
  String get keep => 'Conservar';
  @override
  String get clearArchive => 'Vaciar archivo';
  @override
  String get searchArchive => 'Buscar en el archivo';
  @override
  String get archiveEmpty =>
      'Las tareas terminadas llegan aquí al agitar el teléfono o al tocar ⋮ › Archivar tareas terminadas.';
  @override
  String noArchiveMatch(String q) => 'Ninguna tarea archivada coincide con «$q».';
  @override
  String doneOn(String day) => 'Hecha el $day';
  @override
  String get reopenTask => 'Reabrir tarea';

  // Stats
  @override
  String statsLine(int total, int open, int streakDays) =>
      '$total terminadas en total · $open pendientes · ${streak(streakDays)}';
  @override
  String milestone(int d) => '¡Racha de $d ${d == 1 ? 'día' : 'días'}! Que siga cayendo el polvo.';
  @override
  String bestStreak(int d) => 'Mejor racha: $d ${d == 1 ? 'día' : 'días'}';
  @override
  String weekLine(String now, String last) => 'Esta semana $now · la semana pasada $last';
  @override
  String get last12Weeks => 'Últimas 12 semanas';
  @override
  String heatCell(String day, int c) => '$day: $c ${c == 1 ? 'terminada' : 'terminadas'}';
  @override
  String bestDay(String day) => 'Mejor día: $day';
  @override
  String finishedOn(String day, int c) => '$day: $c ${c == 1 ? 'terminada' : 'terminadas'}';

  // First-launch tasks
  @override
  List<String> get starterTasks => const [
        'Márcame y mira caer las letras',
        'Inclina el teléfono para mover el montón',
        'Las tareas importantes van en negrita y caen como piedras',
        'Arrastra una letra caída o toca el montón',
        'Desliza una tarea hacia un lado para hacerla volar',
        'Agita el teléfono para vaciar el tarro en el archivo',
      ];
}
