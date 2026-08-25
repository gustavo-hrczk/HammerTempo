// =================================================================
// SELEÇÃO DE MODO — sala própria (rm_modos)
//
// Começou como sobreposição sobre o menu, no padrão de o_tela_recordes, e não deu
// certo: o painel do menu ficava aparecendo por trás e a descrição caía por cima de
// "Sair do Jogo". Virou sala, como rm_opcoes — mesma logo, mesma moldura, mesmos
// itens, então a troca não desloca nem repinta nada.
//
// O Versus divide a mesma forja e a mesma faixa entre dois jogadores. Ele usa as
// mesmas armas do Modo Livre e a mesma tela de seleção — o que muda é quem está do
// outro lado da bigorna.
// =================================================================
opcoes_menu = ["Modo Arcade", "Modo Livre", "Modo Versus", "Voltar"];

// Uma linha por modo, abaixo da moldura. O jogador de feira decide de pé, em dois
// segundos: a diferença entre os modos precisa caber numa frase.
//
// "Voltar" não tem descrição — o rótulo já se explica, e uma linha vazia embaixo dele
// faria a área piscar ao passar o cursor.
descricoes = [
    "As " + string(ARCADE_TOTAL_FASES) + " armas em sequência, pontos somando.",
    "Escolha a arma e forje sem pressa.",
    "Dois na mesma forja. WASD contra as setas.",
    ""
];

opcao_selecionada = 0;
