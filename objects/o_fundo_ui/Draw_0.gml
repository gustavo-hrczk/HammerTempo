draw_self();

// --- TRILHOS DAS LANES ---
// O trilho começa na zona de acerto e se desfaz à direita: ele existe para guiar a
// chegada da nota, não para riscar a tela de ponta a ponta. É mais estreito que a
// lane e fica centralizado nela, passando por baixo da nota.
if (!instance_exists(o_controlador_geral) || o_controlador_geral.estado_jogo != MINIGAME.RITMO) {
    exit;
}

var _lanes = ritmo_lanes_y(dono);
var _lane_altura = 42;
var _altura = 26;                       // mais estreito que a lane
var _offset = (_lane_altura - _altura) / 2;

// O trilho nasce na zona de acerto do DONO e se desfaz na direcao de onde as notas
// vem — para o jogador 2 isso e o lado oposto, porque a pista dele e o espelho.
var _x_inicio = ritmo_linha_x(dono);
var _x_fim = _x_inicio - (ritmo_sentido(dono) * 722);
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
