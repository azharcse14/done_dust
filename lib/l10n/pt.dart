part of '../l10n.dart';

class SPt extends S {
  const SPt();

  @override
  String get code => 'pt';

  @override
  String _tasks(int c) => '$c ${c == 1 ? 'tarefa' : 'tarefas'}';

  // Dates
  @override
  List<String> get weekdays =>
      const ['segunda-feira', 'terça-feira', 'quarta-feira', 'quinta-feira', 'sexta-feira', 'sábado', 'domingo'];
  @override
  List<String> get weekdaysShort => const ['seg', 'ter', 'qua', 'qui', 'sex', 'sáb', 'dom'];
  @override
  List<String> get weekdayInitials => const ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];
  @override
  List<String> get months =>
      const ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez'];
  @override
  String formatDay(DateTime d) =>
      '${weekdaysShort[d.weekday - 1]}, ${d.day} de ${months[d.month - 1]}';
  @override
  String due(String day) => 'Vence em $day';
  @override
  String get dueToday => 'Vence hoje';
  @override
  String get dueTomorrow => 'Vence amanhã';
  @override
  String overdue(int days) => 'Atrasada há $days ${days == 1 ? 'dia' : 'dias'}';

  // Common
  @override
  String get undo => 'Desfazer';
  @override
  String get delete => 'Excluir';
  @override
  String get archive => 'Arquivo';
  @override
  String get stats => 'Estatísticas';
  @override
  String get addTask => 'Adicionar tarefa';
  @override
  String streak(int d) => 'Sequência de $d ${d == 1 ? 'dia' : 'dias'}';

  // Main screen
  @override
  String get myTasks => 'Minhas tarefas';
  @override
  String get emptyJar => 'Pote vazio';
  @override
  String jarWith(int c) => 'Pote com as letras de ${_tasks(c)} concluídas';
  @override
  String get allDone => 'Tudo feito. Aproveite a calma.';
  @override
  String goalReached(int g) => 'Meta diária atingida: $g concluídas hoje.';
  @override
  String added(int c) => '${_tasks(c)} adicionada${c == 1 ? '' : 's'}';
  @override
  String duplicated(String t) => '“$t” duplicada';
  @override
  String deleted(String t) => '“$t” excluída';
  @override
  String get nothingToArchive => 'Nada para arquivar ainda. Conclua uma tarefa primeiro.';
  @override
  String archived(int c) => '${_tasks(c)} arquivada${c == 1 ? '' : 's'}';
  @override
  String jarFull(int c) => c == 1
      ? 'O pote está cheio. A tarefa mais antiga foi para o arquivo.'
      : 'O pote está cheio. As $c tarefas mais antigas foram para o arquivo.';
  @override
  String get listEmpty => 'A lista está vazia.';
  @override
  String copied(int c) => '${_tasks(c)} copiada${c == 1 ? '' : 's'} para a área de transferência';
  @override
  String get noMatch => 'Nenhuma tarefa encontrada.';
  @override
  String get clearSearch => 'Limpar busca';
  @override
  String get themeSystem => 'Sistema';
  @override
  String get themeLight => 'Claro';
  @override
  String get themeDark => 'Escuro';
  @override
  String doneOfGoal(int d, int g) => '$d de $g concluídas hoje';
  @override
  String get nothingToday => 'Nada concluído hoje ainda';
  @override
  String doneToday(int d) => '$d ${d == 1 ? 'concluída' : 'concluídas'} hoje';
  @override
  String goalPercent(int p) => '$p por cento da meta diária';
  @override
  String listPercent(int p) => '$p por cento da lista concluída';
  @override
  String get closeSearch => 'Fechar busca';
  @override
  String get searchAndSort => 'Buscar e ordenar';
  @override
  String get more => 'Mais';
  @override
  String get copyList => 'Copiar lista';
  @override
  String get emptyTheJar => 'Arquivar tarefas concluídas';
  @override
  String get sound => 'Som';
  @override
  String get vibration => 'Vibração';
  @override
  String get settings => 'Configurações';
  @override
  String get dailyGoal => 'Meta diária';
  @override
  String get dailyGoalHint => 'Tarefas a concluir por dia';
  @override
  String get off => 'Desligado';
  @override
  String get theme => 'Tema';
  @override
  String get language => 'Idioma';
  @override
  String get soundHint => 'Tique-taques e sopros';
  @override
  String get vibrationHint => 'Sinta as letras caírem';
  @override
  String legend(String day) => '$day: as letras concluídas ficam nesta cor';
  @override
  String get searchTasks => 'Buscar tarefas';
  @override
  String get showAll => 'Todas';
  @override
  String get showOpen => 'Abertas';
  @override
  String get showDone => 'Concluídas';
  @override
  String get sortNewest => 'Mais recentes';
  @override
  String get sortPriority => 'Prioridade';
  @override
  String get sortDue => 'Prazo';
  @override
  String get nothingOnList => 'Nada na lista';
  @override
  String get emptyHint => 'Adicione uma tarefa e marque-a para jogar as letras no pote.';
  @override
  String get gestureHint =>
      'Toque e segure para editar · deslize para excluir · agite para esvaziar o pote';

  // Task editor
  @override
  String get lowHint => 'Letras leves que quicam ao cair.';
  @override
  String get normalHint => 'As letras assentam como areia.';
  @override
  String get highHint => 'Letras grossas e pesadas que empurram as outras.';
  @override
  String get editTask => 'Editar tarefa';
  @override
  String get newTask => 'Nova tarefa';
  @override
  String get whatNeedsDoing => 'O que precisa ser feito?';
  @override
  String get whatNeedsDoingMany => 'O que precisa ser feito? Cole uma lista para adicionar várias.';
  @override
  String get low => 'Baixa';
  @override
  String get normal => 'Normal';
  @override
  String get high => 'Alta';
  @override
  String get today => 'Hoje';
  @override
  String get tomorrow => 'Amanhã';
  @override
  String get pickDate => 'Escolher data';
  @override
  String get removeDueDate => 'Remover prazo';
  @override
  String get duplicate => 'Duplicar';
  @override
  String get saveChanges => 'Salvar alterações';
  @override
  String addMany(int c) => 'Adicionar ${_tasks(c)}';

  @override
  String get noteHint => 'Nota (opcional)';
  @override
  String get pinToTop => 'Fixar no topo';
  @override
  String get unpin => 'Desafixar';
  @override
  String get repeatNever => 'Uma vez';
  @override
  String get repeatDaily => 'Diária';
  @override
  String get repeatWeekly => 'Semanal';

  @override
  String get showOverdue => 'Atrasadas';
  @override
  String overdueCount(int c) => '$c ${c == 1 ? 'atrasada' : 'atrasadas'}';
  @override
  String get reminders => 'Lembretes de prazo';
  @override
  String get remindersHint => 'Uma notificação às 9:00 no dia do prazo';
  @override
  String get remindersBlocked => 'As notificações estão bloqueadas. Permita-as nas configurações do sistema.';
  @override
  String get smartDateHint => 'Dica: termine com “amanhã” ou “sexta” para definir uma data';

  @override
  String get jarStyle => 'Cores do pote';
  @override
  String get jarStyleHint => 'para tarefas recém-concluídas';
  @override
  String jarStyleName(int i) => const ['Dias da semana', 'Pôr do sol', 'Oceano', 'Mono'][i];
  @override
  String get backup => 'Backup';
  @override
  String get copyBackup => 'Copiar backup';
  @override
  String get restoreFromClipboard => 'Restaurar da área de transferência';
  @override
  String get backupCopied => 'Backup copiado. Cole-o em um lugar seguro.';
  @override
  String get restoreQ => 'Restaurar este backup?';
  @override
  String get restoreBody =>
      'Sua lista e seu arquivo atuais serão substituídos pelo backup da área de transferência.';
  @override
  String get restore => 'Restaurar';
  @override
  String get restored => 'Backup restaurado.';
  @override
  String get notABackup => 'A área de transferência não tem um backup do Done Dust.';
  @override
  String get restoreAll => 'Restaurar tudo';
  @override
  String get restoreAllQ => 'Devolver todas as tarefas arquivadas?';
  @override
  String get restoreAllBody => 'Elas voltam para a sua lista como tarefas abertas.';

  @override
  String get alarm => 'Alarme';
  @override
  String alarmAt(String time) => 'Alarme $time';
  @override
  String get removeAlarm => 'Remover alarme';
  @override
  String get stopwatch => 'Cronômetro';
  @override
  String get startStopwatch => 'Iniciar cronômetro';
  @override
  String get pauseStopwatch => 'Pausar cronômetro';

  // Archive
  @override
  String get deletedFromArchive => 'Excluída do arquivo';
  @override
  String get clearArchiveQ => 'Limpar o arquivo?';
  @override
  String get clearArchiveBody => 'As tarefas arquivadas serão excluídas para sempre.';
  @override
  String get keep => 'Manter';
  @override
  String get clearArchive => 'Limpar arquivo';
  @override
  String get searchArchive => 'Buscar no arquivo';
  @override
  String get archiveEmpty =>
      'As tarefas concluídas vêm para cá quando você agita o celular ou toca em ⋮ › Arquivar tarefas concluídas.';
  @override
  String noArchiveMatch(String q) => 'Nenhuma tarefa arquivada corresponde a “$q”.';
  @override
  String doneOn(String day) => 'Concluída em $day';
  @override
  String get reopenTask => 'Reabrir tarefa';

  // Stats
  @override
  String statsLine(int total, int open, int streakDays) =>
      '$total concluídas no total · $open abertas · ${streak(streakDays)}';
  @override
  String milestone(int d) => 'Sequência de $d dias! Continue fazendo a poeira cair.';
  @override
  String bestStreak(int d) => 'Melhor sequência: $d ${d == 1 ? 'dia' : 'dias'}';
  @override
  String weekLine(String now, String last) => 'Esta semana $now · semana passada $last';
  @override
  String get last12Weeks => 'Últimas 12 semanas';
  @override
  String heatCell(String day, int c) => '$day: $c ${c == 1 ? 'concluída' : 'concluídas'}';
  @override
  String bestDay(String day) => 'Melhor dia: $day';
  @override
  String finishedOn(String day, int c) => '$day: $c ${c == 1 ? 'concluída' : 'concluídas'}';

  // First-launch tasks
  @override
  List<String> get starterTasks => const [
        'Marque-me e veja as letras caírem',
        'Incline o celular para deslizar a pilha',
        'Tarefas importantes são grossas e caem como pedra',
        'Arraste uma letra caída ou toque na pilha',
        'Deslize uma tarefa para o lado para soprá-la para longe',
        'Agite o celular para esvaziar o pote no arquivo',
      ];
}
