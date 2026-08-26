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

// Paleta da forja, medida sobre o pergaminho rgb(229,214,161). Estava repetida em
// literais espalhados por sete arquivos — o cobre sozinho aparecia cinco vezes —, o
// que é o mesmo problema que a D-53 resolveu nos menus: o padrão visual precisa
// morar num lugar só, senão ajustar um tom vira caça ao número.
#macro UI_COR_TEXTO    c_black
#macro UI_COR_DESTAQUE c_yellow

#macro UI_COR_COBRE        make_colour_rgb(150, 66, 24)   // 4,68:1 no pergaminho
#macro UI_COR_COBRE_CLARO  make_colour_rgb(176, 92, 32)   // 3,29:1 — só em texto de 30 px
#macro UI_COR_CARMIM       make_colour_rgb(158, 22, 40)   // 5,57:1
#macro UI_COR_APAGADA      make_colour_rgb(120, 105, 95)  // texto secundário
#macro UI_COR_PERGAMINHO   make_colour_rgb(229, 214, 161)  // a cor do painel, luminância 0,673

/// Placa escura atrás de texto solto sobre o cenário. Os três valores andam JUNTOS:
/// é o mesmo tratamento no título da fase e em qualquer texto flutuante, para as duas
/// faixas lerem como a mesma coisa.
///
/// 0,62 é o ponto em que a placa deixa de pesar sem deixar de medir. Ela derruba o
/// pior fundo possível — branco puro — para luminância 0,119, e o texto BRANCO fica em
/// 6,2:1 em cima dela, acima do mínimo AA de 4,5:1. Sobre céu escuro passa de 9:1.
///
/// A 0,80 que veio antes o contraste era 12:1, mas a faixa lia como tarja colada na
/// tela. O creme do pergaminho não serve mais como tinta aqui: a 0,62 ele cairia para
/// 4,3:1, abaixo do mínimo. Placa mais leve exige tinta mais clara.
#macro UI_PLACA_ALPHA  0.62
#macro UI_PLACA_FADE_X 16
#macro UI_PLACA_FADE_Y 6

/// Logo das telas de menu, sempre no mesmo lugar.
function ui_logo() {
    draw_sprite_ext(s_logo_jogo, 0,
                    display_get_gui_width() / 2,
                    (display_get_gui_height() / 2) + UI_LOGO_Y,
                    1.2, 1.2, 0, c_white, 1);
}

/// Moldura do menu, dimensionada pela quantidade de itens — como o menu principal
/// sempre fez. A largura é fixa para as telas não "respirarem" de tamanho ao trocar.
/// A largura e o deslocamento vertical são parâmetros porque a tela de controles é
/// uma TABELA, não um menu: uma linha como "Confirmar / BOTÃO 1" mede 242 px e não
/// cabe no vão de 205 do padrão. Todo o resto — sprite, logo, cursor, cores — segue
/// idêntico, então as telas continuam sendo a mesma tela com conteúdo diferente.
function ui_painel_menu(_qtd_itens, _largura = UI_PAINEL_LARGURA, _offset_y = UI_PAINEL_Y) {
    var _altura = (_qtd_itens * UI_ITEM_GAP) + UI_PAINEL_PADDING;
    var _x = (display_get_gui_width() / 2) - (_largura / 2);
    var _y = (display_get_gui_height() / 2) + _offset_y - (_altura / 2);

    draw_sprite_stretched(s_menu_background_panel, 0, _x, _y, _largura, _altura);
    return _altura;
}

/// Item de menu no padrão da casa.
///
/// O cursor de espada acompanha a LARGURA DO TEXTO, como no menu principal
/// original — é ele que faz o cursor parecer apontar para a palavra em vez de
/// flutuar numa coluna fixa. Em linhas com valor, ele se apoia no rótulo.
function ui_item_menu(_cx, _y, _texto, _selecionado, _valor = "", _largura = UI_ITEM_LARGURA) {
    draw_set_font(f_padrao);
    draw_set_valign(fa_middle);

    var _cor = _selecionado ? UI_COR_DESTAQUE : UI_COR_TEXTO;
    var _cursor_x = 0;

    if (_valor == "") {
        var _largura_texto = string_width(_texto);

        if (_selecionado) {
            ui_caixa_pulsante(_cx, _y, _largura, UI_ITEM_ALTURA);
        }

        draw_set_halign(fa_center);
        draw_set_color(_cor);
        draw_text(_cx, _y, _texto);

        _cursor_x = _cx - (_largura_texto / 2) - 25;
    } else {
        // as margens saem da caixa, não do painel, para rótulo e valor respirarem
        // dentro dela: a esquerda é maior porque é lá que o cursor se encaixa
        var _esq = _cx - (_largura / 2) + 26;
        var _dir = _cx + (_largura / 2) - 13;

        if (_selecionado) {
            ui_caixa_pulsante(_cx, _y, _largura, UI_ITEM_ALTURA);
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

/// Moldura de altura livre, para telas que são TABELA e não lista de itens — a de
/// recordes tem dez linhas de 32 px, que nenhuma contagem de itens de menu descreve.
/// Devolve o Y do topo, que é de onde a tabela se organiza.
function ui_painel_livre(_largura, _altura, _offset_y = 0) {
    var _x = (display_get_gui_width() / 2) - (_largura / 2);
    var _y = (display_get_gui_height() / 2) + _offset_y - (_altura / 2);

    draw_sprite_stretched(s_menu_background_panel, 0, _x, _y, _largura, _altura);
    return _y;
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
/// "Pressione X" com o comando REAL de quem esta jogando.
///
/// Era texto fixo — "Pressione ENTER ou ESPAÇO" —, e no gabinete nao existe teclado:
/// so alavanca e botoes, cada jogador com os seus. A tela prometia uma tecla que nao
/// esta ali e escondia o botao que esta.
///
/// Le o vinculo em vigor, entao acompanha o remapeamento sozinha. E le o vinculo DO
/// JOGADOR CERTO: no Versus e numa partida solo do jogador 2, quem tem de agir e ele,
/// e mandar o outro apertar nao ajuda ninguem.
function ui_texto_confirmar(_dono = undefined) {
    if (is_undefined(_dono)) _dono = solo_jogador();

    var _acao = (_dono == 1) ? ACAO.CONFIRMAR2 : ACAO.CONFIRMAR;

    return "Pressione " + input_nome_da_acao(_acao);
}

/// O mesmo para o Versus, onde os dois precisam saber o proprio botao.
///
/// Quando os dois estao no mesmo vinculo — o padrao de fabrica com um controle so —
/// nao ha o que separar, e repetir o mesmo nome duas vezes so faria a linha crescer.
function ui_texto_confirmar_dupla() {
    var _a = input_nome_da_acao(ACAO.CONFIRMAR);
    var _b = input_nome_da_acao(ACAO.CONFIRMAR2);

    if (_a == _b) return "Pressione " + _a;

    return "Pressione " + _a + " ou " + _b;
}

/// O nome da arma, sem o verbo.
///
/// fases_data guarda "Forjar Espada", que é o rótulo do BOTÃO do seletor — ali ele
/// descreve a ação, e a ação é o ponto. Numa tabela de recordes vira ruído: todas as
/// páginas começam com a mesma palavra, que por isso não distingue nenhuma. Sobra o
/// nome, que é o que o jogador procura.
function fase_nome_curto(_nome) {
    var _verbo = "Forjar ";
    var _n = string_length(_verbo);

    if (string_copy(_nome, 1, _n) == _verbo) {
        return string_delete(_nome, 1, _n);
    }

    return _nome;
}

/// Porcentagem de precisão como texto, TRUNCADA e nunca arredondada.
///
/// Um percurso com 651 acertos e 3 erros da 99,54%, e round() mostrava 100% ao lado de
/// "Erros: 3" — a tela se contradizia sozinha, e o rank saia A porque ele le o valor
/// cheio. 100% passa a significar exatamente o que diz: nenhum erro.
///
/// Truncar tambem e o que o genero faz. Arredondar para cima uma precisao e prometer
/// uma partida perfeita que nao aconteceu.
function ui_pct(_valor) {
    return string(floor(_valor)) + "%";
}

/// Devolve o desenho ao estado padrão, para não vazar configuração entre objetos.
function ui_reset() {
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_font(f_padrao);
}


/// Texto legível sobre fundo QUALQUER — nuvem, céu, forja.
///
/// Texto solto sobre o cenário não tem contraste garantido. A descrição da tela de
/// modos ficava em 1,9:1 sobre a nuvem clara e era quase invisível; o mesmo problema
/// aparece em todo texto desenhado fora de um painel. Dentro dos menus o pergaminho
/// resolve porque a cor de trás é conhecida — fora dele não existe cor conhecida, e
/// só uma placa própria garante o contraste.
///
/// A placa usa a mesma grade de vértices do título da fase (hud_placa_suave), mas com
/// degradê CURTO. A 96 px de cauda ela deixava de ser uma placa e virava uma mancha
/// difusa que sobrava muito além do texto — o degradê existe para a borda não terminar
/// numa linha reta, e não para dissolver a forma inteira.
///
/// Use ESTA função para qualquer texto que não tenha painel atrás. É o padrão.
function ui_texto_flutuante(_cx, _cy, _texto, _alpha = 1, _fonte = f_padrao_pequena, _cor = c_white) {
    if (_texto == "" || _alpha <= 0) {
        return;
    }

    var _halign = draw_get_halign();
    var _valign = draw_get_valign();

    draw_set_font(_fonte);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    // O texto precisa caber no MIOLO da placa, onde o alpha está no pico. Se ele
    // invadir a faixa de degradê, as pontas das letras perdem o fundo e voltam a
    // depender do céu — que é justamente o problema que a placa existe para resolver.
    var _pad = 14;
    var _fade_x = UI_PLACA_FADE_X;
    var _fade_y = UI_PLACA_FADE_Y;

    var _meia = (string_width(_texto) / 2) + _pad + _fade_x;
    var _alt  = (string_height(_texto) / 2) + _pad + _fade_y;

    hud_placa_suave(floor(_cx - _meia), floor(_cy - _alt),
                    floor(_cx + _meia), floor(_cy + _alt),
                    c_black, UI_PLACA_ALPHA * _alpha, _fade_x, _fade_y);

    // Posição inteira pela regra da fonte de pixel (D-33).
    draw_set_alpha(_alpha);
    draw_set_color(_cor);
    draw_text(floor(_cx), floor(_cy), _texto);
    draw_set_alpha(1);

    draw_set_halign(_halign);
    draw_set_valign(_valign);
}
