// =================================================================
// 1. DESENHA O FUNDO SEMI-TRANSPARENTE (PARA FOCO)
// =================================================================
draw_set_color(c_black);
draw_set_alpha(0.7);
draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
draw_set_alpha(1);


// =================================================================
// 2. DESENHA O PAINEL DE INSTRUÇÕES (COM NOVAS DIMENSÕES E POSIÇÃO)
// =================================================================
// --- Variáveis de Ajuste do Painel ---
var _box_largura = 955; // <<< LARGURA IDEAL
var _box_altura = 550;  // <<< ALTURA IDEAL
var _margin_bottom = 120; // Distância da base da tela

// --- Cálculos de Posição ---
var _cx = display_get_gui_width() / 2;
var _box_y = display_get_gui_height() - _box_altura - _margin_bottom; // Alinha pela base
var _box_x = _cx - (_box_largura / 2);

// Desenha o painel
var _sprite_painel = s_tutorial; 
draw_sprite_stretched(_sprite_painel, 0, _box_x, _box_y, _box_largura, _box_altura);


// =================================================================
// 3. DESENHA OS TEXTOS DENTRO DO PAINEL
// =================================================================

// --- Cálculos de Posição ---
var _cx = display_get_gui_width() / 2;
var _box_y = display_get_gui_height() - _box_altura - _margin_bottom; // Alinha pela base
var _box_x = _cx - (_box_largura / 2);

// --- INSTRUÇÕES ---
draw_set_halign(fa_left); // Alinhado à esquerda para blocos de texto
draw_set_color(c_black);
var _texto_instrucoes = "Use as  <SETAS>  ou  <W A S D>  do teclado para acertar as notas no ritmo da forja.\n\n" + 
						"Use as teclas  <ESC>  ou  <P>  para pausar o jogo.\n" + 
                       "Seu objetivo é forjar a melhor arma possível acertando as notas com precisão para aumentar sua pontuação.\n\n" +
                       "Cuidado! Errar muitas notas seguidas pode arruinar seu trabalho.";

// Posição e largura do texto, relativas ao painel
var _padding = 60;
var _texto_x = _box_x + _padding;
//var _texto_y = _titulo_y + 80;
var _texto_largura_max = _box_largura - (_padding * 2);

draw_text_ext(_texto_x, 220, _texto_instrucoes, 35, _texto_largura_max);


// =================================================================
// 4. DESENHA O PROMPT PARA CONTINUAR (COM EFEITO PULSANTE)
// =================================================================
draw_set_halign(fa_center);
draw_set_valign(fa_middle); // Centraliza o prompt verticalmente

var _prompt_text = "Pressione ENTER para começar";
var _prompt_y = _box_y + _box_altura - 60; // Posição relativa à base do painel

// --- Lógica da Caixa Pulsante ---
var _texto_largura = string_width(_prompt_text);
var _highlight_width = _texto_largura + 40;
var _highlight_height = 50;

// ... (código da pulsação) ...
var _min_alpha = 0.15;
var _max_alpha = 0.5;
var _pulse_speed = 0.004;
var _normalized_sine = (sin(current_time * _pulse_speed) + 1) / 2;
var _current_pulse_alpha = _min_alpha + (_max_alpha - _min_alpha) * _normalized_sine;
// ...

draw_set_color(c_black);
draw_set_alpha(_current_pulse_alpha);
draw_rectangle(_cx - _highlight_width/2, _prompt_y - _highlight_height/2, _cx + _highlight_width/2, _prompt_y + _highlight_height/2, false);
draw_set_alpha(1);

// --- Desenho do Texto do Prompt ---
draw_set_color(c_yellow);
draw_text(_cx, _prompt_y, _prompt_text);

draw_set_halign(fa_center);
draw_set_valign(fa_middle); // Centraliza o prompt verticalmente

var _prompt_text = "COMO FORJAR";
var _prompt_y = _box_y + _box_altura - 480; // Posição relativa à base do painel

// --- Lógica da Caixa Pulsante ---
var _texto_largura = string_width(_prompt_text);
var _highlight_width = _texto_largura + 40;
var _highlight_height = 50;

// ... (código da pulsação) ...
var _min_alpha = 0.15;
var _max_alpha = 0.5;
var _pulse_speed = 0.000;
var _normalized_sine = (sin(current_time * _pulse_speed) + 1) / 2;
var _current_pulse_alpha = _min_alpha + (_max_alpha - _min_alpha) * _normalized_sine;
// ...

draw_set_color(c_black);
draw_set_alpha(_current_pulse_alpha);
draw_rectangle(_cx - _highlight_width/2, _prompt_y - _highlight_height/2, _cx + _highlight_width/2, _prompt_y + _highlight_height/2, false);
draw_set_alpha(1);

// --- Desenho do Texto do Prompt ---
draw_set_color(c_yellow);
draw_text(_cx, _prompt_y, _prompt_text);


// Reseta o alinhamento para o padrão
draw_set_halign(fa_left);
draw_set_valign(fa_top);