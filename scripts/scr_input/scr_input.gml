/// scr_input — camada de ações de entrada
/// Nenhum objeto deve consultar keyboard_* ou gamepad_* diretamente: todos perguntam
/// por AÇÕES. Assim teclado, encoder de arcade e controle convivem sem duplicar código,
/// e o remapeamento (Sprint 3.5) precisa mexer só neste arquivo.

/// Ações do jogo. __COUNT precisa ser sempre a última.
enum ACAO {
    // Faixas da forja. Estas SÃO remapeáveis: são o que o jogador martela.
    LANE_CIMA,
    LANE_BAIXO,
    LANE_ESQ,
    LANE_DIR,

    CONFIRMAR,
    VOLTAR,
    PAUSAR,

    // Direcionais de MENU. Existem separados das faixas de propósito.
    //
    // Antes os menus navegavam pelas próprias LANE_*, então remapear uma faixa
    // levava junto a navegação de todas as telas: trocar "Cima" da forja trocava
    // também o "para cima" do menu, das opções e da própria tela de controles —
    // e bastava um vínculo infeliz para não haver mais como sair de lugar nenhum.
    //
    // Não entram em input_acoes_configuraveis() nem são gravados no save: ficam
    // sempre nos vínculos de fábrica, e são a garantia de que os menus continuam
    // navegáveis independentemente do que o jogador fizer com a forja.
    MENU_CIMA,
    MENU_BAIXO,
    MENU_ESQ,
    MENU_DIR,

    // Faixas do JOGADOR 2. Existem só no Versus, e são remapeáveis como as do 1.
    //
    // A divisão de fábrica segue o teclado compartilhado: WASD à esquerda para o
    // jogador 1, setas à direita para o jogador 2 — cada um alcança as suas sem
    // disputar espaço com o outro.
    LANE2_CIMA,
    LANE2_BAIXO,
    LANE2_ESQ,
    LANE2_DIR,

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
    global.input_teclas_fixas = array_create(ACAO.__COUNT, []);
    global.input_eixo_agora = [false, false, false, false];   // cima, baixo, esq, dir
    global.input_eixo_antes = [false, false, false, false];

    input_vinculos_de_fabrica();
    input_vinculos_fixos();
}

/// Vínculos que valem SEMPRE, somados ao que o jogador configurar e imunes ao
/// remapeamento.
///
/// As setas acionam as faixas da forja em caráter absoluto. Elas são o controle que
/// combina com o desenho da tela — quatro faixas empilhadas, com um ícone de seta em
/// cada uma —, e nenhum remapeamento deve tirar do teclado a forma de jogar que a
/// própria tela ensina. Quem configurar botões de arcade ganha os botões; as setas
/// continuam ali.
function input_vinculos_fixos() {
    global.input_teclas_fixas[ACAO.LANE_CIMA]  = [vk_up];
    global.input_teclas_fixas[ACAO.LANE_BAIXO] = [vk_down];
    global.input_teclas_fixas[ACAO.LANE_ESQ]   = [vk_left];
    global.input_teclas_fixas[ACAO.LANE_DIR]   = [vk_right];
}

/// Teclas que a captura recusa.
///
/// As setas já acionam as faixas em caráter fixo e navegam os menus; ESC é a saída
/// de emergência da tela de controles. Vincular qualquer uma delas a outra ação
/// criaria um comando que dispara duas coisas ao mesmo tempo, sem nada na tela
/// explicando por quê.
function input_tecla_reservada(_tecla) {
    return (_tecla == vk_up || _tecla == vk_down
         || _tecla == vk_left || _tecla == vk_right
         || _tecla == vk_escape);
}

/// Vínculos de fábrica. Separados do init porque o "Restaurar padrão" da tela de
/// controles precisa voltar exatamente a este estado.
///
/// As lanes ficam só no direcional (d-pad + analógico): os botões de ação são
/// reservados para confirmar/voltar, evitando conflito no gabinete.
function input_vinculos_de_fabrica() {
    input_bind(ACAO.LANE_CIMA,  [vk_up,    ord("W")], [gp_padu]);
    input_bind(ACAO.LANE_BAIXO, [vk_down,  ord("S")], [gp_padd]);
    input_bind(ACAO.LANE_ESQ,   [vk_left,  ord("A")], [gp_padl]);
    input_bind(ACAO.LANE_DIR,   [vk_right, ord("D")], [gp_padr]);

    input_bind(ACAO.CONFIRMAR,  [vk_enter, vk_space], [gp_face1, gp_start]);
    input_bind(ACAO.VOLTAR,     [vk_escape],          [gp_face2, gp_select]);
    input_bind(ACAO.PAUSAR,     [vk_escape],          [gp_start]);

    // Navegação de menu: setas E WASD, para continuar respondendo mesmo que o
    // jogador leve as faixas da forja para outras teclas.
    input_bind(ACAO.MENU_CIMA,  [vk_up,    ord("W")], [gp_padu]);
    input_bind(ACAO.MENU_BAIXO, [vk_down,  ord("S")], [gp_padd]);
    input_bind(ACAO.MENU_ESQ,   [vk_left,  ord("A")], [gp_padl]);
    input_bind(ACAO.MENU_DIR,   [vk_right, ord("D")], [gp_padr]);

    // Faixas do jogador 2: as setas, do lado direito do teclado. Sem botão de
    // controle por padrão — um segundo gamepad precisa ser mapeado à mão.
    input_bind(ACAO.LANE2_CIMA,  [vk_up],    []);
    input_bind(ACAO.LANE2_BAIXO, [vk_down],  []);
    input_bind(ACAO.LANE2_ESQ,   [vk_left],  []);
    input_bind(ACAO.LANE2_DIR,   [vk_right], []);
}

/// A ação de faixa de um jogador. _dono é 0 para o jogador 1 e 1 para o 2.
///
/// Todo o gameplay pergunta por aqui em vez de nomear ACAO.LANE_* direto: é o que
/// permite o mesmo código de julgamento servir aos dois jogadores.
/// O par tipo->acao NAO e o que a intuicao sugere: o tipo 2 e DIREITA e o tipo 3 e
/// ESQUERDA. Quem manda e o Instance Creation Code de rm_forja, que e a origem da
/// convencao desde a jam, e a mesma inversao aparece nos nomes dos sprites de impacto.
/// Escrever na ordem "natural" aqui trocaria as duas faixas do meio do jogador 2.
function input_lane(_dono, _tipo) {
    if (_dono == 0) {
        switch (_tipo) {
            case 0: return ACAO.LANE_BAIXO;
            case 1: return ACAO.LANE_CIMA;
            case 2: return ACAO.LANE_DIR;
            case 3: return ACAO.LANE_ESQ;
        }
    }
    switch (_tipo) {
        case 0: return ACAO.LANE2_BAIXO;
        case 1: return ACAO.LANE2_CIMA;
        case 2: return ACAO.LANE2_DIR;
        case 3: return ACAO.LANE2_ESQ;
    }
    return ACAO.LANE_CIMA;
}

/// Sprite do alvo de cada faixa, na mesma convencao.
function ritmo_sprite_alvo(_tipo) {
    switch (_tipo) {
        case 0: return s_alvo_baixo;
        case 1: return s_alvo_cima;
        case 2: return s_alvo_direita;
    }
    return s_alvo_esquerda;
}

/// A ação é uma faixa da forja do jogador 1?
///
/// Usada para suspender os vínculos FIXOS dentro do Versus: as setas são vínculo fixo
/// das faixas do jogador 1 desde sempre, e no Versus elas pertencem ao jogador 2 —
/// sem isto, cada tecla do jogador 2 martelaria também para o jogador 1.
function input_lane_do_jogador1(_acao) {
    return (_acao == ACAO.LANE_CIMA || _acao == ACAO.LANE_BAIXO
         || _acao == ACAO.LANE_ESQ  || _acao == ACAO.LANE_DIR);
}

/// Identificador estável da ação no save. Não usa o índice do enum de propósito:
/// inserir uma ação no meio da lista embaralharia todo mapeamento já gravado —
/// mesmo cuidado de save_id_fase().
function input_id_acao(_acao) {
    switch (_acao) {
        case ACAO.LANE_CIMA:  return "lane_cima";
        case ACAO.LANE_BAIXO: return "lane_baixo";
        case ACAO.LANE_ESQ:   return "lane_esq";
        case ACAO.LANE_DIR:   return "lane_dir";
        case ACAO.CONFIRMAR:  return "confirmar";
        case ACAO.VOLTAR:     return "voltar";
        case ACAO.PAUSAR:     return "pausar";

        case ACAO.LANE2_CIMA:  return "lane2_cima";
        case ACAO.LANE2_BAIXO: return "lane2_baixo";
        case ACAO.LANE2_ESQ:   return "lane2_esq";
        case ACAO.LANE2_DIR:   return "lane2_dir";
    }

    // MENU_* cai aqui de propósito: sem identificador, input_aplicar_save() e
    // input_gravar_controles() ignoram essas ações, e elas permanecem sempre nos
    // vínculos de fábrica. É o que impede o remapeamento da forja de alcançar a
    // navegação dos menus.
    return "";
}

/// Rótulo da ação na tela de controles.
function input_rotulo_acao(_acao) {
    switch (_acao) {
        case ACAO.LANE_CIMA:  return "Faixa 1";
        case ACAO.LANE_ESQ:   return "Faixa 2";
        case ACAO.LANE_DIR:   return "Faixa 3";
        case ACAO.LANE_BAIXO: return "Faixa 4";
        case ACAO.CONFIRMAR:  return "Confirmar";
        case ACAO.VOLTAR:     return "Voltar";
        case ACAO.PAUSAR:     return "Pausar";

        case ACAO.LANE2_CIMA:  return "P2 Faixa 1";
        case ACAO.LANE2_ESQ:   return "P2 Faixa 2";
        case ACAO.LANE2_DIR:   return "P2 Faixa 3";
        case ACAO.LANE2_BAIXO: return "P2 Faixa 4";
    }
    return "?";
}

/// Ordem em que as ações aparecem na tela de controles: as quatro faixas na mesma
/// sequência de cima para baixo em que estão em rm_forja, depois os comandos.
function input_acoes_configuraveis() {
    return [ACAO.LANE_CIMA, ACAO.LANE_ESQ, ACAO.LANE_DIR, ACAO.LANE_BAIXO,
            ACAO.CONFIRMAR, ACAO.VOLTAR, ACAO.PAUSAR];
}

/// As faixas do jogador 2, numa segunda pagina da tela de controles.
///
/// Ficam separadas em vez de somadas a lista acima porque onze linhas nao cabem na
/// moldura — e porque quem esta configurando o jogador 1 raramente quer o 2 na mesma
/// tela.
function input_acoes_configuraveis_p2() {
    return [ACAO.LANE2_CIMA, ACAO.LANE2_ESQ, ACAO.LANE2_DIR, ACAO.LANE2_BAIXO];
}

/// Aplica sobre os vínculos de fábrica o que estiver gravado no save.
///
/// Precisa rodar DEPOIS de save_carregar(): no boot, input_init() vem antes, então
/// esta função é o segundo passo. O save guarda só o que foi remapeado — o que não
/// estiver lá continua de fábrica, e assim mudar um padrão no futuro alcança quem
/// nunca mexeu nos controles.
function input_aplicar_save() {
    if (!variable_global_exists("save") || !is_struct(global.save)) return;
    if (!variable_struct_exists(global.save, "controles")) return;

    var _c = global.save.controles;
    if (!is_struct(_c)) return;

    for (var _a = 0; _a < ACAO.__COUNT; _a++) {
        var _id = input_id_acao(_a);
        if (_id == "" || !variable_struct_exists(_c, _id)) continue;

        var _v = _c[$ _id];
        if (!is_struct(_v)) continue;

        if (variable_struct_exists(_v, "teclas") && is_array(_v.teclas)) {
            global.input_teclas[_a] = _v.teclas;
        }
        if (variable_struct_exists(_v, "botoes") && is_array(_v.botoes)) {
            global.input_botoes[_a] = _v.botoes;
        }
    }
}

/// Índice do eixo analógico correspondente à ação (-1 se a ação não é direcional).
function input_eixo_indice(_acao) {
    switch (_acao) {
        case ACAO.LANE_CIMA:  case ACAO.MENU_CIMA:  return 0;
        case ACAO.LANE_BAIXO: case ACAO.MENU_BAIXO: return 1;
        case ACAO.LANE_ESQ:   case ACAO.MENU_ESQ:   return 2;
        case ACAO.LANE_DIR:   case ACAO.MENU_DIR:   return 3;
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

    // Os vínculos FIXOS (as setas) valem para as faixas do jogador 1 fora do Versus.
    // Dentro dele as setas pertencem ao jogador 2, e mantê-las aqui faria cada tecla
    // dele martelar para os dois.
    if (!(versus_ativo() && input_lane_do_jogador1(_acao))) {
        var _fixas = global.input_teclas_fixas[_acao];
        for (var i = 0; i < array_length(_fixas); i++) {
            if (keyboard_check_pressed(_fixas[i])) {
                global.input_dispositivo = "teclado";
                return true;
            }
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

    // Os vínculos FIXOS (as setas) valem para as faixas do jogador 1 fora do Versus.
    // Dentro dele as setas pertencem ao jogador 2, e mantê-las aqui faria cada tecla
    // dele martelar para os dois.
    if (!(versus_ativo() && input_lane_do_jogador1(_acao))) {
        var _fixas = global.input_teclas_fixas[_acao];
        for (var i = 0; i < array_length(_fixas); i++) {
            if (keyboard_check(_fixas[i])) return true;
        }
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
    return input_pressed(ACAO.MENU_DIR) - input_pressed(ACAO.MENU_ESQ);
}

/// Eixo vertical discreto (-1, 0, 1) para navegação de menu.
function input_eixo_v() {
    return input_pressed(ACAO.MENU_BAIXO) - input_pressed(ACAO.MENU_CIMA);
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

    // Sem vínculo configurável, mas com um fixo, a ação continua funcionando —
    // exibir "NENHUM" ali seria mentira.
    if (array_length(_teclas) == 0) {
        var _fixas = global.input_teclas_fixas[_acao];
        if (array_length(_fixas) > 0) return input_nome_da_tecla(_fixas[0]);
        return "NENHUM";
    }

    for (var i = 0; i < array_length(_teclas); i++) {
        var _t = _teclas[i];
        if (_t != vk_up && _t != vk_down && _t != vk_left && _t != vk_right) {
            return input_nome_da_tecla(_t);
        }
    }

    return input_nome_da_tecla(_teclas[0]);
}

// =====================================================================
// REMAPEAMENTO
// =====================================================================

/// Botões de controle que a captura reconhece.
function input_botoes_conhecidos() {
    return [gp_face1, gp_face2, gp_face3, gp_face4,
            gp_shoulderl, gp_shoulderr, gp_start, gp_select,
            gp_padu, gp_padd, gp_padl, gp_padr];
}

/// Primeiro botão do controle ativo pressionado neste frame, ou -1.
function input_botao_pressionado() {
    var _s = global.input_slot;
    if (_s < 0) return -1;

    var _lista = input_botoes_conhecidos();
    for (var i = 0; i < array_length(_lista); i++) {
        if (gamepad_button_check_pressed(_s, _lista[i])) return _lista[i];
    }
    return -1;
}

/// Grava a tabela inteira de vínculos no save.
///
/// Grava tudo, e não só a ação alterada, porque remapear costuma mexer em mais de
/// uma: o controle escolhido é retirado de quem o usava antes. A partir da primeira
/// alteração o mapeamento passa a ser do jogador — "Restaurar padrão" esvazia a
/// chave e devolve o save ao estado de seguir os vínculos de fábrica.
function input_gravar_controles() {
    if (!variable_global_exists("save") || !is_struct(global.save)) return;

    var _c = {};
    for (var _a = 0; _a < ACAO.__COUNT; _a++) {
        var _id = input_id_acao(_a);
        if (_id == "") continue;

        _c[$ _id] = {
            teclas: global.input_teclas[_a],
            botoes: global.input_botoes[_a]
        };
    }

    global.save.controles = _c;
    save_gravar();
}

/// Tira um controle de todas as ações menos a que vai recebê-lo. Dois comandos no
/// mesmo botão deixam o gabinete imprevisível — e é o tipo de erro que só aparece
/// no meio de uma partida, com fila esperando.
function input_liberar_controle(_acao_dona, _codigo, _no_teclado) {
    for (var _a = 0; _a < ACAO.__COUNT; _a++) {
        if (_a == _acao_dona) continue;

        var _origem = _no_teclado ? global.input_teclas[_a] : global.input_botoes[_a];
        var _limpo = [];

        for (var i = 0; i < array_length(_origem); i++) {
            if (_origem[i] != _codigo) array_push(_limpo, _origem[i]);
        }

        if (_no_teclado) {
            global.input_teclas[_a] = _limpo;
        } else {
            global.input_botoes[_a] = _limpo;
        }
    }
}

/// Passa a ação a responder a esta tecla, e só a ela.
function input_definir_tecla(_acao, _tecla) {
    input_liberar_controle(_acao, _tecla, true);
    global.input_teclas[_acao] = [_tecla];
    input_gravar_controles();
}

/// Passa a ação a responder a este botão de controle, e só a ele.
function input_definir_botao(_acao, _botao) {
    input_liberar_controle(_acao, _botao, false);
    global.input_botoes[_acao] = [_botao];
    input_gravar_controles();
}

/// Devolve tudo ao estado de fábrica e esvazia a chave do save, para o mapeamento
/// voltar a acompanhar os padrões do jogo em vez de ficar congelado no disco.
function input_restaurar_padrao() {
    input_vinculos_de_fabrica();

    if (variable_global_exists("save") && is_struct(global.save)) {
        global.save.controles = {};
        save_gravar();
    }
}
