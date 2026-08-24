if (!instance_exists(o_controlador_geral) || o_controlador_geral.estado_jogo != MINIGAME.RITMO) {
    exit;
}

if (o_controlador_geral.pausa) {
    exit;
}

// Durante o respiro da derrota a partida já acabou: martelar não pontua nem
// penaliza, só a animação do alvo continua respondendo.
if (o_controlador_geral.fase_falhou) {
    afundamento = max(0, afundamento - 0.8);
    pop = max(0, pop - 0.14);
    brilho = max(0, brilho - 0.10);
    exit;
}

// --- decaimento do feedback visual ---
pop = max(0, pop - 0.14);
brilho = max(0, brilho - 0.10);
afundamento = max(0, afundamento - 0.8);

// =================================================================
// PARTE 1: ANIMAÇÃO DO ALVO ENQUANTO A AÇÃO ESTÁ PRESSIONADA
// =================================================================
if (input_held(minha_acao)) {
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
if (!input_pressed(minha_acao)) {
    exit;
}

afundamento = 5;

var _nota = ritmo_nota_alcancavel(meu_tipo);

if (_nota == noone) {
    // Toque sem nota alcançável: custa pontos e quebra o combo, mas não encerra
    // a partida (auditoria GP-04).
    o_controlador_geral.stats_toques_invalidos++;
    o_controlador_geral.pontuacao = max(0, o_controlador_geral.pontuacao - 10);
    o_controlador_geral.stats_sequencia = 0;
    debug_registrar_julgamento("inválido", 0);
    exit;
}

var _erro_frames = ritmo_erro_frames(_nota);
var _erro_ms = ritmo_frames_ms(_erro_frames);
var _julgamento = ritmo_julgar(_nota);

o_controlador_geral.stats_toques_invalidos = 0;
o_controlador_geral.stats_sequencia_errada = 0;

switch (_julgamento) {

    case JULGAMENTO.PERFEITO:
        var _ganho = 100 + (10 * o_controlador_geral.stats_sequencia);
        o_controlador_geral.pontuacao += _ganho;
        o_controlador_geral.stats_sequencia++;
        o_controlador_geral.stats_acertos_perfeitos++;

        _nota.estourar(COR_PERFEITO_NOTA);
        pop = 1;
        brilho = 1;
        brilho_cor = COR_PERFEITO;
        ritmo_impacto_bigorna(meu_tipo, JULGAMENTO.PERFEITO, 3, IMPACTO_ATRASO_PERFEITO);
        o_ferreiro.iniciar_martelada_perfeita();
        o_audio_manager.play_martelada_sequencial_sfx();

        hud_registrar_julgamento("PERFEITO!", COR_PERFEITO, true);
        hud_registrar_ganho(_ganho, COR_PERFEITO_GANHO);

        debug_registrar_julgamento("PERFEITO", _erro_ms);
        break;

    case JULGAMENTO.OTIMO:
        var _ganho_otimo = 75 + (7 * o_controlador_geral.stats_sequencia);
        o_controlador_geral.pontuacao += _ganho_otimo;
        o_controlador_geral.stats_sequencia++;
        o_controlador_geral.stats_acertos_otimos++;

        _nota.estourar(COR_OTIMO_NOTA);
        pop = 0.8;
        brilho = 0.75;
        brilho_cor = COR_OTIMO;
        ritmo_impacto_bigorna(meu_tipo, JULGAMENTO.OTIMO, 2, IMPACTO_ATRASO_NORMAL);
        o_ferreiro.iniciar_martelada_normal();
        o_audio_manager.play_martelada_sequencial_sfx();

        hud_registrar_julgamento("ÓTIMO!", COR_OTIMO, true);
        hud_registrar_ganho(_ganho_otimo, COR_OTIMO_GANHO);

        debug_registrar_julgamento("ÓTIMO", _erro_ms);
        break;

    case JULGAMENTO.BOM:
        var _ganho_bom = 50 + (5 * o_controlador_geral.stats_sequencia);
        o_controlador_geral.pontuacao += _ganho_bom;
        o_controlador_geral.stats_sequencia++;
        o_controlador_geral.stats_acertos_bons++;

        _nota.estourar(COR_BOM_NOTA);
        pop = 0.55;
        brilho = 0.5;
        brilho_cor = COR_BOM;
        ritmo_impacto_bigorna(meu_tipo, JULGAMENTO.BOM, 1, IMPACTO_ATRASO_NORMAL);
        o_ferreiro.iniciar_martelada_normal();
        o_audio_manager.play_martelada_sequencial_sfx();

        hud_registrar_julgamento("BOM!", COR_BOM, true);
        hud_registrar_ganho(_ganho_bom, COR_BOM_GANHO);

        debug_registrar_julgamento("BOM", _erro_ms);
        break;
}
