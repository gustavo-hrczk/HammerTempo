// --- SETUP DE DESENHO ---
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// --- POSICIONAMENTO ---
// Com a faixa "ótimas" a lista de duas colunas passou a estourar o painel: a frase
// de feedback invadia a caixa do prompt. Virou uma grade 2x3 em fonte pequena, que
// economiza uma linha inteira e ainda agrupa os três julgamentos lado a lado.
var _cx = display_get_gui_width() / 2;
var _col_esq = _cx - 300;
var _col_dir = _cx + 300;

var _linha1 = 522;
var _linha2 = 558;

var _perfeitas = o_controlador_geral.stats_acertos_perfeitos;
var _otimas = o_controlador_geral.stats_acertos_otimos;
var _boas = o_controlador_geral.stats_acertos_bons;
var _erros = o_controlador_geral.stats_erros;

var _julgadas = _perfeitas + _otimas + _boas + _erros;
var _precisao = (_julgadas > 0) ? ((_perfeitas + _otimas + _boas) / _julgadas) * 100 : 0;

draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(c_black);

// --- GRADE DE ESTATÍSTICAS ---
// Em f_padrao: com a grade 2x3 o espaço permite o tamanho cheio, e os números
// são a informação que o jogador mais quer ler nesta tela.
draw_set_font(f_padrao);

draw_text(_col_esq, _linha1, "Perfeitas: " + string(_perfeitas));
draw_text(_cx,      _linha1, "Ótimas: " + string(_otimas));
draw_text(_col_dir, _linha1, "Boas: " + string(_boas));

draw_text(_col_esq, _linha2, "Erros: " + string(_erros));
draw_text(_cx,      _linha2, "Total: " + string(o_controlador_geral.stats_total_notas));
draw_text(_col_dir, _linha2, "Precisão: " + string(round(_precisao)) + "%");

// --- PONTUAÇÃO EM DESTAQUE ---
// Era preta, igual à grade de estatísticas acima, e sumia no meio delas. O cobre
// vem da rampa do combo, então a paleta da partida e a do resultado são a mesma;
// mede 4,68:1 sobre o pergaminho (229,214,161).
var _texto_pontos = "Pontuação: " + string(o_controlador_geral.pontuacao);

draw_set_font(f_padrao);
draw_set_color(UI_COR_COBRE);
draw_text(_cx, 594, _texto_pontos);
draw_set_color(c_black);

// --- RECORDE NOVO ---
// Ancorado na largura real da pontuação, não num deslocamento fixo: com 6 dígitos o
// antigo +190 encostava no número.
//
// A onda percorre o texto letra a letra. O deslocamento é ARREDONDADO porque Kobold 7
// é fonte de pixel: posição fracionária suja o traço, que foi o problema do contador
// dinâmico da contagem regressiva.
if (recorde_novo) {
    draw_set_font(f_padrao_pequena);
    draw_set_halign(fa_left);

    var _rec = "NOVO RECORDE!";
    var _rx = _cx + (string_width(_texto_pontos) / 2) + 30;

    // carmim, 5,57:1 — o vermelho anterior (178,58,22) ficava em 4,12:1 e quase
    // se confundia com o cobre da pontuação ao lado
    draw_set_color(UI_COR_CARMIM);

    for (var i = 1; i <= string_length(_rec); i++) {
        var _ch = string_char_at(_rec, i);
        var _onda = round(sin((current_time * 0.006) - (i * 0.55)) * 4);

        draw_text(floor(_rx), 594 + _onda, _ch);
        _rx += string_width(_ch);
    }

    draw_set_color(c_black);
    draw_set_halign(fa_center);
}

// --- FRASE DE FEEDBACK (escolhida no evento Create) ---
draw_set_font(f_padrao_pequena);
draw_set_color(c_gray);
draw_text(_cx, 628, frase_escolhida);
draw_set_color(c_black);

// --- PROMPT PARA CONTINUAR ---
// A GUI agora tem 720 px de altura (antes herdava os 768 do splash), então o prompt
// desceu para dentro da tela — auditoria UI-01.
ui_prompt(_cx, 676, ui_texto_confirmar() + " para continuar", 65);

// =================================================================
// --- DESENHA A ARMA FORJADA E SUA MOLDURA (NOVA SEÇÃO) ---
// =================================================================

// Posições baseadas no centro superior do painel de resultados (se você tiver um)
var _panel_top_y = 200; // Altura do topo do seu painel de resultados (ajuste conforme necessário)
var _center_x = _cx;

// Posição central para a arma e a moldura
// Ajuste este valor para mover tudo para cima ou para baixo na tela.
var _pos_y_arma_e_moldura = _panel_top_y - 45; // Por exemplo, 200 pixels acima do topo do painel

// 1. Desenha a arma forjada
// As sprites fixas de arma têm 250x250.
// Vamos desenhá-las em sua escala original (1,1) para caberem bem na moldura.
// Se você quiser que a arma seja menor dentro da moldura, ajuste a escala.
draw_sprite_ext(sprite_da_arma_final, 0, _center_x, _pos_y_arma_e_moldura, 0.8, 0.8, 0, c_white, 1);

// 2. Desenha a moldura por cima da arma
// A moldura tem 300x300. Usaremos escala 1,1 se ela já tiver o tamanho que você quer.
// Se quiser que a moldura seja um pouco maior ou menor, ajuste a escala.
draw_sprite_ext(sprite_da_moldura_final, 0, _center_x, _pos_y_arma_e_moldura, 1.1, 1.1, 0, c_white, 1);

ui_reset();