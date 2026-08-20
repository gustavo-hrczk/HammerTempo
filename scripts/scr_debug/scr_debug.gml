/// scr_debug — overlay de diagnóstico (F3)
/// Existe para tornar visíveis os problemas que a auditoria só conseguiu deduzir do
/// código: duplicação de controladores, erro de tempo dos acertos e estado do input.

function debug_init() {
    global.debug_ativo = false;
    global.debug_ultimo_erro_ms = 0;
    global.debug_ultimo_julgamento = "-";
}

function debug_toggle() {
    global.debug_ativo = !global.debug_ativo;
}

/// Registra o resultado da última tentativa de acerto (chamado por o_buttons_forja).
function debug_registrar_julgamento(_texto, _erro_ms) {
    global.debug_ultimo_julgamento = _texto;
    global.debug_ultimo_erro_ms = _erro_ms;
}

/// Descreve a música em reprodução e seu ganho — a forma mais rápida de flagrar uma
/// fase que ficou muda (auditoria CV-02).
function debug_texto_musica() {
    if (!instance_exists(o_audio_manager)) return "sem gerenciador";

    var _m = o_audio_manager.musica_atual;
    if (_m == -1) return "nenhuma";

    return audio_get_name(_m) +
        (audio_is_playing(_m) ? " tocando" : " PARADA") +
        " gain " + string_format(audio_sound_get_gain(_m), 1, 2);
}

function debug_draw() {
    if (!global.debug_ativo) return;

    var _linhas = [
        "FPS: " + string(fps) + " / real " + string(fps_real),
        "room: " + room_get_name(room),
        "controladores: " + string(instance_number(o_controlador_geral)) +
            "  audio: " + string(instance_number(o_audio_manager)) +
            "  fundo: " + string(instance_number(o_background_manajer_forja)),
        "estado: " + string(o_controlador_geral.estado_jogo),
        "notas vivas: " + string(instance_number(o_nota_seta)),
        "pontos: " + string(o_controlador_geral.pontuacao) +
            "  combo: " + string(o_controlador_geral.stats_sequencia) +
            "  perfeitos: " + string(o_controlador_geral.stats_acertos_perfeitos) +
            "  bons: " + string(o_controlador_geral.stats_acertos_bons),
        "perdidas: " + string(o_controlador_geral.stats_erros) +
            "  seguidas: " + string(o_controlador_geral.stats_sequencia_errada) +
            "  toques inválidos: " + string(o_controlador_geral.stats_toques_invalidos) +
            "  total de notas: " + string(o_controlador_geral.stats_total_notas),
        "último acerto: " + global.debug_ultimo_julgamento +
            " (" + string_format(global.debug_ultimo_erro_ms, 1, 1) + " ms)",
        "música: " + debug_texto_musica(),
        "input: " + global.input_dispositivo +
            (input_tem_gamepad() ? "  [gamepad slot " + string(global.input_slot) + "]" : "  [sem gamepad]")
    ];

    draw_set_font(f_padrao_pequena);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    var _y = 8;
    var _altura = array_length(_linhas) * 22 + 10;

    draw_set_color(c_black);
    draw_set_alpha(0.65);
    draw_rectangle(4, 4, 640, _y + _altura, false);
    draw_set_alpha(1);

    draw_set_color(c_lime);
    for (var i = 0; i < array_length(_linhas); i++) {
        draw_text(12, _y + 4 + (i * 22), _linhas[i]);
    }

    ui_reset();
}
