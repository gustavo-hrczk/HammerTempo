// Esta instancia foi criada PELO Versus? So essas sao destruidas no desmonte — as
// da sala sobrevivem, com o dono trocado.
criado_pelo_versus = false;

// De quem e este ferreiro. 0 e o jogador 1, que e o unico fora do Versus.
dono = 0;

// CONJUNTO DE SPRITES DO DONO.
//
// O ferreiro 2 e a mesma arte com outra paleta, entao ele tem os mesmos estados e a
// mesma contagem de quadros — muda so de qual asset cada estado vem. Guardar o
// conjunto num struct evita espalhar `if (dono == 1)` pelos treze pontos que trocam
// de sprite, onde um esquecido daria ao jogador 2 a cor do jogador 1 no meio de uma
// animacao.
//
// Montado JA NO CREATE, com o dono que a instancia tem neste instante.
//
// Estava sendo montado no primeiro Step, o que abria uma janela fatal: o evento
// Animation End dispara ANTES do Step do primeiro quadro, e chegava em meus_sprites
// ainda indefinido — o jogo travava ao abrir qualquer fase.
//
// Para o ferreiro 1, que nasce com a sala, `dono` ja vale 0 aqui e esta correto. Para
// o ferreiro 2, criado em codigo, quem o cria chama adotar_sprites() de novo depois de
// definir o dono — a funcao e idempotente exatamente para isso.
meus_sprites = undefined;

/// Monta o conjunto do dono atual. Idempotente.
adotar_sprites = function() {
    meus_sprites = (dono == 0)
        ? { idle: s_ferreiro_idle,  martelada: s_ferreiro_martelada,
            andando: s_ferreiro_andando, win: s_ferreiro_win,
            falha: s_ferreiro_falha, miss: s_ferreiro_miss }
        : { idle: s_ferreiro2_idle, martelada: s_ferreiro2_martelada,
            andando: s_ferreiro2_andando, win: s_ferreiro2_win,
            falha: s_ferreiro2_falha, miss: s_ferreiro2_miss };

    // O jogador 2 fica a DIREITA e encara o jogador 1. A origem dos sprites e a base
    // centrada (120,240), entao o espelho gira em torno dos proprios pes.
    image_xscale = frente();

    sprite_index = meus_sprites.idle;
};

/// Para que lado este ferreiro olha quando esta de frente.
///
/// O jogador 1 olha para a direita, como sempre olhou. O jogador 2 e o espelho: ele
/// fica a direita da tela e encara o 1. Toda vez que o codigo antigo dizia
/// `image_xscale = 1` para dizer "volte a olhar para frente", ele agora diz frente() —
/// senao o ferreiro 2 se desespelharia no meio de qualquer animacao, e apareceria de
/// costas para o oponente.
frente = function() {
    // Espelho SO no Versus, onde os dois se encaram. O jogador 2 jogando sozinho fica
    // no lugar de sempre e olha para o mesmo lado de sempre: espelha-lo ali o deixava
    // de costas para a propria bigorna.
    if (!versus_ativo()) return 1;

    return (dono == 0) ? 1 : -1;
};

estado = FERREIRO_ESTADO.IDLE;

// Posição de trabalho, junto à bigorna. O ócio da seleção de fase sempre termina
// aqui antes da partida começar.
home_x = x;

// Ultima coisa do Create: adotar_sprites depende de frente(), definida acima.
adotar_sprites();

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
    sprite_index = meus_sprites.miss;
    image_index = 0;
    image_speed = 0;
    image_xscale = frente();
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
    sprite_index = meus_sprites.martelada;
    image_index = MARTELADA_QUADRO_INICIAL;
    image_speed = 1;
    velocidade_martelada = 1;
    image_xscale = frente();
    x = home_x;
}

// Função para iniciar a martelada PERFEITA
iniciar_martelada_perfeita = function() {
    estado = FERREIRO_ESTADO.MARTELANDO;
    sprite_index = meus_sprites.martelada;
    image_index = MARTELADA_QUADRO_INICIAL;
    image_speed = 0.8;
    velocidade_martelada = 0.8;
    image_xscale = frente();
    x = home_x;

    // A faísca antiga saiu daqui. Ela disparava no instante da tecla, enquanto o
    // impacto novo e o tremor acompanham o contato do martelo — manter as duas
    // desfaria justamente a sincronia que o impacto veio trazer.
}

/// Devolve o ferreiro ao repouso. Usada ao reiniciar a fase pelo menu de pausa,
/// quando ele pode estar congelado no meio de uma martelada.
voltar_ao_repouso = function() {
    estado = FERREIRO_ESTADO.IDLE;
    sprite_index = meus_sprites.idle;
    image_index = 0;
    image_speed = 0.5;
    image_xscale = frente();
    x = home_x;
}

// --- ANIMAÇÕES DE RESULTADO ---
iniciar_comemoracao = function() {
    estado = FERREIRO_ESTADO.COMEMORANDO;
    image_xscale = frente();
}

iniciar_animacao_falha = function() {
    estado = FERREIRO_ESTADO.FALHA;
    sprite_index = meus_sprites.falha;
    image_index = 0;
    image_speed = 1;
    image_xscale = frente();
}
