estado = FERREIRO_ESTADO.IDLE;

// Posição de trabalho, junto à bigorna. O ócio da seleção de fase sempre termina
// aqui antes da partida começar.
home_x = x;
passeio_min = x - 110;
passeio_max = x + 30;
indo_para_casa = false;

// --- ÓCIO ORGÂNICO ---
// Em vez de um vaivém de metrônomo, ele alterna pausas e caminhadas curtas para
// destinos aleatórios, com tempos variados.
ocio_timer = 60;
ocio_destino = x;

dano_timer = 0;

// Guarda a velocidade da martelada em curso: a pausa zera image_speed, e sem isso
// a animação nunca voltava a andar — o evento de fim de animação também não
// dispara, porque animação parada não termina.
velocidade_martelada = 1;

// --- REAÇÃO AO ERRO ---
// Usa o frame vermelho de dano que já estava no projeto e nunca tinha sido usado.
aplicar_dano = function() {
    if (estado == FERREIRO_ESTADO.MARTELANDO) exit;
    if (estado == FERREIRO_ESTADO.FALHA || estado == FERREIRO_ESTADO.FALHOU_ESTATICO) exit;

    estado = FERREIRO_ESTADO.DANO;
    sprite_index = s_ferreiro_miss;
    image_index = 0;
    image_speed = 0;
    image_xscale = 1;
    dano_timer = room_speed * 0.18;
}

// Função para iniciar a martelada NORMAL
iniciar_martelada_normal = function() {
    estado = FERREIRO_ESTADO.MARTELANDO;
    sprite_index = s_ferreiro_martelada;
    image_index = 0;
    image_speed = 1;
    velocidade_martelada = 1;
    image_xscale = 1;
    x = home_x;
}

// Função para iniciar a martelada PERFEITA
iniciar_martelada_perfeita = function() {
    estado = FERREIRO_ESTADO.MARTELANDO;
    sprite_index = s_ferreiro_martelada;
    image_index = 0;
    image_speed = 0.8;
    velocidade_martelada = 0.8;
    image_xscale = 1;
    x = home_x;

    // faísca no acerto perfeito, como era antes dos efeitos de impacto
    if (instance_exists(o_bigorna)) {
        instance_create_layer(o_bigorna.x + 40, o_bigorna.y - 10, "Gameplay", o_faisca);
    }
}

/// Devolve o ferreiro ao repouso. Usada ao reiniciar a fase pelo menu de pausa,
/// quando ele pode estar congelado no meio de uma martelada.
voltar_ao_repouso = function() {
    estado = FERREIRO_ESTADO.IDLE;
    sprite_index = s_ferreiro_idle;
    image_index = 0;
    image_speed = 0.5;
    image_xscale = 1;
    x = home_x;
}

// --- ANIMAÇÕES DE RESULTADO ---
iniciar_comemoracao = function() {
    estado = FERREIRO_ESTADO.COMEMORANDO;
    image_xscale = 1;
}

iniciar_animacao_falha = function() {
    estado = FERREIRO_ESTADO.FALHA;
    sprite_index = s_ferreiro_falha;
    image_index = 0;
    image_speed = 1;
    image_xscale = 1;
}
