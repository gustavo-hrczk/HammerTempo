estado = FERREIRO_ESTADO.IDLE;

// Posição de trabalho, junto à bigorna. O ócio da seleção de fase sempre termina
// aqui antes da partida começar.
home_x = x;

// Alcance do passeio. Era -110/+30 (140 px); foi alargado para dar variedade ao
// ócio. A trava da contagem (ver o Step) garante a volta à bigorna a tempo mesmo
// que esta faixa cresça de novo no futuro.
passeio_min = x - 160;
passeio_max = x + 55;
indo_para_casa = false;

// --- ÓCIO ORGÂNICO ---
// Em vez de um vaivém de metrônomo, ele alterna pausas e caminhadas curtas para
// destinos aleatórios, com tempos variados.
ocio_timer = 60;
ocio_destino = x;

// Distância mínima para uma caminhada valer a pena. Sem ela, o destino era sorteado
// como POSIÇÃO dentro de uma faixa de 140 px, e na maior parte das vezes caía a
// poucos pixels de onde ele já estava: a animação de andar começava e terminava sem
// que ele saísse do lugar. Eram os "passinhos" estranhos.
passeio_passo_min = 55;

/// Sorteia para onde ir. Sorteia DISTÂNCIA e lado, não posição, para a caminhada
/// nunca ser curta demais. Devolve o próprio x quando não há espaço para nenhum dos
/// lados — nesse caso quem chamou fica parado mais um tempo.
sortear_destino = function() {
    var _dist = irandom_range(passeio_passo_min, 100);
    var _lado = (random(1) < 0.5) ? -1 : 1;

    var _alvo = clamp(x + (_dist * _lado), passeio_min, passeio_max);
    if (abs(_alvo - x) >= passeio_passo_min) return _alvo;

    // encostou no limite desse lado: tenta o oposto
    _alvo = clamp(x - (_dist * _lado), passeio_min, passeio_max);
    if (abs(_alvo - x) >= passeio_passo_min) return _alvo;

    return x;
}

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

// A martelada COMECA no alto do movimento, nao no repouso.
//
// s_ferreiro_martelada tem 6 quadros: 0 e a pose de repouso, 1 a 3 levantam o
// martelo e 4 e o contato com a bigorna. Comecando do zero, chegar ao contato levava
// 266 ms na martelada normal e 333 ms na perfeita — mas duas colcheias a 108 BPM
// distam 278 ms, e cada acerto reinicia a animacao. Em trecho rapido o ferreiro
// reiniciava a preparacao a cada nota e NUNCA chegava a golpear.
//
// Partindo do quadro 3, o contato vem um quadro depois: 67 ms normal, 83 ms perfeito.
// A animacao inteira passa a caber entre duas notas rapidas.
#macro MARTELADA_QUADRO_INICIAL 3
#macro MARTELADA_QUADRO_CONTATO 4

// Função para iniciar a martelada NORMAL
iniciar_martelada_normal = function() {
    estado = FERREIRO_ESTADO.MARTELANDO;
    sprite_index = s_ferreiro_martelada;
    image_index = MARTELADA_QUADRO_INICIAL;
    image_speed = 1;
    velocidade_martelada = 1;
    image_xscale = 1;
    x = home_x;
}

// Função para iniciar a martelada PERFEITA
iniciar_martelada_perfeita = function() {
    estado = FERREIRO_ESTADO.MARTELANDO;
    sprite_index = s_ferreiro_martelada;
    image_index = MARTELADA_QUADRO_INICIAL;
    image_speed = 0.8;
    velocidade_martelada = 0.8;
    image_xscale = 1;
    x = home_x;

    // A faísca antiga saiu daqui. Ela disparava no instante da tecla, enquanto o
    // impacto novo e o tremor acompanham o contato do martelo — manter as duas
    // desfaria justamente a sincronia que o impacto veio trazer.
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
