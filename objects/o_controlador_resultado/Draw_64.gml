// --- SETUP DE DESENHO ---
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// --- POSICIONAMENTO ---
var _col1_x = (display_get_gui_width() / 2) - 300;
var _col2_x = (display_get_gui_width() / 2) + 50;

var _base_y = 540;
var _line_gap = 30;
var _line1_y = _base_y;
var _line2_y = _base_y + _line_gap;
var _line3_y = _base_y + (_line_gap * 2);


// --- DESENHA AS ESTATÍSTICAS ---
draw_set_font(f_padrao); // Define a fonte padrão
draw_set_color(c_black);
draw_text(_col1_x, _line1_y, "Notas Perfeitas: " + string(o_controlador_geral.stats_acertos_perfeitos));
draw_text(_col1_x, _line2_y, "Notas Boas: " + string(o_controlador_geral.stats_acertos_bons));

draw_text(_col2_x, _line1_y, "Erros: " + string(o_controlador_geral.stats_erros));
draw_text(_col2_x, _line2_y, "Total de Notas: " + string(o_controlador_geral.stats_total_notas));

draw_set_halign(fa_center);
draw_text(display_get_gui_width() / 2, _line3_y, "Pontuação: " + string(o_controlador_geral.pontuacao));

// =================================================================
// --- DESENHA A FRASE DE FEEDBACK (NOVA SEÇÃO) ---
// =================================================================
// (A frase já foi escolhida no Evento Create)

// Posição Y para a frase, logo abaixo da pontuação
var _frase_y = _line3_y + 40;

// Mude a cor e o estilo se quiser
draw_set_color(c_gray); // Um cinza claro para diferenciar

draw_text(display_get_gui_width() / 2, _frase_y, frase_escolhida);

// Volta para a fonte e cor padrão para o resto
// draw_set_font(f_padrao);
draw_set_color(c_black);


// --- DESENHA O PROMPT PARA CONTINUAR (COM EFEITO PULSANTE) ---
// =================================================================
var _prompt_text = "Pressione ENTER ou ESPAÇO para continuar";
var _prompt_y = 720; // <<< AJUSTE AQUI a altura do prompt

// --- DESENHA A CAIXA PULSANTE ATRÁS DO TEXTO ---
var _texto_largura = string_width(_prompt_text)+25;
var _texto_altura = string_height(_prompt_text);
var _highlight_padding = 5;

var _rect_x1 = (display_get_gui_width() / 2) - (_texto_largura / 2) - _highlight_padding;
var _rect_y1 = _prompt_y - (_texto_altura / 2) - _highlight_padding;
var _rect_x2 = (display_get_gui_width() / 2) + (_texto_largura / 2) + _highlight_padding;
var _rect_y2 = _prompt_y + (_texto_altura / 2) + _highlight_padding;

// Lógica de pulsação (copiada do seu menu)

var _min_alpha = 0.15;
var _max_alpha = 0.5;
var _pulse_speed = 0.004;
var _normalized_sine = (sin(current_time * _pulse_speed) + 1) / 2;
var _current_pulse_alpha = _min_alpha + (_max_alpha - _min_alpha) * _normalized_sine;

draw_set_color(c_black);
draw_set_alpha(_current_pulse_alpha);
draw_rectangle(_rect_x1, _rect_y1, _rect_x2, _rect_y2, false);
draw_set_alpha(1);

// --- DESENHA O TEXTO DO PROMPT POR CIMA ---

draw_set_color(c_yellow);
draw_set_valign(fa_middle); // Garante o alinhamento vertical
draw_text(display_get_gui_width() / 2, _prompt_y, _prompt_text);

// =================================================================
// --- DESENHA A ARMA FORJADA E SUA MOLDURA (NOVA SEÇÃO) ---
// =================================================================

// Posições baseadas no centro superior do painel de resultados (se você tiver um)
var _panel_top_y = 200; // Altura do topo do seu painel de resultados (ajuste conforme necessário)
var _center_x = display_get_gui_width() / 2;

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

// Reseta os alinhamentos
draw_set_halign(fa_left);
draw_set_valign(fa_top);