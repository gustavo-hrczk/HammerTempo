/// scr_input — camada de ações de entrada
/// Nenhum objeto deve consultar keyboard_* ou gamepad_* diretamente: todos perguntam
/// por AÇÕES. Assim teclado, encoder de arcade e controle convivem sem duplicar código,
/// e o remapeamento (Sprint 3.5) precisa mexer só neste arquivo.

/// Ações do jogo. __COUNT precisa ser sempre a última.
enum ACAO {
    LANE_CIMA,
    LANE_BAIXO,
    LANE_ESQ,
    LANE_DIR,
    CONFIRMAR,
    VOLTAR,
    PAUSAR,
    __COUNT
}

#macro INPUT_DEADZONE 0.5

/// Associa teclas e botões de controle a uma ação.
function input_bind(_acao, _teclas, _botoes) {
    global.input_teclas[_acao] = _teclas;
    global.input_botoes[_acao] = _botoes;
}

/// Prepara a camada de input. Chamado uma única vez, no boot.
function input_init() {
    global.input_slot = -1;              // slot do controle ativo (-1 = nenhum)
    global.input_dispositivo = "teclado"; // último dispositivo usado (para os ícones da UI)
    global.input_teclas = array_create(ACAO.__COUNT, []);
    global.input_botoes = array_create(ACAO.__COUNT, []);
    global.input_eixo_agora = [false, false, false, false];   // cima, baixo, esq, dir
    global.input_eixo_antes = [false, false, false, false];

    // As lanes ficam só no direcional (d-pad + analógico): os botões de ação
    // são reservados para confirmar/voltar, evitando conflito no gabinete.
    input_bind(ACAO.LANE_CIMA,  [vk_up,    ord("W")], [gp_padu]);
    input_bind(ACAO.LANE_BAIXO, [vk_down,  ord("S")], [gp_padd]);
    input_bind(ACAO.LANE_ESQ,   [vk_left,  ord("A")], [gp_padl]);
    input_bind(ACAO.LANE_DIR,   [vk_right, ord("D")], [gp_padr]);

    input_bind(ACAO.CONFIRMAR,  [vk_enter, vk_space], [gp_face1, gp_start]);
    input_bind(ACAO.VOLTAR,     [vk_escape],          [gp_face2, gp_select]);
    input_bind(ACAO.PAUSAR,     [vk_escape],          [gp_start]);
}

/// Índice do eixo analógico correspondente à ação (-1 se a ação não é direcional).
function input_eixo_indice(_acao) {
    switch (_acao) {
        case ACAO.LANE_CIMA:  return 0;
        case ACAO.LANE_BAIXO: return 1;
        case ACAO.LANE_ESQ:   return 2;
        case ACAO.LANE_DIR:   return 3;
        default: return -1;
    }
}

/// Atualiza o slot do controle e o estado do analógico. Chamado uma vez por frame.
function input_update() {
    // Procura um controle conectado (suporta plugar/desplugar durante o jogo).
    if (global.input_slot < 0 || !gamepad_is_connected(global.input_slot)) {
        global.input_slot = -1;
        var _total = gamepad_get_device_count();
        for (var i = 0; i < _total; i++) {
            if (gamepad_is_connected(i)) {
                global.input_slot = i;
                break;
            }
        }
    }

    array_copy(global.input_eixo_antes, 0, global.input_eixo_agora, 0, 4);

    if (global.input_slot >= 0) {
        var _s = global.input_slot;
        var _h = gamepad_axis_value(_s, gp_axislh);
        var _v = gamepad_axis_value(_s, gp_axislv);
        global.input_eixo_agora[0] = (_v < -INPUT_DEADZONE);
        global.input_eixo_agora[1] = (_v >  INPUT_DEADZONE);
        global.input_eixo_agora[2] = (_h < -INPUT_DEADZONE);
        global.input_eixo_agora[3] = (_h >  INPUT_DEADZONE);
    } else {
        global.input_eixo_agora[0] = false;
        global.input_eixo_agora[1] = false;
        global.input_eixo_agora[2] = false;
        global.input_eixo_agora[3] = false;
    }
}

/// A ação foi acionada neste frame?
function input_pressed(_acao) {
    var _teclas = global.input_teclas[_acao];
    for (var i = 0; i < array_length(_teclas); i++) {
        if (keyboard_check_pressed(_teclas[i])) {
            global.input_dispositivo = "teclado";
            return true;
        }
    }

    var _s = global.input_slot;
    if (_s >= 0) {
        var _botoes = global.input_botoes[_acao];
        for (var i = 0; i < array_length(_botoes); i++) {
            if (gamepad_button_check_pressed(_s, _botoes[i])) {
                global.input_dispositivo = "gamepad";
                return true;
            }
        }
        var _eixo = input_eixo_indice(_acao);
        if (_eixo >= 0 && global.input_eixo_agora[_eixo] && !global.input_eixo_antes[_eixo]) {
            global.input_dispositivo = "gamepad";
            return true;
        }
    }

    return false;
}

/// A ação está sendo mantida pressionada?
function input_held(_acao) {
    var _teclas = global.input_teclas[_acao];
    for (var i = 0; i < array_length(_teclas); i++) {
        if (keyboard_check(_teclas[i])) return true;
    }

    var _s = global.input_slot;
    if (_s >= 0) {
        var _botoes = global.input_botoes[_acao];
        for (var i = 0; i < array_length(_botoes); i++) {
            if (gamepad_button_check(_s, _botoes[i])) return true;
        }
        var _eixo = input_eixo_indice(_acao);
        if (_eixo >= 0 && global.input_eixo_agora[_eixo]) return true;
    }

    return false;
}

/// Eixo horizontal discreto (-1, 0, 1) para navegação de menu.
function input_eixo_h() {
    return input_pressed(ACAO.LANE_DIR) - input_pressed(ACAO.LANE_ESQ);
}

/// Eixo vertical discreto (-1, 0, 1) para navegação de menu.
function input_eixo_v() {
    return input_pressed(ACAO.LANE_BAIXO) - input_pressed(ACAO.LANE_CIMA);
}

/// Há um controle conectado?
function input_tem_gamepad() {
    return (global.input_slot >= 0);
}

// =====================================================================
// NOMES LEGÍVEIS DOS CONTROLES
// A tela de tutorial escrevia "W A D S" na unha. Assim que o remapeamento existir
// (e no gabinete ele vai existir), um rótulo fixo passa a mentir para o jogador.
// Estas funções leem o vínculo de verdade, então a tela acompanha sozinha.
// =====================================================================

/// Nome de exibição de uma tecla de teclado.
function input_nome_da_tecla(_codigo) {
    switch (_codigo) {
        case vk_up:      return "CIMA";
        case vk_down:    return "BAIXO";
        case vk_left:    return "ESQ.";
        case vk_right:   return "DIR.";
        case vk_space:   return "ESPAÇO";
        case vk_enter:   return "ENTER";
        case vk_escape:  return "ESC";
        case vk_shift:   return "SHIFT";
        case vk_control: return "CTRL";
        case vk_tab:     return "TAB";
    }

    // letras e números falam por si
    if ((_codigo >= ord("A") && _codigo <= ord("Z"))
        || (_codigo >= ord("0") && _codigo <= ord("9"))) {
        return chr(_codigo);
    }

    return "?";
}

/// Nome de exibição de um botão de controle.
function input_nome_do_botao(_codigo) {
    switch (_codigo) {
        case gp_face1:     return "BOTÃO 1";
        case gp_face2:     return "BOTÃO 2";
        case gp_face3:     return "BOTÃO 3";
        case gp_face4:     return "BOTÃO 4";
        case gp_shoulderl: return "L1";
        case gp_shoulderr: return "R1";
        case gp_start:     return "START";
        case gp_select:    return "SELECT";
        case gp_padu:      return "CIMA";
        case gp_padd:      return "BAIXO";
        case gp_padl:      return "ESQ.";
        case gp_padr:      return "DIR.";
    }
    return "?";
}

/// Como o jogador aciona esta ação, no dispositivo em uso.
///
/// No teclado, prefere o vínculo que NÃO é seta direcional quando existe outro: as
/// setas já estão desenhadas no ícone do alvo, então repetir "CIMA" ao lado de uma
/// seta para cima não ensina nada, enquanto "W" ensina. Se a seta for o único
/// vínculo, ela é usada mesmo assim.
function input_nome_da_acao(_acao) {
    if (global.input_dispositivo == "gamepad") {
        var _botoes = global.input_botoes[_acao];
        if (array_length(_botoes) > 0) return input_nome_do_botao(_botoes[0]);
    }

    var _teclas = global.input_teclas[_acao];
    if (array_length(_teclas) == 0) return "?";

    for (var i = 0; i < array_length(_teclas); i++) {
        var _t = _teclas[i];
        if (_t != vk_up && _t != vk_down && _t != vk_left && _t != vk_right) {
            return input_nome_da_tecla(_t);
        }
    }

    return input_nome_da_tecla(_teclas[0]);
}
