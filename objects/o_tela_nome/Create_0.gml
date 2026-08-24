// =================================================================
// ENTRADA DE INICIAIS
// Três letras por direcional, que é o que funciona igual em teclado e em alavanca de
// arcade — foi por isso que o formato de 3 letras foi escolhido na D-52, e não por
// nostalgia.
// =================================================================
letras = array_create(PLACAR_NOME_TAMANHO, 0);   // índices em PLACAR_LETRAS
cursor = 0;

posicao_prevista = placar_posicao(o_controlador_geral.fase_atual,
                                  o_controlador_geral.pontuacao);

// Precisão pela mesma conta da tela de resultado, para os dois números baterem.
var _p = o_controlador_geral.stats_acertos_perfeitos;
var _o = o_controlador_geral.stats_acertos_otimos;
var _b = o_controlador_geral.stats_acertos_bons;
var _julgadas = _p + _o + _b + o_controlador_geral.stats_erros;

precisao = (_julgadas > 0) ? (((_p + _o + _b) / _julgadas) * 100) : 0;

// Numa feira ninguém fica olhando uma tela parada: se o jogador saiu do gabinete no
// meio da digitação, o placar grava sozinho e a máquina volta a ficar disponível.
espera = room_speed * 25;

PAINEL_LARGURA = 420;

/// Grava e sai.
confirmar = function() {
    var _nome = "";
    for (var i = 0; i < PLACAR_NOME_TAMANHO; i++) {
        _nome += placar_letra(letras[i]);
    }

    placar_registrar(o_controlador_geral.fase_atual,
                     _nome,
                     o_controlador_geral.pontuacao,
                     precisao);

    instance_destroy();
}
