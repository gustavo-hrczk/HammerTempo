// Este objeto só funciona se o jogo estiver no estado de SELECAO_FASE (1)
if (o_controlador_geral.estado_jogo != MINIGAME.SELECAO_FASE) {
    exit;
}

// --- LÓGICA DE RETORNO (ESC) ---
if (keyboard_check_pressed(vk_escape)) {
    // Toca o som de retorno e ajusta o volume mestre, se necessário.
    audio_play_sound(snd_voltar_cancelar, 10, false);
    
    // Mudar de sala usando a transição suave
    o_transicao.mudar_de_sala(rm_menu);
    exit;
}


// --- LÓGICA DE NAVEGAÇÃO HORIZONTAL (SIMPLIFICADA) ---
var _items_por_linha = 3; 

// 1. Calcula o movimento HORIZONTAL, somando as setas e as teclas
var _move_h = keyboard_check_pressed(vk_right) - keyboard_check_pressed(vk_left);
_move_h += keyboard_check_pressed(ord("D")) - keyboard_check_pressed(ord("A"));

// 2. Calcula o movimento VERTICAL (Apenas para garantir que o input seja lido, mesmo que não seja usado)
var _move_v = keyboard_check_pressed(vk_down) - keyboard_check_pressed(vk_up);
_move_v += keyboard_check_pressed(ord("S")) - keyboard_check_pressed(ord("W"));


// --- Lógica para MUDAR A OPÇÃO E TOCAR SOM ---
if (_move_h != 0 || _move_v != 0) { 
    // Toca o som de navegação (Lógica de alternância)
    var _som_a_tocar = o_controlador_geral.nav_sounds[o_controlador_geral.nav_sound_index];
    o_audio_manager.play_sfx(_som_a_tocar);
    o_controlador_geral.nav_sound_index = 1 - o_controlador_geral.nav_sound_index;
    
    // Calcula o novo índice (movimento vertical é ignorado pois _move_v não tem multiplicador)
    var _novo_indice = opcao_selecionada + _move_h; 
    
    // Lógica para o cursor "dar a volta" e se manter dentro dos limites
    if (_novo_indice < 0) { 
        _novo_indice += total_opcoes; 
    }
    if (_novo_indice >= total_opcoes) { 
        _novo_indice -= total_opcoes; 
    }
    
    opcao_selecionada = _novo_indice;
}


// --- LÓGICA DE SELEÇÃO (ENTER) ---
if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
    
    // >>> CORREÇÃO DO SOM DE CONFIRMAÇÃO COM VOLUME MESTRE <<<
    // A chamada do som de confirmação deve ser simples no Step do menu, 
    // pois o volume é gerenciado pelo Audio Manager ou pelo botão Aplicar do Opções.
    audio_play_sound(snd_menu_confirm, 10, false);

    o_controlador_geral.resetar_estatisticas();
    o_controlador_geral.fase_atual = opcao_selecionada;
    
    o_controlador_geral.estado_jogo = MINIGAME.CONTAGEM;
    o_controlador_geral.contagem_timer = 3 * room_speed;
    
    instance_destroy();
}