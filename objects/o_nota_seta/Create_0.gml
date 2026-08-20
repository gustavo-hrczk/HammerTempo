velocidade = 5;
tipo_seta = 0;
image_speed = 0;
esta_morrendo = false;
sobe_ao_morrer = false;

// Função para iniciar o fade final
iniciar_fade_final = function(cor, _deve_subir) {
    if (esta_morrendo == false) {
        esta_morrendo = true;
        image_blend = cor;
        sobe_ao_morrer = _deve_subir;
        if (_deve_subir) {
            velocidade = 0;
        }
    }
}

// Nota perdida: contabiliza o erro uma única vez.
registrar_erro = function() {
    if (esta_morrendo) exit;

    o_controlador_geral.stats_erros++;
    o_controlador_geral.pontuacao = max(0, o_controlador_geral.pontuacao - 50);
    o_controlador_geral.stats_sequencia_errada++;
    o_controlador_geral.stats_sequencia = 0;

    if (instance_exists(o_ferreiro)) {
        o_ferreiro.aplicar_shade_erro();
    }

    iniciar_fade_final(c_red, false);
}
