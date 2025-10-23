if (o_controlador_geral.pausa){
	exit;
}
// Obtenha as dimensões da GUI
var _view_w = display_get_gui_width();
var _view_h = display_get_gui_height();

// --- FUNÇÃO AUXILIAR (NÃO PRECISA MUDAR) ---
var draw_parallax_layer_scaled = function(sprite, x_pos, speed, view_w, view_h, alpha) {
    if (!sprite_exists(sprite)) return 0;
    var _sprite_w = sprite_get_width(sprite);
    var _scale = view_w / _sprite_w;
    var _scaled_w = _sprite_w * _scale;
    var _scaled_h = sprite_get_height(sprite) * _scale;
    var _y_pos = view_h - _scaled_h;
    draw_sprite_ext(sprite, 0, x_pos, _y_pos, _scale, _scale, 0, c_white, alpha);
    draw_sprite_ext(sprite, 0, x_pos - _scaled_w, _y_pos, _scale, _scale, 0, c_white, alpha);
    var _new_x = (x_pos + speed) % _scaled_w;
    return _new_x;
}

// --- LÓGICA DE TRANSIÇÃO E DESENHO ---
var _current_alpha = 1.0;
var _next_alpha = 0.0;
var _progress_ratio = 0;

if (state == 1) {
    _progress_ratio = transition_progress / transition_duration;
    _current_alpha = 1.0 - _progress_ratio;
    _next_alpha = _progress_ratio;
}

// 1. FUNDO SÓLIDO (com transição de cor)
var _color1 = bg_colors[current_set_index];
var _color2 = bg_colors[next_set_index];
var _final_color = merge_colour(_color1, _color2, _progress_ratio);
draw_clear_alpha(_final_color, 1);

// 2. DESENHA O CONJUNTO ATUAL
var _current_sprites = background_sets[current_set_index];
var _current_speeds = background_speeds[current_set_index]; // <<< PEGA AS VELOCIDADES CORRETAS
for (var i = 0; i < array_length(_current_sprites); i++) {
    layer_x_current[i] = draw_parallax_layer_scaled(
        _current_sprites[i],
        layer_x_current[i],
        _current_speeds[i], // <<< USA A VELOCIDADE CORRETA
        _view_w, _view_h,
        _current_alpha
    );
}

// 3. DESENHA O PRÓXIMO CONJUNTO (APENAS DURANTE A TRANSIÇÃO)
if (state == 1) {
    var _next_sprites = background_sets[next_set_index];
    var _next_speeds = background_speeds[next_set_index]; // <<< PEGA AS VELOCIDADES CORRETAS
    for (var i = 0; i < array_length(_next_sprites); i++) {
        layer_x_next[i] = draw_parallax_layer_scaled(
            _next_sprites[i],
            layer_x_next[i],
            _next_speeds[i], // <<< USA A VELOCIDADE CORRETA
            _view_w, _view_h,
            _next_alpha
        );
    }
}