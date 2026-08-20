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
#macro RITMO_JANELA_PERFEITO 3   // +-50 ms
#macro RITMO_JANELA_BOM      8   // +-133 ms

/// Resultado possível de uma tentativa de acerto.
enum JULGAMENTO {
    NENHUM,   // não havia nota alcançável
    PERFEITO,
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
    if (_erro <= RITMO_JANELA_BOM)      return JULGAMENTO.BOM;
    return JULGAMENTO.NENHUM;
}

/// A nota passou do ponto em que ainda poderia ser acertada?
function ritmo_nota_perdida(_nota) {
    return (ritmo_erro_frames(_nota) < -RITMO_JANELA_BOM);
}
