//Define a rolagem do texto
y_pos -= scroll_speed;

// Verifica se os créditos já passaram completamente
if (y_pos < -string_height_ext(credit_text, line_height, 2280) ) {
    room_goto(rm_menu); } 

