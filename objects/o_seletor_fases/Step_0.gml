// Este objeto só funciona se o jogo estiver no estado de SELECAO_FASE
if (o_controlador_geral.estado_jogo != MINIGAME.SELECAO_FASE) {
    exit;
}

if (keyboard_check(vk_escape)) {
    room_goto(rm_menu); // Alterado para ir para o menu, não a sala anterior
}

// --- LÓGICA DE NAVEGAÇÃO EM GRADE ---
var _items_por_linha = 3;

// Navegação Horizontal (Esquerda/Direita)
var _move_h = keyboard_check_pressed(vk_right) - keyboard_check_pressed(vk_left);
if (_move_h == 0) { // <<< CORRIGIDO: Usando '==' para comparação
    _move_h = keyboard_check_pressed(ord("D")) - keyboard_check_pressed(ord("A"));
}
if (_move_h != 0) {
    opcao_selecionada += _move_h;
}

// Navegação Vertical (Cima/Baixo)
var _move_v = keyboard_check_pressed(vk_down) - keyboard_check_pressed(vk_up);
if (_move_v == 0) { // <<< CORRIGIDO: Usando '==' para comparação
    _move_v = keyboard_check_pressed(ord("S")) - keyboard_check_pressed(ord("W"));
}
if (_move_v != 0) {
    opcao_selecionada += _move_v * _items_por_linha;
}

// Lógica para o cursor "dar a volta" e se manter dentro dos limites
if (opcao_selecionada < 0) { opcao_selecionada = total_opcoes - 1; }
if (opcao_selecionada >= total_opcoes) { opcao_selecionada = 0; }


// --- LÓGICA DE SELEÇÃO (ENTER) ---
if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
    
    // 1. Zera as estatísticas para a nova partida
    o_controlador_geral.resetar_estatisticas();
    
    // 2. Informa ao controlador qual fase foi escolhida
    o_controlador_geral.fase_atual = opcao_selecionada;
    
    // 3. >>> A CORREÇÃO PRINCIPAL ESTÁ AQUI <<<
    // Muda o estado do jogo para CONTAGEM
    o_controlador_geral.estado_jogo = MINIGAME.CONTAGEM;
    
    // 4. Define o tempo inicial da contagem no controlador geral
    o_controlador_geral.contagem_timer = 3 * room_speed;
    
    // 5. O trabalho deste objeto acabou. Ele se autodestrói.
    instance_destroy();
}