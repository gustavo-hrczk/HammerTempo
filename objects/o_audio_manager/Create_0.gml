// Guarda de instância única (auditoria CV-01)
if (instance_number(object_index) > 1) {
    instance_destroy();
    exit;
}

musica_atual = -1;

// ID da INSTANCIA em reproducao, nao do asset. audio_sound_get_track_position() so
// responde a instancia, e e dela que sai o relogio de ritmo (ver ritmo_relogio).
musica_instancia = -1;

is_fading_out = false;
fade_speed = 0;

// --- CROSSFADE ---
musica_saindo = -1;
saindo_speed = 0;
entrando = false;
entrando_speed = 0;

// --- FUNÇÕES DE ÁUDIO ---

play_sfx = function(som_asset, _ganho = 1) {
    if (audio_is_playing(som_asset)) { audio_stop_sound(som_asset); }
    audio_sound_gain(som_asset, _ganho * global.ganho_sfx, 0);
    audio_play_sound(som_asset, 1, false);
}

// =================================================================
// NIVELAMENTO ENTRE FAIXAS
// As faixas foram gravadas por fontes diferentes e chegam em volumes diferentes:
// medindo o RMS, elas variam de -15,4 a -10,6 dBFS — quase 5 dB entre a mais fraca
// e a mais forte, o que e uma diferenca gritante ao trocar de fase.
//
// A correcao e por GANHO, nao por reencodar o audio: reencodar perde qualidade,
// nao volta atras, e some do diff. Assim o numero fica visivel e ajustavel.
//
// Cada faixa traz o seu ganho em fases_data; o tema do menu usa 1.
ganho_faixa = 1;

/// Volume alvo da música, com a opção do jogador e o nivelamento da faixa.
alvo_musica = function() {
    return global.ganho_musica * ganho_faixa;
}

/// Atualiza na hora a faixa que já está tocando, para o ajuste no menu de opções
/// ser audível enquanto o jogador mexe no valor.
aplicar_volume_musica = function() {
    if (musica_atual != -1 && !is_fading_out && !entrando) {
        audio_sound_gain(musica_atual, global.ganho_musica, 0);
    }
}

/// Toca uma música em loop, com corte seco.
/// A versão anterior (auditoria CV-02) desistia quando a faixa já estava tocando com
/// ganho 0 — o que deixava a fase muda ao ser rejogada.
play_music = function(musica_asset) {
    if (musica_atual == musica_asset && audio_is_playing(musica_asset) && !is_fading_out) {
        audio_sound_gain(musica_asset, alvo_musica(), 0);
        return;
    }

    if (musica_atual != -1) { audio_stop_sound(musica_atual); }
    if (audio_is_playing(musica_asset)) { audio_stop_sound(musica_asset); }

    audio_sound_gain(musica_asset, alvo_musica(), 0);
    musica_instancia = audio_play_sound(musica_asset, 1, true);

    musica_atual = musica_asset;
    is_fading_out = false;
    entrando = false;
}

/// Troca de música com crossfade: a atual sai enquanto a nova entra.
/// É o que evita o corte seco do tema quando a fase começa (auditoria CV-03).
play_music_crossfade = function(musica_asset, duracao_segundos = 0.5, _ganho_faixa = 1) {
    if (musica_atual == musica_asset && audio_is_playing(musica_asset) && !is_fading_out) {
        return;
    }

    // O nivelamento entra ANTES de qualquer conta de ganho: saindo_speed e
    // entrando_speed sao derivados de alvo_musica(), e precisam do valor da faixa
    // que esta entrando, nao da que saiu.
    ganho_faixa = _ganho_faixa;

    var _frames = max(1, duracao_segundos * room_speed);

    // Uma faixa que JÁ estava saindo não pode ser simplesmente esquecida. Antes o
    // campo era sobrescrito e a faixa anterior ficava tocando em laço para sempre,
    // no ganho em que estivesse, sem ninguém para pará-la.
    if (musica_saindo != -1) {
        audio_stop_sound(musica_saindo);
        audio_sound_gain(musica_saindo, alvo_musica(), 0);
        musica_saindo = -1;
    }

    // a faixa atual passa a sair de cena
    if (musica_atual != -1 && audio_is_playing(musica_atual) && musica_atual != musica_asset) {
        musica_saindo = musica_atual;
        saindo_speed = audio_sound_get_gain(musica_saindo) / _frames;
    }

    // A faixa que ENTRA nunca pode ser a que está saindo: o Step reduziria o ganho
    // da instância recém-criada e a pararia no meio, que é a música "quebrando" ao
    // trocar de tela. Como musica_saindo já foi zerado acima, sobra só garantir que
    // não existe instância antiga do mesmo asset.
    if (audio_is_playing(musica_asset)) { audio_stop_sound(musica_asset); }

    audio_sound_gain(musica_asset, 0, 0);
    musica_instancia = audio_play_sound(musica_asset, 1, true);

    musica_atual = musica_asset;
    entrando = true;
    entrando_speed = alvo_musica() / _frames;
    is_fading_out = false;
}

/// Congela e descongela a faixa atual, para a pausa da partida.
/// A pausa congela também a faixa em crossfade: deixá-la correndo fazia o jogador
/// voltar de uma pausa longa com a transição já terminada, e às vezes com a faixa
/// anterior tendo tocado sozinha o tempo todo.
pausar_musica = function() {
    if (musica_atual != -1)  { audio_pause_sound(musica_atual); }
    if (musica_saindo != -1) { audio_pause_sound(musica_saindo); }
}

retomar_musica = function() {
    if (musica_atual != -1)  { audio_resume_sound(musica_atual); }
    if (musica_saindo != -1) { audio_resume_sound(musica_saindo); }
}

stop_music = function() {
    if (musica_atual != -1) {
        audio_stop_sound(musica_atual);
        audio_sound_gain(musica_atual, alvo_musica(), 0); // deixa o asset pronto para a próxima vez
        musica_atual = -1;
        musica_instancia = -1;
    }

    // Parar a música tem de parar TUDO. Sem isto, uma faixa em crossfade sobrevivia
    // ao stop e continuava em laço por baixo da próxima.
    if (musica_saindo != -1) {
        audio_stop_sound(musica_saindo);
        audio_sound_gain(musica_saindo, alvo_musica(), 0);
        musica_saindo = -1;
    }

    is_fading_out = false;
    entrando = false;
}

fade_out_music = function(duracao_segundos) {
    if (musica_atual != -1 && !is_fading_out) {
        is_fading_out = true;
        entrando = false;
        var _current_gain = audio_sound_get_gain(musica_atual);
        fade_speed = _current_gain / max(1, duracao_segundos * room_speed);
    }
}

// =================================================================
// --- SEQUENCIADOR DE MARTELADA ---
// =================================================================

sons_martelada = [
    snd_martelada_01,
    snd_martelada_02,
    snd_martelada_03,
    snd_martelada_04,
    snd_martelada_05
];

martelada_index_atual = 0;
martelada_direcao = 1;

// As amostras de martelada estão em ~-11 dBFS RMS, bem mais quentes que as faixas
// das fases, e encobriam a música. 0,32 equivale a -9,9 dB, que é o suficiente para
// derrubar o volume aparente pela metade — 0,55 (-5,2 dB) mal era perceptível.
// Ponto único de ajuste até existirem volumes separados de música e efeitos.
ganho_martelada = 0.256;   // 20% abaixo dos 0,32 anteriores, ou -1,94 dB

// Toca os sons de martelada em vai-e-vem, dando variação a cada acerto.
// Variação de pitch foi testada e descartada: descaracterizava o som da martelada.
/// Marteladas do jogador 2, se houver.
///
/// TRES PROBLEMAS resolvidos de uma vez quando os dois martelam junto:
///
/// 1. play_sfx PARA a instancia anterior do mesmo asset. Com os dois usando a mesma
///    amostra, a martelada do jogador 2 cortaria a do jogador 1 no meio.
/// 2. Duas copias da MESMA amostra a poucos ms uma da outra se cancelam em faixas de
///    frequencia (comb filtering) e soam ocas.
/// 3. Sem separacao, nao da para saber de ouvido quem acertou.
///
/// A divisao dos cinco samples resolve 1 e 2. O 3 fica em aberto: PANORAMICA NAO FOI
/// USADA porque o GameMaker nao tem funcao de pan para sons simples — separar os
/// canais exigiria emissor posicional com listener e falloff, o que e desproporcional
/// ao ganho. Pitch tambem nao: ja tinha sido testado e descartado por descaracterizar
/// a martelada.
///
/// Na pratica os dois samples ja soam diferentes o bastante para nao se confundirem.
martelada_p2_index = 0;

play_martelada_de = function(_dono) {
    // A DIVISAO DAS AMOSTRAS SO EXISTE NO VERSUS, onde os dois martelam ao mesmo tempo
    // e duas copias da mesma amostra a poucos ms uma da outra soam ocas. Fora dele ha
    // uma marreta so na tela, e ela usa as cinco: o jogador 2 jogando sozinho ouvia
    // duas amostras em laco, um som visivelmente mais pobre que o do jogador 1 na
    // mesma fase.
    if (!versus_ativo() || _dono == 0) {
        play_martelada_sequencial_sfx();
        return;
    }

    // o jogador 2 fica com as amostras pares, que o jogador 1 nunca toca
    var _pares = [sons_martelada[1], sons_martelada[3]];

    play_sfx(_pares[martelada_p2_index], ganho_martelada);

    martelada_p2_index = (martelada_p2_index + 1) mod array_length(_pares);
};

play_martelada_sequencial_sfx = function() {
    // fora do Versus o jogador 1 usa as cinco; dentro dele, so as impares, para nao
    // disputar amostra com o jogador 2
    if (versus_ativo() && (martelada_index_atual mod 2) == 1) {
        martelada_index_atual = (martelada_index_atual + 1) mod array_length(sons_martelada);
    }

    play_sfx(sons_martelada[martelada_index_atual], ganho_martelada);

    if (martelada_direcao == 1) {
        if (martelada_index_atual >= array_length(sons_martelada) - 1) {
            martelada_direcao = -1;
        }
    } else {
        if (martelada_index_atual <= 0) {
            martelada_direcao = 1;
        }
    }

    martelada_index_atual += martelada_direcao;
}
