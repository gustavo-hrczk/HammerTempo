// As notas somem durante TODA a pausa, incluindo a contagem de retomada.
//
// Elas voltavam na retomada com a ideia de o jogador reencontrar o que vinha, e isso
// era um furo: bastava pausar, estudar o padrão que estava chegando com o jogo
// congelado e retomar decorado. A contagem de retomada e o menu de pausa sao o mesmo
// momento do ponto de vista da vantagem — o jogo esta parado nos dois.
//
// De quebra resolve uma colisao de leitura: o numero da retomada e desenhado no meio
// do corredor, em cima de onde as notas estariam.
if (o_controlador_geral.pausa) {
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
