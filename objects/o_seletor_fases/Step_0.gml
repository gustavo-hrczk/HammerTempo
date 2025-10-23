// Este objeto só funciona se o jogo estiver no estado de SELECAO_FASE (1)
if (o_controlador_geral.estado_jogo != 1) {
    exit;
}

// --- LÓGICA DE NAVEGAÇÃO EM GRADE ---
var _items_por_linha = 3; // O mesmo valor do seu Draw Event

// Navegação Horizontal (Esquerda/Direita)
var _move_h = keyboard_check_pressed(vk_right) - keyboard_check_pressed(vk_left);
if(_move_h = 0){
	_move_h = keyboard_check_pressed(ord("D")) - keyboard_check_pressed(ord("A"));
}
if (_move_h != 0) {
    opcao_selecionada += _move_h;
}

// Navegação Vertical (Cima/Baixo)
var _move_v = keyboard_check_pressed(vk_down) - keyboard_check_pressed(vk_up);
if(_move_v = 0){
	_move_v = keyboard_check_pressed(ord("S")) - keyboard_check_pressed(ord("W"));
}
if (_move_v != 0) {
    opcao_selecionada += _move_v * _items_por_linha;
}

// Lógica para o cursor "dar a volta" e se manter dentro dos limites
if (opcao_selecionada < 0) { opcao_selecionada += total_opcoes; }
if (opcao_selecionada >= total_opcoes) { opcao_selecionada -= total_opcoes; }


// --- LÓGICA DE SELEÇÃO (ENTER) ---
if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
    o_controlador_geral.fase_atual = opcao_selecionada;
    o_controlador_geral.estado_jogo = 3; // Muda para RITMO
    instance_destroy();
}