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

    var _txt = audio_get_name(_m) +
        (audio_is_playing(_m) ? " tocando" : " PARADA") +
        " gain " + string_format(audio_sound_get_gain(_m), 1, 2);

    if (o_audio_manager.entrando)     _txt += " [entrando]";
    if (o_audio_manager.is_fading_out) _txt += " [saindo]";

    return _txt;
}

/// Estado da faixa em crossfade. Foi criada para caçar a quebra de laço do tema: uma
/// faixa esquecida aqui continua tocando por baixo da próxima, e não havia como ver
/// isso acontecendo.
function debug_texto_crossfade() {
    if (!instance_exists(o_audio_manager)) return "-";

    var _s = o_audio_manager.musica_saindo;
    if (_s == -1) return "nenhuma";

    return audio_get_name(_s) +
        (audio_is_playing(_s) ? " tocando" : " PARADA") +
        " gain " + string_format(audio_sound_get_gain(_s), 1, 2);
}

/// Apaga os recordes gravados, mantendo as opcoes.
///
/// Existe porque nao ha outro jeito de voltar ao estado "ainda nao forjada" sem
/// apagar o save inteiro e perder volume e tamanho de janela junto. Na feira serve
/// para zerar o gabinete entre sessoes.
///
/// So responde com o overlay de debug ligado, e com Shift: sao dois passos
/// deliberados, para ninguem apagar tudo esbarrando numa tecla.
function debug_zerar_recordes() {
    placar_limpar();
    save_gravar();
}

/// Quantas fases tem recorde gravado. Aparece no overlay, para a limpeza ser visivel.
function debug_total_recordes() {
    if (!variable_global_exists("save") || !is_struct(global.save)) return 0;
    if (!variable_struct_exists(global.save, "leaderboard")) return 0;

    var _livre = global.save.leaderboard.livre;
    var _fases = variable_struct_get_names(_livre);
    var _total = 0;

    for (var i = 0; i < array_length(_fases); i++) {
        _total += array_length(_livre[$ _fases[i]]);
    }
    return _total;
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
        "notas vivas: " + string(instance_number(o_nota_seta)) +
            "  telas: tut=" + string(instance_number(o_tela_tutorial)) +
            " sel=" + string(instance_number(o_seletor_fases)) +
            " res=" + string(instance_number(o_controlador_resultado)),
        "pontos: " + string(jogador().pontuacao) +
            "  combo: " + string(jogador().stats_sequencia) +
            "  perf: " + string(jogador().stats_acertos_perfeitos) +
            "  otim: " + string(jogador().stats_acertos_otimos) +
            "  bons: " + string(jogador().stats_acertos_bons),
        "perdidas: " + string(jogador().stats_erros) +
            "  seguidas: " + string(jogador().stats_sequencia_errada) +
            "  toques inválidos: " + string(jogador().stats_toques_invalidos) +
            "  total de notas: " + string(jogador().stats_total_notas),
        "último acerto: " + global.debug_ultimo_julgamento +
            " (" + string_format(global.debug_ultimo_erro_ms, 1, 1) + " ms)",
        "música: " + debug_texto_musica(),
        "saindo: " + debug_texto_crossfade(),
        "recordes gravados: " + string(debug_total_recordes()) +
            "   [SHIFT+F3 zera]",
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
