/// scr_ui — helpers de desenho compartilhados
/// A caixa pulsante estava copiada em 5 arquivos e o prompt "Enter ou Espaço" em 6.

// =====================================================================
// PADRÃO VISUAL DOS MENUS
// Menu principal, opções e pausa desenhavam cada um do seu jeito: cores de
// destaque diferentes, molduras de tamanhos diferentes, logo em alturas
// diferentes e cursor só em uma delas. Tudo passa por aqui agora, então a
// troca de tela não desloca nem repinta nada.
// =====================================================================

#macro UI_LOGO_Y      -320   // deslocamento do logo em relação ao centro da tela
#macro UI_PAINEL_Y     140   // deslocamento do painel em relação ao centro
#macro UI_PAINEL_W     380
#macro UI_PAINEL_H     300
#macro UI_ITEM_GAP      46
#macro UI_ITEM_ALTURA   40

#macro UI_COR_TEXTO   c_black
#macro UI_COR_DESTAQUE c_yellow

/// Logo das telas de menu, sempre no mesmo lugar.
function ui_logo() {
    draw_sprite_ext(s_logo_jogo, 0,
                    display_get_gui_width() / 2,
                    (display_get_gui_height() / 2) + UI_LOGO_Y,
                    1.2, 1.2, 0, c_white, 1);
}

/// Moldura padrão dos menus, no tamanho e na posição padrão.
function ui_painel_menu() {
    var _x = (display_get_gui_width() / 2) - (UI_PAINEL_W / 2);
    var _y = (display_get_gui_height() / 2) + UI_PAINEL_Y - (UI_PAINEL_H / 2);
    draw_sprite_stretched(s_menu_background_panel, 0, _x, _y, UI_PAINEL_W, UI_PAINEL_H);
    return _y;
}

/// Item de menu no padrão da casa: caixa pulsante, cor de destaque e o cursor de
/// espada à esquerda. `_valor` opcional desenha rótulo à esquerda e valor à direita.
function ui_item_menu(_cx, _y, _texto, _selecionado, _valor = "") {
    if (_selecionado) {
        ui_caixa_pulsante(_cx, _y, UI_PAINEL_W - 44, UI_ITEM_ALTURA);
    }

    var _cor = _selecionado ? UI_COR_DESTAQUE : UI_COR_TEXTO;

    draw_set_font(f_padrao);
    draw_set_valign(fa_middle);
    draw_set_color(_cor);

    if (_valor == "") {
        draw_set_halign(fa_center);
        draw_text(_cx, _y, _texto);
    } else {
        var _esq = _cx - (UI_PAINEL_W / 2) + 34;
        var _dir = _cx + (UI_PAINEL_W / 2) - 34;
        draw_set_halign(fa_left);
        draw_text(_esq, _y, _texto);
        draw_set_halign(fa_right);
        draw_text(_dir, _y, _valor);
    }

    if (_selecionado) {
        draw_sprite(s_menu_seletor, 0, _cx - (UI_PAINEL_W / 2) + 14, _y);
    }
}

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
