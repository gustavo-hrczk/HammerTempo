// O conjunto de sprites so pode ser montado depois de `dono` ter sido definido por
// quem criou a instancia — no Create ele ainda vale 0 para todos.
if (is_undefined(meus_sprites)) adotar_sprites();

// --- LÓGICA DE PAUSA ---
if (gameplay_congelado()) {
    image_speed = 0;
    exit;
}

// Ao despausar, a martelada precisa recuperar a velocidade que a pausa zerou.
if (estado == FERREIRO_ESTADO.MARTELANDO && image_speed == 0) {
    image_speed = velocidade_martelada;
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
        // A decisão só acontece com ele PARADO. Antes o contador corria também
        // durante a caminhada e, ao zerar no meio dela, trocava o destino ou
        // cortava o passo pela metade — o que picava o movimento.
        if (estado != FERREIRO_ESTADO.MARTELANDO && estado != FERREIRO_ESTADO.ANDANDO) {
            indo_para_casa = false;
            ocio_timer--;

            if (ocio_timer <= 0) {
                if (random(1) < 0.45) {
                    // fica parado observando, por um tempo variável
                    estado = FERREIRO_ESTADO.IDLE;
                    ocio_timer = irandom_range(room_speed * 1.0, room_speed * 3.5);
                } else {
                    // caminha até um ponto da oficina, nunca a dois passos daqui
                    ocio_destino = sortear_destino();

                    if (ocio_destino == x) {
                        estado = FERREIRO_ESTADO.IDLE;
                        ocio_timer = irandom_range(room_speed * 1.0, room_speed * 2.0);
                    } else {
                        estado = FERREIRO_ESTADO.ANDANDO;
                    }
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
    // Durante a partida ele nunca sai do lugar. A falha é exceção: no game over a
    // animação começa ainda em RITMO, durante o respiro antes do resultado.
    else if (_jogo == MINIGAME.RITMO) {
        x = home_x;
        image_xscale = frente();
        if (estado != FERREIRO_ESTADO.MARTELANDO
            && estado != FERREIRO_ESTADO.FALHA
            && estado != FERREIRO_ESTADO.FALHOU_ESTATICO) {
            estado = FERREIRO_ESTADO.IDLE;
        }
    }
}

// =================================================================
// EXECUÇÃO DA ANIMAÇÃO
// =================================================================
switch (estado) {

    case FERREIRO_ESTADO.IDLE:
        sprite_index = meus_sprites.idle;
        image_speed = 0.5;
        break;

    case FERREIRO_ESTADO.ANDANDO:
        sprite_index = meus_sprites.andando;
        // O ciclo de 6 quadros a 0,6 fechava em 10 frames, e a 1,2 px/frame ele
        // avançava só 12 px por ciclo completo de passada — os pés patinavam.
        // A 0,35 o ciclo leva 17 frames e ele cobre 27 px, quase o dobro.
        image_speed = 0.35;

        var _vel = 1.6;
        var _alvo = indo_para_casa ? home_x : ocio_destino;

        // TRAVA DA PREPARAÇÃO: voltando para a bigorna, a velocidade é a que for
        // preciso para chegar antes da contagem acabar, venha ele de onde vier.
        // A folga de 0,4 s existe para ele assentar em IDLE antes da primeira nota.
        // Sem isso, alargar o passeio bastaria para ele ainda estar a caminho
        // quando a fase começasse — e o estado RITMO o teleportaria para casa.
        if (indo_para_casa && instance_exists(o_controlador_geral)) {
            var _restante = max(1, o_controlador_geral.contagem_timer - (room_speed * 0.4));
            _vel = max(_vel, abs(_alvo - x) / _restante);

            // os pés acompanham a pressa, senão a passada volta a patinar
            image_speed = 0.35 * (_vel / 1.6);
        }

        var _dir = sign(_alvo - x);

        x += _dir * _vel;
        // ANDANDO ele olha para onde ANDA, e nao para o oponente. frente() aqui
        // invertia o jogador 2: ele caminhava de costas, porque o espelho da pose de
        // repouso nao vale para o passo.
        image_xscale = (_dir < 0) ? -1 : 1;

        if (abs(_alvo - x) <= _vel) {
            x = _alvo;
            estado = FERREIRO_ESTADO.IDLE;

            if (indo_para_casa) {
                image_xscale = frente();
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
        sprite_index = meus_sprites.win;
        image_speed = 0.2;
        break;

    case FERREIRO_ESTADO.FALHA:
        // Animação de falha tocando.
        break;

    case FERREIRO_ESTADO.FALHOU_ESTATICO:
        sprite_index = meus_sprites.falha;
        image_index = sprite_get_number(meus_sprites.falha) - 1; // Trava no último frame
        image_speed = 0;
        break;
}
