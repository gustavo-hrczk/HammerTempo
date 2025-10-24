//Define a rolagem do texto
y_pos -= scroll_speed / 2;

// Verifica se os créditos já passaram completamente
if (y_pos < -string_height_ext(credit_text, line_height, 1080) ) {
    room_goto(rm_menu);
} 

// Botão para pular os créditos 
if (keyboard_check_pressed(vk_space) || keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_escape)) {
    room_goto(rm_menu);
} // Permite pular