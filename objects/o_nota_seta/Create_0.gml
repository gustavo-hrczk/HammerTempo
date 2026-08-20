velocidade = 5;
tipo_seta = 0;
image_speed = 0;
escala = 1;

// 0 = viva, 1 = absorvida pelo alvo (acerto), 2 = perdida (erro)
modo = 0;

/// Acerto: a nota estoura como uma bolha — cresce rápido enquanto some, no lugar
/// onde foi acertada. Substitui a absorção, que ficou apagada demais.
estourar = function(_cor = c_white) {
    if (modo != 0) exit;
    modo = 1;
    velocidade = 0;
    image_blend = _cor;
}

/// Nota perdida: contabiliza o erro uma única vez e sai de cena em vermelho.
registrar_erro = function() {
    if (modo != 0) exit;
    modo = 2;
    image_blend = c_red;

    o_controlador_geral.stats_erros++;
    o_controlador_geral.pontuacao = max(0, o_controlador_geral.pontuacao - 50);
    o_controlador_geral.stats_sequencia_errada++;
    o_controlador_geral.stats_sequencia = 0;

    if (instance_exists(o_ferreiro)) {
        o_ferreiro.aplicar_dano();
    }

    hud_registrar_julgamento("ERRO", make_colour_rgb(235, 95, 75), false);
}
