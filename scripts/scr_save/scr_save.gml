/// scr_save — persistência em disco
/// Base para as opções (Sprint 2) e para o leaderboard (Sprint 4).
/// O arquivo fica na pasta de save do jogo, criada pelo próprio GameMaker.

#macro SAVE_ARQUIVO "hammertempo_save.json"
#macro SAVE_VERSAO 1

/// Estrutura padrão, usada em primeira execução ou se o arquivo estiver corrompido.
function save_padrao() {
    return {
        versao: SAVE_VERSAO,
        opcoes: {
            volume_musica: 8,  // 0 a 10
            volume_sfx: 7,     // 0 a 10 — as amostras de efeito são mais quentes
            tela_cheia: false,
            janela: 1,         // índice em JANELA_TAMANHOS (padrão 1024x576)
            offset_ms: 0       // calibração de latência (Sprint 5)
        },
        recordes: {},          // id da fase -> melhor pontuação
        controles: {},         // id da ação -> {teclas, botoes}; vazio = tudo de fábrica
        leaderboard: {
            arcade: [],
            livre: {}
        }
    };
}

/// Garante que todo campo esperado existe, mesmo em saves antigos ou incompletos.
function save_normalizar(_dados) {
    var _padrao = save_padrao();

    if (!is_struct(_dados)) return _padrao;

    if (!variable_struct_exists(_dados, "opcoes") || !is_struct(_dados.opcoes)) {
        _dados.opcoes = _padrao.opcoes;
    } else {
        // Migração: o save antigo tinha um único "volume" (master). Ele vira o
        // ponto de partida dos dois volumes separados, para ninguém abrir o jogo
        // e achar que o som foi resetado.
        if (variable_struct_exists(_dados.opcoes, "volume")
            && !variable_struct_exists(_dados.opcoes, "volume_musica")) {
            _dados.opcoes.volume_musica = _dados.opcoes.volume;
            _dados.opcoes.volume_sfx = _dados.opcoes.volume;
        }

        var _chaves = variable_struct_get_names(_padrao.opcoes);
        for (var i = 0; i < array_length(_chaves); i++) {
            var _k = _chaves[i];
            if (!variable_struct_exists(_dados.opcoes, _k)) {
                _dados.opcoes[$ _k] = _padrao.opcoes[$ _k];
            }
        }
    }

    if (!variable_struct_exists(_dados, "recordes") || !is_struct(_dados.recordes)) {
        _dados.recordes = {};
    }

    if (!variable_struct_exists(_dados, "controles") || !is_struct(_dados.controles)) {
        _dados.controles = {};
    }

    if (!variable_struct_exists(_dados, "leaderboard") || !is_struct(_dados.leaderboard)) {
        _dados.leaderboard = _padrao.leaderboard;
    }
    if (!variable_struct_exists(_dados.leaderboard, "arcade") || !is_array(_dados.leaderboard.arcade)) {
        _dados.leaderboard.arcade = [];
    }
    if (!variable_struct_exists(_dados.leaderboard, "livre") || !is_struct(_dados.leaderboard.livre)) {
        _dados.leaderboard.livre = {};
    }

    _dados.versao = SAVE_VERSAO;
    return _dados;
}

/// Carrega o save para global.save. Nunca falha: em caso de erro, recria o padrão.
function save_carregar() {
    // defaults dos ganhos antes de qualquer coisa tocar, para o caso de a ordem de
    // criação mudar no futuro
    global.ganho_musica = 0.8;
    global.ganho_sfx = 0.7;

    global.save = save_padrao();

    if (!file_exists(SAVE_ARQUIVO)) {
        show_debug_message("[save] arquivo inexistente, usando padrões");
        return;
    }

    try {
        var _buffer = buffer_load(SAVE_ARQUIVO);
        var _texto = buffer_read(_buffer, buffer_string);
        buffer_delete(_buffer);
        global.save = save_normalizar(json_parse(_texto));
        show_debug_message("[save] carregado");
    } catch (_erro) {
        show_debug_message("[save] arquivo inválido, recriando: " + string(_erro));
        global.save = save_padrao();
    }
}

/// Grava global.save em disco.
function save_gravar() {
    try {
        var _texto = json_stringify(global.save);
        var _buffer = buffer_create(string_byte_length(_texto) + 1, buffer_fixed, 1);
        buffer_write(_buffer, buffer_string, _texto);
        buffer_save(_buffer, SAVE_ARQUIVO);
        buffer_delete(_buffer);
        return true;
    } catch (_erro) {
        show_debug_message("[save] falha ao gravar: " + string(_erro));
        return false;
    }
}

/// Tamanhos de janela oferecidos nas opções. O espaço de design continua sempre
/// 1280x720: só a janela encolhe, e o jogo é escalado para caber nela.
#macro JANELA_TAMANHOS [[640, 360, "640x360"], [1024, 576, "1024x576"], [1280, 720, "1280x720"]]

/// Aplica as opções salvas ao jogo (volumes, tamanho de janela e tela cheia).
///
/// Música e efeitos têm ganhos separados em vez de um master único: as amostras de
/// efeito são bem mais quentes que as faixas das fases (as marteladas estão em
/// ~-11 dBFS RMS), então um controle só nunca equilibra os dois.
function save_aplicar_opcoes() {
    audio_master_gain(1);
    global.ganho_musica = global.save.opcoes.volume_musica / 10;
    global.ganho_sfx = global.save.opcoes.volume_sfx / 10;

    // A faixa que já está tocando acompanha a mudança na hora.
    //
    // instance_exists NÃO basta aqui: no boot esta função roda no Create do
    // o_controlador_geral, que vem antes do o_audio_manager na ordem de criação de
    // rm_splash. A instância já existe, mas o Create dela ainda não rodou e os
    // métodos não existem. Por isso a checagem é pela variável, não pela instância.
    if (instance_exists(o_audio_manager)
        && variable_instance_exists(o_audio_manager, "aplicar_volume_musica")) {
        o_audio_manager.aplicar_volume_musica();
    }

    var _cheia = global.save.opcoes.tela_cheia;
    if (window_get_fullscreen() != _cheia) {
        window_set_fullscreen(_cheia);
    }

    if (!_cheia) {
        var _tamanhos = JANELA_TAMANHOS;
        var _i = clamp(global.save.opcoes.janela, 0, array_length(_tamanhos) - 1);
        var _t = _tamanhos[_i];

        if (window_get_width() != _t[0] || window_get_height() != _t[1]) {
            window_set_size(_t[0], _t[1]);
            window_center();
        }
    }
}

/// Rótulo do tamanho de janela, para a tela de opções.
function save_texto_janela() {
    var _tamanhos = JANELA_TAMANHOS;
    var _i = clamp(global.save.opcoes.janela, 0, array_length(_tamanhos) - 1);
    return _tamanhos[_i][2];
}

/// Identificador estável da fase. Não usa o índice direto de propósito: inserir uma
/// fase no meio da lista não pode embaralhar os recordes já conquistados.
function save_id_fase(_indice) {
    var _n = _indice + 1;
    return (_n < 10) ? ("fase_0" + string(_n)) : ("fase_" + string(_n));
}

/// Melhor pontuação registrada na fase. Zero se nunca foi jogada.
function save_recorde(_indice) {
    var _id = save_id_fase(_indice);
    if (!variable_struct_exists(global.save.recordes, _id)) return 0;
    return global.save.recordes[$ _id];
}

/// Grava a pontuação se ela superar o recorde. Devolve true quando é recorde novo.
function save_registrar_recorde(_indice, _pontos) {
    if (_pontos <= save_recorde(_indice)) return false;

    global.save.recordes[$ save_id_fase(_indice)] = _pontos;
    save_gravar();
    return true;
}

/// Atalho de leitura de uma opção.
function save_opcao(_nome) {
    return global.save.opcoes[$ _nome];
}

/// Atalho de escrita de uma opção (não grava em disco sozinho).
function save_set_opcao(_nome, _valor) {
    global.save.opcoes[$ _nome] = _valor;
}
