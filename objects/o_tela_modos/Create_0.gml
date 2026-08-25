// =================================================================
// SELEÇÃO DE MODO
//
// Sobreposição sobre o menu, como o_tela_recordes e o_tela_controles. Não vale uma
// sala nova para duas linhas: o menu já sabe se calar quando existe sobreposição
// aberta, e a moldura e o logo são os mesmos.
//
// O modo Versus NÃO aparece aqui enquanto não existir. Item de menu que não responde
// lê como defeito do jogo, e numa feira ninguém para para descobrir que era promessa.
// =================================================================
opcoes = ["Modo Arcade", "Modo Livre"];

// Uma linha por modo, abaixo do painel. O jogador de feira decide em dois segundos,
// olhando de pé — a diferença entre os modos precisa caber numa frase.
descricoes = [
    "As " + string(ARCADE_TOTAL_FASES) + " armas em sequência, pontos somando.",
    "Escolha a arma e forje sem pressa."
];

opcao_selecionada = 0;

PAINEL_LARGURA = 340;
