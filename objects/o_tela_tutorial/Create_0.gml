// =================================================================
// TESTE DE TECLAS
// As quatro faixas na MESMA ordem de cima para baixo em que aparecem na partida
// (rm_forja: y 515, 565, 615, 665). Antes o tutorial as mostrava lado a lado, na
// horizontal, o que ensinava uma leitura que o jogo não usa.
// =================================================================
// Qual conjunto de teclas o tutorial ensina.
//
// No Versus ele ensina os DOIS: cada jogador precisa encontrar as proprias teclas
// antes da partida, e no gabinete eles dividem o mesmo teclado — quem nao souber qual
// metade e a sua descobre errando durante a fase.
//
// Fora do Versus so existe o jogador 1, e o tutorial le exatamente como antes.
// Fora do Versus o tutorial ensina as teclas de QUEM ESTA JOGANDO. Estava fixo no
// jogador 1: o jogador 2 abria o tutorial, via as teclas do outro e nao conseguia
// acionar nenhum dos quatro alvos — a tela que existe para ele achar os proprios
// botoes era justamente a que nao respondia a eles.
lane_dono = solo_jogador();

lane_acao = [input_lane(lane_dono, 1), input_lane(lane_dono, 3),
             input_lane(lane_dono, 2), input_lane(lane_dono, 0)]
lane_sprite = [s_alvo_cima,    s_alvo_esquerda, s_alvo_direita, s_alvo_baixo];

// O rótulo NÃO é escrito na unha: vem de input_nome_da_acao(), que lê o vínculo em
// vigor. Assim que houver remapeamento — e no gabinete vai haver — a tela acompanha
// sozinha em vez de continuar prometendo W A D S.

// Estado visual de cada alvo, com o mesmo comportamento de o_buttons_forja: o alvo
// percorre os quadros enquanto a tecla está pressionada, afunda no toque e volta.
lane_frame  = [0, 0, 0, 0];
lane_afunda = [0, 0, 0, 0];
lane_pop    = [0, 0, 0, 0];


/// Troca o tutorial para o outro jogador. Só o Versus usa.
trocar_de_jogador = function() {
    lane_dono = 1 - lane_dono;
    lane_acao = [input_lane(lane_dono, 1), input_lane(lane_dono, 3),
                 input_lane(lane_dono, 2), input_lane(lane_dono, 0)];

    for (var i = 0; i < 4; i++) {
        lane_afunda[i] = 0;
    }
};
