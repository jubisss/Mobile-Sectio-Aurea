import 'package:flutter/material.dart';

enum TipoAcao {
  apenasInstrucoes,
  irParaPomodoro,
  irParaRevisao,
  irParaCornell,
  irParaPodcast,
  irParaFeynman,
  irParaGrupos,
  irParaSavoring,
  irParaVideos,
  irParaMapaMental,
  irParaDiagramaFluxo,
  irParaSimulado,
}

class MetodoEstudo {
  final String titulo;
  final String tempo;
  final String dificuldade;
  final String descricao;
  final List<String> passos;
  final List<String> beneficios;
  final TipoAcao tipoAcao;
  final IconData icone;

  const MetodoEstudo({
    required this.titulo,
    required this.tempo,
    required this.dificuldade,
    required this.descricao,
    required this.passos,
    required this.beneficios,
    required this.tipoAcao,
    required this.icone,
  });
}

class InteligenicaInfo {
  final String chave;
  final String nome;
  final Color cor;
  final IconData icone;
  final String descricao;
  final List<MetodoEstudo> metodos;

  const InteligenicaInfo({
    required this.chave,
    required this.nome,
    required this.cor,
    required this.icone,
    required this.descricao,
    required this.metodos,
  });
}

// ===================== DADOS DOS MÉTODOS =====================

const _pomodoroLinguistica = MetodoEstudo(
  titulo: 'Pomodoro',
  tempo: '25 min',
  dificuldade: 'Fácil',
  icone: Icons.timer_outlined,
  descricao:
      'Estude em blocos de 25 minutos com pausas de 5 minutos. A cada 4 ciclos, faça uma pausa longa de 15 a 30 minutos. Entre um intervalo e outro, mude o conteúdo.',
  passos: [
    'Escolha o conteúdo a estudar',
    'Estude por 25 minutos sem interrupções',
    'Descanse 5 minutos',
    'Mude o conteúdo no próximo ciclo',
    'A cada 4 ciclos, faça pausa longa de 15–30 min',
  ],
  beneficios: ['Mantém o foco', 'Evita cansaço mental', 'Aumenta a produtividade'],
  tipoAcao: TipoAcao.irParaPomodoro,
);

const _feynmanBase = MetodoEstudo(
  titulo: 'Técnica Feynman',
  tempo: '30 min',
  dificuldade: 'Médio',
  icone: Icons.record_voice_over_outlined,
  descricao:
      'Técnica de 4 etapas desenvolvida pelo físico Richard Feynman. Consiste em aprender explicando o conceito em voz alta com suas próprias palavras, como se estivesse ensinando alguém.',
  passos: [
    'Escolha um conceito',
    'Ensine o conteúdo em voz alta com palavras simples',
    'Identifique as lacunas e volte ao material de origem',
    'Reveja e simplifique a explicação',
  ],
  beneficios: ['Fixa o conteúdo profundamente', 'Identifica pontos fracos', 'Desenvolve a comunicação'],
  tipoAcao: TipoAcao.irParaFeynman,
);

const _leituraSavoring = MetodoEstudo(
  titulo: 'Leitura Savoring',
  tempo: '40 min',
  dificuldade: 'Fácil',
  icone: Icons.menu_book_outlined,
  descricao:
      'O estudante deve intercalar a leitura com pausas para reflexão e resumos pessoais, absorvendo o conteúdo de forma mais profunda.',
  passos: [
    'Escolha um texto ou capítulo relevante',
    'Leia um trecho de cada vez',
    'Pause e reflita sobre o que leu',
    'Anote suas reflexões com suas próprias palavras',
    'Faça um resumo pessoal ao final',
  ],
  beneficios: ['Aumenta a compreensão', 'Melhora o vocabulário', 'Desenvolve pensamento crítico'],
  tipoAcao: TipoAcao.irParaSavoring,
);

const _gruposEstudo = MetodoEstudo(
  titulo: 'Grupos de Estudo',
  tempo: '50 min',
  dificuldade: 'Médio',
  icone: Icons.group_outlined,
  descricao:
      'Estratégia feita para trocar conhecimento, esclarecer dúvidas e reforçar conceitos ao ensinar colegas, criando um local confortável para melhor aprendizagem.',
  passos: [
    'Forme um grupo de 3–5 pessoas',
    'Divida os temas entre os membros',
    'Cada um prepara sua parte',
    'Revezem as explicações',
    'Tirem dúvidas coletivamente',
  ],
  beneficios: ['Troca de conhecimento', 'Desenvolve habilidades sociais', 'Aprendizado colaborativo'],
  tipoAcao: TipoAcao.apenasInstrucoes,
);

const _flashcards = MetodoEstudo(
  titulo: 'Flashcards',
  tempo: '25 min',
  dificuldade: 'Fácil',
  icone: Icons.style_outlined,
  descricao:
      'Em pequenos cartões escreve-se a informação relevante à matéria — com uma pergunta de um lado e a resposta do outro, obtendo assim uma boa memorização do conteúdo.',
  passos: [
    'Escreva uma pergunta na frente do cartão',
    'Escreva a resposta no verso',
    'Teste-se diariamente',
    'Separe o que acertou do que errou',
    'Revise mais os que errou',
  ],
  beneficios: ['Memorização ativa', 'Revisão eficiente', 'Portabilidade'],
  tipoAcao: TipoAcao.irParaRevisao,
);

const _mnemonicaPalavras = MetodoEstudo(
  titulo: 'Mnemônica com Palavras, Poemas ou Músicas',
  tempo: '20 min',
  dificuldade: 'Fácil',
  icone: Icons.music_note_outlined,
  descricao:
      'Técnica de memorização que consiste em associações do conteúdo a palavras, siglas, rimas, poemas ou músicas para ajudar na memorização.',
  passos: [
    'Liste as informações a memorizar',
    'Crie uma sigla ou frase conectando os conceitos',
    'Ou transforme em uma música/paródia',
    'Repita várias vezes até fixar',
  ],
  beneficios: ['Memorização divertida', 'Criação de associações únicas', 'Retenção de longo prazo'],
  tipoAcao: TipoAcao.apenasInstrucoes,
);

const _repeticaoEspacada = MetodoEstudo(
  titulo: 'Repetição Espaçada',
  tempo: '15 min/dia',
  dificuldade: 'Médio',
  icone: Icons.repeat_outlined,
  descricao:
      'Ao invés de restringir o conteúdo, essa ferramenta sugere revisões periódicas ao longo do tempo para melhor aproveitamento. O espaçamento fica a critério do usuário.',
  passos: [
    'Dia 1: Estude o conteúdo',
    'Dia 2: Revisão rápida',
    'Dia 4: Revise pontos difíceis',
    'Dia 7: Teste seus conhecimentos',
    'Dia 15: Revisão final',
  ],
  beneficios: ['Revisão eficiente', 'Memorização duradoura', 'Otimização do tempo'],
  tipoAcao: TipoAcao.irParaRevisao,
);

const _cornell = MetodoEstudo(
  titulo: 'Método Cornell',
  tempo: '35 min',
  dificuldade: 'Médio',
  icone: Icons.view_column_outlined,
  descricao:
      'O indivíduo deve dividir a página em duas colunas: o lado esquerdo fica separado para as perguntas, e o lado direito são as respostas ou informações relevantes ao tema.',
  passos: [
    'Divida a página em duas colunas',
    'Coluna esquerda: escreva perguntas',
    'Coluna direita: anote respostas e informações',
    'Revise cobrindo o lado direito',
    'Responda as perguntas de memória',
  ],
  beneficios: ['Organização visual', 'Facilita autoavaliação', 'Material de revisão eficiente'],
  tipoAcao: TipoAcao.irParaCornell,
);

const _testePratico = MetodoEstudo(
  titulo: 'Teste Prático',
  tempo: '35 min',
  dificuldade: 'Médio',
  icone: Icons.assignment_outlined,
  descricao:
      'A ideia é resolver questões e simulados para se acostumar com o formato das provas e identificar pontos fracos.',
  passos: [
    'Selecione questões do tema estudado',
    'Resolva sem consultar o material',
    'Corrija e identifique os erros',
    'Refaça as questões que errou',
  ],
  beneficios: ['Prepara para avaliações', 'Identifica lacunas de aprendizado', 'Gera confiança'],
  tipoAcao: TipoAcao.irParaSimulado,
);

const _mnemonicaPoemas = MetodoEstudo(
  titulo: 'Mnemônica com Poemas ou Músicas',
  tempo: '20 min',
  dificuldade: 'Fácil',
  icone: Icons.queue_music_outlined,
  descricao:
      'Criar rimas, poemas curtos ou paródias musicais para memorizar fórmulas, regras gramaticais ou sequências.',
  passos: [
    'Identifique os itens chave',
    'Crie rimas com as palavras finais',
    'Cante ou recite o poema várias vezes',
    'Utilize o ritmo para puxar pela memória',
  ],
  beneficios: ['Memorização por ritmo', 'Facilidade de evocação', 'Torna o estudo leve'],
  tipoAcao: TipoAcao.apenasInstrucoes,
);

const _videosEducativos = MetodoEstudo(
  titulo: 'Estudo com Vídeos Educativos',
  tempo: '45 min',
  dificuldade: 'Fácil',
  icone: Icons.ondemand_video_outlined,
  descricao:
      'Assistir videoaulas com postura ativa: fazendo anotações, pausando para explicar a si mesmo e respondendo perguntas do vídeo.',
  passos: [
    'Escolha videoaulas confiáveis',
    'Assista com caderno em mãos',
    'Pause e faça anotações breves',
    'Ao final, faça um resumo de 3 frases',
  ],
  beneficios: ['Estímulo audiovisual', 'Explicativo e dinâmico', 'Ideal para conceitos complexos'],
  tipoAcao: TipoAcao.irParaVideos,
);

const _podcast = MetodoEstudo(
  titulo: 'Gravação de Podcast',
  tempo: '30 min',
  dificuldade: 'Médio',
  icone: Icons.mic_none_outlined,
  descricao:
      'Grave áudios resumindo a matéria com suas próprias palavras para ouvir durante deslocamentos e revisões rápidas.',
  passos: [
    'Estude o tema e crie um roteiro de tópicos',
    'Grave seu áudio explicando os tópicos',
    'Ouça a gravação no dia seguinte',
    'Avalie se a explicação ficou clara',
  ],
  beneficios: ['Estudo em movimento', 'Autoavaliação auditiva', 'Fortalece o aprendizado'],
  tipoAcao: TipoAcao.irParaPodcast,
);

const _mapaMental = MetodoEstudo(
  titulo: 'Mapa Mental',
  tempo: '40 min',
  dificuldade: 'Médio',
  icone: Icons.account_tree_outlined,
  descricao:
      'Diagrama radial conectando o tema central a ramificações de subtópicos com palavras-chave, cores e pequenos desenhos.',
  passos: [
    'Coloque o tema principal no centro',
    'Crie ramos para as ideias principais',
    'Adicione sub-ramos com detalhes',
    'Use cores diferentes e símbolos',
  ],
  beneficios: ['Visão holística', 'Estimula a criatividade', 'Excelente para revisão rápida'],
  tipoAcao: TipoAcao.irParaMapaMental,
);

const _mnemonicaNumeros = MetodoEstudo(
  titulo: 'Mnemônica com Números ou Listas Ordenadas',
  tempo: '20 min',
  dificuldade: 'Médio',
  icone: Icons.format_list_numbered_outlined,
  descricao:
      'Associe números a palavras rimadas ou forme histórias sequenciais para lembrar listas de dados ordenados.',
  passos: [
    'Associe cada número de 1 a 10 a um objeto',
    'Conecte o item da matéria ao objeto correspondente',
    'Visualize a cena de forma exagerada',
  ],
  beneficios: ['Guarda sequências exatas', 'Evita esquecer itens de listas', 'Agiliza a memória'],
  tipoAcao: TipoAcao.apenasInstrucoes,
);

const _diagramaFluxos = MetodoEstudo(
  titulo: 'Diagrama de Fluxos',
  tempo: '35 min',
  dificuldade: 'Médio',
  icone: Icons.schema_outlined,
  descricao:
      'Representação gráfica passo a passo de processos, algoritmos ou causas e efeitos de eventos históricos/científicos.',
  passos: [
    'Identifique o início e fim do processo',
    'Mapeie as etapas intermediárias',
    'Conecte as etapas com setas condicionais',
    'Valide a sequência lógica',
  ],
  beneficios: ['Clareza em processos', 'Pensamento sequencial', 'Identifica falhas lógicas'],
  tipoAcao: TipoAcao.irParaDiagramaFluxo,
);

const _mnemonicaImagens = MetodoEstudo(
  titulo: 'Mnemônica com Imagens e Objetos',
  tempo: '20 min',
  dificuldade: 'Fácil',
  icone: Icons.image_outlined,
  descricao:
      'Técnica do "Palácio da Memória" — vincular informações abstratas a objetos visuais familiares em seu quarto ou casa.',
  passos: [
    'Escolha um local familiar (ex: seu quarto)',
    'Associe cada informação a um móvel/objeto',
    'Faça um "passeio mental" pelo local para recordar',
  ],
  beneficios: ['Grande capacidade de retenção', 'Divertido e intuitivo', 'Memória espacial'],
  tipoAcao: TipoAcao.apenasInstrucoes,
);

const _mnemonicaMovimentos = MetodoEstudo(
  titulo: 'Mnemônica com Movimentos',
  tempo: '25 min',
  dificuldade: 'Fácil',
  icone: Icons.front_hand_outlined,
  descricao:
      'Atribuir gestos ou movimentação física a conceitos para utilizar a memória corporal durante o estudo.',
  passos: [
    'Crie um gesto específico para cada conceito',
    'Repita o gesto enquanto fala o conceito',
    'Faça a sequência de gestos para relembrar a matéria',
  ],
  beneficios: ['Ativa a memória corporal', 'Mantém o corpo engajado', 'Reduz o cansaço'],
  tipoAcao: TipoAcao.apenasInstrucoes,
);

const _pomodoroAtivo = MetodoEstudo(
  titulo: 'Pomodoro Ativo',
  tempo: '25 min',
  dificuldade: 'Fácil',
  icone: Icons.directions_run_outlined,
  descricao:
      'Variação do Pomodoro onde o descanso de 5 minutos obrigatoriamente inclui caminhada, alongamento ou polichinelos.',
  passos: [
    'Estude por 25 minutos focado',
    'Nos 5 minutos de pausa, levante da cadeira',
    'Faça alongamento ou caminhada rápida',
    'Volte renovado para o próximo ciclo',
  ],
  beneficios: ['Mantém o foco', 'Movimento no descanso', 'Aumenta a energia e produtividade'],
  tipoAcao: TipoAcao.irParaPomodoro,
);

// ===================== INTELIGÊNCIAS =====================

const List<InteligenicaInfo> todasInteligencias = [
  InteligenicaInfo(
    chave: 'linguistica',
    nome: 'Linguística',
    cor: Color(0xFF9f042c),
    icone: Icons.auto_stories_outlined,
    descricao: 'Você aprende melhor com palavras, leitura, escrita e comunicação.',
    metodos: [
      _pomodoroLinguistica,
      _feynmanBase,
      _leituraSavoring,
      _gruposEstudo,
      _flashcards,
      _mnemonicaPalavras,
      _repeticaoEspacada,
    ],
  ),
  InteligenicaInfo(
    chave: 'intrapessoal',
    nome: 'Intrapessoal',
    cor: Color(0xFF5170ff),
    icone: Icons.self_improvement_outlined,
    descricao: 'Você aprende melhor sozinho, com reflexão, autoanálise e estudos individuais.',
    metodos: [
      _pomodoroLinguistica,
      _feynmanBase,
      _cornell,
      _leituraSavoring,
      _repeticaoEspacada,
      _flashcards,
    ],
  ),
  InteligenicaInfo(
    chave: 'interpessoal',
    nome: 'Interpessoal',
    cor: Color(0xFFff5f00),
    icone: Icons.people_outline,
    descricao: 'Você aprende melhor com outras pessoas, em grupo, discutindo e colaborando.',
    metodos: [
      _pomodoroLinguistica,
      _feynmanBase,
      _testePratico,
      _mnemonicaPoemas,
      _videosEducativos,
      _repeticaoEspacada,
      _gruposEstudo,
    ],
  ),
  InteligenicaInfo(
    chave: 'musical',
    nome: 'Musical',
    cor: Color(0xFF8a03d2),
    icone: Icons.headphones_outlined,
    descricao: 'Você aprende melhor com ritmo, melodia, sons e músicas.',
    metodos: [
      _pomodoroLinguistica,
      _mnemonicaPoemas,
      _podcast,
      _videosEducativos,
      _repeticaoEspacada,
    ],
  ),
  InteligenicaInfo(
    chave: 'logico',
    nome: 'Lógico-Matemática',
    cor: Color(0xFFffbd59),
    icone: Icons.calculate_outlined,
    descricao: 'Você tem facilidade com números, padrões e raciocínio abstrato.',
    metodos: [
      _pomodoroLinguistica,
      _cornell,
      _mapaMental,
      _testePratico,
      _mnemonicaNumeros,
      _diagramaFluxos,
      _repeticaoEspacada,
    ],
  ),
  InteligenicaInfo(
    chave: 'espacial',
    nome: 'Espacial',
    cor: Color(0xFFd203a4),
    icone: Icons.view_in_ar_outlined,
    descricao: 'Você pensa em imagens e visualiza o mundo tridimensionalmente.',
    metodos: [
      _pomodoroLinguistica,
      _cornell,
      _mapaMental,
      _flashcards,
      _mnemonicaImagens,
      _diagramaFluxos,
      _repeticaoEspacada,
    ],
  ),
  InteligenicaInfo(
    chave: 'corporal',
    nome: 'Corporal-Cinestésica',
    cor: Color(0xFF00bf63),
    icone: Icons.directions_run_outlined,
    descricao: 'Você aprende melhor com movimento, prática e experiências hands-on.',
    metodos: [
      _pomodoroAtivo,
      _testePratico,
      _gruposEstudo,
      _mnemonicaMovimentos,
      _videosEducativos,
      _repeticaoEspacada,
      _flashcards,
    ],
  ),
];

Color getTextColorForBackground(Color bg) {
  return bg.computeLuminance() > 0.4 ? Colors.black87 : Colors.white;
}

Color getDificuldadeColor(String dificuldade, {bool isBackground = true}) {
  if (dificuldade.toLowerCase().contains('fácil') || dificuldade.toLowerCase().contains('facil')) {
    return isBackground ? const Color(0xFFdcfce7) : const Color(0xFF166534);
  } else if (dificuldade.toLowerCase().contains('médio') || dificuldade.toLowerCase().contains('medio')) {
    return isBackground ? const Color(0xFFfef3c7) : const Color(0xFF92400e);
  } else {
    return isBackground ? const Color(0xFFfee2e2) : const Color(0xFF991b1b);
  }
}

InteligenicaInfo getIntelligenceByDomName(String domName) {
  final cleanName = domName.toLowerCase().trim();
  for (var intel in todasInteligencias) {
    if (intel.nome.toLowerCase() == cleanName ||
        intel.chave.toLowerCase() == cleanName) {
      return intel;
    }
  }
  // Alternate checks (e.g., Corporal / Cinestésica, Lógico / Lógico-matemática)
  if (cleanName.contains('lógico') || cleanName.contains('logico')) {
    return todasInteligencias.firstWhere((i) => i.chave == 'logico');
  }
  if (cleanName.contains('corporal') || cleanName.contains('cinestésica') || cleanName.contains('cinestesica')) {
    return todasInteligencias.firstWhere((i) => i.chave == 'corporal');
  }
  if (cleanName.contains('lingua') || cleanName.contains('lingüí')) {
    return todasInteligencias.firstWhere((i) => i.chave == 'linguistica');
  }
  // Default fallback to Linguística
  return todasInteligencias.first;
}
