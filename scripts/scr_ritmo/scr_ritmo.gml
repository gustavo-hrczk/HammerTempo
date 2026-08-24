/// scr_ritmo — julgamento de acerto por TEMPO
///
/// Até a Sprint 1 o julgamento era espacial: a nota precisava sobrepor um sprite de
/// 2 px de largura, o que dava uma janela de "perfeito" de ~1 frame e criava faixas
/// mortas em que a tecla certa não valia nada.
///
/// Agora o erro é medido em frames (e, por consequência, em milissegundos), usando a
/// velocidade da própria nota. A exigência passa a ser idêntica em todas as fases,
/// independentemente da velocidade visual das notas.

/// Posição X da linha de acerto (mesma X das instâncias de o_buttons_forja em rm_forja).
#macro RITMO_LINHA_X 98

/// Janelas de julgamento, em frames a 60 fps.
/// Três faixas: o "perfeito" antigo (+-50 ms) saía com frequência alta demais para
/// quem já pegou o ritmo, então virou o intervalo do "ótimo" e o perfeito apertou.
#macro RITMO_JANELA_PERFEITO 2     // +-33 ms
#macro RITMO_JANELA_OTIMO    4.5   // +-75 ms
#macro RITMO_JANELA_BOM      8     // +-133 ms

/// Resultado possível de uma tentativa de acerto.
enum JULGAMENTO {
    NENHUM,   // não havia nota alcançável
    PERFEITO,
    OTIMO,
    BOM
}

/// Erro de tempo de uma nota, em frames.
/// Positivo = adiantado (a nota ainda não chegou), negativo = atrasado.
function ritmo_erro_frames(_nota) {
    if (_nota.velocidade <= 0) return 0;
    return (_nota.x - RITMO_LINHA_X) / _nota.velocidade;
}

/// Converte frames em milissegundos, respeitando o game speed configurado.
function ritmo_frames_ms(_frames) {
    return (_frames / game_get_speed(gamespeed_fps)) * 1000;
}

/// Nota viva do tipo pedido cujo erro de tempo é o menor.
/// Retorna noone se não houver nenhuma dentro da janela de acerto.
function ritmo_nota_alcancavel(_tipo) {
    var _melhor = noone;
    var _menor_erro = RITMO_JANELA_BOM + 1;

    with (o_nota_seta) {
        if (modo != 0 || tipo_seta != _tipo) continue;

        var _erro = abs((x - RITMO_LINHA_X) / velocidade);
        if (_erro <= RITMO_JANELA_BOM && _erro < _menor_erro) {
            _menor_erro = _erro;
            _melhor = id;
        }
    }

    return _melhor;
}

/// Classifica uma nota já alcançável.
function ritmo_julgar(_nota) {
    var _erro = abs(ritmo_erro_frames(_nota));
    if (_erro <= RITMO_JANELA_PERFEITO) return JULGAMENTO.PERFEITO;
    if (_erro <= RITMO_JANELA_OTIMO)    return JULGAMENTO.OTIMO;
    if (_erro <= RITMO_JANELA_BOM)      return JULGAMENTO.BOM;
    return JULGAMENTO.NENHUM;
}

/// A nota passou do ponto em que ainda poderia ser acertada?
function ritmo_nota_perdida(_nota) {
    return (ritmo_erro_frames(_nota) < -RITMO_JANELA_BOM);
}

// =====================================================================
// CORES DO JULGAMENTO
// Cada julgamento tem três tons: o estouro da nota, o brilho do alvo e o número de
// pontos que sobe. Estavam soltos em o_buttons_forja, e mexer num julgamento exigia
// achar as três ocorrências certas no meio do switch.
// =====================================================================

#macro COR_PERFEITO_NOTA   make_colour_rgb(255, 226, 140)
#macro COR_PERFEITO        make_colour_rgb(255, 214, 90)
#macro COR_PERFEITO_GANHO  make_colour_rgb(214, 150, 20)

#macro COR_OTIMO_NOTA      make_colour_rgb(250, 195, 120)
#macro COR_OTIMO           make_colour_rgb(245, 160, 60)
#macro COR_OTIMO_GANHO     make_colour_rgb(190, 110, 20)

#macro COR_BOM_NOTA        make_colour_rgb(205, 235, 190)
#macro COR_BOM             make_colour_rgb(180, 225, 150)
#macro COR_BOM_GANHO       make_colour_rgb(96, 140, 60)

#macro COR_ERRO            make_colour_rgb(235, 95, 75)

// =====================================================================
// IMPACTO NA BIGORNA
// =====================================================================

/// Sprite do impacto na cor da faixa. Os tipos vem do Instance Creation Code dos
/// alvos em rm_forja: 0 baixo, 1 cima, 2 direita, 3 esquerda.
function ritmo_sprite_impacto(_tipo) {
    switch (_tipo) {
        case 0: return s_impacto_baixo;   // amarelo
        case 1: return s_impacto_cima;    // vermelho
        case 2: return s_impacto_dir;     // azul
        case 3: return s_impacto_esq;     // verde
    }
    return s_impacto_cima;
}

/// Dispara o impacto e o tremor da bigorna.
///
/// `_forca` e a amplitude do tremor em pixels, pela qualidade do acerto. Fica num
/// lugar so para os tres julgamentos nao repetirem a mesma sequencia de chamadas —
/// foi assim que a moldura errada nasceu no seletor (D-71).
function ritmo_impacto_bigorna(_tipo, _forca) {
    if (!instance_exists(o_bigorna)) exit;

    // ponto onde o martelo encontra a bigorna: ela mede 120x70 com origem no canto
    var _px = o_bigorna.x + 45;
    var _py = o_bigorna.y + 5;

    var _e = instance_create_layer(_px, _py, "Gameplay", o_impacto_bigorna);
    _e.sprite_index = ritmo_sprite_impacto(_tipo);
    _e.image_index = 0;

    o_bigorna.tremor = _forca;
}
