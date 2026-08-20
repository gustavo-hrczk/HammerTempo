/// scr_ui — helpers de desenho compartilhados
/// A caixa pulsante estava copiada em 5 arquivos e o prompt "Enter ou Espaço" em 6.

/// Alpha oscilante usado nos destaques de menu.
function ui_pulse_alpha(_min = 0.15, _max = 0.5, _velocidade = 0.004) {
    var _seno = (sin(current_time * _velocidade) + 1) / 2;
    return _min + (_max - _min) * _seno;
}

/// Retângulo escuro pulsante, centrado em (_cx, _cy).
function ui_caixa_pulsante(_cx, _cy, _largura, _altura, _cor = c_black) {
    draw_set_color(_cor);
    draw_set_alpha(ui_pulse_alpha());
    draw_rectangle(_cx - _largura / 2, _cy - _altura / 2,
                   _cx + _largura / 2, _cy + _altura / 2, false);
    draw_set_alpha(1);
}

/// Prompt destacado ("Pressione ... para continuar") com a caixa pulsante atrás.
function ui_prompt(_cx, _cy, _texto, _pad_h = 40, _altura = 50) {
    var _halign = draw_get_halign();
    var _valign = draw_get_valign();

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    ui_caixa_pulsante(_cx, _cy, string_width(_texto) + _pad_h, _altura);

    draw_set_color(c_yellow);
    draw_text(_cx, _cy, _texto);

    draw_set_halign(_halign);
    draw_set_valign(_valign);
}

/// Texto do prompt de confirmação conforme o dispositivo em uso.
function ui_texto_confirmar() {
    return (global.input_dispositivo == "gamepad")
        ? "Pressione o BOTÃO 1 ou START"
        : "Pressione ENTER ou ESPAÇO";
}

/// Devolve o desenho ao estado padrão, para não vazar configuração entre objetos.
function ui_reset() {
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_font(f_padrao);
}
