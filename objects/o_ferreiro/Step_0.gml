// --- LÓGICA DE PAUSA ---
if (instance_exists(o_controlador_geral) && o_controlador_geral.pausa) {
    image_speed = 0;
    exit;
}

// --- REAÇÃO AO ERRO: segura o frame vermelho por alguns frames ---
if (estado == FERREIRO_ESTADO.DANO) {
    dano_timer--;
    if (dano_timer > 0) {
        exit;
    }
    estado = FERREIRO_ESTADO.IDLE;
}

// =================================================================
// DECISÃO DE ESTADO
// =================================================================
if (instance_exists(o_controlador_geral)) {

    var _jogo = o_controlador_geral.estado_jogo;

    // Fora da partida ele habita a forja: alterna pausas e caminhadas curtas.
    if (_jogo == MINIGAME.SELECAO_FASE || _jogo == MINIGAME.TUTORIAL || _jogo == MINIGAME.NENHUM) {
        if (estado != FERREIRO_ESTADO.MARTELANDO) {
            indo_para_casa = false;
            ocio_timer--;

            if (ocio_timer <= 0) {
                if (random(1) < 0.45) {
                    // fica parado observando, por um tempo variável
                    estado = FERREIRO_ESTADO.IDLE;
                    ocio_timer = irandom_range(room_speed * 1.0, room_speed * 3.5);
                } else {
                    // caminha até um ponto aleatório da oficina
                    ocio_destino = random_range(passeio_min, passeio_max);
                    estado = FERREIRO_ESTADO.ANDANDO;
                    ocio_timer = room_speed * 6; // trava de segurança
                }
            }
        }
    }
    // Na contagem regressiva ele volta para a bigorna, a tempo de começar a fase.
    else if (_jogo == MINIGAME.CONTAGEM) {
        if (x != home_x) {
            estado = FERREIRO_ESTADO.ANDANDO;
            indo_para_casa = true;
        } else if (estado != FERREIRO_ESTADO.MARTELANDO) {
            estado = FERREIRO_ESTADO.IDLE;
        }
    }
    // Resultado: comemora, mas respeita a animação de falha.
    else if (_jogo == MINIGAME.RESULTADO) {
        if (estado != FERREIRO_ESTADO.FALHA && estado != FERREIRO_ESTADO.FALHOU_ESTATICO) {
            estado = FERREIRO_ESTADO.COMEMORANDO;
        }
    }
    // Durante a partida ele nunca sai do lugar.
    else if (_jogo == MINIGAME.RITMO) {
        x = home_x;
        image_xscale = 1;
        if (estado != FERREIRO_ESTADO.MARTELANDO) {
            estado = FERREIRO_ESTADO.IDLE;
        }
    }
}

// =================================================================
// EXECUÇÃO DA ANIMAÇÃO
// =================================================================
switch (estado) {

    case FERREIRO_ESTADO.IDLE:
        sprite_index = s_ferreiro_idle;
        image_speed = 0.5;
        break;

    case FERREIRO_ESTADO.ANDANDO:
        sprite_index = s_ferreiro_andando;
        image_speed = 0.6;

        var _vel = 1.2;
        var _alvo = indo_para_casa ? home_x : ocio_destino;
        var _dir = sign(_alvo - x);

        x += _dir * _vel;
        image_xscale = (_dir < 0) ? -1 : 1;

        if (abs(_alvo - x) <= _vel) {
            x = _alvo;
            estado = FERREIRO_ESTADO.IDLE;

            if (indo_para_casa) {
                image_xscale = 1;
            } else {
                // chegou ao destino: fica um tempo parado antes de decidir de novo
                ocio_timer = irandom_range(room_speed * 0.6, room_speed * 2.5);
            }
        }
        break;

    case FERREIRO_ESTADO.MARTELANDO:
        // Ação em andamento; o evento de fim de animação devolve para IDLE.
        break;

    case FERREIRO_ESTADO.COMEMORANDO:
        sprite_index = s_ferreiro_win;
        image_speed = 0.2;
        break;

    case FERREIRO_ESTADO.FALHA:
        // Animação de falha tocando.
        break;

    case FERREIRO_ESTADO.FALHOU_ESTATICO:
        sprite_index = s_ferreiro_falha;
        image_index = sprite_get_number(s_ferreiro_falha) - 1; // Trava no último frame
        image_speed = 0;
        break;
}
