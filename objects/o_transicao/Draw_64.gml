// Este evento desenha a camada preta por cima de tudo
if (alpha > 0) {
    var _w = display_get_gui_width();
    var _h = display_get_gui_height();
    draw_set_color(c_black);
    draw_set_alpha(alpha);
    draw_rectangle(0, 0, _w, _h, false);
    draw_set_alpha(1); // Reseta para não afetar outros objetos
}