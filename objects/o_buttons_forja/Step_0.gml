if (!instance_exists(o_controlador_geral) || o_controlador_geral.estado_jogo != MINIGAME.RITMO) {
    exit;
}

if (gameplay_congelado()) {
    exit;
}

// Durante o respiro da derrota a partida já acabou: martelar não pontua nem
// penaliza, só a animação do alvo continua respondendo.
if (o_controlador_geral.fase_falhou) {
    afundamento = max(0, afundamento - 0.8);
    pop = max(0, pop - 0.14);
    brilho = max(0, brilho - 0.10);
    eco = max(0, eco - 0.075);
    exit;
}

// --- decaimento do feedback visual ---
pop = max(0, pop - 0.14);
brilho = max(0, brilho - 0.10);
eco = max(0, eco - 0.075);
afundamento = max(0, afundamento - 0.8);

// =================================================================
// PARTE 1: ANIMAÇÃO DO ALVO ENQUANTO A AÇÃO ESTÁ PRESSIONADA
// =================================================================
// A acao vem do DONO e do TIPO, e nao de uma variavel gravada na criacao: assim os
// alvos do jogador 2 escutam as teclas dele sem depender do codigo de criacao da sala,
// que so existe para os quatro alvos originais.
var _minha = input_lane(dono, meu_tipo);

if (input_held(_minha)) {
    image_index = min(image_index + 1, image_number - 1);
} else {
    image_index = 0;
}

// =================================================================
// PARTE 2: JULGAMENTO POR TEMPO
// A versão anterior julgava por sobreposição de máscaras, o que dava uma janela de
// "perfeito" de ~1 frame e criava faixas em que a tecla certa não valia nada
// (auditoria GP-01 e GP-02). Agora o erro é medido em frames/milissegundos.
// =================================================================
if (!input_pressed(_minha)) {
    exit;
}

afundamento = 5;

var _nota = ritmo_nota_alcancavel(meu_tipo, dono);

if (_nota == noone) {
    // Toque sem nota alcançável: custa pontos e quebra o combo, mas não encerra
    // a partida (auditoria GP-04).
    // UM ERRO E UM ERRO, indiferente do motivo.
    //
    // Deixar a nota passar e apertar a tecla errada eram contados como coisas
    // diferentes, e so o primeiro entrava em stats_erros. O resultado de um Versus saiu
    // com um jogador de ZERO erros e quatro mil pontos a menos que o adversario: ele
    // martelava fora do tempo, quebrava o proprio combo — que e quase toda a pontuacao
    // — e ainda levava nota S, porque a precisao nao enxergava aquilo.
    //
    // Duas categorias para uma falha so nao descreviam melhor o que aconteceu; apenas
    // escondiam metade dela. Agora conta como erro, entra na precisao e no rank.
    jogador(dono).stats_erros++;
    jogador(dono).stats_toques_invalidos++;   // so para o diagnostico do F3
    jogador(dono).pontuacao = max(0, jogador(dono).pontuacao - 10);
    jogador(dono).stats_sequencia = 0;

    // stats_sequencia_errada NAO entra aqui, e e a unica coisa que continua separada:
    // ela leva ao game over, e a auditoria GP-04 decidiu que quem esta experimentando
    // as teclas nao pode ser expulso da fase por isso. Contar o erro e uma coisa,
    // encerrar a partida e outra.
    hud_registrar_julgamento("ERRO", COR_ERRO, false, dono);

    debug_registrar_julgamento("inválido", 0);
    exit;
}

var _erro_frames = ritmo_erro_frames(_nota);
var _erro_ms = ritmo_frames_ms(_erro_frames);
var _julgamento = ritmo_julgar(_nota);

jogador(dono).stats_toques_invalidos = 0;
jogador(dono).stats_sequencia_errada = 0;

switch (_julgamento) {

    case JULGAMENTO.PERFEITO:
        var _ganho = 100 + (10 * jogador(dono).stats_sequencia);
        jogador(dono).pontuacao += _ganho;
        jogador(dono).stats_sequencia++;
        jogador(dono).stats_acertos_perfeitos++;

        _nota.estourar(COR_PERFEITO_NOTA);
        pop = 1;
        brilho = 1;
        brilho_cor = COR_PERFEITO;
        eco = 1;
        eco_cor = COR_PERFEITO;
        ritmo_impacto_bigorna(meu_tipo, JULGAMENTO.PERFEITO, 3, IMPACTO_ATRASO_PERFEITO, dono);
        with (ferreiro_de(dono)) iniciar_martelada_perfeita();
        o_audio_manager.play_martelada_de(dono);

        hud_registrar_julgamento("PERFEITO!", COR_PERFEITO, true, dono);
        hud_registrar_ganho(_ganho, COR_PERFEITO_GANHO, dono);

        debug_registrar_julgamento("PERFEITO", _erro_ms);
        break;

    case JULGAMENTO.OTIMO:
        var _ganho_otimo = 75 + (7 * jogador(dono).stats_sequencia);
        jogador(dono).pontuacao += _ganho_otimo;
        jogador(dono).stats_sequencia++;
        jogador(dono).stats_acertos_otimos++;

        _nota.estourar(COR_OTIMO_NOTA);
        pop = 0.55;
        brilho = 0.7;
        brilho_cor = COR_OTIMO;
        eco = 0.55;
        eco_cor = COR_OTIMO;
        ritmo_impacto_bigorna(meu_tipo, JULGAMENTO.OTIMO, 2, IMPACTO_ATRASO_NORMAL, dono);
        with (ferreiro_de(dono)) iniciar_martelada_normal();
        o_audio_manager.play_martelada_de(dono);

        hud_registrar_julgamento("ÓTIMO!", COR_OTIMO, true, dono);
        hud_registrar_ganho(_ganho_otimo, COR_OTIMO_GANHO, dono);

        debug_registrar_julgamento("ÓTIMO", _erro_ms);
        break;

    case JULGAMENTO.BOM:
        var _ganho_bom = 50 + (5 * jogador(dono).stats_sequencia);
        jogador(dono).pontuacao += _ganho_bom;
        jogador(dono).stats_sequencia++;
        jogador(dono).stats_acertos_bons++;

        _nota.estourar(COR_BOM_NOTA);
        pop = 0.28;
        brilho = 0.45;
        brilho_cor = COR_BOM;
        ritmo_impacto_bigorna(meu_tipo, JULGAMENTO.BOM, 1, IMPACTO_ATRASO_NORMAL, dono);
        with (ferreiro_de(dono)) iniciar_martelada_normal();
        o_audio_manager.play_martelada_de(dono);

        hud_registrar_julgamento("BOM!", COR_BOM, true, dono);
        hud_registrar_ganho(_ganho_bom, COR_BOM_GANHO, dono);

        debug_registrar_julgamento("BOM", _erro_ms);
        break;
}
