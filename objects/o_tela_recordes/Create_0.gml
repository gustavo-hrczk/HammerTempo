// =================================================================
// TABELA DE RECORDES
// Sobreposicao sobre o menu, como o_tela_controles e o_tela_nome: a tabela tem 480 px
// de altura e nao caberia sob o logo, cuja tinta desce ate y=400.
//
// So a frente LIVRE por enquanto. A frente Arcade grava o total do percurso inteiro
// (D-52) e entra aqui quando o modo existir, como uma segunda aba.
// =================================================================
fase_exibida = 0;
total_fases = array_length(o_controlador_geral.fases_data);

PAINEL_LARGURA = 380;
PAINEL_ALTURA  = 480;
