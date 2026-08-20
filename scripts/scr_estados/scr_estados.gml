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
    IN,   // de preto para transparente (revelando a sala)
    OUT,  // de transparente para preto (escondendo a sala)
    IDLE  // nenhuma transição ativa
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
