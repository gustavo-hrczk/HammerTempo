/// scr_jogador — o estado que pertence a UM jogador.
///
/// Pontuação, combo, acertos e erros eram variáveis soltas em o_controlador_geral, o
/// que funcionou enquanto existia um jogador só. O Versus obriga a separá-las: dois
/// jogadores dividem a tela, a música e o teclado, mas nada da pontuação de um pode
/// vazar para o outro.
///
/// A escolha aqui foi UMA fonte de verdade, e não espelhamento. A alternativa — deixar
/// as variáveis antigas valendo para o jogador 1 e criar um struct paralelo para o 2 —
/// seria menos invasiva agora e viraria dois lugares para atualizar em toda mudança
/// futura, com a garantia de que um dia eles discordariam.
///
/// Fora do Versus só existe o jogador 0, e `jogador()` sem argumento devolve ele — o
/// código de um jogador continua lendo como código de um jogador.

/// Quantos jogadores o jogo comporta. Só o Versus usa os dois.
#macro JOGADORES_MAX 2

function EstadoJogador() constructor {
    pontuacao = 0;

    stats_total_notas = 0;
    stats_acertos_perfeitos = 0;
    stats_acertos_otimos = 0;
    stats_acertos_bons = 0;
    stats_erros = 0;

    // combo em curso e a contagem que leva ao game over
    stats_sequencia = 0;
    stats_sequencia_errada = 0;

    // toque sem nota alcançável: custa pontos, não encerra a fase (GP-04)
    stats_toques_invalidos = 0;

    /// Zera tudo para o começo de uma fase.
    static reiniciar = function() {
        pontuacao = 0;
        stats_total_notas = 0;
        stats_acertos_perfeitos = 0;
        stats_acertos_otimos = 0;
        stats_acertos_bons = 0;
        stats_erros = 0;
        stats_sequencia = 0;
        stats_sequencia_errada = 0;
        stats_toques_invalidos = 0;
    }

    /// Quantas notas o jogador acertou, em qualquer qualidade.
    static acertos = function() {
        return stats_acertos_perfeitos + stats_acertos_otimos + stats_acertos_bons;
    }

    /// Notas efetivamente JULGADAS — acertos mais erros.
    ///
    /// Diferente de stats_total_notas, que conta tudo o que foi gerado: no fim da fase
    /// pode haver nota ainda em voo, e é por isso que a precisão e o nível da arma têm
    /// denominadores diferentes (ver icone_nivel_por_precisao).
    static julgadas = function() {
        return acertos() + stats_erros;
    }

    /// Precisão em porcentagem, sobre as notas julgadas.
    static precisao = function() {
        var _j = julgadas();
        return (_j > 0) ? ((acertos() / _j) * 100) : 0;
    }
}

/// Estado de um jogador.
///
/// Sem argumento devolve o jogador ATIVO do modo solo — que é o 1 na esmagadora
/// maioria das vezes, mas pode ser o 2 quando ele inicia uma partida sozinho. Todo o
/// gameplay passa o índice explicitamente; quem omite são as telas de um jogador, e
/// para elas "o jogador" é exatamente esse.
function jogador(_n = undefined) {
    if (is_undefined(_n)) _n = solo_jogador();
    return o_controlador_geral.jogadores[_n];
}

// =====================================================================
// QUEM PERTENCE A QUEM
//
// Ferreiro, bigorna e alvos deixaram de ser instancia unica. Todo objeto de gameplay
// carrega um `dono` — 0 para o jogador 1, 1 para o 2 — e os efeitos de um nunca
// alcancam o outro.
//
// Fora do Versus so existe o dono 0, e as funcoes abaixo devolvem a unica instancia
// que existe. E por isso que o codigo de um jogador nao precisou aprender nada novo.
// =====================================================================

/// O ferreiro de um jogador, ou noone.
function ferreiro_de(_dono = 0) {
    with (o_ferreiro) {
        if (dono == _dono) return id;
    }
    return noone;
}

/// A bigorna de um jogador, ou noone.
function bigorna_de(_dono = 0) {
    with (o_bigorna) {
        if (dono == _dono) return id;
    }
    return noone;
}

// =====================================================================
// MONTAGEM DA CENA
//
// A sala rm_forja e montada para UM jogador, com o ferreiro e a bigorna no centro. O
// Versus reaproveita a mesma sala e reposiciona: o jogador 1 recua para a esquerda e o
// jogador 2 nasce a direita, os dois virados um para o outro, com a forja ao fundo
// entre eles.
//
// Feito em codigo e nao numa sala propria porque quase tudo e igual — cenario, fundo,
// HUD, controlador. Uma segunda sala seria uma copia que precisaria ser mantida em
// paralelo para sempre.
// =====================================================================

/// X da bigorna de cada jogador no Versus.
///
/// Espelhar a posicao original (619) em torno do centro poria as duas bigornas em 619
/// e 661 — encostadas. Os dois lados precisam recuar de verdade, e 330/950 da 620 px
/// de separacao mantendo a construcao da forja visivel no meio.
#macro VERSUS_BIGORNA_P1 330
#macro VERSUS_BIGORNA_P2 950

/// Distancia entre a bigorna e o ferreiro, preservada da cena original (661 - 619).
#macro VERSUS_VAO_FERREIRO 42

/// Passa a cena de um jogador para o jogador 2.
///
/// Quando o jogador 2 inicia uma partida sozinho, nada de layout muda — ele joga no
/// enquadramento de sempre, que ja esta validado. O que muda e de quem sao o ferreiro,
/// a bigorna e os alvos que a sala criou, e a paleta que o ferreiro veste.
function solo_adotar_dono(_dono) {
    with (o_ferreiro)      { dono = _dono; adotar_sprites(); }
    with (o_bigorna)         dono = _dono;
    with (o_buttons_forja)   dono = _dono;
    with (o_fundo_ui)        dono = _dono;
}

/// Reposiciona o jogador 1 e cria o jogador 2. Idempotente.
function versus_montar_cena() {
    if (!versus_ativo()) return;

    var _b1 = bigorna_de(0);
    var _f1 = ferreiro_de(0);
    if (_b1 == noone || _f1 == noone) return;

    // ja montado?
    if (bigorna_de(1) != noone) return;

    var _y_bigorna = _b1.y;
    var _y_ferreiro = _f1.y;

    _b1.x = VERSUS_BIGORNA_P1;
    _f1.x = VERSUS_BIGORNA_P1 + VERSUS_VAO_FERREIRO;
    _f1.home_x = _f1.x;

    var _b2 = instance_create_layer(VERSUS_BIGORNA_P2, _y_bigorna, "Gameplay", o_bigorna);
    _b2.dono = 1;

    // O ferreiro 2 fica do outro lado da propria bigorna: a cena inteira dele e o
    // espelho da do jogador 1.
    var _f2 = instance_create_layer(VERSUS_BIGORNA_P2 - VERSUS_VAO_FERREIRO,
                                    _y_ferreiro, "Gameplay", o_ferreiro);
    _f2.dono = 1;
    _f2.home_x = _f2.x;

    // o conjunto de sprites foi montado no Create com dono 0; agora que ele sabe quem
    // e, remonta com a paleta e o espelho certos
    with (_f2) adotar_sprites();

    // Alvos e corredor do jogador 2, no topo da tela.
    var _linha2 = ritmo_linha_x(1);
    for (var _t = 0; _t < 4; _t++) {
        var _a = instance_create_layer(_linha2, ritmo_lane_y(_t, 1), "Gameplay", o_buttons_forja);
        _a.dono = 1;
        _a.meu_tipo = _t;
        _a.sprite_index = ritmo_sprite_alvo(_t);
    }

    var _fundo2 = instance_create_layer(0, RITMO_CORREDOR_P2, "Gameplay", o_fundo_ui);
    _fundo2.dono = 1;
    _fundo2.image_yscale = -1;   // a moldura do corredor aponta para dentro da tela
}

/// Desfaz a montagem, devolvendo a cena de um jogador.
function versus_desmontar_cena() {
    with (o_bigorna)       { if (dono == 1) instance_destroy(); }
    with (o_ferreiro)      { if (dono == 1) instance_destroy(); }
    with (o_buttons_forja) { if (dono == 1) instance_destroy(); }
    with (o_fundo_ui)      { if (dono == 1) instance_destroy(); }
    with (o_nota_seta)     { if (dono == 1) instance_destroy(); }
}
