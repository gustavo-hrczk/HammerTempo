// Pega os dados da fase atual que está no controlador
var _dados_fase = o_controlador_geral.fases_data[o_controlador_geral.fase_atual];

// --- Configura as variáveis de DURAÇÃO e DIFICULDADE ---
minha_duracao = (_dados_fase.duracao_segundos == -1) ? -1 : _dados_fase.duracao_segundos * room_speed;
velocidade_das_notas = _dados_fase.velocidade_notas;
tipos_permitidos = _dados_fase.tipos_seta_permitidos;
duracao_total = minha_duracao; // usada pela barra de progresso do HUD
is_endless_mode = (minha_duracao == -1);
dificuldade_level = 0;
dificuldade_timer = 15 * room_speed;
esta_finalizando = false;
esperando_respiro = false;   // pausa entre a última nota e a tela de resultado

// Usadas apenas pelo modo infinito. Ficavam sem inicialização, o que quebraria a
// fase no primeiro aumento de dificuldade (auditoria GP-05).
intervalo_min = 60;
intervalo_max = 100;

// A música começa exatamente aqui, junto com o agendamento da primeira nota: é
// esse instante que define o alinhamento entre a faixa e as notas. O crossfade
// suaviza a saída do tema sem mexer na posição da faixa.
o_audio_manager.play_music_crossfade(_dados_fase.musica_fase, 0.4);

// --- RITMO ---
// A grade de notas e ABSOLUTA: cada nota tem um instante em segundos da faixa, e o
// spawner compara esse instante com o relogio do audio. Antes cada nota era agendada
// a partir da anterior, por alarme em frames — o que acumulava erro de truncamento e
// deixava a grade inteira deslocada por (1000 ms fixos + viagem) mod batida.
// Diagnostico completo em 06-RITMO-AUTOTRACK.md.
var _bpm = _dados_fase.beat_tempo_bpm;
beat_seg = 60 / _bpm;

// tempo que a nota leva do nascimento ate a zona de acerto
viagem_seg = (x - RITMO_LINHA_X) / velocidade_das_notas / room_speed;

// Escolhe aleatoriamente um dos padroes de ritmo definidos para a fase
var _patterns = _dados_fase.ritmo_patterns;
meu_pattern_atual = _patterns[irandom(array_length(_patterns) - 1)];
pattern_index = 0;

// A primeira nota chega numa BATIDA DE VERDADE da faixa, e nao 1000 ms fixos depois
// como antes. O respiro inicial e o mesmo de sempre: tempo de viagem mais um segundo,
// arredondado para cima ate a proxima batida.
var _fase_batida = _dados_fase.primeira_batida_ms / 1000;
var _minimo = viagem_seg + 1;
var _batidas = ceil((_minimo - _fase_batida) / beat_seg);

proximo_t = _fase_batida + (_batidas * beat_seg);

// =================================================================
// MAPA DA MUSICA
// Quando a fase tem mapa gerado, ele MANDA: instante e faixa saem da percussao da
// propria faixa, e o gerador por padrao ritmico nem entra em cena.
//
// O padrao continua existindo como reserva. Uma faixa nova que ainda nao passou pela
// ferramenta joga, so que com o arranjo sorteado de antes.
//
// O mapa comeca no primeiro instante que deixa espaco para a viagem da nota: as
// notas anteriores a isso teriam de nascer antes de a musica comecar.
// =================================================================
mapa = mapa_da_fase(o_controlador_geral.fase_atual);
mapa_index = 0;
usa_mapa = (array_length(mapa) > 0);

if (usa_mapa) {
    while (mapa_index < array_length(mapa) && mapa[mapa_index][0] < viagem_seg) {
        mapa_index++;
    }
}

/// Cria uma nota de um tipo especifico que deve encostar na zona no instante _t.
criar_nota_tipo = function(_t, _tipo) {
    var _pos_y;

    switch (_tipo) {
        case 0: _pos_y = 665; break;
        case 1: _pos_y = 515; break;
        case 2: _pos_y = 615; break;
        case 3: _pos_y = 565; break;
    }

    var _n = instance_create_layer(x, _pos_y, "Gameplay", o_nota_seta);
    _n.tipo_seta = _tipo;
    _n.velocidade = velocidade_das_notas;
    _n.t_alvo = _t;

    o_controlador_geral.stats_total_notas++;
}

/// Cria uma nota que deve encostar na zona de acerto no instante _t.
criar_nota = function(_t) {
    var _tipo = irandom(tipos_permitidos - 1);
    var _pos_y;

    switch (_tipo) {
        case 0: _pos_y = 665; break;
        case 1: _pos_y = 515; break;
        case 2: _pos_y = 615; break;
        case 3: _pos_y = 565; break;
    }

    var _n = instance_create_layer(x, _pos_y, "Gameplay", o_nota_seta);
    _n.tipo_seta = _tipo;
    _n.velocidade = velocidade_das_notas;
    _n.t_alvo = _t;

    o_controlador_geral.stats_total_notas++;
}
