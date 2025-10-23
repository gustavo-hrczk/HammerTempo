

// Objeto: o_background_manager
// Evento: Draw -> Draw

var _view_w = display_get_gui_width();
var _view_h = display_get_gui_height();

// 1. FUNDO SÓLIDO
draw_clear_alpha(make_colour_rgb(137, 178, 255), 1);

// --- FUNÇÃO AUXILIAR PARA DESENHAR CAMADAS EM PARALLAX COM ESCALA ---
// A função agora também recebe 'view_h' como um argumento.
var draw_parallax_layer_scaled = function(sprite, x_pos, speed, view_w, view_h) { // <<< ALTERAÇÃO AQUI
    if (!sprite_exists(sprite)) return;

    var _sprite_w = sprite_get_width(sprite);
    var _scale = view_w / _sprite_w;
    
    var _scaled_w = _sprite_w * _scale;
    var _scaled_h = sprite_get_height(sprite) * _scale;
    
    // Alinha a imagem na BASE da tela, usando o parâmetro 'view_h'.
    var _y_pos = view_h - _scaled_h; // <<< ALTERAÇÃO AQUI
    
    draw_sprite_ext(sprite, 0, x_pos, _y_pos, _scale, _scale, 0, c_white, 1);
    draw_sprite_ext(sprite, 0, x_pos - _scaled_w, _y_pos, _scale, _scale, 0, c_white, 1);
    
    var _new_x = x_pos + speed;
    
    if (_new_x >= _scaled_w) {
        _new_x -= _scaled_w;
    }
    
    return _new_x;
}

// --- ATUALIZA E DESENHA CADA CAMADA ---
// Agora passamos a variável '_view_h' para a função em cada chamada.
// <<< ALTERAÇÃO EM TODAS AS LINHAS ABAIXO
layer_x_stars        = draw_parallax_layer_scaled(s_bg_stars, layer_x_stars, speed_stars, _view_w, _view_h);
layer_x_far_clouds   = draw_parallax_layer_scaled(s_bg_far_clouds, layer_x_far_clouds, speed_far_clouds, _view_w, _view_h);
layer_x_mid_clouds   = draw_parallax_layer_scaled(s_bg_mid_clouds, layer_x_mid_clouds, speed_mid_clouds, _view_w, _view_h);
layer_x_front_clouds = draw_parallax_layer_scaled(s_bg_front_clouds, layer_x_front_clouds, speed_front_clouds, _view_w, _view_h);