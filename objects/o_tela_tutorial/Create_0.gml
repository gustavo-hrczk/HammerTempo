// =================================================================
// TESTE DE TECLAS
// As quatro faixas na MESMA ordem de cima para baixo em que aparecem na partida
// (rm_forja: y 515, 565, 615, 665). Antes o tutorial as mostrava lado a lado, na
// horizontal, o que ensinava uma leitura que o jogo não usa.
// =================================================================
lane_acao   = [ACAO.LANE_CIMA, ACAO.LANE_ESQ,   ACAO.LANE_DIR,  ACAO.LANE_BAIXO];
lane_sprite = [s_alvo_cima,    s_alvo_esquerda, s_alvo_direita, s_alvo_baixo];

// O rótulo NÃO é escrito na unha: vem de input_nome_da_acao(), que lê o vínculo em
// vigor. Assim que houver remapeamento — e no gabinete vai haver — a tela acompanha
// sozinha em vez de continuar prometendo W A D S.

// Estado visual de cada alvo, com o mesmo comportamento de o_buttons_forja: o alvo
// percorre os quadros enquanto a tecla está pressionada, afunda no toque e volta.
lane_frame  = [0, 0, 0, 0];
lane_afunda = [0, 0, 0, 0];
lane_pop    = [0, 0, 0, 0];
