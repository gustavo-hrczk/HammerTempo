draw_self();

// --- TRILHOS DAS LANES ---
// Histórico: a primeira versão pintava a faixa inteira com alpha constante e ficou
// pesada; a segunda usou segmentos e criou degraus visíveis. Esta desenha um
// quadrilátero com alpha interpolado por vértice — degradê contínuo, invisível do
// lado direito e presente só na aproximação do alvo.
if (!instance_exists(o_controlador_geral) || o_controlador_geral.estado_jogo != MINIGAME.RITMO) {
    exit;
}

var _lanes = [515, 565, 615, 665];
var _altura = 42;
var _alpha_esq = 0.10;   // junto ao alvo
var _alpha_dir = 0.00;   // onde a nota nasce
var _cor = c_black;

for (var i = 0; i < array_length(_lanes); i++) {
    var _y = _lanes[i];

    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_colour(0, _y, _cor, _alpha_esq);
    draw_vertex_colour(0, _y + _altura, _cor, _alpha_esq);
    draw_vertex_colour(room_width, _y, _cor, _alpha_dir);
    draw_vertex_colour(room_width, _y + _altura, _cor, _alpha_dir);
    draw_primitive_end();
}

draw_set_alpha(1);
draw_set_color(c_white);
