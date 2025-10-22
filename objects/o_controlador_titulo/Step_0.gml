// Lógica para navegar no menu (usando setas cima/baixo) e selecionar com Enter
if (keyboard_check_pressed(vk_down)) {
    opcao_selecionada = (opcao_selecionada + 1) % array_length(opcoes_menu);
}
if (keyboard_check_pressed(vk_up)) {
    opcao_selecionada = (opcao_selecionada - 1 + array_length(opcoes_menu)) % array_length(opcoes_menu);
}

// Se selecionou "Iniciar Jogo"
if (keyboard_check_pressed(vk_enter) && opcao_selecionada == 0) {
    // AVISA AO CONTROLADOR GERAL PARA INICIAR A TRANSIÇÃO
    o_controlador_geral.iniciar_transicao_camera = true;

    // VAI PARA A SALA DA FORJA
    room_goto(rm_forja);
}