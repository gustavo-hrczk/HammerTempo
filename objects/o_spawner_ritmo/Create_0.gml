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
viagem_seg = (x - RITMO_LINHA_X) / velocidade_das_notas / room_speed;

// Escolhe aleatoriamente um dos padroes de ritmo definidos para a fase
var _patterns = _dados_fase.ritmo_patterns;
meu_pattern_atual = _patterns[irandom(array_length(_patterns) - 1)];
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
linha_pos = irandom(array_length(linhas) - 1);
linha_dir = choose(-1, 1);

figura = ritmo_sortear_figura();
figura_resta = figura.notas;

/// Proximo tipo de seta, seguindo a figura em curso.
proxima_faixa = function() {
    var _n = array_length(linhas);

    if (figura_resta <= 0) {
        figura = ritmo_sortear_figura();
        figura_resta = figura.notas;

        // figura nova comeca de um lugar novo, senao ela apenas continua a anterior
        if (figura.tipo == FIGURA.SALTO) {
            linha_pos = irandom(_n - 1);
        }
        linha_dir = choose(-1, 1);
    }

    figura_resta--;

    switch (figura.tipo) {
        case FIGURA.ESCADA:
            // anda uma linha por vez e QUICA na borda, em vez de dar a volta:
            // saltar do pe da pista para o topo lê como erro, nao como frase
            linha_pos += linha_dir;
            if (linha_pos < 0)   { linha_pos = min(1, _n - 1); linha_dir =  1; }
            if (linha_pos >= _n) { linha_pos = max(0, _n - 2); linha_dir = -1; }
            break;

        case FIGURA.ALTERNAR:
            linha_pos = clamp(linha_pos + linha_dir, 0, _n - 1);
            linha_dir = -linha_dir;
            break;

        case FIGURA.SALTO:
            linha_pos = irandom(_n - 1);
            break;

        // REPETIR fica onde esta
    }

    return linhas[clamp(linha_pos, 0, _n - 1)];
}

/// Cria uma nota que deve encostar na zona de acerto no instante _t.
criar_nota = function(_t) {
    var _tipo = proxima_faixa();
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
