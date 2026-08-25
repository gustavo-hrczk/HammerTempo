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
o_audio_manager.play_music_crossfade(_dados_fase.musica_fase, 0.4, _dados_fase.ganho_musica);

// --- RITMO ---
// A grade de notas e ABSOLUTA: cada nota tem um instante em segundos da faixa, e o
// spawner compara esse instante com o relogio do audio. Antes cada nota era agendada
// a partir da anterior, por alarme em frames — o que acumulava erro de truncamento e
// deixava a grade inteira deslocada por (1000 ms fixos + viagem) mod batida.
// Diagnostico completo em 06-RITMO-AUTOTRACK.md.
var _bpm = _dados_fase.beat_tempo_bpm;
beat_seg = 60 / _bpm;

// tempo que a nota leva do nascimento ate a zona de acerto
// A viagem e a mesma para os dois jogadores: as pistas sao simetricas, entao a
// distancia entre o ponto de nascimento e a linha de acerto e identica dos dois lados.
viagem_seg = abs(x - RITMO_LINHA_X) / velocidade_das_notas / room_speed;

// Escolhe aleatoriamente um dos padroes de ritmo definidos para a fase
// UM motivo por fase, sem sorteio. O sorteio entre padroes fazia a mesma fase soar
// diferente a cada partida, o que e o oposto de identidade: o jogador nunca chegava
// a reconhecer a frase como sendo daquela musica.
meu_pattern_atual = _dados_fase.ritmo_patterns[0];
pattern_index = 0;

// A primeira nota chega numa BATIDA DE VERDADE da faixa, e nao 1000 ms fixos depois
// como antes.
//
// Por padrao ela espera o tempo de viagem mais um segundo, que e o minimo para a
// nota nascer na borda direita e atravessar a tela inteira. Mas faixa que ja comeca
// tocando nao combina com 5 segundos de tela vazia, entao a fase pode pedir um
// respiro menor com primeira_nota_seg.
//
// Respiro menor que a viagem funciona porque a posicao da nota e DERIVADA do relogio
// (D-94): uma nota criada com o relogio ja adiantado nasce no meio do caminho, na
// posicao certa, em vez de na borda. Le como entrar numa musica ja em andamento.
var _fase_batida = _dados_fase.primeira_batida_ms / 1000;

var _minimo = variable_struct_exists(_dados_fase, "primeira_nota_seg")
    ? _dados_fase.primeira_nota_seg
    : viagem_seg + 1;

var _batidas = ceil((_minimo - _fase_batida) / beat_seg);

proximo_t = _fase_batida + (_batidas * beat_seg);

// =================================================================
// DISPOSICAO DAS FAIXAS
// Estado da sequencia de figuras. Ver ritmo_sortear_figura em scr_ritmo: a faixa da
// nota deixou de ser sorteada uma a uma e passou a andar por figuras — repete, sobe,
// desce, alterna —, que e como uma linha de percussao se move.
// =================================================================
linhas = ritmo_linhas_permitidas(tipos_permitidos);
pesos_figura = ritmo_pesos_figura(_dados_fase);
linha_pos = irandom(array_length(linhas) - 1);
linha_dir = choose(-1, 1);

figura = ritmo_sortear_figura(pesos_figura);
figura_resta = figura.notas;

// Historico curto das linhas usadas. E ele que faz cada figura NOVA comecar onde a
// pista anda vazia: sem isso as figuras se encadeavam onde a anterior parou, e a
// sequencia inteira ficava presa no miolo.
historico = [];

/// Linha menos usada nas ultimas notas. Empate sai no sorteio.
linha_mais_livre = function() {
    var _n = array_length(linhas);
    var _uso = array_create(_n, 0);

    for (var i = 0; i < array_length(historico); i++) {
        _uso[historico[i]]++;
    }

    var _melhor = 0;
    var _menor = _uso[0];

    for (var i = 1; i < _n; i++) {
        if (_uso[i] < _menor || (_uso[i] == _menor && irandom(1) == 0)) {
            _menor = _uso[i];
            _melhor = i;
        }
    }
    return _melhor;
}

/// Proximo tipo de seta, seguindo a figura em curso.
proxima_faixa = function() {
    var _n = array_length(linhas);

    if (figura_resta <= 0) {
        figura = ritmo_sortear_figura(pesos_figura);

        // TODA figura nova comeca na linha mais livre, nao onde a anterior parou.
        // Esta e a mudanca que tirou a sequencia do miolo: antes so o SALTO
        // reposicionava, e a pista se concentrava em duas linhas.
        linha_pos = linha_mais_livre();

        if (figura.tipo == FIGURA.VARREDURA) {
            // atravessa a pista inteira, partindo em direcao ao lado mais distante
            linha_dir = (linha_pos < _n / 2) ? 1 : -1;
            figura_resta = _n - 1;
        } else {
            linha_dir = choose(-1, 1);
            figura_resta = figura.notas;
        }
    }

    figura_resta--;

    switch (figura.tipo) {
        case FIGURA.ESCADA:
        case FIGURA.VARREDURA:
            // anda uma linha por vez e QUICA na borda, em vez de dar a volta:
            // saltar do pe da pista para o topo lê como erro, nao como frase.
            //
            // O quique pousa NA borda (0 ou _n-1). A versao anterior devolvia para
            // 1 e _n-2, ou seja, ricocheteava antes de encostar — e era por isso que
            // as linhas extremas ficavam com 14% e 11% das notas.
            linha_pos += linha_dir;
            if (linha_pos < 0)   { linha_pos = 0;      linha_dir =  1; }
            if (linha_pos >= _n) { linha_pos = _n - 1; linha_dir = -1; }
            break;

        case FIGURA.ALTERNAR:
            // passo de 1 ou 2: alternancia sempre adjacente soa mecanica
            var _passo = choose(1, 1, 2);
            var _nova = linha_pos + (linha_dir * _passo);

            if (_nova >= 0 && _nova < _n) linha_pos = _nova;
            linha_dir = -linha_dir;
            break;

        // REPETIR fica onde esta
    }

    linha_pos = clamp(linha_pos, 0, _n - 1);

    array_push(historico, linha_pos);
    if (array_length(historico) > 16) array_delete(historico, 0, 1);

    return linhas[linha_pos];
}

/// Cria uma nota que deve encostar na zona de acerto no instante _t.
/// Cria uma nota que deve encostar na zona de acerto no instante _t.
///
/// No Versus a MESMA faixa e sorteada uma vez e entregue aos dois jogadores: eles
/// disputam a execucao do mesmo trecho, e sortear duas vezes daria padroes diferentes
/// — a partida deixaria de ser comparavel.
criar_nota = function(_t) {
    var _tipo = proxima_faixa();

    for (var _d = 0; _d < jogadores_em_jogo(); _d++) {
        if (!versus_recebe_nota(_d)) continue;

        var _x = ritmo_linha_x(_d) - (ritmo_sentido(_d) * viagem_seg
                                      * velocidade_das_notas * room_speed);

        var _n = instance_create_layer(_x, ritmo_lane_y(_tipo, _d), "Gameplay", o_nota_seta);
        _n.tipo_seta = _tipo;
        _n.velocidade = velocidade_das_notas;
        _n.t_alvo = _t;
        _n.dono = _d;

        jogador(_d).stats_total_notas++;
    }
}
