// =================================================================
// TABELA DE RECORDES
// Sobreposicao sobre o menu, como o_tela_controles e o_tela_nome: a tabela tem 480 px
// de altura e nao caberia sob o logo, cuja tinta desce ate y=400.
//
// DUAS FRENTES, e a primeira pagina e o ARCADE. Ele vem antes porque e o total do
// percurso inteiro — o numero que a feira compara — e porque so ele tem uma tabela,
// enquanto o Livre tem uma por arma.
//
// As duas nunca se misturam: o Arcade soma ate seis fases, entao um percurso mediano
// vale mais que a melhor partida solta de qualquer fase.
// =================================================================
total_fases = array_length(o_controlador_geral.fases_data);

// pagina 0 = Arcade; 1 em diante = uma arma cada
pagina = 0;
total_paginas = total_fases + 1;

PAINEL_LARGURA = 380;
PAINEL_ALTURA  = 480;
