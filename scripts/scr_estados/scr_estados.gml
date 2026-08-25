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
    ARCADE
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
