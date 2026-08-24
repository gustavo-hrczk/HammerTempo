// Pega o número total de fases que definimos no controlador
opcoes_fase = o_controlador_geral.fases_data;
total_opcoes = array_length(opcoes_fase);

// Começa selecionando a primeira fase (índice 0)
opcao_selecionada = 0;

// =================================================================
// PAGINACAO
// Cabem tres cartoes de 360 px numa tela de 1280. Com a quarta fase, o quarto cartao
// nascia em x=1360 — fora da tela. Em vez de espremer os cartoes, a lista pagina: o
// direcional passa de pagina ao cruzar a borda, sem tecla nova para aprender.
// =================================================================
POR_PAGINA = 3;
total_paginas = ceil(total_opcoes / POR_PAGINA);
