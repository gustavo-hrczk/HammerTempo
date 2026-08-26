//Define a rolagem do texto
y_pos -= scroll_speed / 2;

// Verifica se os créditos já passaram completamente
if (y_pos < -string_height_ext(credit_text, line_height, CREDITOS_LARGURA)) {
    ir_para_sala(rm_menu);
}

// Botão para pular os créditos 
if (input_pressed(ACAO.CONFIRMAR) || input_pressed(ACAO.VOLTAR)) {
    o_audio_manager.play_sfx(snd_menu_return);
    ir_para_sala(rm_menu);
}