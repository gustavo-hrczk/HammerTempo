/// scr_estados — enums globais do jogo
/// Antes viviam dentro de eventos Create espalhados; centralizados aqui para que
/// nenhum objeto precise depender da ordem de criação para conhecer um estado.

/// Estados do fluxo principal do jogo.
/// Os valores são consultados por vários objetos: NUNCA reordene esta lista,
/// sempre acrescente estados novos no final.
enum MINIGAME {
    NENHUM,
    SELECAO_FASE,
    TUTORIAL,
    CONTAGEM,
    RITMO,
    TEMPERA,   // reservado — minigame não implementado
    AFIACAO,   // reservado — minigame não implementado
    RESULTADO
}

/// Estados do fade universal (o_transicao).
enum FADE {
    IN,     // de preto para transparente (revelando a sala)
    OUT,    // de transparente para preto (escondendo a sala)
    IDLE,   // nenhuma transição ativa
    ESPERA  // tela preta parada, o "respiro" entre uma sala e outra
}

/// Estados de animação do ferreiro (o_ferreiro).
enum FERREIRO_ESTADO {
    IDLE,
    MARTELANDO,
    COMEMORANDO,
    FALHA,
    FALHOU_ESTATICO,
    DANO,      // frame vermelho ao perder uma nota
    ANDANDO    // passeia pela forja fora da partida
}

/// Modo de jogo escolhido antes de entrar na forja.
///
/// LIVRE  — o jogador escolhe a arma e joga uma fase de cada vez. E o modo original.
/// ARCADE — percurso unico pelas fases em ordem, com a pontuacao acumulando. Falhar
///          encerra o percurso, e o total vai para um ranking global.
///
/// Os valores vao para o save (leaderboard.livre e leaderboard.arcade), entao NUNCA
/// reordene: acrescente no final.
enum MODO {
    LIVRE,
    ARCADE,
    VERSUS
}

// =================================================================
// AJUSTES DO MODO ARCADE
//
// Estes dois numeros existem para serem mexidos NA FEIRA, sem precisar entender o
// resto do codigo.
// =================================================================

/// Quantas fases tem um percurso Arcade, contadas do inicio da lista.
///
/// Com as seis, o percurso vai de ~23 s (quem falha na Adaga) a 5min48 (quem completa).
/// A media esperada fica perto de 3 min, porque falhar encerra e o gabinete se libera
/// sozinho — o maximo e pago so por quem chega na Espada, que e quem junta plateia.
///
/// SE A FILA TRAVAR NO DIA: baixar para 3 corta o percurso para ~2min30. E o unico
/// ajuste necessario, nada mais depende deste numero.
#macro ARCADE_TOTAL_FASES 6

/// A primeira fase do percurso nao pode dar game over.
///
/// A Adaga falha com 4 notas perdidas em sequencia, o que a 2,25 notas/s sao 1,8
/// segundo sem acertar nada — quem nunca jogou faz isso nos primeiros cinco segundos
/// e seria ejetado em vinte, sem ter jogado. A primeira fase E a rampa de aprendizado
/// do percurso, entao ela nao expulsa ninguem.
#macro ARCADE_PRIMEIRA_IMUNE true

/// O tutorial reaparece a cada percurso Arcade.
///
/// tutorial_ja_foi_visto guarda a SESSAO inteira, o que serve para quem joga em casa e
/// atrapalha na feira: ali cada partida e um visitante novo, que alem de nao conhecer
/// o jogo nao conhece os botoes do gabinete. No Modo Livre o comportamento continua
/// sendo uma vez por sessao.
///
/// Custa ~25 s por percurso. Se a fila apertar, este e o primeiro a desligar.
#macro ARCADE_SEMPRE_TUTORIAL true


/// O gameplay esta congelado por alguma tela aberta por cima dele?
///
/// Existem DUAS telas que param a partida sem trocar de estado: o menu de pausa e o
/// intervalo do percurso Arcade. Nos dois casos o estado continua sendo RITMO, entao
/// quem checa so o estado continua rodando por baixo.
///
/// Foi assim que o intervalo virou defeito critico: o menu e navegado com o
/// direcional, que sao as MESMAS teclas das faixas da forja, entao cada movimento do
/// cursor entrava como martelada invalida e custava pontos ao jogador enquanto ele
/// decidia se queria continuar.
///
/// Toda checagem de "posso agir?" no gameplay passa a ser esta funcao, e nao
/// `o_controlador_geral.pausa` — uma tela nova que congele a partida so precisa
/// entrar aqui.
function gameplay_congelado() {
    if (!instance_exists(o_controlador_geral)) {
        return true;
    }
    return o_controlador_geral.pausa || instance_exists(o_tela_intervalo);
}


/// A partida corrente e de dois jogadores?
///
/// Consultada em todo lugar que hoje assume um jogador so. Ler o modo direto
/// espalharia a comparacao por dezenas de arquivos, e o dia em que o Versus ganhasse
/// uma variante nenhum deles saberia.
function versus_ativo() {
    return instance_exists(o_controlador_geral)
        && o_controlador_geral.modo_jogo == MODO.VERSUS;
}

/// Quantos jogadores estao em jogo agora.
function jogadores_em_jogo() {
    return versus_ativo() ? 2 : 1;
}

/// Quais jogadores estao em jogo, por indice.
///
/// No solo NAO e sempre [0]: o jogador 2 pode iniciar uma partida sozinho, e nesse
/// caso ele joga com a propria arte, as proprias teclas e o proprio placar — no
/// layout de um jogador, que ja esta validado. Dar autonomia a ele exigia que o jogo
/// soubesse QUEM joga, e nao so quantos.
function jogadores_ativos() {
    if (versus_ativo()) return [0, 1];
    return [solo_jogador()];
}

/// Indice do jogador que esta jogando sozinho. Zero fora do caso acima.
///
/// Chama-se solo_jogador e nao solo_dono porque o controlador tem uma VARIAVEL com
/// esse nome, e o GML nao admite funcao e variavel homonimas.
function solo_jogador() {
    if (!instance_exists(o_controlador_geral)) return 0;
    return o_controlador_geral.solo_dono;
}

// =================================================================
// ALTERNANCIA DO VERSUS
//
// A partida nao e os dois jogando o tempo todo. Ela alterna: um trecho so do jogador
// 1, um trecho so do jogador 2, um trecho dos dois — e volta.
//
// Isto e uma REGRA DE AGENDAMENTO, e nao autoria musical. Nao ha marcacao de compasso
// na faixa dizendo de quem e cada trecho: o que existe e um ciclo de tempo, e o
// spawner pergunta a cada nota se aquele jogador esta recebendo agora.
//
// O ciclo e proposital nesta ordem — solo, solo, juntos. Comecar pelos solos deixa
// cada um entender a propria pista antes de ter o outro martelando ao lado, e o
// trecho de ambos vira o climax do ciclo em vez do estado normal.
// =================================================================

/// Duracao ALVO de cada estrofe solo, em segundos. O valor real e ajustado para as
/// estrofes fecharem exatamente no terco da fase.
#macro VERSUS_ESTROFE 4.5

/// Quanto da fase e disputado em estrofes alternadas. O resto e tocado pelos dois.
///
/// Dois tercos alternando, um terco junto. Ficar oito segundos sem receber nota era
/// tempo demais parado numa partida de menos de um minuto — o jogador desengajava
/// justamente quando devia estar disputando. Estrofes curtas mantem os dois no jogo, e
/// o terco final junto vira o climax em vez de mais um trecho igual aos outros.
#macro VERSUS_FRACAO_ALTERNADA (2 / 3)

/// Quantas estrofes alternadas a fase tem. SEMPRE PAR, para os dois jogadores ficarem
/// com a mesma quantidade de solos.
function versus_estrofes() {
    if (!instance_exists(o_spawner_ritmo)) return 2;

    var _sp = o_spawner_ritmo;
    var _alternadas = _sp.notas_totais * VERSUS_FRACAO_ALTERNADA;

    // notas por estrofe, mirando VERSUS_ESTROFE segundos
    var _por_seg = (_sp.duracao_total / room_speed);
    var _densidade = (_por_seg > 0) ? (_sp.notas_totais / _por_seg) : 2;

    var _n = max(2, round(_alternadas / max(1, VERSUS_ESTROFE * _densidade)));
    if (_n mod 2 == 1) _n++;

    return _n;
}

/// Este jogador esta recebendo esta nota?
///
/// A divisao e por INDICE DE NOTA, e nao por tempo. Dividir por tempo parecia justo e
/// nao e: os motivos tem densidade irregular, entao trechos de igual duracao entregam
/// quantidades diferentes de nota — foi o que apareceu no Florete, com um jogador
/// recebendo bem mais que o outro numa fase em que ninguem errou.
///
/// Contando nota, a conta fecha por construcao: as estrofes dividem exatamente as duas
/// primeiras tercas partes, e o ultimo terco vai inteiro para os dois.
function versus_recebe_nota(_dono, _indice = 0) {
    if (!versus_ativo()) {
        return (_dono == solo_jogador());
    }

    if (!instance_exists(o_spawner_ritmo)) return (_dono == 0);

    var _total = o_spawner_ritmo.notas_totais;
    if (_total <= 0) return true;

    // O TRECHO ALTERNADO E ARREDONDADO PARA BAIXO ATE FECHAR NAS ESTROFES.
    //
    // Sem isso a ultima estrofe fica com uma nota a mais ou a menos que as outras, e
    // como as estrofes se alternam entre os dois, essa sobra cai sempre no mesmo
    // jogador. Com 78 notas eram quatro de diferenca. Cortando o resto para o terco
    // final — que os dois tocam junto — a divisao fecha exata.
    var _n = versus_estrofes();
    var _tamanho = floor((_total * VERSUS_FRACAO_ALTERNADA) / _n);
    var _alternadas = _tamanho * _n;

    // TERCO FINAL: os dois tocam.
    if (_indice >= _alternadas) return true;

    // ESTROFES ALTERNADAS, comecando no jogador 1.
    var _estrofe = floor(_indice / max(1, _tamanho));

    return ((_estrofe mod 2) == _dono);
}

/// Em que trecho a partida esta: 0 solo do 1, 1 solo do 2, 2 os dois.
function versus_trecho() {
    var _i = instance_exists(o_spawner_ritmo) ? o_spawner_ritmo.notas_criadas : 0;

    if (versus_recebe_nota(0, _i) && versus_recebe_nota(1, _i)) return 2;
    return versus_recebe_nota(1, _i) ? 1 : 0;
}

/// Rotulo do trecho atual, para a tela mostrar de quem e a vez.
function versus_rotulo_trecho() {
    switch (versus_trecho()) {
        case 0: return "VEZ DO JOGADOR 1";
        case 1: return "VEZ DO JOGADOR 2";
    }
    return "OS DOIS!";
}
