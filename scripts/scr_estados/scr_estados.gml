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
