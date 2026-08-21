// Durante o MENU de pausa as notas somem: com o jogo congelado e o campo à
// vista, dava para estudar o que vinha e decorar. Na contagem de retomada elas
// voltam, porque aí o jogador precisa ver o que está chegando.
if (o_controlador_geral.pausa && o_controlador_geral.retomada_timer <= 0) {
    exit;
}

var _w = sprite_get_width(sprite_index);
var _h = sprite_get_height(sprite_index);

// a sprite tem origem no canto, então o encolhimento é compensado para a nota
// diminuir a partir do próprio centro
var _dx = x + (_w * (1 - escala)) / 2;
var _dy = y + (_h * (1 - escala)) / 2;

if (modo == 0) {
    // Contorno escuro: descola a nota do bege claro do painel sem mudar a arte.
    draw_sprite_ext(sprite_index, image_index, x - 1, y, 1, 1, 0, c_black, image_alpha * 0.45);
    draw_sprite_ext(sprite_index, image_index, x + 1, y, 1, 1, 0, c_black, image_alpha * 0.45);
    draw_sprite_ext(sprite_index, image_index, x, y - 1, 1, 1, 0, c_black, image_alpha * 0.45);
    draw_sprite_ext(sprite_index, image_index, x, y + 1, 1, 1, 0, c_black, image_alpha * 0.45);
}

draw_sprite_ext(sprite_index, image_index, _dx, _dy, escala, escala, 0, image_blend, image_alpha);

// Brilho de aproximação: acende de leve quando a nota entra na janela de acerto.
// Ensina o tempo certo sem precisar de texto.
if (modo == 0) {
    var _erro = abs(ritmo_erro_frames(id));
    if (_erro <= RITMO_JANELA_BOM) {
        var _forca = 1 - (_erro / RITMO_JANELA_BOM);
        gpu_set_blendmode(bm_add);
        draw_sprite_ext(sprite_index, image_index, x, y, 1, 1, 0, c_white, _forca * 0.3);
        gpu_set_blendmode(bm_normal);
    }
}
