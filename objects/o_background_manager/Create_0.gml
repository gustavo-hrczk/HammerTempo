// Evento Create de o_background_manager

// --- Variáveis de Posição ---
// Cada camada terá sua própria posição X para o scroll
layer_x_stars = 0;
layer_x_far_clouds = 0;
layer_x_mid_clouds = 0;
layer_x_front_clouds = 0;

// --- Variáveis de Velocidade ---
// A velocidade define o efeito parallax. Valores menores = mais lento (mais distante)
speed_stars = 0.1;
speed_far_clouds = 0.2;
speed_mid_clouds = 0.3;
speed_front_clouds = 0.5; // Camada mais rápida

// --- Armazenar a Largura dos Sprites ---
// Pegamos a largura de cada sprite para saber quando resetar a posição (loop)
width_stars = sprite_get_width(s_bg_stars);
width_far_clouds = sprite_get_width(s_bg_far_clouds);
width_mid_clouds = sprite_get_width(s_bg_mid_clouds);
width_front_clouds = sprite_get_width(s_bg_front_clouds);