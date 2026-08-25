/// scr_ritmo — julgamento de acerto por TEMPO
///
/// Até a Sprint 1 o julgamento era espacial: a nota precisava sobrepor um sprite de
/// 2 px de largura, o que dava uma janela de "perfeito" de ~1 frame e criava faixas
/// mortas em que a tecla certa não valia nada.
///
/// Agora o erro é medido em frames (e, por consequência, em milissegundos), usando a
/// velocidade da própria nota. A exigência passa a ser idêntica em todas as fases,
/// independentemente da velocidade visual das notas.

/// Posição X da linha de acerto (mesma X das instâncias de o_buttons_forja em rm_forja).
#macro RITMO_LINHA_X 98

/// Janelas de julgamento, em frames a 60 fps.
/// Três faixas: o "perfeito" antigo (+-50 ms) saía com frequência alta demais para
/// quem já pegou o ritmo, então virou o intervalo do "ótimo" e o perfeito apertou.
#macro RITMO_JANELA_PERFEITO 2     // +-33 ms
#macro RITMO_JANELA_OTIMO    4.5   // +-75 ms
#macro RITMO_JANELA_BOM      8     // +-133 ms

/// Resultado possível de uma tentativa de acerto.
enum JULGAMENTO {
    NENHUM,   // não havia nota alcançável
    PERFEITO,
    OTIMO,
    BOM
}

/// Erro de tempo de uma nota, em frames.
/// Positivo = adiantado (a nota ainda não chegou), negativo = atrasado.
function ritmo_erro_frames(_nota) {
    if (_nota.velocidade <= 0) return 0;
    return (_nota.x - RITMO_LINHA_X) / _nota.velocidade;
}

/// Converte frames em milissegundos, respeitando o game speed configurado.
function ritmo_frames_ms(_frames) {
    return (_frames / game_get_speed(gamespeed_fps)) * 1000;
}

/// Nota viva do tipo pedido cujo erro de tempo é o menor.
/// Retorna noone se não houver nenhuma dentro da janela de acerto.
function ritmo_nota_alcancavel(_tipo) {
    var _melhor = noone;
    var _menor_erro = RITMO_JANELA_BOM + 1;

    with (o_nota_seta) {
        if (modo != 0 || tipo_seta != _tipo) continue;

        var _erro = abs((x - RITMO_LINHA_X) / velocidade);
        if (_erro <= RITMO_JANELA_BOM && _erro < _menor_erro) {
            _menor_erro = _erro;
            _melhor = id;
        }
    }

    return _melhor;
}

/// Classifica uma nota já alcançável.
function ritmo_julgar(_nota) {
    var _erro = abs(ritmo_erro_frames(_nota));
    if (_erro <= RITMO_JANELA_PERFEITO) return JULGAMENTO.PERFEITO;
    if (_erro <= RITMO_JANELA_OTIMO)    return JULGAMENTO.OTIMO;
    if (_erro <= RITMO_JANELA_BOM)      return JULGAMENTO.BOM;
    return JULGAMENTO.NENHUM;
}

/// A nota passou do ponto em que ainda poderia ser acertada?
function ritmo_nota_perdida(_nota) {
    return (ritmo_erro_frames(_nota) < -RITMO_JANELA_BOM);
}

// =====================================================================
// CORES DO JULGAMENTO
// Cada julgamento tem três tons: o estouro da nota, o brilho do alvo e o número de
// pontos que sobe. Estavam soltos em o_buttons_forja, e mexer num julgamento exigia
// achar as três ocorrências certas no meio do switch.
// =====================================================================

#macro COR_PERFEITO_NOTA   make_colour_rgb(255, 226, 140)
#macro COR_PERFEITO        make_colour_rgb(255, 214, 90)
#macro COR_PERFEITO_GANHO  make_colour_rgb(214, 150, 20)

#macro COR_OTIMO_NOTA      make_colour_rgb(250, 195, 120)
#macro COR_OTIMO           make_colour_rgb(245, 160, 60)
#macro COR_OTIMO_GANHO     make_colour_rgb(190, 110, 20)

#macro COR_BOM_NOTA        make_colour_rgb(205, 235, 190)
#macro COR_BOM             make_colour_rgb(180, 225, 150)
#macro COR_BOM_GANHO       make_colour_rgb(96, 140, 60)

#macro COR_ERRO            make_colour_rgb(235, 95, 75)

// =====================================================================
// IMPACTO NA BIGORNA
//
// Os tres numeros de ajuste do efeito ficam aqui em cima, juntos, para nao ter de
// cacar no meio da funcao.
// =====================================================================

/// Escala do efeito. INTEIRA, sempre: a arte e pixel art e escala fracionaria
/// borra o traco — mesma regra das fontes (D-33). O sprite tem 48x48, entao 2
/// resulta em 96x96 sobre uma bigorna de 120x70.
#macro IMPACTO_ESCALA 4

/// Deslocamento do centro do efeito em relacao ao canto da bigorna, que mede 120x70
/// com origem no canto superior esquerdo. E o ponto onde o martelo a encontra.
#macro IMPACTO_DX 65
#macro IMPACTO_DY -5

/// Frames de espera ate o martelo encostar na bigorna.
///
/// A martelada comeca no quadro 3 e o contato e o quadro 4 (ver o_ferreiro), ou seja
/// UM quadro de animacao depois. A 60 fps de jogo isso da 4 frames na martelada
/// normal (15 fps de sprite) e 5 na perfeita (12 fps, porque image_speed e 0,8).
#macro IMPACTO_ATRASO_NORMAL   4
#macro IMPACTO_ATRASO_PERFEITO 5

/// Sprite do impacto, por FAIXA e por QUALIDADE do acerto.
///
/// Hoje existe um conjunto so, usado nos tres julgamentos. Amanha entram os conjuntos
/// separados de Bom e Perfeito, e a tabela abaixo e o unico lugar que muda: nem o
/// julgamento nem o desenho sabem quantos conjuntos existem.
///
/// A tabela e [qualidade][faixa]. As faixas vem do Instance Creation Code dos alvos em
/// rm_forja: 0 baixo, 1 cima, 2 direita, 3 esquerda. Trocar uma linha por sprites
/// novos e tudo o que sera preciso.
function ritmo_tabela_impacto() {
    static _tabela = undefined;

    if (is_undefined(_tabela)) {
        // Um conjunto POR QUALIDADE, indexado pelo tipo da faixa. Os sprites novos ja
        // sao nomeados pelo tipo, entao o indice e direto.
        //
        // O conjunto anterior era um so para as tres qualidades, e a lista dele vinha
        // com os indices 2 e 3 invertidos DE PROPOSITO: os sprites s_impacto_esq e
        // s_impacto_dir estao com os nomes trocados — o "esq" e verde e o "dir" e
        // azul, enquanto a faixa 2 (ESQ) usa nota azul e a 3 (DIR) usa verde. A
        // inversao na tabela consertava a troca no nome. Aqui isso deixa de existir.
        _tabela = {};

        _tabela[$ string(JULGAMENTO.BOM)] =
            [s_vfx_bom_0, s_vfx_bom_1, s_vfx_bom_2, s_vfx_bom_3];

        _tabela[$ string(JULGAMENTO.OTIMO)] =
            [s_vfx_otimo_0, s_vfx_otimo_1, s_vfx_otimo_2, s_vfx_otimo_3];

        _tabela[$ string(JULGAMENTO.PERFEITO)] =
            [s_vfx_perfeito_0, s_vfx_perfeito_1, s_vfx_perfeito_2, s_vfx_perfeito_3];
    }

    return _tabela;
}

/// Sprite do impacto para uma faixa e um julgamento.
///
/// Cai no conjunto base se a qualidade ainda nao tiver conjunto proprio, entao os
/// sprites novos podem entrar um de cada vez sem quebrar nada no meio do caminho.
function ritmo_sprite_impacto(_tipo, _julgamento = JULGAMENTO.PERFEITO) {
    var _tabela = ritmo_tabela_impacto();
    var _chave = string(_julgamento);

    var _conjunto = variable_struct_exists(_tabela, _chave)
        ? _tabela[$ _chave]
        : _tabela[$ string(JULGAMENTO.PERFEITO)];

    if (_tipo < 0 || _tipo >= array_length(_conjunto)) return _conjunto[0];
    return _conjunto[_tipo];
}


/// Agenda o impacto e o tremor da bigorna para o instante do CONTATO do martelo.
///
/// `_forca` e a amplitude do tremor em pixels e `_atraso` os frames ate o contato,
/// ambos pela qualidade do acerto. Ficam num lugar so para os tres julgamentos nao
/// repetirem a mesma sequencia de chamadas — foi assim que a moldura errada nasceu
/// no seletor (D-71).
///
/// O alvo pressionado NAO espera: resposta de input tem de ser imediata, senao o
/// jogo parece atrasado. Quem espera e o que representa o golpe.
function ritmo_impacto_bigorna(_tipo, _julgamento, _forca, _atraso) {
    if (!instance_exists(o_bigorna)) exit;

    var _e = instance_create_layer(o_bigorna.x + IMPACTO_DX,
                                   o_bigorna.y + IMPACTO_DY,
                                   "Gameplay", o_impacto_bigorna);

    _e.sprite_index = ritmo_sprite_impacto(_tipo, _julgamento);
    _e.image_xscale = IMPACTO_ESCALA;
    _e.image_yscale = IMPACTO_ESCALA;
    _e.atraso = _atraso;
    _e.forca = _forca;
}


// =====================================================================
// RELOGIO DE RITMO
//
// A posicao da propria faixa e a unica referencia que nao deriva: e o audio se
// contando. O contador de frames deriva por truncamento e por frame perdido, e o
// agendamento relativo (cada nota a partir da anterior) soma o erro por construcao.
// Ver 06-RITMO-AUTOTRACK.md.
// =====================================================================

/// Posicao da faixa da fase, em segundos, ou -1 se nao ha faixa tocando.
///
/// Le a INSTANCIA, nao o asset: audio_sound_get_track_position() so responde a
/// instancia devolvida por audio_play_sound.
function ritmo_relogio() {
    if (!instance_exists(o_audio_manager)) return -1;

    var _i = o_audio_manager.musica_instancia;
    if (_i == -1 || !audio_is_playing(_i)) return -1;

    return audio_sound_get_track_position(_i);
}

/// Onde a nota deve estar AGORA, dado o instante em que ela precisa chegar a zona.
///
/// Posicao derivada do relogio em vez de integrada quadro a quadro. Como
/// ritmo_erro_frames() calcula (x - LINHA) / velocidade, esta formula faz o erro de
/// julgamento virar exatamente o erro de tempo contra a musica — o julgamento nao
/// precisou mudar uma linha para ficar preciso.
function ritmo_x_da_nota(_t_alvo, _agora, _velocidade) {
    return RITMO_LINHA_X + (_t_alvo - _agora) * _velocidade * game_get_speed(gamespeed_fps);
}

// =====================================================================
// DISPOSICAO DAS FAIXAS
//
// A faixa da nota era irandom(). Com 2 ou 3 faixas isso passa, porque o sorteio
// produz corridas por acaso — a Adaga mede 59% de repeticao de linha. Com 4 faixas
// cai para 19% e vira ruido: sem corrida, sem simetria, sem repeticao deliberada.
// O ouvido espera frase e a mao recebe aleatoriedade.
//
// Aqui a sequencia e montada por FIGURAS, que e como uma linha de percussao anda:
// repete, sobe, desce, alterna. O sorteio decide qual figura vem, nao cada nota.
// =====================================================================

/// Tipos de seta ordenados pela LINHA VISUAL, de cima para baixo.
///
/// rm_forja poe cima(1) em y=515, esquerda(3) em 565, direita(2) em 615 e baixo(0)
/// em 665. Sem esta traducao, "subir uma faixa" andaria na ordem do enum e pularia
/// pela tela.
function ritmo_linhas_permitidas(_tipos) {
    var _visual = [1, 3, 2, 0];
    var _out = [];

    for (var i = 0; i < array_length(_visual); i++) {
        if (_visual[i] < _tipos) array_push(_out, _visual[i]);
    }
    return _out;
}

enum FIGURA { REPETIR, ESCADA, ALTERNAR, VARREDURA }

/// Sorteia a proxima figura, com pesos da FASE.
///
/// Os pesos sao [escada, varredura, alternar, repetir], em porcentagem. Eles dao
/// caracter de MOVIMENTO a cada fase: uma anda em escada, outra varre a pista de
/// ponta a ponta, outra alterna. Sem isso as seis fases se moviam igual, e a
/// identidade ficava so no ritmo.
///
/// Escada e varredura ATRAVESSAM a pista; alternar e repetir ficam em uma regiao.
/// Uma fase de 2 faixas nao tem o que atravessar, entao pende para alternar.
function ritmo_sortear_figura(_pesos) {
    var _r = irandom(99);
    var _acc = _pesos[0];

    if (_r < _acc) return { tipo: FIGURA.ESCADA, notas: irandom_range(4, 7) };

    _acc += _pesos[1];
    if (_r < _acc) return { tipo: FIGURA.VARREDURA, notas: 0 };

    _acc += _pesos[2];
    if (_r < _acc) return { tipo: FIGURA.ALTERNAR, notas: irandom_range(4, 6) };

    return { tipo: FIGURA.REPETIR, notas: irandom_range(2, 3) };
}

/// Pesos de figura de uma fase, com o perfil da Espada como padrao — ela e a
/// referencia de personalidade do jogo.
function ritmo_pesos_figura(_fase) {
    if (variable_struct_exists(_fase, "figuras")) return _fase.figuras;
    return [34, 24, 24, 18];
}


