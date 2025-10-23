// Define a fonte 
draw_set_font(f_padrao); 

// Defina a cor do texto
draw_set_color(c_dkgrey);

// Desenha o texto, permitindo quebra de linha
draw_text_ext(1280 / 8, y_pos, credit_text, line_height, 1280 - 300); 

// Botão para pular os créditos 
if (keyboard_check_pressed(vk_space)) {
    room_goto(rm_menu);} // Permite pular