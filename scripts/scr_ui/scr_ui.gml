/// scr_ui — helpers de desenho compartilhados
/// A caixa pulsante estava copiada em 5 arquivos e o prompt "Enter ou Espaço" em 6.

// =====================================================================
// PADRÃO VISUAL DOS MENUS
// Menu principal, opções e pausa desenhavam cada um do seu jeito: cores de
// destaque diferentes, molduras de tamanhos diferentes, logo em alturas
// diferentes e cursor só em uma delas. Tudo passa por aqui agora, então a
// troca de tela não desloca nem repinta nada.
// =====================================================================

#macro UI_LOGO_Y        -320   // deslocamento do logo em relação ao centro da tela
#macro UI_PAINEL_Y       140   // deslocamento do painel em relação ao centro
#macro UI_PAINEL_LARGURA 260   // largura da moldura, herdada do menu principal
#macro UI_ITEM_GAP        45
#macro UI_ITEM_ALTURA     40

// Largura da caixa de destaque, IGUAL em todos os itens de menu, opções e pausa.
// Antes cada tela calculava a sua: o menu usava a largura do texto + 75, e as opções
// usavam o painel - 36 (224 px), então a caixa mudava de tamanho ao trocar de tela.
// O valor vem do item mais largo do menu principal — "Começar Jogo" mede 168 px em
// f_padrao — mais a mesma folga de 75. O texto mais longo de todos ("Sair para o
// menu", 218 px) ainda cabe dentro dela.
#macro UI_ITEM_LARGURA   243
#macro UI_PAINEL_PADDING  40   // folga vertical acima e abaixo dos itens

#macro UI_COR_TEXTO    c_black
#macro UI_COR_DESTAQUE c_yellow

/// Logo das telas de menu, sempre no mesmo lugar.
function ui_logo() {
    draw_sprite_ext(s_logo_jogo, 0,
                    display_get_gui_width() / 2,
                    (display_get_gui_height() / 2) + UI_LOGO_Y,
                    1.2, 1.2, 0, c_white, 1);
}

/// Moldura do menu, dimensionada pela quantidade de itens — como o menu principal
/// sempre fez. A largura é fixa para as telas não "respirarem" de tamanho ao trocar.
function ui_painel_menu(_qtd_itens) {
    var _altura = (_qtd_itens * UI_ITEM_GAP) + UI_PAINEL_PADDING;
    var _x = (display_get_gui_width() / 2) - (UI_PAINEL_LARGURA / 2);
    var _y = (display_get_gui_height() / 2) + UI_PAINEL_Y - (_altura / 2);

    draw_sprite_stretched(s_menu_background_panel, 0, _x, _y, UI_PAINEL_LARGURA, _altura);
    return _altura;
}

/// Item de menu no padrão da casa.
///
/// O cursor de espada acompanha a LARGURA DO TEXTO, como no menu principal
/// original — é ele que faz o cursor parecer apontar para a palavra em vez de
/// flutuar numa coluna fixa. Em linhas com valor, ele se apoia no rótulo.
function ui_item_menu(_cx, _y, _texto, _selecionado, _valor = "") {
    draw_set_font(f_padrao);
    draw_set_valign(fa_middle);

    var _cor = _selecionado ? UI_COR_DESTAQUE : UI_COR_TEXTO;
    var _cursor_x = 0;

    if (_valor == "") {
        var _largura_texto = string_width(_texto);

        if (_selecionado) {
            ui_caixa_pulsante(_cx, _y, UI_ITEM_LARGURA, UI_ITEM_ALTURA);
        }

        draw_set_halign(fa_center);
        draw_set_color(_cor);
        draw_text(_cx, _y, _texto);

        _cursor_x = _cx - (_largura_texto / 2) - 25;
    } else {
        // as margens saem da caixa, não do painel, para rótulo e valor respirarem
        // dentro dela: a esquerda é maior porque é lá que o cursor se encaixa
        var _esq = _cx - (UI_ITEM_LARGURA / 2) + 26;
        var _dir = _cx + (UI_ITEM_LARGURA / 2) - 13;

        if (_selecionado) {
            ui_caixa_pulsante(_cx, _y, UI_ITEM_LARGURA, UI_ITEM_ALTURA);
        }

        draw_set_color(_cor);
        draw_set_halign(fa_left);
        draw_text(_esq, _y, _texto);
        draw_set_halign(fa_right);
        draw_text(_dir, _y, _valor);

        _cursor_x = _esq - 20;
    }

    if (_selecionado) {
        draw_sprite(s_menu_seletor, 0, _cursor_x, _y);
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
