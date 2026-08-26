// =================================================================
// TELA DE CONTROLES
// Sobreposta à tela de opções, no padrão de o_tela_tutorial: evita uma room nova
// para uma tela que só existe enquanto está aberta.
// =================================================================
// DUAS PAGINAS: as sete acoes do jogador 1 e as quatro faixas do jogador 2. Onze
// linhas nao cabem na moldura, e quem esta configurando um jogador raramente quer o
// outro na mesma tela. Os LADOS trocam de pagina, como na tela de recordes.
pagina = 0;

acoes_por_pagina = [input_acoes_configuraveis(), input_acoes_configuraveis_p2()];
// Titulos CURTOS: "CONTROLES - JOGADOR 2" media mais que a largura da moldura e
// vazava pelos dois lados, junto com as setas de pagina.
titulos_pagina = ["CONTROLES  P1", "CONTROLES  P2"];

acoes = acoes_por_pagina[pagina];

/// Troca de pagina e recalcula o que a tela mostra.
ir_para_pagina = function(_p) {
    pagina = (_p + array_length(acoes_por_pagina)) mod array_length(acoes_por_pagina);
    acoes = acoes_por_pagina[pagina];

    LINHA_RESTAURAR = array_length(acoes);
    total_linhas = LINHA_RESTAURAR + 1;

    // a pagina do jogador 2 e mais curta: o cursor nao pode ficar fora dela
    opcao_selecionada = min(opcao_selecionada, LINHA_RESTAURAR);
};

// A ultima linha da lista nao e uma acao: e o "Restaurar padrao", que precisa estar
// aqui porque um vinculo mal escolhido pode deixar o jogo sem como responder — e no
// gabinete nao ha teclado para socorrer.
LINHA_RESTAURAR = array_length(acoes);
total_linhas = LINHA_RESTAURAR + 1;

opcao_selecionada = 0;
capturando = false;

// Uma TABELA precisa de mais largura que um menu: "Confirmar / BOTÃO 1" mede 242 px
// e o vão do padrão é de 205. O painel também sobe, porque sete linhas descem mais
// do que as cinco das opções.
PAINEL_LARGURA = 360;
ITEM_LARGURA   = 340;

// Sem logo, e por medida: a tinta dele desce ate y=400 na tela, e o painel das
// opcoes so nao a corta porque comeca em 367 e cobre o resto. Sete linhas mais o
// titulo formam 400 px de painel, que embaixo do logo terminariam fora da tela.
// Esta e uma sobreposicao, como o_tela_tutorial, entao o titulo vai dentro do painel.
PAINEL_OFFSET  = 20;
