draw_self();

// --- TRILHOS DAS LANES ---
// O trilho começa na zona de acerto e se desfaz à direita: ele existe para guiar a
// chegada da nota, não para riscar a tela de ponta a ponta. É mais estreito que a
// lane e fica centralizado nela, passando por baixo da nota.
if (!instance_exists(o_controlador_geral) || o_controlador_geral.estado_jogo != MINIGAME.RITMO) {
    exit;
}

var _lanes = [515, 565, 615, 665];
var _lane_altura = 42;
var _altura = 26;                       // mais estreito que a lane
var _offset = (_lane_altura - _altura) / 2;

var _x_inicio = RITMO_LINHA_X;          // nasce na zona de acerto
var _x_fim = 820;                       // e se desfaz bem antes da borda direita
// segue o mesmo fade de entrada do HUD, para nada aparecer de uma vez só
var _alpha_inicio = 0.10 * global.hud_entrada;
var _cor = c_black;

for (var i = 0; i < array_length(_lanes); i++) {
    var _y = _lanes[i] + _offset;

    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_colour(_x_inicio, _y, _cor, _alpha_inicio);
    draw_vertex_colour(_x_inicio, _y + _altura, _cor, _alpha_inicio);
    draw_vertex_colour(_x_fim, _y, _cor, 0);
    draw_vertex_colour(_x_fim, _y + _altura, _cor, 0);
    draw_primitive_end();
}

draw_set_alpha(1);
draw_set_color(c_white);
