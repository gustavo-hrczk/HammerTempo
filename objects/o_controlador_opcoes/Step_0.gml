// --- CONTROLE DE NAVEGAÇÃO ---

if(room != rm_opcoes){
	exit;
}

if(room = rm_opcoes && keyboard_check(vk_escape)){
	room_goto(rm_menu);
}

var _move = keyboard_check_pressed(vk_down) - keyboard_check_pressed(vk_up);
if (_move == 0) { // Corrigido de '=' para '==' para comparação
    _move = keyboard_check_pressed(ord("S")) - keyboard_check_pressed(ord("W"));
}
if (_move != 0) {
    opcao_selecionada += _move;
    var _total_opcoes = array_length(opcoes_menu);
    
    // Lógica para o cursor "dar a volta" (loop)
    if (opcao_selecionada < 0) {
        opcao_selecionada = _total_opcoes - 1;
    }
    if (opcao_selecionada >= _total_opcoes) {
        opcao_selecionada = 0;
    }
}

// --- CONTROLE DE SELEÇÃO ---
if (keyboard_check_pressed(vk_left) || keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("A")) || keyboard_check_pressed(ord("D")) || keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
    
    switch (opcao_selecionada) {
		case 0: // volume
            if(keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"))){
				if(opcoes_volume-0.01 <= 0){
					opcoes_volume = 0
				} else {
					opcoes_volume -= 0.01
				}
			}
			if(keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"))){
				if(opcoes_volume+0.01 >= 1){
					opcoes_volume = 1
				} else {
					opcoes_volume += 0.01
				}
			}
            break;
            
        case 1: // fullscreen
            if(keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"))){
				opcoes_tela_cheia = !opcoes_tela_cheia
			}
			if(keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"))){
				opcoes_tela_cheia = !opcoes_tela_cheia
			}
            break;
			
		case 2: //aplicar
			if(keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)){
				window_set_fullscreen(opcoes_tela_cheia)
				audio_play_sound(snd_menu_confirm, 10, false);
				audio_sound_gain(snd_menu_confirm, o_controlador_opcoes.opcoes_volume,0);
				room_goto(rm_menu);
			}
            break;
    }
}