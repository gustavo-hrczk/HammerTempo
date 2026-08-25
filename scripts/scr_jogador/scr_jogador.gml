/// scr_jogador — o estado que pertence a UM jogador.
///
/// Pontuação, combo, acertos e erros eram variáveis soltas em o_controlador_geral, o
/// que funcionou enquanto existia um jogador só. O Versus obriga a separá-las: dois
/// jogadores dividem a tela, a música e o teclado, mas nada da pontuação de um pode
/// vazar para o outro.
///
/// A escolha aqui foi UMA fonte de verdade, e não espelhamento. A alternativa — deixar
/// as variáveis antigas valendo para o jogador 1 e criar um struct paralelo para o 2 —
/// seria menos invasiva agora e viraria dois lugares para atualizar em toda mudança
/// futura, com a garantia de que um dia eles discordariam.
///
/// Fora do Versus só existe o jogador 0, e `jogador()` sem argumento devolve ele — o
/// código de um jogador continua lendo como código de um jogador.

/// Quantos jogadores o jogo comporta. Só o Versus usa os dois.
#macro JOGADORES_MAX 2

function EstadoJogador() constructor {
    pontuacao = 0;

    stats_total_notas = 0;
    stats_acertos_perfeitos = 0;
    stats_acertos_otimos = 0;
    stats_acertos_bons = 0;
    stats_erros = 0;

    // combo em curso e a contagem que leva ao game over
    stats_sequencia = 0;
    stats_sequencia_errada = 0;

    // toque sem nota alcançável: custa pontos, não encerra a fase (GP-04)
    stats_toques_invalidos = 0;

    /// Zera tudo para o começo de uma fase.
    static reiniciar = function() {
        pontuacao = 0;
        stats_total_notas = 0;
        stats_acertos_perfeitos = 0;
        stats_acertos_otimos = 0;
        stats_acertos_bons = 0;
        stats_erros = 0;
        stats_sequencia = 0;
        stats_sequencia_errada = 0;
        stats_toques_invalidos = 0;
    }

    /// Quantas notas o jogador acertou, em qualquer qualidade.
    static acertos = function() {
        return stats_acertos_perfeitos + stats_acertos_otimos + stats_acertos_bons;
    }

    /// Notas efetivamente JULGADAS — acertos mais erros.
    ///
    /// Diferente de stats_total_notas, que conta tudo o que foi gerado: no fim da fase
    /// pode haver nota ainda em voo, e é por isso que a precisão e o nível da arma têm
    /// denominadores diferentes (ver icone_nivel_por_precisao).
    static julgadas = function() {
        return acertos() + stats_erros;
    }

    /// Precisão em porcentagem, sobre as notas julgadas.
    static precisao = function() {
        var _j = julgadas();
        return (_j > 0) ? ((acertos() / _j) * 100) : 0;
    }
}

/// Estado de um jogador.
///
/// Sem argumento devolve o jogador ATIVO do modo solo — que é o 1 na esmagadora
/// maioria das vezes, mas pode ser o 2 quando ele inicia uma partida sozinho. Todo o
/// gameplay passa o índice explicitamente; quem omite são as telas de um jogador, e
/// para elas "o jogador" é exatamente esse.
function jogador(_n = undefined) {
    if (is_undefined(_n)) _n = solo_jogador();
    return o_controlador_geral.jogadores[_n];
}

// =====================================================================
// QUEM PERTENCE A QUEM
//
// Ferreiro, bigorna e alvos deixaram de ser instancia unica. Todo objeto de gameplay
// carrega um `dono` — 0 para o jogador 1, 1 para o 2 — e os efeitos de um nunca
// alcancam o outro.
//
// Fora do Versus so existe o dono 0, e as funcoes abaixo devolvem a unica instancia
// que existe. E por isso que o codigo de um jogador nao precisou aprender nada novo.
// =====================================================================

/// O ferreiro de um jogador, ou noone.
function ferreiro_de(_dono = 0) {
    with (o_ferreiro) {
        if (dono == _dono) return id;
    }
    return noone;
}

/// A bigorna de um jogador, ou noone.
function bigorna_de(_dono = 0) {
    with (o_bigorna) {
        if (dono == _dono) return id;
    }
    return noone;
}

// =====================================================================
// MONTAGEM DA CENA
//
// A sala rm_forja e montada para UM jogador, com o ferreiro e a bigorna no centro. O
// Versus reaproveita a mesma sala e reposiciona: o jogador 1 recua para a esquerda e o
// jogador 2 nasce a direita, os dois virados um para o outro, com a forja ao fundo
// entre eles.
//
// Feito em codigo e nao numa sala propria porque quase tudo e igual — cenario, fundo,
// HUD, controlador. Uma segunda sala seria uma copia que precisaria ser mantida em
// paralelo para sempre.
// =====================================================================

/// X da bigorna de cada jogador no Versus.
///
/// Espelhar a posicao original (619) em torno do centro poria as duas bigornas em 619
/// e 661 — encostadas. Os dois lados precisam recuar de verdade.
///
/// 250 e 1030 sao SIMETRICOS em relacao ao centro da tela (640), e nao em relacao a
/// construcao da forja, que nao e centrada — ela vai de 324 a ~1030. Alinhar pela
/// forja dava mais area util ao jogador 1 que ao 2.
///
/// Com o ferreiro do lado de dentro de cada bigorna, os dois pares ficam nas pontas e
/// a construcao respira no meio.
/// 260 e 1020, e nao 250 e 1030: dez pixels para dentro de cada lado, para os
/// ferreiros sairem de baixo das caixas de pontuacao que ficam nos cantos.
#macro VERSUS_BIGORNA_P1 270
#macro VERSUS_BIGORNA_P2 1010

/// Distancia entre a bigorna e o ferreiro, preservada da cena original (661 - 619).
#macro VERSUS_VAO_FERREIRO 42

/// Passa a cena de um jogador para o jogador 2.
///
/// Quando o jogador 2 inicia uma partida sozinho, nada de layout muda — ele joga no
/// enquadramento de sempre, que ja esta validado. O que muda e de quem sao o ferreiro,
/// a bigorna e os alvos que a sala criou, e a paleta que o ferreiro veste.
function solo_adotar_dono(_dono) {
    // So remonta quem MUDOU de dono. adotar_sprites reposiciona sprite e espelho, e
    // chama-la todo quadro reiniciaria a animacao do ferreiro sem parar.
    with (o_ferreiro) {
        if (dono != _dono) {
            dono = _dono;
            adotar_sprites();
        }
    }

    with (o_bigorna)       dono = _dono;
    with (o_buttons_forja) dono = _dono;
    with (o_fundo_ui)      { dono = _dono; image_alpha = 1; }
}

/// Poe a cena de acordo com o modo e o dono atuais. Chamada TODO QUADRO em rm_forja.
///
/// Substituiu a montagem feita uma vez na virada de estado, que dependia de a sala ja
/// existir naquele quadro exato — e nao dependia so disso: trocar de modo ou de dono
/// entre uma partida e outra deixava a cena com a configuracao anterior, porque a
/// virada ja tinha passado.
///
/// Sincronizar todo quadro e barato (as funcoes saem cedo quando nada mudou) e o
/// resultado nunca fica dessincronizado do estado, seja qual for o caminho que o
/// jogador tenha feito para chegar ali.
function cena_sincronizar() {
    if (room != rm_forja) return;

    if (versus_ativo()) {
        versus_montar_cena();
        versus_revelar_cena();
        return;
    }

    // O desmonte e decidido por uma BANDEIRA, e nao por "existe alguem com dono 1".
    //
    // Perguntar pelo dono era um defeito grave: no solo do jogador 2 a cena INTEIRA
    // adota dono 1, entao a checagem dava verdadeiro e o desmonte apagava o ferreiro, a
    // bigorna, os alvos e o corredor — o jogo ficava sem cena e sem resposta a tecla
    // nenhuma, em todos os modos.
    if (global.versus_montado) versus_desmontar_cena();

    solo_adotar_dono(o_controlador_geral.solo_dono);
}

/// Reposiciona o jogador 1 e cria o jogador 2. Idempotente.
function versus_montar_cena() {
    if (!versus_ativo()) return;
    if (global.versus_montado) return;

    // A AUTORIDADE DAS PISTAS E FIXA, e nao herdada de quem abriu o menu.
    //
    // Jogador 1 e SEMPRE a pista de baixo, jogador 2 SEMPRE a de cima. Quem entra no
    // Versus depois de uma partida solo do jogador 2 chegava com as instancias da sala
    // marcadas com dono 1 — e entao ferreiro_de(0) nao achava ninguem e a montagem
    // desistia na primeira linha, deixando um ferreiro so, com a paleta errada.
    //
    // Reivindicar o dono aqui torna a montagem imune ao caminho que o jogador fez.
    with (o_ferreiro)      { if (!criado_pelo_versus) { dono = 0; adotar_sprites(); } }
    with (o_bigorna)       { if (!criado_pelo_versus) dono = 0; }
    with (o_buttons_forja) { if (!criado_pelo_versus) dono = 0; }
    with (o_fundo_ui)      { if (!criado_pelo_versus) dono = 0; }

    var _b1 = bigorna_de(0);
    var _f1 = ferreiro_de(0);
    if (_b1 == noone || _f1 == noone) return;

    var _y_bigorna = _b1.y;
    var _y_ferreiro = _f1.y;

    // Guarda de onde o jogador 1 saiu, para o desmonte devolver. Sem isto, sair de um
    // Versus e comecar uma partida solo na MESMA sala deixava o ferreiro recuado, e ele
    // caminhava de volta ao home_x na frente do jogador.
    global.versus_x_original = [_b1.x, _f1.x];

    _b1.x = VERSUS_BIGORNA_P1;
    _f1.x = VERSUS_BIGORNA_P1 + VERSUS_VAO_FERREIRO;
    _f1.home_x = _f1.x;

    global.versus_montado = true;

    var _b2 = instance_create_layer(VERSUS_BIGORNA_P2, _y_bigorna, "Gameplay", o_bigorna);
    _b2.dono = 1;
    _b2.criado_pelo_versus = true;

    // PROFUNDIDADE EXPLICITA, e nao "a mesma do jogador 1".
    //
    // Todo o cenario vive na camada Gameplay com depth 0, e ali a ordem entre uma
    // instancia da SALA e outra criada em tempo real e indefinida — foi por isso que o
    // ferreiro 2 continuou atras da forja mesmo depois de copiar a profundidade do
    // ferreiro 1. Menor desenha na frente.
    _b2.depth = -1;

    // A BIGORNA TAMBEM ESPELHA. Ela ficava virada para o mesmo lado da do jogador 1, e
    // isso nao era so estetica: o efeito de impacto nasce a IMPACTO_DX da borda dela,
    // no ponto onde o martelo encosta — com a bigorna ao contrario, o clarao caia do
    // lado errado, longe da martelada.
    _b2.image_xscale = -1;

    // O ferreiro 2 fica do outro lado da propria bigorna: a cena inteira dele e o
    // espelho da do jogador 1.
    var _f2 = instance_create_layer(VERSUS_BIGORNA_P2 - VERSUS_VAO_FERREIRO,
                                    _y_ferreiro, "Gameplay", o_ferreiro);
    _f2.dono = 1;
    _f2.criado_pelo_versus = true;
    _f2.home_x = _f2.x;
    _f2.depth = -1;

    // ENTRADA EM DEGRADE. O par do jogador 2 nao pode simplesmente aparecer no meio da
    // cena: ele surge transparente e ganha corpo em meio segundo, o que le como "o
    // segundo ferreiro chegando a forja" em vez de um erro de desenho.
    _f2.image_alpha = 0;
    _b2.image_alpha = 0;

    // o conjunto de sprites foi montado no Create com dono 0; agora que ele sabe quem
    // e, remonta com a paleta e o espelho certos
    with (_f2) adotar_sprites();

    // A pista fica para depois: no seletor de armas so a CENA aparece (dois ferreiros,
    // duas bigornas). Ver versus_montar_pista.
}

/// Cria a pista do jogador 2: os quatro alvos e o corredor de cima.
///
/// Separada da cena porque ela so faz sentido com a fase comecando. Durante a selecao
/// de armas o corredor de cima ficava desenhado por cima do ceu, sem nota nenhuma
/// para receber.
function versus_montar_pista() {
    if (!versus_ativo() || global.versus_pista_montada) return;
    if (!global.versus_montado) return;

    global.versus_pista_montada = true;

    var _linha2 = ritmo_linha_x(1);
    for (var _t = 0; _t < 4; _t++) {
        var _a = instance_create_layer(_linha2, ritmo_lane_y(_t, 1), "Gameplay", o_buttons_forja);
        _a.dono = 1;
        _a.criado_pelo_versus = true;
        _a.meu_tipo = _t;
        _a.sprite_index = ritmo_sprite_alvo(_t);
        _a.image_alpha = 0;
        _a.depth = -1;   // na frente do corredor, como os do jogador 1
    }

    var _fundo2 = instance_create_layer(0, RITMO_CORREDOR_P2, "Gameplay", o_fundo_ui);
    _fundo2.dono = 1;
    _fundo2.criado_pelo_versus = true;

    // O corredor fica ATRAS das notas. Com todos em depth 0 a ordem era indefinida, e
    // o fundo do jogador 2 acabava por cima — a pista dele parecia vazia porque as
    // notas estavam escondidas debaixo do proprio corredor.
    _fundo2.depth = 2;
    // SEM espelho vertical: a origem do sprite fica no topo, entao yscale -1 desenhava
    // a faixa inteira para cima, fora da tela — era por isso que o corredor do jogador
    // 2 aparecia sem fundo, so com as notas soltas no ceu.
    _fundo2.image_alpha = 0;

}

/// Faz a cena do jogador 2 ganhar corpo. Chamada todo quadro; para sozinha no fim.
function versus_revelar_cena() {
    if (!versus_ativo()) return;

    var _passo = 1 / (room_speed * 0.5);

    with (o_ferreiro)      { if (dono == 1) image_alpha = min(1, image_alpha + _passo); }
    with (o_bigorna)       { if (dono == 1) image_alpha = min(1, image_alpha + _passo); }
    with (o_fundo_ui)      { if (dono == 1) image_alpha = min(1, image_alpha + _passo); }
    with (o_buttons_forja) { if (dono == 1) image_alpha = min(1, image_alpha + _passo); }
}

/// Desfaz a montagem, devolvendo a cena de um jogador.
function versus_desmontar_cena() {
    global.versus_montado = false;
    global.versus_pista_montada = false;

    // SO restaura posicao de verdade. O valor inicial e [-1,-1], e restaura-lo mandava
    // a bigorna para x=-1, encostada na borda esquerda da tela — era o que aparecia
    // como "a bigorna foi projetada para outra posicao" ao sair de uma partida.
    var _o = global.versus_x_original;

    if (_o[0] >= 0) {
        with (o_bigorna)  { if (!criado_pelo_versus) x = _o[0]; }
        with (o_ferreiro) { if (!criado_pelo_versus) { x = _o[1]; home_x = _o[1]; } }
    }

    global.versus_x_original = [-1, -1];

    // SO o que o Versus criou. Destruir por `dono == 1` apagava a cena do jogador 2
    // jogando sozinho, que usa as instancias da SALA com o dono trocado.
    with (o_bigorna)       { if (criado_pelo_versus) instance_destroy(); }
    with (o_ferreiro)      { if (criado_pelo_versus) instance_destroy(); }
    with (o_buttons_forja) { if (criado_pelo_versus) instance_destroy(); }
    with (o_fundo_ui)      { if (criado_pelo_versus) instance_destroy(); }
    with (o_nota_seta)     { if (dono == 1) instance_destroy(); }
}
